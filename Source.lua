--[[
    ╔══════════════════════════════════════════════╗
    ║            GENARIX UI LIBRARY                ║
    ║            Version: 2.3.0                    ║
    ║            Creator: Genarix                  ║
    ║            Universal UI Library              ║
    ╚══════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local GenarixUI = {}

local _windowKeybind = nil
local _allAccentObjects = {}
local _currentAccentColor = Color3.fromRGB(130, 80, 255)

-- Tabela para guardar referências de toggles ativos (para atualizar cor)
local _activeToggles = {}

-- Tabela para guardar referências de botões (para atualizar cor)
local _accentButtons = {}

local Theme = {
    Background   = Color3.fromRGB(16, 16, 20),
    Header       = Color3.fromRGB(10, 10, 14),
    Accent       = Color3.fromRGB(130, 80, 255),
    AccentDark   = Color3.fromRGB(90, 50, 200),
    AccentGlow   = Color3.fromRGB(160, 110, 255),
    Surface      = Color3.fromRGB(24, 24, 30),
    SurfaceLight = Color3.fromRGB(32, 32, 40),
    SurfaceHover = Color3.fromRGB(40, 40, 50),
    Text         = Color3.fromRGB(230, 230, 240),
    TextDim      = Color3.fromRGB(130, 130, 150),
    Border       = Color3.fromRGB(45, 45, 60),
    SliderBg     = Color3.fromRGB(35, 35, 45),
    ToggleOn     = Color3.fromRGB(130, 80, 255),
    ToggleOff    = Color3.fromRGB(45, 45, 55),
    NotifBg      = Color3.fromRGB(20, 20, 26),
    Close        = Color3.fromRGB(200, 50, 60),
    Minimize     = Color3.fromRGB(200, 180, 50),
    TabInactive  = Color3.fromRGB(24, 24, 30),
}

local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function AddStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function AddPadding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.Parent = parent
    return p
end

local function Tween(instance, duration, properties, style, direction)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local t = TweenService:Create(instance, info, properties)
    t:Play()
    return t
end

local function AddShadow(parent)
    local s = Instance.new("ImageLabel")
    s.AnchorPoint = Vector2.new(0.5, 0.5)
    s.BackgroundTransparency = 1
    s.Position = UDim2.new(0.5, 0, 0.5, 4)
    s.Size = UDim2.new(1, 35, 1, 35)
    s.ZIndex = -1
    s.Image = "rbxassetid://6014261993"
    s.ImageColor3 = Color3.fromRGB(0, 0, 0)
    s.ImageTransparency = 0.35
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(49, 49, 450, 450)
    s.Parent = parent
end

local function RegisterAccent(obj, property)
    table.insert(_allAccentObjects, {Object = obj, Property = property})
end

function GenarixUI:SetAccentColor(color)
    _currentAccentColor = color
    Theme.Accent = color
    Theme.ToggleOn = color
    local h, s, v = color:ToHSV()
    Theme.AccentDark = Color3.fromHSV(h, math.min(s + 0.15, 1), math.max(v - 0.15, 0))
    Theme.AccentGlow = Color3.fromHSV(h, math.max(s - 0.15, 0), math.min(v + 0.1, 1))

    -- Atualizar todos os objetos registrados
    for _, data in pairs(_allAccentObjects) do
        if data.Object and data.Object.Parent then
            pcall(function() data.Object[data.Property] = color end)
        end
    end

    -- Atualizar toggles ativos
    for _, toggleData in pairs(_activeToggles) do
        if toggleData.switch and toggleData.switch.Parent and toggleData.getState() then
            toggleData.switch.BackgroundColor3 = color
        end
    end

    -- Atualizar botões
    for _, btnData in pairs(_accentButtons) do
        if btnData.btn and btnData.btn.Parent then
            btnData.btn.BackgroundColor3 = color
            -- Atualizar stroke também
            for _, child in pairs(btnData.btn:GetChildren()) do
                if child:IsA("UIStroke") then
                    child.Color = color
                end
            end
        end
    end
end

function GenarixUI:GetAccentColor() return _currentAccentColor end
function GenarixUI:SetToggleKey(k) _windowKeybind = k end
function GenarixUI:GetToggleKey() return _windowKeybind end

-- NOTIFICATION
local NotifContainer = nil
local function EnsureNotifContainer(screenGui)
    if NotifContainer then return end
    NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 300, 1, -20)
    NotifContainer.Position = UDim2.new(1, -310, 0, 10)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.ZIndex = 100
    NotifContainer.Parent = screenGui
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 8)
    l.VerticalAlignment = Enum.VerticalAlignment.Bottom
    l.Parent = NotifContainer
end

function GenarixUI:Notify(config)
    config = config or {}
    local ntitle = config.Title or "Genarix"
    local ncontent = config.Content or ""
    local nduration = config.Duration or 3
    if not NotifContainer then return end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Theme.NotifBg
    notif.ClipsDescendants = true
    notif.ZIndex = 100
    notif.Parent = NotifContainer
    AddCorner(notif, 10)
    AddStroke(notif, _currentAccentColor, 1, 0.5)

    local ab = Instance.new("Frame")
    ab.Size = UDim2.new(0, 3, 0.7, 0)
    ab.Position = UDim2.new(0, 8, 0.15, 0)
    ab.BackgroundColor3 = _currentAccentColor
    ab.ZIndex = 101
    ab.Parent = notif
    AddCorner(ab, 2)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -25, 0, 18)
    tl.Position = UDim2.new(0, 18, 0, 8)
    tl.BackgroundTransparency = 1
    tl.Text = ntitle
    tl.TextColor3 = _currentAccentColor
    tl.TextSize = 13
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 101
    tl.Parent = notif

    local cl = Instance.new("TextLabel")
    cl.Size = UDim2.new(1, -25, 0, 16)
    cl.Position = UDim2.new(0, 18, 0, 28)
    cl.BackgroundTransparency = 1
    cl.Text = ncontent
    cl.TextColor3 = Theme.TextDim
    cl.TextSize = 12
    cl.Font = Enum.Font.Gotham
    cl.TextXAlignment = Enum.TextXAlignment.Left
    cl.TextWrapped = true
    cl.ZIndex = 101
    cl.Parent = notif

    local pb = Instance.new("Frame")
    pb.Size = UDim2.new(1, -20, 0, 2)
    pb.Position = UDim2.new(0, 10, 1, -8)
    pb.BackgroundColor3 = Theme.SliderBg
    pb.ZIndex = 101
    pb.Parent = notif
    AddCorner(pb, 1)

    local pf = Instance.new("Frame")
    pf.Size = UDim2.new(1, 0, 1, 0)
    pf.BackgroundColor3 = _currentAccentColor
    pf.ZIndex = 102
    pf.Parent = pb
    AddCorner(pf, 1)

    Tween(notif, 0.4, {Size = UDim2.new(1, 0, 0, 60)})
    task.delay(0.4, function()
        Tween(pf, nduration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)
    end)
    task.delay(nduration + 0.5, function()
        Tween(notif, 0.3, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.35)
        notif:Destroy()
    end)
end

-- ================================================
-- CREATE WINDOW
-- ================================================
function GenarixUI:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Genarix UI"
    local toggleKeybind = config.Keybind or Enum.KeyCode.K
    _windowKeybind = toggleKeybind

    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    local _openDropdowns = {}

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GenarixUI_" .. windowName
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    Window.ScreenGui = screenGui
    EnsureNotifContainer(screenGui)

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 550, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    AddCorner(mainFrame, 12)
    local mainStroke = AddStroke(mainFrame, _currentAccentColor, 1.5, 0.6)
    RegisterAccent(mainStroke, "Color")
    AddShadow(mainFrame)
    Window.MainFrame = mainFrame

    -- HEADER
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = Theme.Header
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    AddCorner(header, 12)

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 14)
    headerFix.Position = UDim2.new(0, 0, 1, -14)
    headerFix.BackgroundColor3 = Theme.Header
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local sepLine = Instance.new("Frame")
    sepLine.Size = UDim2.new(1, -20, 0, 2)
    sepLine.Position = UDim2.new(0, 10, 1, -1)
    sepLine.BackgroundColor3 = _currentAccentColor
    sepLine.BorderSizePixel = 0
    sepLine.Parent = header
    AddCorner(sepLine, 1)
    RegisterAccent(sepLine, "BackgroundColor3")

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 28, 0, 28)
    iconLbl.Position = UDim2.new(0, 12, 0.5, -14)
    iconLbl.BackgroundColor3 = _currentAccentColor
    iconLbl.BackgroundTransparency = 0.85
    iconLbl.Text = string.sub(windowName, 1, 1)
    iconLbl.TextColor3 = _currentAccentColor
    iconLbl.TextSize = 14
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.BorderSizePixel = 0
    iconLbl.Parent = header
    AddCorner(iconLbl, 7)
    RegisterAccent(iconLbl, "BackgroundColor3")
    RegisterAccent(iconLbl, "TextColor3")

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -130, 1, 0)
    titleLbl.Position = UDim2.new(0, 48, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = windowName
    titleLbl.TextColor3 = Theme.Text
    titleLbl.TextSize = 16
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = header

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -60, 0.5, -13)
    minimizeBtn.BackgroundColor3 = Theme.Minimize
    minimizeBtn.BackgroundTransparency = 0.85
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Theme.Minimize
    minimizeBtn.TextSize = 14
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header
    AddCorner(minimizeBtn, 6)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
    closeBtn.BackgroundColor3 = Theme.Close
    closeBtn.BackgroundTransparency = 0.85
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Theme.Close
    closeBtn.TextSize = 13
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    AddCorner(closeBtn, 6)

    for _, btn in pairs({minimizeBtn, closeBtn}) do
        btn.MouseEnter:Connect(function() Tween(btn, 0.2, {BackgroundTransparency = 0.5}) end)
        btn.MouseLeave:Connect(function() Tween(btn, 0.2, {BackgroundTransparency = 0.85}) end)
    end

    -- SIDEBAR
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 135, 1, -48)
    sidebar.Position = UDim2.new(0, 0, 0, 44)
    sidebar.BackgroundColor3 = Theme.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    AddCorner(sidebar, 12)

    local sFixT = Instance.new("Frame"); sFixT.Size = UDim2.new(1,0,0,14); sFixT.BackgroundColor3 = Theme.Surface; sFixT.BorderSizePixel = 0; sFixT.Parent = sidebar
    local sFixR = Instance.new("Frame"); sFixR.Size = UDim2.new(0,14,1,0); sFixR.Position = UDim2.new(1,-14,0,0); sFixR.BackgroundColor3 = Theme.Surface; sFixR.BorderSizePixel = 0; sFixR.Parent = sidebar
    local sSep = Instance.new("Frame"); sSep.Size = UDim2.new(0,1,1,-16); sSep.Position = UDim2.new(1,0,0,8); sSep.BackgroundColor3 = Theme.Border; sSep.BackgroundTransparency = 0.5; sSep.BorderSizePixel = 0; sSep.Parent = sidebar

    local tabBtnContainer = Instance.new("ScrollingFrame")
    tabBtnContainer.Size = UDim2.new(1, -12, 1, -16)
    tabBtnContainer.Position = UDim2.new(0, 6, 0, 8)
    tabBtnContainer.BackgroundTransparency = 1
    tabBtnContainer.ScrollBarThickness = 0
    tabBtnContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabBtnContainer.Parent = sidebar
    local tbLayout = Instance.new("UIListLayout"); tbLayout.SortOrder = Enum.SortOrder.LayoutOrder; tbLayout.Padding = UDim.new(0, 4); tbLayout.Parent = tabBtnContainer

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -143, 1, -52)
    contentArea.Position = UDim2.new(0, 140, 0, 48)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    -- DRAGGING
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- MINIMIZE
    local minimized = false
    local storedPos = nil
    local originalSize = UDim2.new(0, 550, 0, 400)

    local function doMinimize()
        minimized = true; storedPos = mainFrame.Position
        Tween(mainFrame, 0.4, {Size = UDim2.new(0,550,0,0), Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset+200)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.4, function() mainFrame.Visible = false end)
        GenarixUI:Notify({Title = "Minimizado", Content = "Aperte '".. _windowKeybind.Name .."' para maximizar a GUI", Duration = 4})
    end

    local function doMaximize()
        minimized = false; mainFrame.Visible = true
        local tp = storedPos or UDim2.new(0.5,-275,0.5,-200)
        mainFrame.Position = UDim2.new(tp.X.Scale, tp.X.Offset, tp.Y.Scale, tp.Y.Offset+200)
        mainFrame.Size = UDim2.new(0,550,0,0)
        Tween(mainFrame, 0.4, {Size = originalSize, Position = tp})
    end

    minimizeBtn.MouseButton1Click:Connect(doMinimize)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(mainFrame, 0.3, {Size = UDim2.new(0,550,0,0), Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset+200)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.35, function() screenGui:Destroy() end)
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == _windowKeybind then if minimized then doMaximize() else doMinimize() end end
    end)

    mainFrame.Size = UDim2.new(0,550,0,0)
    mainFrame.Position = UDim2.new(0.5,-275,0.5,0)
    task.delay(0.1, function() Tween(mainFrame, 0.5, {Size = originalSize, Position = UDim2.new(0.5,-275,0.5,-200)}) end)

    local function closeAllDropdowns()
        for _, dd in pairs(_openDropdowns) do if dd.close then dd.close() end end
    end

    -- ================================================
    -- CREATE TAB
    -- ================================================
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or ""
        local Tab = {}; Tab.Sections = {}; Tab.Name = tabName

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1,0,1,0); tabContent.BackgroundTransparency = 1; tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = _currentAccentColor; tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false; tabContent.Parent = contentArea
        local cLayout = Instance.new("UIListLayout"); cLayout.SortOrder = Enum.SortOrder.LayoutOrder; cLayout.Padding = UDim.new(0,8); cLayout.Parent = tabContent
        AddPadding(tabContent, 4, 4, 4, 4)
        tabContent:GetPropertyChangedSignal("CanvasPosition"):Connect(function() closeAllDropdowns() end)

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1,0,0,34); tabBtn.BackgroundColor3 = Theme.TabInactive; tabBtn.BackgroundTransparency = 0.5
        tabBtn.Text = ""; tabBtn.BorderSizePixel = 0; tabBtn.AutoButtonColor = false; tabBtn.LayoutOrder = #Window.Tabs+1; tabBtn.Parent = tabBtnContainer
        AddCorner(tabBtn, 8)

        local indicator = Instance.new("Frame"); indicator.Size = UDim2.new(0,3,0.6,0); indicator.Position = UDim2.new(0,0,0.2,0)
        indicator.BackgroundColor3 = _currentAccentColor; indicator.BackgroundTransparency = 1; indicator.BorderSizePixel = 0; indicator.Parent = tabBtn
        AddCorner(indicator, 2); RegisterAccent(indicator, "BackgroundColor3")

        local icoLabel = Instance.new("TextLabel"); icoLabel.Size = UDim2.new(0,22,1,0); icoLabel.Position = UDim2.new(0,8,0,0)
        icoLabel.BackgroundTransparency = 1; icoLabel.Text = tabIcon; icoLabel.TextColor3 = Theme.TextDim; icoLabel.TextSize = 14; icoLabel.Font = Enum.Font.Gotham; icoLabel.Parent = tabBtn

        local nameLabel = Instance.new("TextLabel"); nameLabel.Size = UDim2.new(1,-38,1,0); nameLabel.Position = UDim2.new(0,32,0,0)
        nameLabel.BackgroundTransparency = 1; nameLabel.Text = tabName; nameLabel.TextColor3 = Theme.TextDim; nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.GothamSemibold; nameLabel.TextXAlignment = Enum.TextXAlignment.Left; nameLabel.Parent = tabBtn

        local tabData = {Content=tabContent, Button=tabBtn, Indicator=indicator, NameLabel=nameLabel, IconLabel=icoLabel, Tab=Tab}
        table.insert(Window.Tabs, tabData)

        local function activateTab()
            closeAllDropdowns()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false; Tween(t.Button, 0.25, {BackgroundColor3=Theme.TabInactive, BackgroundTransparency=0.5})
                Tween(t.Indicator, 0.25, {BackgroundTransparency=1}); t.NameLabel.TextColor3=Theme.TextDim; t.IconLabel.TextColor3=Theme.TextDim
            end
            tabContent.Visible = true; Tween(tabBtn, 0.25, {BackgroundColor3=Theme.SurfaceLight, BackgroundTransparency=0})
            Tween(indicator, 0.25, {BackgroundTransparency=0}); nameLabel.TextColor3=Theme.Text; icoLabel.TextColor3=_currentAccentColor
            Window.ActiveTab = Tab
        end

        tabBtn.MouseButton1Click:Connect(activateTab)
        tabBtn.MouseEnter:Connect(function() if Window.ActiveTab ~= Tab then Tween(tabBtn, 0.2, {BackgroundTransparency=0.3}) end end)
        tabBtn.MouseLeave:Connect(function() if Window.ActiveTab ~= Tab then Tween(tabBtn, 0.2, {BackgroundTransparency=0.5}) end end)
        if #Window.Tabs == 1 then activateTab() end

        -- ================================================
        -- CREATE SECTION
        -- ================================================
        function Tab:CreateSection(sectionName)
            sectionName = sectionName or "Section"
            local Section = {}; local elementOrder = 2

            local sFrame = Instance.new("Frame"); sFrame.Size = UDim2.new(1,0,0,0); sFrame.AutomaticSize = Enum.AutomaticSize.Y
            sFrame.BackgroundColor3 = Theme.Surface; sFrame.LayoutOrder = #Tab.Sections+1; sFrame.Parent = tabContent
            AddCorner(sFrame, 10); AddStroke(sFrame, Theme.Border, 1, 0.7); AddPadding(sFrame, 10, 10, 12, 12)
            local sLayout = Instance.new("UIListLayout"); sLayout.SortOrder = Enum.SortOrder.LayoutOrder; sLayout.Padding = UDim.new(0,7); sLayout.Parent = sFrame

            local sTitle = Instance.new("TextLabel"); sTitle.Size = UDim2.new(1,0,0,18); sTitle.BackgroundTransparency = 1; sTitle.Text = sectionName
            sTitle.TextColor3 = _currentAccentColor; sTitle.TextSize = 12; sTitle.Font = Enum.Font.GothamBold; sTitle.TextXAlignment = Enum.TextXAlignment.Left
            sTitle.LayoutOrder = 0; sTitle.Parent = sFrame; RegisterAccent(sTitle, "TextColor3")

            local tSep = Instance.new("Frame"); tSep.Size = UDim2.new(1,0,0,1); tSep.BackgroundColor3 = Theme.Border; tSep.BackgroundTransparency = 0.5; tSep.LayoutOrder = 1; tSep.Parent = sFrame
            table.insert(Tab.Sections, Section)

            -- TOGGLE (com atualização dinâmica de cor)
            function Section:CreateToggle(cfg)
                cfg = cfg or {}
                local toggled = cfg.Default or false
                local cb = cfg.Callback or function() end
                elementOrder = elementOrder + 1

                local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,30); f.BackgroundTransparency = 1; f.LayoutOrder = elementOrder; f.Parent = sFrame
                local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,-55,1,0); l.BackgroundTransparency = 1; l.Text = cfg.Name or "Toggle"
                l.TextColor3 = Theme.Text; l.TextSize = 13; l.Font = Enum.Font.GothamSemibold; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f

                local sw = Instance.new("TextButton"); sw.Size = UDim2.new(0,44,0,22); sw.Position = UDim2.new(1,-44,0.5,-11)
                sw.BackgroundColor3 = toggled and _currentAccentColor or Theme.ToggleOff; sw.Text = ""; sw.AutoButtonColor = false; sw.Parent = f
                AddCorner(sw, 11)

                local ci = Instance.new("Frame"); ci.Size = UDim2.new(0,16,0,16)
                ci.Position = toggled and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
                ci.BackgroundColor3 = toggled and Color3.fromRGB(255,255,255) or Theme.TextDim; ci.Parent = sw
                AddCorner(ci, 8)

                -- Registrar toggle para atualização dinâmica
                local toggleId = #_activeToggles + 1
                _activeToggles[toggleId] = {
                    switch = sw,
                    getState = function() return toggled end
                }

                local function upd()
                    if toggled then
                        Tween(sw, 0.3, {BackgroundColor3 = _currentAccentColor})
                        Tween(ci, 0.3, {Position = UDim2.new(1,-19,0.5,-8), BackgroundColor3 = Color3.fromRGB(255,255,255)})
                    else
                        Tween(sw, 0.3, {BackgroundColor3 = Theme.ToggleOff})
                        Tween(ci, 0.3, {Position = UDim2.new(0,3,0.5,-8), BackgroundColor3 = Theme.TextDim})
                    end
                    cb(toggled)
                end

                sw.MouseButton1Click:Connect(function() toggled = not toggled; upd() end)
                sw.MouseEnter:Connect(function()
                    if toggled then Tween(sw, 0.15, {BackgroundColor3 = Theme.AccentGlow})
                    else Tween(sw, 0.15, {BackgroundColor3 = Theme.SurfaceHover}) end
                end)
                sw.MouseLeave:Connect(function()
                    if toggled then Tween(sw, 0.15, {BackgroundColor3 = _currentAccentColor})
                    else Tween(sw, 0.15, {BackgroundColor3 = Theme.ToggleOff}) end
                end)

                if cfg.Default then cb(true) end
                local API = {}
                function API:Set(v) toggled = v; upd() end
                function API:Get() return toggled end
                return API
            end

            -- SLIDER
            function Section:CreateSlider(cfg)
                cfg = cfg or {}
                local sMin,sMax,sInc = cfg.Min or 0, cfg.Max or 100, cfg.Increment or 1
                local curVal = cfg.Default or sMin; local cb = cfg.Callback or function() end
                elementOrder = elementOrder + 1

                local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,48); f.BackgroundTransparency = 1; f.LayoutOrder = elementOrder; f.Parent = sFrame
                local hdr = Instance.new("Frame"); hdr.Size = UDim2.new(1,0,0,18); hdr.BackgroundTransparency = 1; hdr.Parent = f
                local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.6,0,1,0); lbl.BackgroundTransparency = 1; lbl.Text = cfg.Name or "Slider"
                lbl.TextColor3 = Theme.Text; lbl.TextSize = 13; lbl.Font = Enum.Font.GothamSemibold; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = hdr
                local val = Instance.new("TextLabel"); val.Size = UDim2.new(0.4,0,1,0); val.Position = UDim2.new(0.6,0,0,0); val.BackgroundTransparency = 1
                val.Text = tostring(curVal); val.TextColor3 = _currentAccentColor; val.TextSize = 13; val.Font = Enum.Font.GothamBold; val.TextXAlignment = Enum.TextXAlignment.Right; val.Parent = hdr
                RegisterAccent(val, "TextColor3")

                local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,0,6); bg.Position = UDim2.new(0,0,0,26); bg.BackgroundColor3 = Theme.SliderBg; bg.Parent = f; AddCorner(bg, 3)
                local iR = math.clamp((curVal-sMin)/(sMax-sMin),0,1)
                local fill = Instance.new("Frame"); fill.Size = UDim2.new(iR,0,1,0); fill.BackgroundColor3 = _currentAccentColor; fill.Parent = bg; AddCorner(fill, 3); RegisterAccent(fill, "BackgroundColor3")
                local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,14,0,14); knob.Position = UDim2.new(iR,-7,0.5,-7); knob.BackgroundColor3 = Color3.fromRGB(255,255,255); knob.ZIndex = 3; knob.Parent = bg; AddCorner(knob, 7)
                local kS = AddStroke(knob, _currentAccentColor, 2, 0); RegisterAccent(kS, "Color")

                local sliding = false
                local function upd(input)
                    local r = math.clamp((input.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1)
                    local raw = sMin+(sMax-sMin)*r; local v = math.floor(raw/sInc+0.5)*sInc; v = math.clamp(v,sMin,sMax)
                    if sInc >= 1 then v = math.floor(v) else v = tonumber(string.format("%.2f",v)) end
                    local nr = (v-sMin)/(sMax-sMin); curVal = v
                    Tween(fill, 0.08, {Size=UDim2.new(nr,0,1,0)}); Tween(knob, 0.08, {Position=UDim2.new(nr,-7,0.5,-7)}); val.Text=tostring(v); cb(v)
                end
                bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding=true; upd(i) end end)
                knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding=true end end)
                UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding=false end end)
                cb(curVal)

                local API = {}
                function API:Set(v) v=math.clamp(v,sMin,sMax); curVal=v; local r=(v-sMin)/(sMax-sMin); Tween(fill,0.15,{Size=UDim2.new(r,0,1,0)}); Tween(knob,0.15,{Position=UDim2.new(r,-7,0.5,-7)}); val.Text=tostring(v); cb(v) end
                function API:Get() return curVal end
                return API
            end

            -- KEYBIND
            function Section:CreateKeybind(cfg)
                cfg = cfg or {}
                local currentKey = cfg.Default or Enum.KeyCode.Unknown
                local currentInputType = "Keyboard"
                local cb = cfg.Callback or function() end
                local flag = cfg.Flag or nil; local listening = false
                elementOrder = elementOrder + 1

                if typeof(cfg.Default) == "EnumItem" then
                    if cfg.Default == Enum.UserInputType.MouseButton1 then currentInputType="MouseButton1"; currentKey=nil
                    elseif cfg.Default == Enum.UserInputType.MouseButton2 then currentInputType="MouseButton2"; currentKey=nil
                    elseif cfg.Default == Enum.UserInputType.MouseButton3 then currentInputType="MouseButton3"; currentKey=nil
                    else currentInputType="Keyboard" end
                end

                local function getDisplay()
                    if currentInputType=="MouseButton1" then return "Mouse1" elseif currentInputType=="MouseButton2" then return "Mouse2"
                    elseif currentInputType=="MouseButton3" then return "Mouse3" elseif currentKey and currentKey~=Enum.KeyCode.Unknown then return currentKey.Name
                    else return "None" end
                end

                local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,30); f.BackgroundTransparency = 1; f.LayoutOrder = elementOrder; f.Parent = sFrame
                local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,-80,1,0); l.BackgroundTransparency = 1; l.Text = cfg.Name or "Keybind"
                l.TextColor3 = Theme.Text; l.TextSize = 13; l.Font = Enum.Font.GothamSemibold; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
                local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0,70,0,24); btn.Position = UDim2.new(1,-70,0.5,-12)
                btn.BackgroundColor3 = Theme.SliderBg; btn.Text = getDisplay(); btn.TextColor3 = _currentAccentColor; btn.TextSize = 12
                btn.Font = Enum.Font.GothamBold; btn.AutoButtonColor = false; btn.Parent = f; AddCorner(btn, 6); AddStroke(btn, Theme.Border, 1, 0.6)
                RegisterAccent(btn, "TextColor3")

                btn.MouseEnter:Connect(function() if not listening then Tween(btn, 0.15, {BackgroundColor3=Theme.SurfaceHover}) end end)
                btn.MouseLeave:Connect(function() if not listening then Tween(btn, 0.15, {BackgroundColor3=Theme.SliderBg}) end end)
                btn.MouseButton1Click:Connect(function() listening=true; btn.Text="..."; Tween(btn, 0.2, {BackgroundColor3=Theme.AccentDark}) end)

                UserInputService.InputBegan:Connect(function(input, gp)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey=input.KeyCode; currentInputType="Keyboard"; btn.Text=getDisplay(); listening=false; Tween(btn, 0.2, {BackgroundColor3=Theme.SliderBg})
                            if flag=="GUIToggle" then _windowKeybind=currentKey end
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            currentKey=nil; currentInputType="MouseButton2"; btn.Text=getDisplay(); listening=false; Tween(btn, 0.2, {BackgroundColor3=Theme.SliderBg})
                        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                            currentKey=nil; currentInputType="MouseButton3"; btn.Text=getDisplay(); listening=false; Tween(btn, 0.2, {BackgroundColor3=Theme.SliderBg})
                        end
                    else
                        if not gp then
                            local fire = false
                            if currentInputType=="Keyboard" and currentKey and input.KeyCode==currentKey then fire=true
                            elseif currentInputType=="MouseButton2" and input.UserInputType==Enum.UserInputType.MouseButton2 then fire=true
                            elseif currentInputType=="MouseButton3" and input.UserInputType==Enum.UserInputType.MouseButton3 then fire=true end
                            if fire then cb() end
                        end
                    end
                end)

                local API = {}
                function API:Set(key)
                    if typeof(key)=="EnumItem" then
                        if key==Enum.UserInputType.MouseButton1 then currentInputType="MouseButton1"; currentKey=nil
                        elseif key==Enum.UserInputType.MouseButton2 then currentInputType="MouseButton2"; currentKey=nil
                        elseif key==Enum.UserInputType.MouseButton3 then currentInputType="MouseButton3"; currentKey=nil
                        else currentInputType="Keyboard"; currentKey=key end
                    end
                    btn.Text=getDisplay()
                    if flag=="GUIToggle" and currentKey then _windowKeybind=currentKey end
                end
                function API:Get() return currentKey or currentInputType end
                function API:GetInputType() return currentInputType end
                return API
            end

            -- BUTTON (com atualização dinâmica de cor)
            function Section:CreateButton(cfg)
                cfg = cfg or {}
                local cb = cfg.Callback or function() end
                elementOrder = elementOrder + 1

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1,0,0,32)
                btn.BackgroundColor3 = _currentAccentColor
                btn.BackgroundTransparency = 0.8
                btn.Text = cfg.Name or "Button"
                btn.TextColor3 = Theme.Text
                btn.TextSize = 13
                btn.Font = Enum.Font.GothamSemibold
                btn.AutoButtonColor = false
                btn.LayoutOrder = elementOrder
                btn.Parent = sFrame
                AddCorner(btn, 8)
                local btnStroke = AddStroke(btn, _currentAccentColor, 1, 0.5)

                -- Registrar para atualização dinâmica
                local btnId = #_accentButtons + 1
                _accentButtons[btnId] = {btn = btn}
                RegisterAccent(btnStroke, "Color")
                RegisterAccent(btn, "BackgroundColor3")

                btn.MouseEnter:Connect(function() Tween(btn, 0.2, {BackgroundTransparency = 0.5}) end)
                btn.MouseLeave:Connect(function() Tween(btn, 0.2, {BackgroundTransparency = 0.8}) end)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, 0.1, {BackgroundTransparency = 0.2})
                    task.delay(0.15, function() Tween(btn, 0.2, {BackgroundTransparency = 0.8}) end)
                    cb()
                end)
            end

            -- DROPDOWN
            function Section:CreateDropdown(cfg)
                cfg = cfg or {}
                local options = cfg.Options or {}
                local currentOption = cfg.Default or (options[1] or "None")
                local cb = cfg.Callback or function() end
                local isOpen = false; elementOrder = elementOrder + 1
                local ddId = tostring(elementOrder)..tabName..sectionName

                local dFrame = Instance.new("Frame"); dFrame.Size = UDim2.new(1,0,0,30); dFrame.BackgroundTransparency = 1; dFrame.LayoutOrder = elementOrder; dFrame.ZIndex = 50; dFrame.Parent = sFrame
                local dLabel = Instance.new("TextLabel"); dLabel.Size = UDim2.new(0.5,0,0,30); dLabel.BackgroundTransparency = 1; dLabel.Text = cfg.Name or "Dropdown"
                dLabel.TextColor3 = Theme.Text; dLabel.TextSize = 13; dLabel.Font = Enum.Font.GothamSemibold; dLabel.TextXAlignment = Enum.TextXAlignment.Left; dLabel.ZIndex = 50; dLabel.Parent = dFrame

                local dBtn = Instance.new("TextButton"); dBtn.Size = UDim2.new(0.48,0,0,26); dBtn.Position = UDim2.new(0.52,0,0,2)
                dBtn.BackgroundColor3 = Theme.SliderBg; dBtn.Text = tostring(currentOption).." ▾"; dBtn.TextColor3 = _currentAccentColor
                dBtn.TextSize = 12; dBtn.Font = Enum.Font.GothamBold; dBtn.AutoButtonColor = false; dBtn.ZIndex = 51; dBtn.Parent = dFrame
                AddCorner(dBtn, 6); AddStroke(dBtn, Theme.Border, 1, 0.6); RegisterAccent(dBtn, "TextColor3")

                local optionsFrame = Instance.new("Frame"); optionsFrame.BackgroundColor3 = Color3.fromRGB(22,22,28); optionsFrame.BorderSizePixel = 0
                optionsFrame.ClipsDescendants = true; optionsFrame.ZIndex = 200; optionsFrame.Visible = false; optionsFrame.Size = UDim2.new(0,0,0,0)
                optionsFrame.Parent = screenGui; AddCorner(optionsFrame, 8); AddStroke(optionsFrame, _currentAccentColor, 1, 0.4)
                local optLayout = Instance.new("UIListLayout"); optLayout.SortOrder = Enum.SortOrder.LayoutOrder; optLayout.Padding = UDim.new(0,2); optLayout.Parent = optionsFrame
                AddPadding(optionsFrame, 4, 4, 4, 4)

                local function closeDD()
                    if not isOpen then return end; isOpen = false
                    Tween(optionsFrame, 0.2, {Size=UDim2.new(0,dBtn.AbsoluteSize.X,0,0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                    task.delay(0.2, function() optionsFrame.Visible = false end)
                    dBtn.Text = tostring(currentOption).." ▾"; _openDropdowns[ddId] = nil
                end

                local function openDD()
                    closeAllDropdowns(); isOpen = true
                    local absPos = dBtn.AbsolutePosition; local absSize = dBtn.AbsoluteSize
                    optionsFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y+absSize.Y+4)
                    optionsFrame.Size = UDim2.new(0, absSize.X, 0, 0); optionsFrame.Visible = true
                    Tween(optionsFrame, 0.25, {Size=UDim2.new(0, absSize.X, 0, #options*28+10)})
                    dBtn.Text = tostring(currentOption).." ▴"; _openDropdowns[ddId] = {close=closeDD}
                end

                for i, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton"); optBtn.Size = UDim2.new(1,0,0,26); optBtn.BackgroundColor3 = Theme.SurfaceHover
                    optBtn.BackgroundTransparency = 0.8; optBtn.Text = tostring(opt); optBtn.TextColor3 = Theme.Text; optBtn.TextSize = 12
                    optBtn.Font = Enum.Font.Gotham; optBtn.AutoButtonColor = false; optBtn.LayoutOrder = i; optBtn.ZIndex = 201; optBtn.Parent = optionsFrame; AddCorner(optBtn, 4)
                    optBtn.MouseEnter:Connect(function() Tween(optBtn, 0.15, {BackgroundTransparency=0.3, BackgroundColor3=_currentAccentColor}) end)
                    optBtn.MouseLeave:Connect(function() Tween(optBtn, 0.15, {BackgroundTransparency=0.8, BackgroundColor3=Theme.SurfaceHover}) end)
                    optBtn.MouseButton1Click:Connect(function() currentOption=opt; closeDD(); cb(opt) end)
                end

                dBtn.MouseButton1Click:Connect(function() if isOpen then closeDD() else openDD() end end)
                dBtn.MouseEnter:Connect(function() Tween(dBtn, 0.15, {BackgroundColor3=Theme.SurfaceHover}) end)
                dBtn.MouseLeave:Connect(function() Tween(dBtn, 0.15, {BackgroundColor3=Theme.SliderBg}) end)

                local API = {}
                function API:Set(v) currentOption=v; dBtn.Text=tostring(v).." ▾"; cb(v) end
                function API:Get() return currentOption end
                return API
            end

            -- LABEL
            function Section:CreateLabel(text)
                elementOrder = elementOrder + 1
                local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,0,0,20); l.BackgroundTransparency = 1; l.Text = text or ""
                l.TextColor3 = Theme.TextDim; l.TextSize = 12; l.Font = Enum.Font.Gotham; l.TextWrapped = true
                l.TextXAlignment = Enum.TextXAlignment.Left; l.LayoutOrder = elementOrder; l.Parent = sFrame
                local API = {}; function API:Set(t) l.Text = t end; return API
            end

            return Section
        end
        return Tab
    end
    return Window
end

return GenarixUI

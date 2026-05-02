--[[
    ╔══════════════════════════════════════════════╗
    ║            GENARIX UI LIBRARY                ║
    ║            Version: 1.1.0                    ║
    ║            Creator: Genarix                  ║
    ╚══════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local GenarixUI = {}

-- Variável global para controlar a keybind da janela
local _windowKeybind = nil

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
    local info = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(instance, info, properties)
    t:Play()
    return t
end

local function AddShadow(parent)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
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
    return s
end

-- ================================================
-- NOTIFICATION SYSTEM
-- ================================================
local NotifContainer = nil

local function EnsureNotifContainer(screenGui)
    if NotifContainer then return end
    NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "Notifications"
    NotifContainer.Size = UDim2.new(0, 300, 1, -20)
    NotifContainer.Position = UDim2.new(1, -310, 0, 10)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.BorderSizePixel = 0
    NotifContainer.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = NotifContainer
end

function GenarixUI:Notify(config)
    config = config or {}
    local title = config.Title or "Genarix UI"
    local content = config.Content or ""
    local duration = config.Duration or 3
    if not NotifContainer then return end

    local notif = Instance.new("Frame")
    notif.Name = "Notif"
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Theme.NotifBg
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = NotifContainer
    AddCorner(notif, 10)
    AddStroke(notif, Theme.Accent, 1, 0.5)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0.7, 0)
    accentBar.Position = UDim2.new(0, 8, 0.15, 0)
    accentBar.BackgroundColor3 = Theme.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notif
    AddCorner(accentBar, 2)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -25, 0, 18)
    titleLabel.Position = UDim2.new(0, 18, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Accent
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -25, 0, 16)
    contentLabel.Position = UDim2.new(0, 18, 0, 28)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Theme.TextDim
    contentLabel.TextSize = 12
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Parent = notif

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, -20, 0, 2)
    progressBg.Position = UDim2.new(0, 10, 1, -8)
    progressBg.BackgroundColor3 = Theme.SliderBg
    progressBg.BorderSizePixel = 0
    progressBg.Parent = notif
    AddCorner(progressBg, 1)

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = Theme.Accent
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    AddCorner(progressFill, 1)

    Tween(notif, 0.4, {Size = UDim2.new(1, 0, 0, 60)})
    task.delay(0.4, function()
        Tween(progressFill, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)
    end)
    task.delay(duration + 0.5, function()
        Tween(notif, 0.3, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.35)
        notif:Destroy()
    end)
end

-- Função para mudar a keybind da janela externamente
function GenarixUI:SetToggleKey(newKey)
    _windowKeybind = newKey
end

function GenarixUI:GetToggleKey()
    return _windowKeybind
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

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GenarixUI_" .. windowName
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    Window.ScreenGui = screenGui
    EnsureNotifContainer(screenGui)

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 520, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    AddCorner(mainFrame, 12)
    AddStroke(mainFrame, Theme.Accent, 1.5, 0.6)
    AddShadow(mainFrame)
    Window.MainFrame = mainFrame

    -- HEADER
    local header = Instance.new("Frame")
    header.Name = "Header"
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
    sepLine.BackgroundColor3 = Theme.Accent
    sepLine.BorderSizePixel = 0
    sepLine.Parent = header
    AddCorner(sepLine, 1)

    local sepGrad = Instance.new("UIGradient")
    sepGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Theme.AccentGlow),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    }
    sepGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.7)
    }
    sepGrad.Parent = sepLine

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 12, 0.5, -14)
    icon.BackgroundColor3 = Theme.Accent
    icon.BackgroundTransparency = 0.85
    icon.Text = string.sub(windowName, 1, 1)
    icon.TextColor3 = Theme.Accent
    icon.TextSize = 14
    icon.Font = Enum.Font.GothamBold
    icon.BorderSizePixel = 0
    icon.Parent = header
    AddCorner(icon, 7)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -130, 1, 0)
    title.Position = UDim2.new(0, 48, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = windowName
    title.TextColor3 = Theme.Text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

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
        btn.MouseEnter:Connect(function()
            Tween(btn, 0.2, {BackgroundTransparency = 0.5})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.2, {BackgroundTransparency = 0.85})
        end)
    end

    -- SIDEBAR
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 130, 1, -48)
    sidebar.Position = UDim2.new(0, 0, 0, 44)
    sidebar.BackgroundColor3 = Theme.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    AddCorner(sidebar, 12)

    local sidebarFixTop = Instance.new("Frame")
    sidebarFixTop.Size = UDim2.new(1, 0, 0, 14)
    sidebarFixTop.BackgroundColor3 = Theme.Surface
    sidebarFixTop.BorderSizePixel = 0
    sidebarFixTop.Parent = sidebar

    local sidebarFixRight = Instance.new("Frame")
    sidebarFixRight.Size = UDim2.new(0, 14, 1, 0)
    sidebarFixRight.Position = UDim2.new(1, -14, 0, 0)
    sidebarFixRight.BackgroundColor3 = Theme.Surface
    sidebarFixRight.BorderSizePixel = 0
    sidebarFixRight.Parent = sidebar

    local sidebarSep = Instance.new("Frame")
    sidebarSep.Size = UDim2.new(0, 1, 1, -16)
    sidebarSep.Position = UDim2.new(1, 0, 0, 8)
    sidebarSep.BackgroundColor3 = Theme.Border
    sidebarSep.BackgroundTransparency = 0.5
    sidebarSep.BorderSizePixel = 0
    sidebarSep.Parent = sidebar

    local tabButtonContainer = Instance.new("ScrollingFrame")
    tabButtonContainer.Size = UDim2.new(1, -12, 1, -16)
    tabButtonContainer.Position = UDim2.new(0, 6, 0, 8)
    tabButtonContainer.BackgroundTransparency = 1
    tabButtonContainer.BorderSizePixel = 0
    tabButtonContainer.ScrollBarThickness = 0
    tabButtonContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    tabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabButtonContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabButtonContainer.Parent = sidebar

    local tabBtnLayout = Instance.new("UIListLayout")
    tabBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBtnLayout.Padding = UDim.new(0, 4)
    tabBtnLayout.Parent = tabButtonContainer

    -- CONTENT AREA
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -138, 1, -52)
    contentArea.Position = UDim2.new(0, 135, 0, 48)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainFrame

    -- DRAGGING
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- MINIMIZE / MAXIMIZE
    local minimized = false
    local storedPos = nil
    local originalSize = UDim2.new(0, 520, 0, 380)

    local minimizeNotif = Instance.new("Frame")
    minimizeNotif.Size = UDim2.new(0, 320, 0, 42)
    minimizeNotif.Position = UDim2.new(0, 15, 1, 10)
    minimizeNotif.BackgroundColor3 = Theme.NotifBg
    minimizeNotif.BorderSizePixel = 0
    minimizeNotif.Visible = false
    minimizeNotif.Parent = screenGui
    AddCorner(minimizeNotif, 10)
    AddStroke(minimizeNotif, Theme.Accent, 1, 0.4)

    local mnAccent = Instance.new("Frame")
    mnAccent.Size = UDim2.new(0, 3, 0.6, 0)
    mnAccent.Position = UDim2.new(0, 8, 0.2, 0)
    mnAccent.BackgroundColor3 = Theme.Accent
    mnAccent.BorderSizePixel = 0
    mnAccent.Parent = minimizeNotif
    AddCorner(mnAccent, 2)

    local mnText = Instance.new("TextLabel")
    mnText.Name = "MinNotifText"
    mnText.Size = UDim2.new(1, -25, 1, 0)
    mnText.Position = UDim2.new(0, 18, 0, 0)
    mnText.BackgroundTransparency = 1
    mnText.Text = "Aperte '" .. _windowKeybind.Name .. "' para maximizar a GUI"
    mnText.TextColor3 = Theme.Text
    mnText.TextSize = 12
    mnText.Font = Enum.Font.GothamSemibold
    mnText.TextXAlignment = Enum.TextXAlignment.Left
    mnText.Parent = minimizeNotif

    local function doMinimize()
        minimized = true
        storedPos = mainFrame.Position
        -- Atualizar texto da notificação com a tecla atual
        mnText.Text = "Aperte '" .. _windowKeybind.Name .. "' para maximizar a GUI"
        Tween(mainFrame, 0.4, {
            Size = UDim2.new(0, 520, 0, 0),
            Position = UDim2.new(
                mainFrame.Position.X.Scale,
                mainFrame.Position.X.Offset,
                mainFrame.Position.Y.Scale,
                mainFrame.Position.Y.Offset + 190
            )
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.4, function()
            mainFrame.Visible = false
        end)
        minimizeNotif.Visible = true
        minimizeNotif.Position = UDim2.new(0, 15, 1, 10)
        Tween(minimizeNotif, 0.5, {Position = UDim2.new(0, 15, 1, -57)})
    end

    local function doMaximize()
        minimized = false
        mainFrame.Visible = true
        local tp = storedPos or UDim2.new(0.5, -260, 0.5, -190)
        mainFrame.Position = UDim2.new(tp.X.Scale, tp.X.Offset, tp.Y.Scale, tp.Y.Offset + 190)
        mainFrame.Size = UDim2.new(0, 520, 0, 0)
        Tween(mainFrame, 0.4, {Size = originalSize, Position = tp})
        Tween(minimizeNotif, 0.3, {Position = UDim2.new(0, 15, 1, 10)})
        task.delay(0.3, function()
            minimizeNotif.Visible = false
        end)
    end

    minimizeBtn.MouseButton1Click:Connect(function()
        doMinimize()
    end)

    -- CLOSE
    closeBtn.MouseButton1Click:Connect(function()
        Tween(mainFrame, 0.3, {
            Size = UDim2.new(0, 520, 0, 0),
            Position = UDim2.new(
                mainFrame.Position.X.Scale,
                mainFrame.Position.X.Offset,
                mainFrame.Position.Y.Scale,
                mainFrame.Position.Y.Offset + 190
            )
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        Tween(minimizeNotif, 0.3, {Position = UDim2.new(0, 15, 1, 10)})
        task.delay(0.35, function()
            screenGui:Destroy()
        end)
    end)

    -- KEYBIND TOGGLE - Usa _windowKeybind que pode ser alterada
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == _windowKeybind then
            if minimized then
                doMaximize()
            else
                doMinimize()
            end
        end
    end)

    -- ANIMAÇÃO DE ENTRADA
    mainFrame.Size = UDim2.new(0, 520, 0, 0)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, 0)
    task.delay(0.1, function()
        Tween(mainFrame, 0.5, {
            Size = originalSize,
            Position = UDim2.new(0.5, -260, 0.5, -190)
        })
    end)

    -- ================================================
    -- CREATE TAB
    -- ================================================
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or ""

        local Tab = {}
        Tab.Sections = {}
        Tab.Name = tabName

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "Tab_" .. tabName
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = Theme.Accent
        tabContent.ScrollBarImageTransparency = 0.5
        tabContent.ScrollingDirection = Enum.ScrollingDirection.Y
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.Parent = contentArea

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent

        AddPadding(tabContent, 4, 4, 4, 4)

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 34)
        tabBtn.BackgroundColor3 = Theme.TabInactive
        tabBtn.BackgroundTransparency = 0.5
        tabBtn.Text = ""
        tabBtn.BorderSizePixel = 0
        tabBtn.AutoButtonColor = false
        tabBtn.LayoutOrder = #Window.Tabs + 1
        tabBtn.Parent = tabButtonContainer
        AddCorner(tabBtn, 8)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0.6, 0)
        indicator.Position = UDim2.new(0, 0, 0.2, 0)
        indicator.BackgroundColor3 = Theme.Accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.Parent = tabBtn
        AddCorner(indicator, 2)

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 22, 1, 0)
        iconLabel.Position = UDim2.new(0, 8, 0, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = tabIcon
        iconLabel.TextColor3 = Theme.TextDim
        iconLabel.TextSize = 14
        iconLabel.Font = Enum.Font.Gotham
        iconLabel.Parent = tabBtn

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -38, 1, 0)
        nameLabel.Position = UDim2.new(0, 32, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = tabName
        nameLabel.TextColor3 = Theme.TextDim
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = tabBtn

        local tabData = {
            Content = tabContent,
            Button = tabBtn,
            Indicator = indicator,
            NameLabel = nameLabel,
            IconLabel = iconLabel,
            Tab = Tab
        }
        table.insert(Window.Tabs, tabData)

        local function activateTab()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                Tween(t.Button, 0.25, {BackgroundColor3 = Theme.TabInactive, BackgroundTransparency = 0.5})
                Tween(t.Indicator, 0.25, {BackgroundTransparency = 1})
                t.NameLabel.TextColor3 = Theme.TextDim
                t.IconLabel.TextColor3 = Theme.TextDim
            end
            tabContent.Visible = true
            Tween(tabBtn, 0.25, {BackgroundColor3 = Theme.SurfaceLight, BackgroundTransparency = 0})
            Tween(indicator, 0.25, {BackgroundTransparency = 0})
            nameLabel.TextColor3 = Theme.Text
            iconLabel.TextColor3 = Theme.Accent
            Window.ActiveTab = Tab
        end

        tabBtn.MouseButton1Click:Connect(activateTab)

        tabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabBtn, 0.2, {BackgroundTransparency = 0.3})
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabBtn, 0.2, {BackgroundTransparency = 0.5})
            end
        end)

        if #Window.Tabs == 1 then
            activateTab()
        end

        -- ================================================
        -- CREATE SECTION
        -- ================================================
        function Tab:CreateSection(sectionName)
            sectionName = sectionName or "Section"

            local Section = {}
            local elementOrder = 2

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "Section_" .. sectionName
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.BackgroundColor3 = Theme.Surface
            sectionFrame.BorderSizePixel = 0
            sectionFrame.LayoutOrder = #Tab.Sections + 1
            sectionFrame.Parent = tabContent
            AddCorner(sectionFrame, 10)
            AddStroke(sectionFrame, Theme.Border, 1, 0.7)
            AddPadding(sectionFrame, 10, 10, 12, 12)

            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 7)
            sectionLayout.Parent = sectionFrame

            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Size = UDim2.new(1, 0, 0, 18)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = Theme.Accent
            sectionTitle.TextSize = 12
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.LayoutOrder = 0
            sectionTitle.Parent = sectionFrame

            local titleSep = Instance.new("Frame")
            titleSep.Size = UDim2.new(1, 0, 0, 1)
            titleSep.BackgroundColor3 = Theme.Border
            titleSep.BackgroundTransparency = 0.5
            titleSep.BorderSizePixel = 0
            titleSep.LayoutOrder = 1
            titleSep.Parent = sectionFrame

            table.insert(Tab.Sections, Section)

            -- TOGGLE
            function Section:CreateToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local tName = toggleConfig.Name or "Toggle"
                local tDefault = toggleConfig.Default or false
                local tCallback = toggleConfig.Callback or function() end

                local toggled = tDefault
                elementOrder = elementOrder + 1

                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, 0, 0, 30)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.LayoutOrder = elementOrder
                toggleFrame.Parent = sectionFrame

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(1, -55, 1, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = tName
                toggleLabel.TextColor3 = Theme.Text
                toggleLabel.TextSize = 13
                toggleLabel.Font = Enum.Font.GothamSemibold
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame

                local switchBtn = Instance.new("TextButton")
                switchBtn.Size = UDim2.new(0, 44, 0, 22)
                switchBtn.Position = UDim2.new(1, -44, 0.5, -11)
                switchBtn.BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff
                switchBtn.Text = ""
                switchBtn.BorderSizePixel = 0
                switchBtn.AutoButtonColor = false
                switchBtn.Parent = toggleFrame
                AddCorner(switchBtn, 11)

                local circle = Instance.new("Frame")
                circle.Size = UDim2.new(0, 16, 0, 16)
                circle.Position = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                circle.BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Theme.TextDim
                circle.BorderSizePixel = 0
                circle.Parent = switchBtn
                AddCorner(circle, 8)

                local function updateToggle()
                    if toggled then
                        Tween(switchBtn, 0.3, {BackgroundColor3 = Theme.ToggleOn})
                        Tween(circle, 0.3, {
                            Position = UDim2.new(1, -19, 0.5, -8),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        })
                    else
                        Tween(switchBtn, 0.3, {BackgroundColor3 = Theme.ToggleOff})
                        Tween(circle, 0.3, {
                            Position = UDim2.new(0, 3, 0.5, -8),
                            BackgroundColor3 = Theme.TextDim
                        })
                    end
                    tCallback(toggled)
                end

                switchBtn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    updateToggle()
                end)

                switchBtn.MouseEnter:Connect(function()
                    Tween(switchBtn, 0.15, {BackgroundColor3 = toggled and Theme.AccentGlow or Theme.SurfaceHover})
                end)
                switchBtn.MouseLeave:Connect(function()
                    Tween(switchBtn, 0.15, {BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff})
                end)

                if tDefault then
                    tCallback(true)
                end

                local ToggleAPI = {}
                function ToggleAPI:Set(value)
                    toggled = value
                    updateToggle()
                end
                function ToggleAPI:Get()
                    return toggled
                end
                return ToggleAPI
            end

            -- SLIDER
            function Section:CreateSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local sName = sliderConfig.Name or "Slider"
                local sMin = sliderConfig.Min or 0
                local sMax = sliderConfig.Max or 100
                local sDefault = sliderConfig.Default or sMin
                local sIncrement = sliderConfig.Increment or 1
                local sCallback = sliderConfig.Callback or function() end

                local currentVal = sDefault
                elementOrder = elementOrder + 1

                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, 0, 0, 48)
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.LayoutOrder = elementOrder
                sliderFrame.Parent = sectionFrame

                local sliderHeader = Instance.new("Frame")
                sliderHeader.Size = UDim2.new(1, 0, 0, 18)
                sliderHeader.BackgroundTransparency = 1
                sliderHeader.Parent = sliderFrame

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(0.6, 0, 1, 0)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = sName
                sliderLabel.TextColor3 = Theme.Text
                sliderLabel.TextSize = 13
                sliderLabel.Font = Enum.Font.GothamSemibold
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderHeader

                local sliderValue = Instance.new("TextLabel")
                sliderValue.Size = UDim2.new(0.4, 0, 1, 0)
                sliderValue.Position = UDim2.new(0.6, 0, 0, 0)
                sliderValue.BackgroundTransparency = 1
                sliderValue.Text = tostring(currentVal)
                sliderValue.TextColor3 = Theme.Accent
                sliderValue.TextSize = 13
                sliderValue.Font = Enum.Font.GothamBold
                sliderValue.TextXAlignment = Enum.TextXAlignment.Right
                sliderValue.Parent = sliderHeader

                local sliderBg = Instance.new("Frame")
                sliderBg.Size = UDim2.new(1, 0, 0, 6)
                sliderBg.Position = UDim2.new(0, 0, 0, 26)
                sliderBg.BackgroundColor3 = Theme.SliderBg
                sliderBg.BorderSizePixel = 0
                sliderBg.Parent = sliderFrame
                AddCorner(sliderBg, 3)

                local initRel = math.clamp((sDefault - sMin) / (sMax - sMin), 0, 1)

                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new(initRel, 0, 1, 0)
                sliderFill.BackgroundColor3 = Theme.Accent
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderBg
                AddCorner(sliderFill, 3)

                local fillGrad = Instance.new("UIGradient")
                fillGrad.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Theme.AccentDark),
                    ColorSequenceKeypoint.new(1, Theme.Accent)
                }
                fillGrad.Parent = sliderFill

                local sliderKnob = Instance.new("Frame")
                sliderKnob.Size = UDim2.new(0, 14, 0, 14)
                sliderKnob.Position = UDim2.new(initRel, -7, 0.5, -7)
                sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderKnob.BorderSizePixel = 0
                sliderKnob.ZIndex = 3
                sliderKnob.Parent = sliderBg
                AddCorner(sliderKnob, 7)
                AddStroke(sliderKnob, Theme.Accent, 2, 0)

                local knobGlow = Instance.new("Frame")
                knobGlow.Size = UDim2.new(0, 22, 0, 22)
                knobGlow.Position = UDim2.new(0.5, -11, 0.5, -11)
                knobGlow.BackgroundColor3 = Theme.Accent
                knobGlow.BackgroundTransparency = 0.85
                knobGlow.BorderSizePixel = 0
                knobGlow.ZIndex = 2
                knobGlow.Parent = sliderKnob
                AddCorner(knobGlow, 11)

                local sliding = false

                local function updateSlider(input)
                    local rel = math.clamp(
                        (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X,
                        0, 1
                    )
                    local raw = sMin + (sMax - sMin) * rel
                    local val = math.floor(raw / sIncrement + 0.5) * sIncrement
                    val = math.clamp(val, sMin, sMax)

                    if sIncrement >= 1 then
                        val = math.floor(val)
                    else
                        val = tonumber(string.format("%.2f", val))
                    end

                    local newRel = (val - sMin) / (sMax - sMin)
                    currentVal = val

                    Tween(sliderFill, 0.08, {Size = UDim2.new(newRel, 0, 1, 0)})
                    Tween(sliderKnob, 0.08, {Position = UDim2.new(newRel, -7, 0.5, -7)})
                    sliderValue.Text = tostring(val)
                    sCallback(val)
                end

                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        updateSlider(input)
                    end
                end)
                sliderKnob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                sCallback(sDefault)

                local SliderAPI = {}
                function SliderAPI:Set(value)
                    value = math.clamp(value, sMin, sMax)
                    currentVal = value
                    local r = (value - sMin) / (sMax - sMin)
                    Tween(sliderFill, 0.15, {Size = UDim2.new(r, 0, 1, 0)})
                    Tween(sliderKnob, 0.15, {Position = UDim2.new(r, -7, 0.5, -7)})
                    sliderValue.Text = tostring(value)
                    sCallback(value)
                end
                function SliderAPI:Get()
                    return currentVal
                end
                return SliderAPI
            end

            -- KEYBIND
            function Section:CreateKeybind(kbConfig)
                kbConfig = kbConfig or {}
                local kName = kbConfig.Name or "Keybind"
                local kDefault = kbConfig.Default or Enum.KeyCode.Unknown
                local kCallback = kbConfig.Callback or function() end
                local kFlag = kbConfig.Flag or nil

                local currentKey = kDefault
                local listening = false
                elementOrder = elementOrder + 1

                local kbFrame = Instance.new("Frame")
                kbFrame.Size = UDim2.new(1, 0, 0, 30)
                kbFrame.BackgroundTransparency = 1
                kbFrame.LayoutOrder = elementOrder
                kbFrame.Parent = sectionFrame

                local kbLabel = Instance.new("TextLabel")
                kbLabel.Size = UDim2.new(1, -80, 1, 0)
                kbLabel.BackgroundTransparency = 1
                kbLabel.Text = kName
                kbLabel.TextColor3 = Theme.Text
                kbLabel.TextSize = 13
                kbLabel.Font = Enum.Font.GothamSemibold
                kbLabel.TextXAlignment = Enum.TextXAlignment.Left
                kbLabel.Parent = kbFrame

                local kbBtn = Instance.new("TextButton")
                kbBtn.Size = UDim2.new(0, 70, 0, 24)
                kbBtn.Position = UDim2.new(1, -70, 0.5, -12)
                kbBtn.BackgroundColor3 = Theme.SliderBg
                kbBtn.Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name
                kbBtn.TextColor3 = Theme.Accent
                kbBtn.TextSize = 12
                kbBtn.Font = Enum.Font.GothamBold
                kbBtn.BorderSizePixel = 0
                kbBtn.AutoButtonColor = false
                kbBtn.Parent = kbFrame
                AddCorner(kbBtn, 6)
                AddStroke(kbBtn, Theme.Border, 1, 0.6)

                kbBtn.MouseEnter:Connect(function()
                    if not listening then
                        Tween(kbBtn, 0.15, {BackgroundColor3 = Theme.SurfaceHover})
                    end
                end)
                kbBtn.MouseLeave:Connect(function()
                    if not listening then
                        Tween(kbBtn, 0.15, {BackgroundColor3 = Theme.SliderBg})
                    end
                end)

                kbBtn.MouseButton1Click:Connect(function()
                    listening = true
                    kbBtn.Text = "..."
                    Tween(kbBtn, 0.2, {BackgroundColor3 = Theme.AccentDark})
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            kbBtn.Text = currentKey.Name
                            listening = false
                            Tween(kbBtn, 0.2, {BackgroundColor3 = Theme.SliderBg})

                            -- Se for a flag "GUIToggle", atualiza a keybind global
                            if kFlag == "GUIToggle" then
                                _windowKeybind = currentKey
                            end
                        end
                    else
                        if not gameProcessed and input.KeyCode == currentKey then
                            kCallback()
                        end
                    end
                end)

                local KeybindAPI = {}
                function KeybindAPI:Set(key)
                    currentKey = key
                    kbBtn.Text = key.Name
                    if kFlag == "GUIToggle" then
                        _windowKeybind = key
                    end
                end
                function KeybindAPI:Get()
                    return currentKey
                end
                return KeybindAPI
            end

            return Section
        end

        return Tab
    end

    return Window
end

return GenarixUI

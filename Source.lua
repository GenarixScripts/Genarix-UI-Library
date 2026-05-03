--[[
    ╔══════════════════════════════════════════════╗
    ║            GENARIX UI LIBRARY                ║
    ║            Version: 2.4.0                    ║
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
local _activeToggles = {}
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

local function AddCorner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c end
local function AddStroke(p, color, thick, trans) local s = Instance.new("UIStroke"); s.Color = color or Theme.Border; s.Thickness = thick or 1; s.Transparency = trans or 0.5; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s end
local function AddPadding(p, t, b, l, r) local pd = Instance.new("UIPadding"); pd.PaddingTop = UDim.new(0,t or 0); pd.PaddingBottom = UDim.new(0,b or 0); pd.PaddingLeft = UDim.new(0,l or 0); pd.PaddingRight = UDim.new(0,r or 0); pd.Parent = p; return pd end
local function Tween(i, d, props, s, dir) local info = TweenInfo.new(d or 0.3, s or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out); local t = TweenService:Create(i, info, props); t:Play(); return t end
local function AddShadow(p) local s = Instance.new("ImageLabel"); s.AnchorPoint = Vector2.new(0.5,0.5); s.BackgroundTransparency = 1; s.Position = UDim2.new(0.5,0,0.5,4); s.Size = UDim2.new(1,35,1,35); s.ZIndex = -1; s.Image = "rbxassetid://6014261993"; s.ImageColor3 = Color3.fromRGB(0,0,0); s.ImageTransparency = 0.35; s.ScaleType = Enum.ScaleType.Slice; s.SliceCenter = Rect.new(49,49,450,450); s.Parent = p end
local function RegisterAccent(obj, prop) table.insert(_allAccentObjects, {Object = obj, Property = prop}) end

function GenarixUI:SetAccentColor(color)
    _currentAccentColor = color; Theme.Accent = color; Theme.ToggleOn = color
    local h, s, v = color:ToHSV()
    Theme.AccentDark = Color3.fromHSV(h, math.min(s+0.15,1), math.max(v-0.15,0))
    Theme.AccentGlow = Color3.fromHSV(h, math.max(s-0.15,0), math.min(v+0.1,1))
    for _, data in pairs(_allAccentObjects) do
        if data.Object and data.Object.Parent then pcall(function() data.Object[data.Property] = color end) end
    end
    for _, td in pairs(_activeToggles) do
        if td.switch and td.switch.Parent and td.getState() then td.switch.BackgroundColor3 = color end
    end
    for _, bd in pairs(_accentButtons) do
        if bd.btn and bd.btn.Parent then
            bd.btn.BackgroundColor3 = color
            for _, child in pairs(bd.btn:GetChildren()) do if child:IsA("UIStroke") then child.Color = color end end
        end
    end
end

function GenarixUI:GetAccentColor() return _currentAccentColor end
function GenarixUI:SetToggleKey(k) _windowKeybind = k end
function GenarixUI:GetToggleKey() return _windowKeybind end

-- NOTIFICATION
local NotifContainer = nil
local function EnsureNotifContainer(sg)
    if NotifContainer then return end
    NotifContainer = Instance.new("Frame"); NotifContainer.Size = UDim2.new(0,300,1,-20); NotifContainer.Position = UDim2.new(1,-310,0,10)
    NotifContainer.BackgroundTransparency = 1; NotifContainer.ZIndex = 100; NotifContainer.Parent = sg
    local l = Instance.new("UIListLayout"); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0,8); l.VerticalAlignment = Enum.VerticalAlignment.Bottom; l.Parent = NotifContainer
end

function GenarixUI:Notify(cfg)
    cfg = cfg or {}; local nt = cfg.Title or "Genarix"; local nc = cfg.Content or ""; local nd = cfg.Duration or 3
    if not NotifContainer then return end
    local n = Instance.new("Frame"); n.Size = UDim2.new(1,0,0,0); n.BackgroundColor3 = Theme.NotifBg; n.ClipsDescendants = true; n.ZIndex = 100; n.Parent = NotifContainer; AddCorner(n,10); AddStroke(n, _currentAccentColor, 1, 0.5)
    local ab = Instance.new("Frame"); ab.Size = UDim2.new(0,3,0.7,0); ab.Position = UDim2.new(0,8,0.15,0); ab.BackgroundColor3 = _currentAccentColor; ab.ZIndex = 101; ab.Parent = n; AddCorner(ab,2)
    local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(1,-25,0,18); tl.Position = UDim2.new(0,18,0,8); tl.BackgroundTransparency = 1; tl.Text = nt; tl.TextColor3 = _currentAccentColor; tl.TextSize = 13; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 101; tl.Parent = n
    local cl = Instance.new("TextLabel"); cl.Size = UDim2.new(1,-25,0,16); cl.Position = UDim2.new(0,18,0,28); cl.BackgroundTransparency = 1; cl.Text = nc; cl.TextColor3 = Theme.TextDim; cl.TextSize = 12; cl.Font = Enum.Font.Gotham; cl.TextXAlignment = Enum.TextXAlignment.Left; cl.TextWrapped = true; cl.ZIndex = 101; cl.Parent = n
    local pb = Instance.new("Frame"); pb.Size = UDim2.new(1,-20,0,2); pb.Position = UDim2.new(0,10,1,-8); pb.BackgroundColor3 = Theme.SliderBg; pb.ZIndex = 101; pb.Parent = n; AddCorner(pb,1)
    local pf = Instance.new("Frame"); pf.Size = UDim2.new(1,0,1,0); pf.BackgroundColor3 = _currentAccentColor; pf.ZIndex = 102; pf.Parent = pb; AddCorner(pf,1)
    Tween(n, 0.4, {Size = UDim2.new(1,0,0,60)})
    task.delay(0.4, function() Tween(pf, nd, {Size = UDim2.new(0,0,1,0)}, Enum.EasingStyle.Linear) end)
    task.delay(nd+0.5, function() Tween(n, 0.3, {Size = UDim2.new(1,0,0,0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In); task.wait(0.35); n:Destroy() end)
end

-- ================================================
-- CREATE WINDOW
-- ================================================
function GenarixUI:CreateWindow(cfg)
    cfg = cfg or {}; local windowName = cfg.Name or "Genarix UI"; local toggleKeybind = cfg.Keybind or Enum.KeyCode.K
    _windowKeybind = toggleKeybind
    local Window = {}; Window.Tabs = {}; Window.ActiveTab = nil; local _openDropdowns = {}

    local sg = Instance.new("ScreenGui"); sg.Name = "GenarixUI_"..windowName; sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() sg.Parent = game:GetService("CoreGui") end); if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    Window.ScreenGui = sg; EnsureNotifContainer(sg)

    local mf = Instance.new("Frame"); mf.Name = "MainFrame"; mf.Size = UDim2.new(0,550,0,400); mf.Position = UDim2.new(0.5,-275,0.5,-200)
    mf.BackgroundColor3 = Theme.Background; mf.BorderSizePixel = 0; mf.Active = true; mf.ClipsDescendants = true; mf.Parent = sg
    AddCorner(mf, 12); local ms = AddStroke(mf, _currentAccentColor, 1.5, 0.6); RegisterAccent(ms, "Color"); AddShadow(mf)
    Window.MainFrame = mf

    local hdr = Instance.new("Frame"); hdr.Size = UDim2.new(1,0,0,42); hdr.BackgroundColor3 = Theme.Header; hdr.BorderSizePixel = 0; hdr.Parent = mf; AddCorner(hdr, 12)
    local hf = Instance.new("Frame"); hf.Size = UDim2.new(1,0,0,14); hf.Position = UDim2.new(0,0,1,-14); hf.BackgroundColor3 = Theme.Header; hf.BorderSizePixel = 0; hf.Parent = hdr
    local sl = Instance.new("Frame"); sl.Size = UDim2.new(1,-20,0,2); sl.Position = UDim2.new(0,10,1,-1); sl.BackgroundColor3 = _currentAccentColor; sl.BorderSizePixel = 0; sl.Parent = hdr; AddCorner(sl,1); RegisterAccent(sl, "BackgroundColor3")
    local ic = Instance.new("TextLabel"); ic.Size = UDim2.new(0,28,0,28); ic.Position = UDim2.new(0,12,0.5,-14); ic.BackgroundColor3 = _currentAccentColor; ic.BackgroundTransparency = 0.85; ic.Text = string.sub(windowName,1,1); ic.TextColor3 = _currentAccentColor; ic.TextSize = 14; ic.Font = Enum.Font.GothamBold; ic.BorderSizePixel = 0; ic.Parent = hdr; AddCorner(ic,7); RegisterAccent(ic,"BackgroundColor3"); RegisterAccent(ic,"TextColor3")
    local ti = Instance.new("TextLabel"); ti.Size = UDim2.new(1,-130,1,0); ti.Position = UDim2.new(0,48,0,0); ti.BackgroundTransparency = 1; ti.Text = windowName; ti.TextColor3 = Theme.Text; ti.TextSize = 16; ti.Font = Enum.Font.GothamBold; ti.TextXAlignment = Enum.TextXAlignment.Left; ti.Parent = hdr

    local minBtn = Instance.new("TextButton"); minBtn.Size = UDim2.new(0,26,0,26); minBtn.Position = UDim2.new(1,-60,0.5,-13); minBtn.BackgroundColor3 = Theme.Minimize; minBtn.BackgroundTransparency = 0.85; minBtn.Text = "—"; minBtn.TextColor3 = Theme.Minimize; minBtn.TextSize = 14; minBtn.Font = Enum.Font.GothamBold; minBtn.BorderSizePixel = 0; minBtn.AutoButtonColor = false; minBtn.Parent = hdr; AddCorner(minBtn,6)
    local clsBtn = Instance.new("TextButton"); clsBtn.Size = UDim2.new(0,26,0,26); clsBtn.Position = UDim2.new(1,-32,0.5,-13); clsBtn.BackgroundColor3 = Theme.Close; clsBtn.BackgroundTransparency = 0.85; clsBtn.Text = "X"; clsBtn.TextColor3 = Theme.Close; clsBtn.TextSize = 13; clsBtn.Font = Enum.Font.GothamBold; clsBtn.BorderSizePixel = 0; clsBtn.AutoButtonColor = false; clsBtn.Parent = hdr; AddCorner(clsBtn,6)
    for _,b in pairs({minBtn,clsBtn}) do b.MouseEnter:Connect(function() Tween(b,0.2,{BackgroundTransparency=0.5}) end); b.MouseLeave:Connect(function() Tween(b,0.2,{BackgroundTransparency=0.85}) end) end

    local sb = Instance.new("Frame"); sb.Size = UDim2.new(0,135,1,-48); sb.Position = UDim2.new(0,0,0,44); sb.BackgroundColor3 = Theme.Surface; sb.BorderSizePixel = 0; sb.Parent = mf; AddCorner(sb,12)
    Instance.new("Frame", sb).Size = UDim2.new(1,0,0,14); sb:GetChildren()[#sb:GetChildren()].BackgroundColor3 = Theme.Surface; sb:GetChildren()[#sb:GetChildren()].BorderSizePixel = 0
    local sfr = Instance.new("Frame"); sfr.Size = UDim2.new(0,14,1,0); sfr.Position = UDim2.new(1,-14,0,0); sfr.BackgroundColor3 = Theme.Surface; sfr.BorderSizePixel = 0; sfr.Parent = sb
    local sep = Instance.new("Frame"); sep.Size = UDim2.new(0,1,1,-16); sep.Position = UDim2.new(1,0,0,8); sep.BackgroundColor3 = Theme.Border; sep.BackgroundTransparency = 0.5; sep.BorderSizePixel = 0; sep.Parent = sb

    local tbc = Instance.new("ScrollingFrame"); tbc.Size = UDim2.new(1,-12,1,-16); tbc.Position = UDim2.new(0,6,0,8); tbc.BackgroundTransparency = 1; tbc.ScrollBarThickness = 0; tbc.AutomaticCanvasSize = Enum.AutomaticSize.Y; tbc.Parent = sb
    local tbl = Instance.new("UIListLayout"); tbl.SortOrder = Enum.SortOrder.LayoutOrder; tbl.Padding = UDim.new(0,4); tbl.Parent = tbc

    local ca = Instance.new("Frame"); ca.Size = UDim2.new(1,-143,1,-52); ca.Position = UDim2.new(0,140,0,48); ca.BackgroundTransparency = 1; ca.Parent = mf

    -- DRAG
    local dg,di,ds,sp = false,nil,nil,nil
    hdr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true; ds=i.Position; sp=mf.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dg=false end end) end end)
    hdr.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then di=i end end)
    UserInputService.InputChanged:Connect(function(i) if i==di and dg then local d=i.Position-ds; mf.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)

    local minimized,storedPos = false,nil; local origSize = UDim2.new(0,550,0,400)
    local function doMin() minimized=true; storedPos=mf.Position; Tween(mf,0.4,{Size=UDim2.new(0,550,0,0),Position=UDim2.new(mf.Position.X.Scale,mf.Position.X.Offset,mf.Position.Y.Scale,mf.Position.Y.Offset+200)},Enum.EasingStyle.Quint,Enum.EasingDirection.In); task.delay(0.4,function() mf.Visible=false end); GenarixUI:Notify({Title="Minimizado",Content="Aperte '".._windowKeybind.Name.."' para maximizar",Duration=4}) end
    local function doMax() minimized=false; mf.Visible=true; local tp=storedPos or UDim2.new(0.5,-275,0.5,-200); mf.Position=UDim2.new(tp.X.Scale,tp.X.Offset,tp.Y.Scale,tp.Y.Offset+200); mf.Size=UDim2.new(0,550,0,0); Tween(mf,0.4,{Size=origSize,Position=tp}) end
    minBtn.MouseButton1Click:Connect(doMin)
    clsBtn.MouseButton1Click:Connect(function() Tween(mf,0.3,{Size=UDim2.new(0,550,0,0),Position=UDim2.new(mf.Position.X.Scale,mf.Position.X.Offset,mf.Position.Y.Scale,mf.Position.Y.Offset+200)},Enum.EasingStyle.Quint,Enum.EasingDirection.In); task.delay(0.35,function() sg:Destroy() end) end)
    UserInputService.InputBegan:Connect(function(i,gp) if gp then return end; if i.KeyCode==_windowKeybind then if minimized then doMax() else doMin() end end end)
    mf.Size=UDim2.new(0,550,0,0); mf.Position=UDim2.new(0.5,-275,0.5,0); task.delay(0.1,function() Tween(mf,0.5,{Size=origSize,Position=UDim2.new(0.5,-275,0.5,-200)}) end)
    local function closeAllDD() for _,dd in pairs(_openDropdowns) do if dd.close then dd.close() end end end

    -- ================================================
    -- CREATE TAB
    -- ================================================
    function Window:CreateTab(tc)
        tc = tc or {}; local tn = tc.Name or "Tab"; local tIcon = tc.Icon or ""
        local Tab = {}; Tab.Sections = {}; Tab.Name = tn

        local tabC = Instance.new("ScrollingFrame"); tabC.Size = UDim2.new(1,0,1,0); tabC.BackgroundTransparency = 1; tabC.ScrollBarThickness = 3
        tabC.ScrollBarImageColor3 = _currentAccentColor; tabC.AutomaticCanvasSize = Enum.AutomaticSize.Y; tabC.Visible = false; tabC.Parent = ca
        RegisterAccent(tabC, "ScrollBarImageColor3")
        local cL = Instance.new("UIListLayout"); cL.SortOrder = Enum.SortOrder.LayoutOrder; cL.Padding = UDim.new(0,8); cL.Parent = tabC; AddPadding(tabC,4,4,4,4)
        tabC:GetPropertyChangedSignal("CanvasPosition"):Connect(function() closeAllDD() end)

        local tBtn = Instance.new("TextButton"); tBtn.Size = UDim2.new(1,0,0,34); tBtn.BackgroundColor3 = Theme.TabInactive; tBtn.BackgroundTransparency = 0.5
        tBtn.Text = ""; tBtn.BorderSizePixel = 0; tBtn.AutoButtonColor = false; tBtn.LayoutOrder = #Window.Tabs+1; tBtn.Parent = tbc; AddCorner(tBtn,8)
        local ind = Instance.new("Frame"); ind.Size = UDim2.new(0,3,0.6,0); ind.Position = UDim2.new(0,0,0.2,0); ind.BackgroundColor3 = _currentAccentColor; ind.BackgroundTransparency = 1; ind.BorderSizePixel = 0; ind.Parent = tBtn; AddCorner(ind,2); RegisterAccent(ind,"BackgroundColor3")
        local iL = Instance.new("TextLabel"); iL.Size = UDim2.new(0,22,1,0); iL.Position = UDim2.new(0,8,0,0); iL.BackgroundTransparency = 1; iL.Text = tIcon; iL.TextColor3 = Theme.TextDim; iL.TextSize = 14; iL.Font = Enum.Font.Gotham; iL.Parent = tBtn
        local nL = Instance.new("TextLabel"); nL.Size = UDim2.new(1,-38,1,0); nL.Position = UDim2.new(0,32,0,0); nL.BackgroundTransparency = 1; nL.Text = tn; nL.TextColor3 = Theme.TextDim; nL.TextSize = 13; nL.Font = Enum.Font.GothamSemibold; nL.TextXAlignment = Enum.TextXAlignment.Left; nL.Parent = tBtn
        local td = {Content=tabC,Button=tBtn,Indicator=ind,NameLabel=nL,IconLabel=iL,Tab=Tab}; table.insert(Window.Tabs, td)

        local function actTab()
            closeAllDD()
            for _,t in pairs(Window.Tabs) do t.Content.Visible=false; Tween(t.Button,0.25,{BackgroundColor3=Theme.TabInactive,BackgroundTransparency=0.5}); Tween(t.Indicator,0.25,{BackgroundTransparency=1}); t.NameLabel.TextColor3=Theme.TextDim; t.IconLabel.TextColor3=Theme.TextDim end
            tabC.Visible=true; Tween(tBtn,0.25,{BackgroundColor3=Theme.SurfaceLight,BackgroundTransparency=0}); Tween(ind,0.25,{BackgroundTransparency=0}); nL.TextColor3=Theme.Text; iL.TextColor3=_currentAccentColor; Window.ActiveTab=Tab
        end
        tBtn.MouseButton1Click:Connect(actTab)
        tBtn.MouseEnter:Connect(function() if Window.ActiveTab~=Tab then Tween(tBtn,0.2,{BackgroundTransparency=0.3}) end end)
        tBtn.MouseLeave:Connect(function() if Window.ActiveTab~=Tab then Tween(tBtn,0.2,{BackgroundTransparency=0.5}) end end)
        if #Window.Tabs==1 then actTab() end

        function Tab:CreateSection(sName)
            sName = sName or "Section"; local Section = {}; local eOrd = 2
            local sF = Instance.new("Frame"); sF.Size = UDim2.new(1,0,0,0); sF.AutomaticSize = Enum.AutomaticSize.Y; sF.BackgroundColor3 = Theme.Surface; sF.LayoutOrder = #Tab.Sections+1; sF.Parent = tabC; AddCorner(sF,10); AddStroke(sF,Theme.Border,1,0.7); AddPadding(sF,10,10,12,12)
            local sL = Instance.new("UIListLayout"); sL.SortOrder = Enum.SortOrder.LayoutOrder; sL.Padding = UDim.new(0,7); sL.Parent = sF
            local sT = Instance.new("TextLabel"); sT.Size = UDim2.new(1,0,0,18); sT.BackgroundTransparency = 1; sT.Text = sName; sT.TextColor3 = _currentAccentColor; sT.TextSize = 12; sT.Font = Enum.Font.GothamBold; sT.TextXAlignment = Enum.TextXAlignment.Left; sT.LayoutOrder = 0; sT.Parent = sF; RegisterAccent(sT,"TextColor3")
            local tS = Instance.new("Frame"); tS.Size = UDim2.new(1,0,0,1); tS.BackgroundColor3 = Theme.Border; tS.BackgroundTransparency = 0.5; tS.LayoutOrder = 1; tS.Parent = sF
            table.insert(Tab.Sections, Section)

            function Section:CreateToggle(c)
                c = c or {}; local tg = c.Default or false; local cb = c.Callback or function() end; eOrd = eOrd+1
                local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,30); f.BackgroundTransparency = 1; f.LayoutOrder = eOrd; f.Parent = sF
                local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,-55,1,0); l.BackgroundTransparency = 1; l.Text = c.Name or "Toggle"; l.TextColor3 = Theme.Text; l.TextSize = 13; l.Font = Enum.Font.GothamSemibold; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
                local sw = Instance.new("TextButton"); sw.Size = UDim2.new(0,44,0,22); sw.Position = UDim2.new(1,-44,0.5,-11); sw.BackgroundColor3 = tg and _currentAccentColor or Theme.ToggleOff; sw.Text = ""; sw.AutoButtonColor = false; sw.Parent = f; AddCorner(sw,11)
                local ci = Instance.new("Frame"); ci.Size = UDim2.new(0,16,0,16); ci.Position = tg and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8); ci.BackgroundColor3 = tg and Color3.fromRGB(255,255,255) or Theme.TextDim; ci.Parent = sw; AddCorner(ci,8)
                table.insert(_activeToggles, {switch=sw, getState=function() return tg end})
                local function upd() if tg then Tween(sw,0.3,{BackgroundColor3=_currentAccentColor}); Tween(ci,0.3,{Position=UDim2.new(1,-19,0.5,-8),BackgroundColor3=Color3.fromRGB(255,255,255)}) else Tween(sw,0.3,{BackgroundColor3=Theme.ToggleOff}); Tween(ci,0.3,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=Theme.TextDim}) end; cb(tg) end
                sw.MouseButton1Click:Connect(function() tg = not tg; upd() end)
                sw.MouseEnter:Connect(function() if tg then Tween(sw,0.15,{BackgroundColor3=Theme.AccentGlow}) else Tween(sw,0.15,{BackgroundColor3=Theme.SurfaceHover}) end end)
                sw.MouseLeave:Connect(function() if tg then Tween(sw,0.15,{BackgroundColor3=_currentAccentColor}) else Tween(sw,0.15,{BackgroundColor3=Theme.ToggleOff}) end end)
                if c.Default then cb(true) end
                local A = {}; function A:Set(v) tg=v; upd() end; function A:Get() return tg end; return A
            end

            function Section:CreateSlider(c)
                c = c or {}; local mn,mx,inc = c.Min or 0, c.Max or 100, c.Increment or 1; local cv = c.Default or mn; local cb = c.Callback or function() end; eOrd = eOrd+1
                local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,48); f.BackgroundTransparency = 1; f.LayoutOrder = eOrd; f.Parent = sF
                local h = Instance.new("Frame"); h.Size = UDim2.new(1,0,0,18); h.BackgroundTransparency = 1; h.Parent = f
                local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(0.6,0,1,0); lb.BackgroundTransparency = 1; lb.Text = c.Name or "Slider"; lb.TextColor3 = Theme.Text; lb.TextSize = 13; lb.Font = Enum.Font.GothamSemibold; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.Parent = h
                local vl = Instance.new("TextLabel"); vl.Size = UDim2.new(0.4,0,1,0); vl.Position = UDim2.new(0.6,0,0,0); vl.BackgroundTransparency = 1; vl.Text = tostring(cv); vl.TextColor3 = _currentAccentColor; vl.TextSize = 13; vl.Font = Enum.Font.GothamBold; vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Parent = h; RegisterAccent(vl,"TextColor3")
                local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,0,6); bg.Position = UDim2.new(0,0,0,26); bg.BackgroundColor3 = Theme.SliderBg; bg.Parent = f; AddCorner(bg,3)
                local ir = math.clamp((cv-mn)/(mx-mn),0,1)
                local fl = Instance.new("Frame"); fl.Size = UDim2.new(ir,0,1,0); fl.BackgroundColor3 = _currentAccentColor; fl.Parent = bg; AddCorner(fl,3); RegisterAccent(fl,"BackgroundColor3")
                local kn = Instance.new("Frame"); kn.Size = UDim2.new(0,14,0,14); kn.Position = UDim2.new(ir,-7,0.5,-7); kn.BackgroundColor3 = Color3.fromRGB(255,255,255); kn.ZIndex = 3; kn.Parent = bg; AddCorner(kn,7); local ks = AddStroke(kn,_currentAccentColor,2,0); RegisterAccent(ks,"Color")
                local sl = false
                local function up(i) local r = math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1); local raw = mn+(mx-mn)*r; local v = math.floor(raw/inc+0.5)*inc; v = math.clamp(v,mn,mx); if inc>=1 then v=math.floor(v) else v=tonumber(string.format("%.2f",v)) end; local nr=(v-mn)/(mx-mn); cv=v; Tween(fl,0.08,{Size=UDim2.new(nr,0,1,0)}); Tween(kn,0.08,{Position=UDim2.new(nr,-7,0.5,-7)}); vl.Text=tostring(v); cb(v) end
                bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true; up(i) end end)
                kn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true end end)
                UserInputService.InputChanged:Connect(function(i) if sl and i.UserInputType==Enum.UserInputType.MouseMovement then up(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end end)
                cb(cv)
                local A = {}; function A:Set(v) v=math.clamp(v,mn,mx); cv=v; local r=(v-mn)/(mx-mn); Tween(fl,0.15,{Size=UDim2.new(r,0,1,0)}); Tween(kn,0.15,{Position=UDim2.new(r,-7,0.5,-7)}); vl.Text=tostring(v); cb(v) end; function A:Get() return cv end; return A
            end

            function Section:CreateKeybind(c)
                c = c or {}; local ck = c.Default or Enum.KeyCode.Unknown; local cit = "Keyboard"; local cb = c.Callback or function() end; local fl = c.Flag; local li = false; eOrd = eOrd+1
                if typeof(c.Default)=="EnumItem" then
                    if c.Default==Enum.UserInputType.MouseButton1 then cit="MouseButton1"; ck=nil
                    elseif c.Default==Enum.UserInputType.MouseButton2 then cit="MouseButton2"; ck=nil
                    elseif c.Default==Enum.UserInputType.MouseButton3 then cit="MouseButton3"; ck=nil end
                end
                local function gd() if cit=="MouseButton1" then return "Mouse1" elseif cit=="MouseButton2" then return "Mouse2" elseif cit=="MouseButton3" then return "Mouse3" elseif ck and ck~=Enum.KeyCode.Unknown then return ck.Name else return "None" end end
                local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,30); f.BackgroundTransparency = 1; f.LayoutOrder = eOrd; f.Parent = sF
                local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,-80,1,0); l.BackgroundTransparency = 1; l.Text = c.Name or "Keybind"; l.TextColor3 = Theme.Text; l.TextSize = 13; l.Font = Enum.Font.GothamSemibold; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
                local bn = Instance.new("TextButton"); bn.Size = UDim2.new(0,70,0,24); bn.Position = UDim2.new(1,-70,0.5,-12); bn.BackgroundColor3 = Theme.SliderBg; bn.Text = gd(); bn.TextColor3 = _currentAccentColor; bn.TextSize = 12; bn.Font = Enum.Font.GothamBold; bn.AutoButtonColor = false; bn.Parent = f; AddCorner(bn,6); AddStroke(bn,Theme.Border,1,0.6); RegisterAccent(bn,"TextColor3")
                bn.MouseEnter:Connect(function() if not li then Tween(bn,0.15,{BackgroundColor3=Theme.SurfaceHover}) end end)
                bn.MouseLeave:Connect(function() if not li then Tween(bn,0.15,{BackgroundColor3=Theme.SliderBg}) end end)
                bn.MouseButton1Click:Connect(function() li=true; bn.Text="..."; Tween(bn,0.2,{BackgroundColor3=Theme.AccentDark}) end)
                UserInputService.InputBegan:Connect(function(i,gp)
                    if li then
                        if i.UserInputType==Enum.UserInputType.Keyboard then ck=i.KeyCode; cit="Keyboard"; bn.Text=gd(); li=false; Tween(bn,0.2,{BackgroundColor3=Theme.SliderBg}); if fl=="GUIToggle" then _windowKeybind=ck end
                        elseif i.UserInputType==Enum.UserInputType.MouseButton2 then ck=nil; cit="MouseButton2"; bn.Text=gd(); li=false; Tween(bn,0.2,{BackgroundColor3=Theme.SliderBg})
                        elseif i.UserInputType==Enum.UserInputType.MouseButton3 then ck=nil; cit="MouseButton3"; bn.Text=gd(); li=false; Tween(bn,0.2,{BackgroundColor3=Theme.SliderBg}) end
                    else
                        if not gp then local fire=false; if cit=="Keyboard" and ck and i.KeyCode==ck then fire=true elseif cit=="MouseButton2" and i.UserInputType==Enum.UserInputType.MouseButton2 then fire=true elseif cit=="MouseButton3" and i.UserInputType==Enum.UserInputType.MouseButton3 then fire=true end; if fire then cb() end end
                    end
                end)
                local A = {}
                function A:Set(k) if typeof(k)=="EnumItem" then if k==Enum.UserInputType.MouseButton1 then cit="MouseButton1";ck=nil elseif k==Enum.UserInputType.MouseButton2 then cit="MouseButton2";ck=nil elseif k==Enum.UserInputType.MouseButton3 then cit="MouseButton3";ck=nil else cit="Keyboard";ck=k end end; bn.Text=gd(); if fl=="GUIToggle" and ck then _windowKeybind=ck end end
                function A:Get() return ck or cit end; function A:GetInputType() return cit end; return A
            end

            function Section:CreateButton(c)
                c = c or {}; local cb = c.Callback or function() end; eOrd = eOrd+1
                local bn = Instance.new("TextButton"); bn.Size = UDim2.new(1,0,0,32); bn.BackgroundColor3 = _currentAccentColor; bn.BackgroundTransparency = 0.8; bn.Text = c.Name or "Button"; bn.TextColor3 = Theme.Text; bn.TextSize = 13; bn.Font = Enum.Font.GothamSemibold; bn.AutoButtonColor = false; bn.LayoutOrder = eOrd; bn.Parent = sF; AddCorner(bn,8)
                local bStr = AddStroke(bn, _currentAccentColor, 1, 0.5)
                RegisterAccent(bn, "BackgroundColor3"); RegisterAccent(bStr, "Color")
                table.insert(_accentButtons, {btn=bn})
                bn.MouseEnter:Connect(function() Tween(bn,0.2,{BackgroundTransparency=0.5}) end)
                bn.MouseLeave:Connect(function() Tween(bn,0.2,{BackgroundTransparency=0.8}) end)
                bn.MouseButton1Click:Connect(function() Tween(bn,0.1,{BackgroundTransparency=0.2}); task.delay(0.15,function() Tween(bn,0.2,{BackgroundTransparency=0.8}) end); cb() end)
            end

            function Section:CreateDropdown(c)
                c = c or {}; local opts = c.Options or {}; local cur = c.Default or (opts[1] or "None"); local cb = c.Callback or function() end; local isO = false; eOrd = eOrd+1
                local did = tostring(eOrd)..tn..sName
                local dF = Instance.new("Frame"); dF.Size = UDim2.new(1,0,0,30); dF.BackgroundTransparency = 1; dF.LayoutOrder = eOrd; dF.ZIndex = 50; dF.Parent = sF
                local dL = Instance.new("TextLabel"); dL.Size = UDim2.new(0.5,0,0,30); dL.BackgroundTransparency = 1; dL.Text = c.Name or "Dropdown"; dL.TextColor3 = Theme.Text; dL.TextSize = 13; dL.Font = Enum.Font.GothamSemibold; dL.TextXAlignment = Enum.TextXAlignment.Left; dL.ZIndex = 50; dL.Parent = dF
                local dB = Instance.new("TextButton"); dB.Size = UDim2.new(0.48,0,0,26); dB.Position = UDim2.new(0.52,0,0,2); dB.BackgroundColor3 = Theme.SliderBg; dB.Text = tostring(cur).." ▾"; dB.TextColor3 = _currentAccentColor; dB.TextSize = 12; dB.Font = Enum.Font.GothamBold; dB.AutoButtonColor = false; dB.ZIndex = 51; dB.Parent = dF; AddCorner(dB,6); AddStroke(dB,Theme.Border,1,0.6); RegisterAccent(dB,"TextColor3")

                local oF = Instance.new("Frame"); oF.BackgroundColor3 = Color3.fromRGB(22,22,28); oF.BorderSizePixel = 0; oF.ClipsDescendants = true; oF.ZIndex = 200; oF.Visible = false; oF.Size = UDim2.new(0,0,0,0); oF.Parent = sg; AddCorner(oF,8)
                local oStroke = AddStroke(oF, _currentAccentColor, 1, 0.4)
                RegisterAccent(oStroke, "Color")
                local oL = Instance.new("UIListLayout"); oL.SortOrder = Enum.SortOrder.LayoutOrder; oL.Padding = UDim.new(0,2); oL.Parent = oF; AddPadding(oF,4,4,4,4)

                local function clDD() if not isO then return end; isO=false; Tween(oF,0.2,{Size=UDim2.new(0,dB.AbsoluteSize.X,0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.In); task.delay(0.2,function() oF.Visible=false end); dB.Text=tostring(cur).." ▾"; _openDropdowns[did]=nil end
                local function opDD() closeAllDD(); isO=true; local ap=dB.AbsolutePosition; local as=dB.AbsoluteSize; oF.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+4); oF.Size=UDim2.new(0,as.X,0,0); oF.Visible=true; Tween(oF,0.25,{Size=UDim2.new(0,as.X,0,#opts*28+10)}); dB.Text=tostring(cur).." ▴"; _openDropdowns[did]={close=clDD} end

                for i,opt in ipairs(opts) do
                    local ob = Instance.new("TextButton"); ob.Size = UDim2.new(1,0,0,26); ob.BackgroundColor3 = Theme.SurfaceHover; ob.BackgroundTransparency = 0.8; ob.Text = tostring(opt); ob.TextColor3 = Theme.Text; ob.TextSize = 12; ob.Font = Enum.Font.Gotham; ob.AutoButtonColor = false; ob.LayoutOrder = i; ob.ZIndex = 201; ob.Parent = oF; AddCorner(ob,4)
                    ob.MouseEnter:Connect(function() Tween(ob,0.15,{BackgroundTransparency=0.3,BackgroundColor3=_currentAccentColor}) end)
                    ob.MouseLeave:Connect(function() Tween(ob,0.15,{BackgroundTransparency=0.8,BackgroundColor3=Theme.SurfaceHover}) end)
                    ob.MouseButton1Click:Connect(function() cur=opt; clDD(); cb(opt) end)
                end
                dB.MouseButton1Click:Connect(function() if isO then clDD() else opDD() end end)
                dB.MouseEnter:Connect(function() Tween(dB,0.15,{BackgroundColor3=Theme.SurfaceHover}) end)
                dB.MouseLeave:Connect(function() Tween(dB,0.15,{BackgroundColor3=Theme.SliderBg}) end)
                local A = {}; function A:Set(v) cur=v; dB.Text=tostring(v).." ▾"; cb(v) end; function A:Get() return cur end; return A
            end

            function Section:CreateLabel(text)
                eOrd = eOrd+1; local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,0,0,20); l.BackgroundTransparency = 1; l.Text = text or ""; l.TextColor3 = Theme.TextDim; l.TextSize = 12; l.Font = Enum.Font.Gotham; l.TextWrapped = true; l.TextXAlignment = Enum.TextXAlignment.Left; l.LayoutOrder = eOrd; l.Parent = sF
                local A = {}; function A:Set(t) l.Text = t end; return A
            end

            return Section
        end
        return Tab
    end
    return Window
end

return GenarixUI

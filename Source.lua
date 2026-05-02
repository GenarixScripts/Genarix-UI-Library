--[[
    ╔══════════════════════════════════════════════╗
    ║            GENARIX UI LIBRARY                ║
    ║            Version: 1.0.0                    ║
    ║            Creator: Genarix                  ║
    ╚══════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GenarixUI = {}
GenarixUI.__index = GenarixUI

local Theme = {
    Background     = Color3.fromRGB(16, 16, 20),
    Header         = Color3.fromRGB(10, 10, 14),
    Accent         = Color3.fromRGB(130, 80, 255),
    AccentDark     = Color3.fromRGB(90, 50, 200),
    AccentGlow     = Color3.fromRGB(160, 110, 255),
    Surface        = Color3.fromRGB(24, 24, 30),
    SurfaceLight   = Color3.fromRGB(32, 32, 40),
    SurfaceHover   = Color3.fromRGB(40, 40, 50),
    Text           = Color3.fromRGB(230, 230, 240),
    TextDim        = Color3.fromRGB(130, 130, 150),
    Border         = Color3.fromRGB(45, 45, 60),
    SliderBg       = Color3.fromRGB(35, 35, 45),
    Toggle_On      = Color3.fromRGB(130, 80, 255),
    Toggle_Off     = Color3.fromRGB(45, 45, 55),
    NotifBg        = Color3.fromRGB(20, 20, 26),
    TabInactive    = Color3.fromRGB(24, 24, 30),
}

-- [ FUNÇÕES INTERNAS ] --
local function AddCorner(i, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = i
    return c
end

local function AddStroke(i, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thick or 1
    s.Transparency = trans or 0.5
    s.Parent = i
    return s
end

local function Tween(i, d, p, s, dir)
    local info = TweenInfo.new(d or 0.3, s or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(i, info, p)
    t:Play()
    return t
end

-- [ NOTIFICATION SYSTEM ] --
local NotifContainer = nil
local function EnsureNotifContainer(sg)
    if NotifContainer then return end
    NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 300, 1, -20)
    NotifContainer.Position = UDim2.new(1, -310, 0, 10)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = sg
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 8)
    l.VerticalAlignment = Enum.VerticalAlignment.Bottom
    l.Parent = NotifContainer
end

function GenarixUI:Notify(cfg)
    local t = cfg.Title or "Genarix UI"
    local c = cfg.Content or ""
    local d = cfg.Duration or 3
    if not NotifContainer then return end
    local n = Instance.new("Frame")
    n.Size = UDim2.new(1, 0, 0, 0); n.BackgroundColor3 = Theme.NotifBg; n.ClipsDescendants = true; n.Parent = NotifContainer
    AddCorner(n, 10); AddStroke(n, Theme.Accent, 1, 0.5)
    local a = Instance.new("Frame"); a.Size = UDim2.new(0, 3, 0.7, 0); a.Position = UDim2.new(0, 8, 0.15, 0); a.BackgroundColor3 = Theme.Accent; a.Parent = n; AddCorner(a, 2)
    local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(1, -25, 0, 18); tl.Position = UDim2.new(0, 18, 0, 8); tl.BackgroundTransparency = 1; tl.Text = t; tl.TextColor3 = Theme.Accent; tl.Font = Enum.Font.GothamBold; tl.TextSize = 13; tl.TextXAlignment = 0; tl.Parent = n
    local cl = Instance.new("TextLabel"); cl.Size = UDim2.new(1, -25, 0, 16); cl.Position = UDim2.new(0, 18, 0, 28); cl.BackgroundTransparency = 1; cl.Text = c; cl.TextColor3 = Theme.TextDim; cl.Font = Enum.Font.Gotham; cl.TextSize = 12; cl.TextXAlignment = 0; cl.TextWrapped = true; cl.Parent = n
    local pb = Instance.new("Frame"); pb.Size = UDim2.new(1, -20, 0, 2); pb.Position = UDim2.new(0, 10, 1, -8); pb.BackgroundColor3 = Theme.SliderBg; pb.Parent = n; AddCorner(pb, 1)
    local pf = Instance.new("Frame"); pf.Size = UDim2.new(1, 0, 1, 0); pf.BackgroundColor3 = Theme.Accent; pf.Parent = pb; AddCorner(pf, 1)
    Tween(n, 0.4, {Size = UDim2.new(1, 0, 0, 60)})
    task.delay(0.4, function() Tween(pf, d, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear) end)
    task.delay(d + 0.5, function() Tween(n, 0.3, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In) task.wait(0.35); n:Destroy() end)
end

-- [ WINDOW ] --
function GenarixUI:CreateWindow(cfg)
    local windowName = cfg.Name or "Genarix UI"
    local toggleKey = cfg.Keybind or Enum.KeyCode.K
    local Window = {Tabs = {}, ActiveTab = nil}
    
    local sg = Instance.new("ScreenGui"); sg.Name = "GenarixUI"; sg.ResetOnSpawn = false; pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    EnsureNotifContainer(sg)
    
    local mf = Instance.new("Frame"); mf.Size = UDim2.new(0, 520, 0, 380); mf.Position = UDim2.new(0.5, -260, 0.5, -190); mf.BackgroundColor3 = Theme.Background; mf.Active = true; mf.Parent = sg; AddCorner(mf, 12); AddStroke(mf, Theme.Accent, 1.5, 0.6)
    
    local h = Instance.new("Frame"); h.Size = UDim2.new(1, 0, 0, 42); h.BackgroundColor3 = Theme.Header; h.Parent = mf; AddCorner(h, 12)
    local hf = Instance.new("Frame"); hf.Size = UDim2.new(1, 0, 0, 14); hf.Position = UDim2.new(0, 0, 1, -14); hf.BackgroundColor3 = Theme.Header; hf.BorderSizePixel = 0; hf.Parent = h
    local tit = Instance.new("TextLabel"); tit.Size = UDim2.new(1, -100, 1, 0); tit.Position = UDim2.new(0, 15, 0, 0); tit.BackgroundTransparency = 1; tit.Text = windowName; tit.TextColor3 = Theme.Text; tit.Font = Enum.Font.GothamBold; tit.TextSize = 16; tit.TextXAlignment = 0; tit.Parent = h
    
    local cls = Instance.new("TextButton"); cls.Size = UDim2.new(0, 26, 0, 26); cls.Position = UDim2.new(1, -32, 0.5, -13); cls.BackgroundColor3 = Theme.Red; cls.BackgroundTransparency = 0.8; cls.Text = "X"; cls.TextColor3 = Theme.Red; cls.Parent = h; AddCorner(cls, 6)
    cls.MouseButton1Click:Connect(function() sg:Destroy() end)

    local tb = Instance.new("Frame"); tb.Size = UDim2.new(0, 130, 1, -48); tb.Position = UDim2.new(0, 0, 0, 44); tb.BackgroundColor3 = Theme.Surface; tb.Parent = mf; AddCorner(tb, 12)
    local tbc = Instance.new("ScrollingFrame"); tbc.Size = UDim2.new(1, -12, 1, -16); tbc.Position = UDim2.new(0, 6, 0, 8); tbc.BackgroundTransparency = 1; tbc.ScrollBarThickness = 0; tbc.Parent = tb
    Instance.new("UIListLayout").Parent = tbc; tbc.UIListLayout.Padding = UDim.new(0, 4)
    
    local ca = Instance.new("Frame"); ca.Size = UDim2.new(1, -138, 1, -52); ca.Position = UDim2.new(0, 135, 0, 48); ca.BackgroundTransparency = 1; ca.Parent = mf
    
    -- Dragging
    local d, di, ds, sp = false, nil, nil, nil
    h.InputBegan:Connect(function(i) if i.UserInputType == Enum.KeyCode.Unknown or i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = mf.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - ds; mf.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

    function Window:CreateTab(tcfg)
        local tabName = tcfg.Name or "Tab"
        local tc = Instance.new("ScrollingFrame"); tc.Size = UDim2.new(1, 0, 1, 0); tc.BackgroundTransparency = 1; tc.ScrollBarThickness = 2; tc.Visible = false; tc.Parent = ca
        Instance.new("UIListLayout").Parent = tc; tc.UIListLayout.Padding = UDim.new(0, 8)
        
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = Theme.TabInactive; btn.Text = tabName; btn.TextColor3 = Theme.TextDim; btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13; btn.Parent = tbc; AddCorner(btn, 6)
        
        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(Window.Tabs) do v.tc.Visible = false; v.btn.TextColor3 = Theme.TextDim; v.btn.BackgroundColor3 = Theme.TabInactive end
            tc.Visible = true; btn.TextColor3 = Theme.Text; btn.BackgroundColor3 = Theme.SurfaceLight
        end)
        
        local Tab = {tc = tc, btn = btn}
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then tc.Visible = true; btn.TextColor3 = Theme.Text; btn.BackgroundColor3 = Theme.SurfaceLight end

        function Tab:CreateSection(sName)
            local s = Instance.new("Frame"); s.Size = UDim2.new(1, 0, 0, 0); s.AutomaticSize = 2; s.BackgroundColor3 = Theme.Surface; s.Parent = tc; AddCorner(s, 10); AddStroke(s, Theme.Border, 1, 0.7)
            local l = Instance.new("UIListLayout"); l.Padding = UDim.new(0, 7); l.Parent = s
            local p = Instance.new("UIPadding"); p.PaddingTop = UDim.new(0, 10); p.PaddingBottom = UDim.new(0, 10); p.PaddingLeft = UDim.new(0, 12); p.PaddingRight = UDim.new(0, 12); p.Parent = s
            local st = Instance.new("TextLabel"); st.Size = UDim2.new(1, 0, 0, 18); st.BackgroundTransparency = 1; st.Text = sName; st.TextColor3 = Theme.Accent; st.Font = 17; st.TextSize = 12; st.TextXAlignment = 0; st.Parent = s
            
            local Section = {}
            function Section:CreateToggle(tcfg)
                local tFrame = Instance.new("Frame"); tFrame.Size = UDim2.new(1, 0, 0, 30); tFrame.BackgroundTransparency = 1; tFrame.Parent = s
                local tLabel = Instance.new("TextLabel"); tLabel.Size = UDim2.new(1, -50, 1, 0); tLabel.BackgroundTransparency = 1; tLabel.Text = tcfg.Name; tLabel.TextColor3 = Theme.Text; tLabel.Font = 17; tLabel.TextSize = 13; tLabel.TextXAlignment = 0; tLabel.Parent = tFrame
                local sw = Instance.new("TextButton"); sw.Size = UDim2.new(0, 40, 0, 20); sw.Position = UDim2.new(1, -40, 0.5, -10); sw.BackgroundColor3 = Theme.Toggle_Off; sw.Text = ""; sw.Parent = tFrame; AddCorner(sw, 10)
                local circ = Instance.new("Frame"); circ.Size = UDim2.new(0, 14, 0, 14); circ.Position = UDim2.new(0, 3, 0.5, -7); circ.BackgroundColor3 = Theme.TextDim; circ.Parent = sw; AddCorner(circ, 7)
                local toggled = tcfg.Default or false
                local function up() 
                    Tween(sw, 0.3, {BackgroundColor3 = toggled and Theme.Toggle_On or Theme.Toggle_Off})
                    Tween(circ, 0.3, {Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
                    tcfg.Callback(toggled)
                end
                sw.MouseButton1Click:Connect(function() toggled = not toggled; up() end); up()
            end

            function Section:CreateSlider(scfg)
                local slF = Instance.new("Frame"); slF.Size = UDim2.new(1, 0, 0, 45); slF.BackgroundTransparency = 1; slF.Parent = s
                local slL = Instance.new("TextLabel"); slL.Size = UDim2.new(1, 0, 0, 20); slL.BackgroundTransparency = 1; slL.Text = scfg.Name; slL.TextColor3 = Theme.Text; slL.Font = 17; slL.TextSize = 13; slL.TextXAlignment = 0; slL.Parent = slF
                local valL = Instance.new("TextLabel"); valL.Size = UDim2.new(1, 0, 0, 20); valL.BackgroundTransparency = 1; valL.Text = tostring(scfg.Default); valL.TextColor3 = Theme.Accent; valL.Font = 17; valL.TextSize = 13; valL.TextXAlignment = 1; valL.Parent = slF
                local sBg = Instance.new("Frame"); sBg.Size = UDim2.new(1, 0, 0, 6); sBg.Position = UDim2.new(0, 0, 1, -10); sBg.BackgroundColor3 = Theme.SliderBg; sBg.Parent = slF; AddCorner(sBg, 3)
                local sFi = Instance.new("Frame"); sFi.Size = UDim2.new((scfg.Default-scfg.Min)/(scfg.Max-scfg.Min), 0, 1, 0); sFi.BackgroundColor3 = Theme.Accent; sFi.Parent = sBg; AddCorner(sFi, 3)
                local move = false
                local function upd(i)
                    local r = math.clamp((i.Position.X - sBg.AbsolutePosition.X)/sBg.AbsoluteSize.X, 0, 1)
                    local v = math.floor(scfg.Min + (scfg.Max - scfg.Min) * r)
                    valL.Text = tostring(v); sFi.Size = UDim2.new(r, 0, 1, 0); scfg.Callback(v)
                end
                sBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move = true; upd(i) end end)
                UserInputService.InputChanged:Connect(function(i) if move and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move = false end end)
            end

            function Section:CreateKeybind(kcfg)
                local kF = Instance.new("Frame"); kF.Size = UDim2.new(1, 0, 0, 30); kF.BackgroundTransparency = 1; kF.Parent = s
                local kL = Instance.new("TextLabel"); kL.Size = UDim2.new(1, -70, 1, 0); kL.BackgroundTransparency = 1; kL.Text = kcfg.Name; kL.TextColor3 = Theme.Text; kL.Font = 17; kL.TextSize = 13; kL.TextXAlignment = 0; kL.Parent = kF
                local kB = Instance.new("TextButton"); kB.Size = UDim2.new(0, 70, 0, 24); kB.Position = UDim2.new(1, -70, 0.5, -12); kB.BackgroundColor3 = Theme.SliderBg; kB.Text = kcfg.Default.Name; kB.TextColor3 = Theme.Accent; kB.Parent = kF; AddCorner(kB, 6)
                local list = false; local curr = kcfg.Default
                kB.MouseButton1Click:Connect(function() list = true; kB.Text = "..." end)
                UserInputService.InputBegan:Connect(function(i, g) if list and i.UserInputType == Enum.UserInputType.Keyboard then curr = i.KeyCode; kB.Text = curr.Name; list = false elseif not g and i.KeyCode == curr then kcfg.Callback() end end)
            end
            return Section
        end
        return Tab
    end
    return Window
end

return GenarixUI

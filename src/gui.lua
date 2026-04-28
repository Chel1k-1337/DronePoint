local GUI = {}
local Settings = nil
local Utils = nil

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ColorPresets = {
    {Name = "Red", Color = Color3.fromRGB(255, 50, 50)},
    {Name = "Green", Color = Color3.fromRGB(50, 255, 50)},
    {Name = "Blue", Color = Color3.fromRGB(50, 150, 255)},
    {Name = "Yellow", Color = Color3.fromRGB(255, 255, 50)},
    {Name = "Orange", Color = Color3.fromRGB(255, 150, 50)},
    {Name = "White", Color = Color3.fromRGB(255, 255, 255)}
}

function GUI.Init(settingsRef, utilsRef)
    Settings = settingsRef
    Utils = utilsRef
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DronePoint_Premium_v2"
    ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 120, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
    
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(1, 0, 0, 50)
    Logo.BackgroundTransparency = 1
    Logo.Text = "DRONEPOINT"
    Logo.TextColor3 = Color3.fromRGB(255, 80, 80)
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 14
    Logo.Parent = Sidebar

    local NavList = Instance.new("Frame")
    NavList.Size = UDim2.new(1, 0, 1, -60)
    NavList.Position = UDim2.new(0, 0, 0, 50)
    NavList.BackgroundTransparency = 1
    NavList.Parent = Sidebar
    local layout = Instance.new("UIListLayout", NavList)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 5)

    -- Container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -130, 1, -20)
    Container.Position = UDim2.new(0, 125, 0, 10)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local function CreateTabBtn(name)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.9, 0, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        b.Text = name
        b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 12
        b.Parent = NavList
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        return b
    end

    local Tabs = { Drones = CreateTabBtn("Drones"), Rockets = CreateTabBtn("Rockets"), Players = CreateTabBtn("Players"), Settings = CreateTabBtn("Settings") }
    
    local function CreateContent()
        local c = Instance.new("ScrollingFrame")
        c.Size = UDim2.new(1, 0, 1, 0)
        c.BackgroundTransparency = 1
        c.ScrollBarThickness = 2
        c.CanvasSize = UDim2.new(0, 0, 1.5, 0)
        c.Visible = false
        c.Parent = Container
        local l = Instance.new("UIListLayout", c)
        l.Padding = UDim.new(0, 10)
        return c
    end

    local Contents = { Drones = CreateContent(), Rockets = CreateContent(), Players = CreateContent(), Settings = CreateContent() }

    local function Switch(n)
        for k, v in pairs(Contents) do v.Visible = (k == n) end
        for k, v in pairs(Tabs) do
            v.BackgroundColor3 = (k == n and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(30, 30, 35))
            v.TextColor3 = (k == n and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8))
        end
    end
    for k, v in pairs(Tabs) do v.MouseButton1Click:Connect(function() Switch(k) end) end
    Switch("Drones")

    Utils.MakeDraggable(Logo, MainFrame)

    local function CreateToggle(n, p, c, d)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.95, 0, 0, 40)
        f.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        f.Parent = p
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6, 0, 1, 0)
        l.Position = UDim2.new(0.05, 0, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = n
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 34, 0, 18)
        b.Position = UDim2.new(0.95, -34, 0.5, -9)
        b.BackgroundColor3 = d and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(50, 50, 55)
        b.Text = ""
        b.Parent = f
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        local a = d
        b.MouseButton1Click:Connect(function()
            a = not a
            b.BackgroundColor3 = a and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(50, 50, 55)
            c(a)
        end)
    end

    local function CreateColorSelector(p, config)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.95, 0, 0, 25)
        f.BackgroundTransparency = 1
        f.Parent = p
        for i, preset in ipairs(ColorPresets) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.14, 0, 1, 0)
            b.Position = UDim2.new((i-1)*0.16, 0, 0, 0)
            b.BackgroundColor3 = preset.Color
            b.Text = ""
            b.Parent = f
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(function() config.Color = preset.Color end)
        end
    end

    -- Setup
    CreateToggle("FPV Drone", Contents.Drones, function(v) Settings.Drones.FPV.Enabled = v end, Settings.Drones.FPV.Enabled)
    CreateColorSelector(Contents.Drones, Settings.Drones.FPV)
    CreateToggle("Bober", Contents.Drones, function(v) Settings.Drones.Bober.Enabled = v end, Settings.Drones.Bober.Enabled)
    CreateToggle("Shahed 136", Contents.Drones, function(v) Settings.Drones.Shahed136.Enabled = v end, Settings.Drones.Shahed136.Enabled)
    CreateToggle("Gerbera", Contents.Drones, function(v) Settings.Drones.Gerbera.Enabled = v end, Settings.Drones.Gerbera.Enabled)
    CreateToggle("Lancet", Contents.Drones, function(v) Settings.Drones.Lancet.Enabled = v end, Settings.Drones.Lancet.Enabled)
    
    CreateToggle("All Missiles", Contents.Rockets, function(v) Settings.Rockets.Missile.Enabled = v end, Settings.Rockets.Missile.Enabled)
    CreateColorSelector(Contents.Rockets, Settings.Rockets.Missile)
    
    CreateToggle("Enable Player ESP", Contents.Players, function(v) Settings.Players.Enabled = v end, Settings.Players.Enabled)
    CreateColorSelector(Contents.Players, Settings.Players)

    local StyleBtn = Instance.new("TextButton")
    StyleBtn.Size = UDim2.new(0.95, 0, 0, 35)
    StyleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    StyleBtn.Text = "RENDER: " .. Settings.Visuals.Style:upper()
    StyleBtn.TextColor3 = Color3.new(1, 1, 1)
    StyleBtn.Font = Enum.Font.GothamBold
    StyleBtn.TextSize = 11
    StyleBtn.Parent = Contents.Settings
    Instance.new("UICorner", StyleBtn).CornerRadius = UDim.new(0, 6)
    StyleBtn.MouseButton1Click:Connect(function()
        Settings.Visuals.Style = (Settings.Visuals.Style == "Highlight" and "Box" or "Highlight")
        StyleBtn.Text = "RENDER: " .. Settings.Visuals.Style:upper()
    end)

    local BoxStyleBtn = Instance.new("TextButton")
    BoxStyleBtn.Size = UDim2.new(0.95, 0, 0, 35)
    BoxStyleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    BoxStyleBtn.Text = "BOX STYLE: " .. Settings.Visuals.BoxStyle:upper()
    BoxStyleBtn.TextColor3 = Color3.new(1, 1, 1)
    BoxStyleBtn.Font = Enum.Font.GothamBold
    BoxStyleBtn.TextSize = 11
    BoxStyleBtn.Parent = Contents.Settings
    Instance.new("UICorner", BoxStyleBtn).CornerRadius = UDim.new(0, 6)
    BoxStyleBtn.MouseButton1Click:Connect(function()
        Settings.Visuals.BoxStyle = (Settings.Visuals.BoxStyle == "Corners" and "Full" or "Corners")
        BoxStyleBtn.Text = "BOX STYLE: " .. Settings.Visuals.BoxStyle:upper()
    end)
    
    CreateToggle("Box Outline", Contents.Settings, function(v) Settings.Visuals.ShowOutline = v end, Settings.Visuals.ShowOutline)
    
    CreateToggle("Universal ESP", Contents.Settings, function(v) Settings.Universal.Enabled = v end, Settings.Universal.Enabled)

    local Unload = Instance.new("TextButton")
    Unload.Size = UDim2.new(0.9, 0, 0, 30)
    Unload.Position = UDim2.new(0.05, 0, 1, -35)
    Unload.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    Unload.Text = "UNLOAD"
    Unload.TextColor3 = Color3.new(1, 0.4, 0.4)
    Unload.Font = Enum.Font.GothamBold
    Unload.TextSize = 10
    Unload.Parent = Sidebar
    Instance.new("UICorner", Unload).CornerRadius = UDim.new(0, 6)
    Unload.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    return ScreenGui
end

return GUI

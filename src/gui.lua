local GUI = {}
local Settings = nil
local Utils = nil

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ColorPresets = {
    {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
    {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
    {Name = "Blue", Color = Color3.fromRGB(0, 100, 255)},
    {Name = "Yellow", Color = Color3.fromRGB(255, 255, 0)},
    {Name = "Orange", Color = Color3.fromRGB(255, 165, 0)},
    {Name = "White", Color = Color3.fromRGB(255, 255, 255)}
}

function GUI.Init(settingsRef, utilsRef)
    Settings = settingsRef
    Utils = utilsRef
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DronePoint_Premium"
    ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "DRONEPOINT ULTIMATE"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    Utils.MakeDraggable(Header, MainFrame)
    
    -- Navigation
    local Nav = Instance.new("Frame")
    Nav.Size = UDim2.new(1, 0, 0, 35)
    Nav.Position = UDim2.new(0, 0, 0, 50)
    Nav.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
    Nav.Parent = MainFrame
    
    local function CreateTab(name, x, w)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(w, 0, 1, 0)
        b.Position = UDim2.new(x, 0, 0, 0)
        b.BackgroundTransparency = 1
        b.Text = name:upper()
        b.TextColor3 = Color3.new(0.6, 0.6, 0.6)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.Parent = Nav
        return b
    end
    
    local Tabs = {
        Drones = CreateTab("Drones", 0, 0.25),
        Rockets = CreateTab("Rockets", 0.25, 0.25),
        Settings = CreateTab("Settings", 0.5, 0.25),
        Debug = CreateTab("Debug", 0.75, 0.25)
    }
    
    local function CreateContent()
        local c = Instance.new("ScrollingFrame")
        c.Size = UDim2.new(1, -10, 1, -135)
        c.Position = UDim2.new(0, 5, 0, 95)
        c.BackgroundTransparency = 1
        c.ScrollBarThickness = 0
        c.CanvasSize = UDim2.new(0, 0, 2, 0)
        c.Visible = false
        c.Parent = MainFrame
        local layout = Instance.new("UIListLayout", c)
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        return c
    end
    
    local Contents = { Drones = CreateContent(), Rockets = CreateContent(), Settings = CreateContent(), Debug = CreateContent() }
    
    local function Switch(n)
        for k, v in pairs(Contents) do v.Visible = (k == n) end
        for k, v in pairs(Tabs) do v.TextColor3 = (k == n and Color3.new(1,1,1) or Color3.new(0.6,0.6,0.6)) end
    end
    for k, v in pairs(Tabs) do v.MouseButton1Click:Connect(function() Switch(k) end) end
    Switch("Drones")
    
    -- Elements
    local function CreateToggle(n, p, c, d)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.95, 0, 0, 45)
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        f.Parent = p
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.5, 0, 1, 0)
        l.Position = UDim2.new(0.05, 0, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = n
        l.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        l.Font = Enum.Font.Gotham
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 40, 0, 22)
        b.Position = UDim2.new(0.95, -40, 0.5, -11)
        b.BackgroundColor3 = d and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(180, 50, 50)
        b.Text = ""
        b.Parent = f
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 11)
        
        local active = d
        b.MouseButton1Click:Connect(function()
            active = not active
            b.BackgroundColor3 = active and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(180, 50, 50)
            c(active)
        end)
    end
    
    local function CreateColorSelector(p, config)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.95, 0, 0, 30)
        f.BackgroundTransparency = 1
        f.Parent = p
        for i, preset in ipairs(ColorPresets) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.15, -4, 1, 0)
            b.Position = UDim2.new((i-1)*0.165, 0, 0, 0)
            b.BackgroundColor3 = preset.Color
            b.Text = ""
            b.Parent = f
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(function() config.Color = preset.Color end)
        end
    end

    -- Setup Sections
    CreateToggle("FPV Drone", Contents.Drones, function(v) Settings.Drones.FPV.Enabled = v end, Settings.Drones.FPV.Enabled)
    CreateColorSelector(Contents.Drones, Settings.Drones.FPV)
    CreateToggle("Bober", Contents.Drones, function(v) Settings.Drones.Bober.Enabled = v end, Settings.Drones.Bober.Enabled)
    CreateToggle("Shahed 136", Contents.Drones, function(v) Settings.Drones.Shahed136.Enabled = v end, Settings.Drones.Shahed136.Enabled)
    CreateToggle("Gerbera", Contents.Drones, function(v) Settings.Drones.Gerbera.Enabled = v end, Settings.Drones.Gerbera.Enabled)
    CreateToggle("Lancet", Contents.Drones, function(v) Settings.Drones.Lancet.Enabled = v end, Settings.Drones.Lancet.Enabled)
    
    CreateToggle("All Missiles", Contents.Rockets, function(v) Settings.Rockets.Missile.Enabled = v end, Settings.Rockets.Missile.Enabled)
    CreateColorSelector(Contents.Rockets, Settings.Rockets.Missile)
    
    CreateToggle("Player ESP", Contents.Settings, function(v) Settings.Players.Enabled = v end, Settings.Players.Enabled)
    CreateColorSelector(Contents.Settings, Settings.Players)
    
    local StyleBtn = Instance.new("TextButton")
    StyleBtn.Size = UDim2.new(0.95, 0, 0, 45)
    StyleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    StyleBtn.Text = "STYLE: " .. Settings.Visuals.Style:upper()
    StyleBtn.TextColor3 = Color3.new(1, 1, 1)
    StyleBtn.Font = Enum.Font.GothamBold
    StyleBtn.TextSize = 12
    StyleBtn.Parent = Contents.Settings
    Instance.new("UICorner", StyleBtn).CornerRadius = UDim.new(0, 8)
    StyleBtn.MouseButton1Click:Connect(function()
        Settings.Visuals.Style = (Settings.Visuals.Style == "Highlight" and "Box" or "Highlight")
        StyleBtn.Text = "STYLE: " .. Settings.Visuals.Style:upper()
    end)
    
    CreateToggle("Givers ESP", Contents.Debug, function(v) Settings.Givers.Enabled = v end, Settings.Givers.Enabled)
    CreateToggle("Universal ESP", Contents.Debug, function(v) Settings.Universal.Enabled = v end, Settings.Universal.Enabled)
    
    local Footer = Instance.new("Frame")
    Footer.Size = UDim2.new(1, 0, 0, 40)
    Footer.Position = UDim2.new(0, 0, 1, -40)
    Footer.BackgroundTransparency = 1
    Footer.Parent = MainFrame
    
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0.9, 0, 0, 30)
    Close.Position = UDim2.new(0.05, 0, 0.5, -15)
    Close.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    Close.Text = "UNLOAD"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 12
    Close.Parent = Footer
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)
    Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    return ScreenGui
end

return GUI

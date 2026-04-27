--[[
    DronePoint ESP Script v1.6
    Fixed Players, 2D Boxes & Color Picker
]]

local Settings = {
    Drones = {
        FPV = { Enabled = true, Color = Color3.fromRGB(255, 0, 0), Names = {"FPV", "Quadcopter", "Expert"} },
        Bober = { Enabled = true, Color = Color3.fromRGB(255, 0, 0), Names = {"Bober", "Бобер", "bbrn"} },
        Shahed136 = { Enabled = true, Color = Color3.fromRGB(255, 165, 0), Names = {"Shahed", "Geran", "Kamikaze", "Герань", "dronenight", "droneday"} },
        Gerbera = { Enabled = true, Color = Color3.fromRGB(255, 165, 0), Names = {"Gerbera", "Гербера", "GrbrBl"} },
        Lancet = { Enabled = true, Color = Color3.fromRGB(255, 0, 0), Names = {"Lancet"} }
    },
    Rockets = {
        Missile = { Enabled = true, Color = Color3.fromRGB(255, 255, 0), Names = {"Missile", "Rocket", "Projectile", "Neptune", "Нептун", "Ballistic", "H"} }
    },
    Players = { Enabled = false, Color = Color3.fromRGB(0, 255, 0) }, -- Default Green
    Givers = { Enabled = true, Color = Color3.fromRGB(0, 255, 255), Names = {"Giver", "Stand", "Table", "Стол", "Выдача"} },
    Universal = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
    Visuals = { Style = "Highlight", FillOpacity = 0.5, OutlineOpacity = 0 }
}

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DronePointESP"
ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)
ScreenGui.IgnoreGuiInset = true

local ActiveESP = {}
local ColorPresets = {
    {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
    {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
    {Name = "Blue", Color = Color3.fromRGB(0, 100, 255)},
    {Name = "Yellow", Color = Color3.fromRGB(255, 255, 0)},
    {Name = "Orange", Color = Color3.fromRGB(255, 165, 0)},
    {Name = "White", Color = Color3.fromRGB(255, 255, 255)}
}

local function ApplyESP(object, config, displayName)
    if not object or not object.Parent then return end
    local id = object:GetDebugId()
    
    if not ActiveESP[id] then
        local box = Instance.new("Frame")
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        local outline = Instance.new("UIStroke")
        outline.Thickness = 1
        outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        outline.Parent = box
        box.Parent = ScreenGui
        
        ActiveESP[id] = {
            Object = object,
            Config = config,
            Name = displayName or object.Name,
            Highlight = nil,
            Box = box,
            Label = nil
        }
    end
    
    local data = ActiveESP[id]
    local isEnabled = (config.Enabled or Settings.Universal.Enabled)
    
    -- Highlight
    if Settings.Visuals.Style == "Highlight" and isEnabled then
        if not data.Highlight then
            data.Highlight = Instance.new("Highlight")
            data.Highlight.Name = "ESPHighlight"
            data.Highlight.Adornee = object
            data.Highlight.Parent = object
        end
        data.Highlight.Enabled = true
        data.Highlight.FillColor = Settings.Universal.Enabled and Settings.Universal.Color or config.Color
        data.Highlight.FillTransparency = Settings.Visuals.FillOpacity
    elseif data.Highlight then
        data.Highlight.Enabled = false
    end
    
    -- Box Color
    data.Box.UIStroke.Color = Settings.Universal.Enabled and Settings.Universal.Color or config.Color
    
    -- Label
    if not data.Label then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPLabel"
        billboard.Size = UDim2.new(0, 150, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        local text = Instance.new("TextLabel")
        text.Parent = billboard
        text.BackgroundTransparency = 1
        text.Size = UDim2.new(1, 0, 1, 0)
        text.Text = data.Name
        text.Font = Enum.Font.GothamBold
        text.TextSize = 14
        text.TextStrokeTransparency = 0.5
        text.TextStrokeColor3 = Color3.new(0, 0, 0)
        billboard.Parent = object
        data.Label = billboard
    end
    data.Label.Enabled = isEnabled
    data.Label.TextLabel.TextColor3 = Settings.Universal.Enabled and Settings.Universal.Color or config.Color
end

local function CheckObject(object)
    if not object:IsA("Model") and not object:IsA("BasePart") then return end
    
    -- Player Check
    local player = Players:GetPlayerFromCharacter(object)
    if player then
        if player ~= LocalPlayer then
            ApplyESP(object, Settings.Players, player.Name)
        end
        return
    end

    local target = object
    if object:IsA("BasePart") and object.Parent and object.Parent:IsA("Model") and object.Parent ~= Workspace then
        target = object.Parent
    end
    if ActiveESP[target:GetDebugId()] then return end
    
    local name = target.Name:lower()
    local partName = object.Name:lower()
    local NameMap = { ["bbrn"] = "Bober", ["grbrbl"] = "Gerbera", ["dronenight"] = "Shahed 136", ["droneday"] = "Shahed 136", ["h"] = "Missile (H)", ["lancet"] = "Lancet" }
    local displayName = NameMap[name] or target.Name:gsub("Meshes/", ""):gsub("_pCube%d+", ""):gsub("_polySurface%d+", ""):gsub("%d+", "")
    
    for _, n in ipairs(Settings.Givers.Names) do if name:find(n:lower()) or partName:find(n:lower()) then ApplyESP(target, Settings.Givers, displayName) return end end
    for _, config in pairs(Settings.Drones) do for _, n in ipairs(config.Names) do if name:find(n:lower()) or partName:find(n:lower()) then ApplyESP(target, config, displayName) return end end end
    for _, n in ipairs(Settings.Rockets.Missile.Names) do if name:find(n:lower()) or partName:find(n:lower()) then ApplyESP(target, Settings.Rockets.Missile, displayName) return end end
    if target:FindFirstChild("Fuselage") or target:FindFirstChild("MainPart") or partName:find("wing") or partName:find("fuselage") then ApplyESP(target, Settings.Drones.FPV, displayName) return end
end

RunService.RenderStepped:Connect(function()
    for id, data in pairs(ActiveESP) do
        if not data.Object or not data.Object.Parent then
            data.Box:Destroy()
            ActiveESP[id] = nil
            continue
        end
        
        local isEnabled = (data.Config.Enabled or Settings.Universal.Enabled)
        if isEnabled and Settings.Visuals.Style == "Box" then
            local cf, size = data.Object:GetBoundingBox()
            local screenPos, onScreen = Camera:WorldToViewportPoint(cf.Position)
            
            if onScreen then
                local topPos = Camera:WorldToViewportPoint(cf.Position + Vector3.new(0, size.Y/2, 0))
                local bottomPos = Camera:WorldToViewportPoint(cf.Position - Vector3.new(0, size.Y/2, 0))
                local height = math.abs(topPos.Y - bottomPos.Y)
                local width = height * 0.7
                
                data.Box.Visible = true
                data.Box.Position = UDim2.new(0, screenPos.X - width/2, 0, screenPos.Y - height/2)
                data.Box.Size = UDim2.new(0, width, 0, height)
            else
                data.Box.Visible = false
            end
        else
            data.Box.Visible = false
        end
        if data.Label then data.Label.Enabled = isEnabled end
        if data.Highlight then data.Highlight.Enabled = (isEnabled and Settings.Visuals.Style == "Highlight") end
    end
end)

-- Player Listeners
local function CharacterAdded(char) task.wait(1) CheckObject(char) end
local function PlayerAdded(p) p.CharacterAdded:Connect(CharacterAdded) if p.Character then CharacterAdded(p.Character) end end
Players.PlayerAdded:Connect(PlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do PlayerAdded(p) end

-- GUI
local MainGUI = Instance.new("ScreenGui")
MainGUI.Name = "DronePointMenu"
MainGUI.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)
MainGUI.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 480)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MainGUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "DronePoint Ultimate v1.6"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TabBar.Parent = MainFrame

local function CreateTab(name, x, w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(w, 0, 1, 0)
    b.Position = UDim2.new(x, 0, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    b.Text = name
    b.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Parent = TabBar
    return b
end

local Tabs = { Drones = CreateTab("Drones", 0, 0.25), Rockets = CreateTab("Rockets", 0.25, 0.25), Settings = CreateTab("Settings", 0.5, 0.25), Debug = CreateTab("Debug", 0.75, 0.25) }
local function CreateContent()
    local c = Instance.new("ScrollingFrame")
    c.Size = UDim2.new(1, 0, 1, -115)
    c.Position = UDim2.new(0, 0, 0, 75)
    c.BackgroundTransparency = 1
    c.ScrollBarThickness = 2
    c.CanvasSize = UDim2.new(0, 0, 2, 0)
    c.Visible = false
    c.Parent = MainFrame
    return c
end
local Contents = { Drones = CreateContent(), Rockets = CreateContent(), Settings = CreateContent(), Debug = CreateContent() }
local function Switch(n)
    for k, v in pairs(Contents) do v.Visible = (k == n) end
    for k, v in pairs(Tabs) do v.TextColor3 = (k == n and Color3.new(1,1,1) or Color3.new(0.7,0.7,0.7)) end
end
for k, v in pairs(Tabs) do v.MouseButton1Click:Connect(function() Switch(k) end) end
Switch("Drones")

local function CreateToggle(n, y, p, c, d)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.9, 0, 0, 35)
    f.Position = UDim2.new(0.05, 0, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    f.Parent = p
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.new(0.05, 0, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = n
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 36, 0, 18)
    b.Position = UDim2.new(0.95, -36, 0.5, -9)
    b.BackgroundColor3 = d and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 0, 0)
    b.Text = ""
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local a = d
    b.MouseButton1Click:Connect(function() a = not a b.BackgroundColor3 = a and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 0, 0) c(a) end)
end

local function CreateColorSelector(y, p, config)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.9, 0, 0, 30)
    f.Position = UDim2.new(0.05, 0, 0, y)
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

CreateToggle("FPV Drone", 10, Contents.Drones, function(v) Settings.Drones.FPV.Enabled = v end, Settings.Drones.FPV.Enabled)
CreateColorSelector(50, Contents.Drones, Settings.Drones.FPV)
CreateToggle("Bober", 90, Contents.Drones, function(v) Settings.Drones.Bober.Enabled = v end, Settings.Drones.Bober.Enabled)
CreateToggle("Shahed 136", 130, Contents.Drones, function(v) Settings.Drones.Shahed136.Enabled = v end, Settings.Drones.Shahed136.Enabled)
CreateToggle("Gerbera", 170, Contents.Drones, function(v) Settings.Drones.Gerbera.Enabled = v end, Settings.Drones.Gerbera.Enabled)
CreateToggle("Lancet", 210, Contents.Drones, function(v) Settings.Drones.Lancet.Enabled = v end, Settings.Drones.Lancet.Enabled)

CreateToggle("All Missiles", 10, Contents.Rockets, function(v) Settings.Rockets.Missile.Enabled = v end, Settings.Rockets.Missile.Enabled)
CreateColorSelector(50, Contents.Rockets, Settings.Rockets.Missile)

CreateToggle("Player ESP", 10, Contents.Settings, function(v) Settings.Players.Enabled = v end, Settings.Players.Enabled)
CreateColorSelector(50, Contents.Settings, Settings.Players)
local StyleBtn = Instance.new("TextButton")
StyleBtn.Size = UDim2.new(0.9, 0, 0, 35)
StyleBtn.Position = UDim2.new(0.05, 0, 0, 90)
StyleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
StyleBtn.Text = "ESP Style: " .. Settings.Visuals.Style
StyleBtn.TextColor3 = Color3.new(1, 1, 1)
StyleBtn.Font = Enum.Font.Gotham
StyleBtn.Parent = Contents.Settings
Instance.new("UICorner", StyleBtn).CornerRadius = UDim.new(0, 6)
StyleBtn.MouseButton1Click:Connect(function()
    Settings.Visuals.Style = (Settings.Visuals.Style == "Highlight" and "Box" or "Highlight")
    StyleBtn.Text = "ESP Style: " .. Settings.Visuals.Style
end)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0.9, 0, 0, 30)
Close.Position = UDim2.new(0.05, 0, 1, -35)
Close.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
Close.Text = "Destroy GUI"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.GothamBold
Close.Parent = MainFrame
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
Close.MouseButton1Click:Connect(function() MainGUI:Destroy() ScreenGui:Destroy() end)

-- Drag
local d, di, ds, sp
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local dl = i.Position - ds MainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dl.X, sp.Y.Scale, sp.Y.Offset + dl.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

Workspace.DescendantAdded:Connect(function(o) task.wait(0.1) CheckObject(o) end)
for _, o in ipairs(Workspace:GetDescendants()) do CheckObject(o) end
print("[DronePoint] v1.6 Loaded!")

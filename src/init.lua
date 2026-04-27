--[[
    DronePoint ESP Script with Styles and Player ESP
    Author: Antigravity AI
    Version: 1.4
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
    Players = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
    Givers = { Enabled = true, Color = Color3.fromRGB(0, 255, 255), Names = {"Giver", "Stand", "Table", "Стол", "Выдача"} },
    Universal = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
    Visuals = {
        Style = "Highlight", -- "Highlight" or "Box"
        FillOpacity = 0.5,
        OutlineOpacity = 0,
        Enabled = true
    }
}

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ESP Logic
local function ApplyESP(object, config, displayName)
    local isEnabled = (config.Enabled or Settings.Universal.Enabled)
    
    -- Highlight Style
    local highlight = object:FindFirstChild("ESPHighlight")
    if Settings.Visuals.Style == "Highlight" then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Adornee = object
            highlight.Parent = object
        end
        highlight.Enabled = isEnabled
        highlight.FillColor = Settings.Universal.Enabled and Settings.Universal.Color or config.Color
        highlight.FillTransparency = Settings.Visuals.FillOpacity
        highlight.OutlineTransparency = Settings.Visuals.OutlineOpacity
    elseif highlight then
        highlight.Enabled = false
    end
    
    -- Box Style
    local box = object:FindFirstChild("ESPBox")
    if Settings.Visuals.Style == "Box" then
        if not box then
            box = Instance.new("SelectionBox")
            box.Name = "ESPBox"
            box.Adornee = object
            box.LineThickness = 0.05
            box.Parent = object
        end
        box.Visible = isEnabled
        box.Color3 = Settings.Universal.Enabled and Settings.Universal.Color or config.Color
    elseif box then
        box.Visible = false
    end
    
    -- Label
    local billboard = object:FindFirstChild("ESPLabel")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPLabel"
        billboard.Size = UDim2.new(0, 150, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        local text = Instance.new("TextLabel")
        text.Parent = billboard
        text.BackgroundTransparency = 1
        text.Size = UDim2.new(1, 0, 1, 0)
        text.Text = displayName or object.Name
        text.Font = Enum.Font.GothamBold
        text.TextSize = 16
        text.TextStrokeTransparency = 0.5
        text.TextStrokeColor3 = Color3.new(0, 0, 0)
        billboard.Parent = object
    end
    billboard.Enabled = isEnabled
    local txt = billboard:FindFirstChildOfClass("TextLabel")
    if txt then txt.TextColor3 = (Settings.Universal.Enabled and Settings.Universal.Color or config.Color) end
end

local function CheckObject(object)
    if not object:IsA("Model") and not object:IsA("BasePart") then return end
    
    -- Player Check
    if Players:GetPlayerFromCharacter(object) then
        if object ~= LocalPlayer.Character then
            ApplyESP(object, Settings.Players, object.Name)
        end
        return
    end

    local target = object
    if object:IsA("BasePart") and object.Parent and object.Parent:IsA("Model") and object.Parent ~= Workspace then
        target = object.Parent
    end

    if target:FindFirstChild("ESPLabel") then return end
    local p = target.Parent
    while p and p ~= Workspace do
        if p:FindFirstChild("ESPLabel") then return end
        p = p.Parent
    end

    local name = target.Name:lower()
    local partName = object.Name:lower()
    local NameMap = { ["bbrn"] = "Bober", ["grbrbl"] = "Gerbera", ["dronenight"] = "Shahed 136", ["droneday"] = "Shahed 136", ["ognik"] = "Ognik", ["h"] = "Missile (H)", ["lancet"] = "Lancet" }
    local displayName = NameMap[name] or target.Name:gsub("Meshes/", ""):gsub("_pCube%d+", ""):gsub("_polySurface%d+", ""):gsub("%d+", "")
    
    for _, n in ipairs(Settings.Givers.Names) do
        if name:find(n:lower()) or partName:find(n:lower()) then ApplyESP(target, Settings.Givers, displayName) return end
    end
    for _, config in pairs(Settings.Drones) do
        for _, n in ipairs(config.Names) do
            if name:find(n:lower()) or partName:find(n:lower()) then ApplyESP(target, config, displayName) return end
        end
    end
    for _, n in ipairs(Settings.Rockets.Missile.Names) do
        if name:find(n:lower()) or partName:find(n:lower()) then ApplyESP(target, Settings.Rockets.Missile, displayName) return end
    end
    if target:FindFirstChild("Fuselage") or target:FindFirstChild("MainPart") or partName:find("wing") or partName:find("fuselage") then
        ApplyESP(target, Settings.Drones.FPV, displayName)
        return
    end
    if Settings.Universal.Enabled then ApplyESP(target, Settings.Universal, displayName) end
end

local function RefreshESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local label = obj:FindFirstChild("ESPLabel")
        if label then
            local name = obj.Name:lower()
            local config = nil
            if Players:GetPlayerFromCharacter(obj) then config = Settings.Players
            elseif name:find("giver") or name:find("stand") then config = Settings.Givers
            else
                for _, d in pairs(Settings.Drones) do for _, n in ipairs(d.Names) do if name:find(n:lower()) then config = d break end end if config then break end end
                if not config then for _, n in ipairs(Settings.Rockets.Missile.Names) do if name:find(n:lower()) then config = Settings.Rockets.Missile break end end end
            end
            if config then ApplyESP(obj, config, label.TextLabel.Text) end
        else
            CheckObject(obj)
        end
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DronePointGUI"
ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "DronePoint Ultimate"
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
    b.TextSize = 12
    b.Parent = TabBar
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
    c.Size = UDim2.new(1, 0, 1, -115)
    c.Position = UDim2.new(0, 0, 0, 75)
    c.BackgroundTransparency = 1
    c.ScrollBarThickness = 4
    c.CanvasSize = UDim2.new(0, 0, 1.5, 0)
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
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.Position = UDim2.new(0.05, 0, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = n
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
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

-- Drones
CreateToggle("FPV Drone", 10, Contents.Drones, function(v) Settings.Drones.FPV.Enabled = v RefreshESP() end, Settings.Drones.FPV.Enabled)
CreateToggle("Bober", 50, Contents.Drones, function(v) Settings.Drones.Bober.Enabled = v RefreshESP() end, Settings.Drones.Bober.Enabled)
CreateToggle("Shahed 136", 90, Contents.Drones, function(v) Settings.Drones.Shahed136.Enabled = v RefreshESP() end, Settings.Drones.Shahed136.Enabled)
CreateToggle("Gerbera", 130, Contents.Drones, function(v) Settings.Drones.Gerbera.Enabled = v RefreshESP() end, Settings.Drones.Gerbera.Enabled)
CreateToggle("Lancet", 170, Contents.Drones, function(v) Settings.Drones.Lancet.Enabled = v RefreshESP() end, Settings.Drones.Lancet.Enabled)

-- Rockets
CreateToggle("All Missiles", 10, Contents.Rockets, function(v) Settings.Rockets.Missile.Enabled = v RefreshESP() end, Settings.Rockets.Missile.Enabled)

-- Settings
CreateToggle("Player ESP", 10, Contents.Settings, function(v) Settings.Players.Enabled = v RefreshESP() end, Settings.Players.Enabled)
local StyleBtn = Instance.new("TextButton")
StyleBtn.Size = UDim2.new(0.9, 0, 0, 35)
StyleBtn.Position = UDim2.new(0.05, 0, 0, 50)
StyleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
StyleBtn.Text = "ESP Style: " .. Settings.Visuals.Style
StyleBtn.TextColor3 = Color3.new(1, 1, 1)
StyleBtn.Font = Enum.Font.Gotham
StyleBtn.Parent = Contents.Settings
Instance.new("UICorner", StyleBtn).CornerRadius = UDim.new(0, 6)
StyleBtn.MouseButton1Click:Connect(function()
    Settings.Visuals.Style = (Settings.Visuals.Style == "Highlight" and "Box" or "Highlight")
    StyleBtn.Text = "ESP Style: " .. Settings.Visuals.Style
    RefreshESP()
end)

-- Debug
CreateToggle("Givers ESP", 10, Contents.Debug, function(v) Settings.Givers.Enabled = v RefreshESP() end, Settings.Givers.Enabled)
CreateToggle("Universal ESP", 50, Contents.Debug, function(v) Settings.Universal.Enabled = v RefreshESP() end, Settings.Universal.Enabled)
local Prnt = Instance.new("TextButton")
Prnt.Size = UDim2.new(0.9, 0, 0, 35)
Prnt.Position = UDim2.new(0.05, 0, 0, 90)
Prnt.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
Prnt.Text = "Print Names (F9)"
Prnt.TextColor3 = Color3.new(1,1,1)
Prnt.Parent = Contents.Debug
Instance.new("UICorner", Prnt).CornerRadius = UDim.new(0, 6)
Prnt.MouseButton1Click:Connect(function() for _, v in ipairs(Workspace:GetDescendants()) do if v:IsA("Model") then print(v.Name) end end end)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0.9, 0, 0, 30)
Close.Position = UDim2.new(0.05, 0, 1, -35)
Close.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
Close.Text = "Destroy GUI"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.GothamBold
Close.Parent = MainFrame
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Drag
local d, di, ds, sp
MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local dl = i.Position - ds MainFrame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dl.X, sp.Y.Scale, sp.Y.Offset + dl.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

Workspace.DescendantAdded:Connect(function(o) task.wait(0.1) CheckObject(o) end)
for _, o in ipairs(Workspace:GetDescendants()) do CheckObject(o) end
print("[DronePoint] Style & Player Update Loaded!")

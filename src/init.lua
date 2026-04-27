--[[
    DronePoint ESP Script with Tabs
    Author: Antigravity AI
    Version: 1.2
]]

local Settings = {
    FPV = { Enabled = true, Color = Color3.fromRGB(255, 0, 0), Names = {"FPV", "Drone", "Quadcopter", "Bober", "Бобер", "Expert", "bbrn", "Ognik"} },
    Shahed = { Enabled = true, Color = Color3.fromRGB(255, 165, 0), Names = {"Shahed", "Geran", "Kamikaze", "Герань", "Gerbera", "Гербера", "GrbrBl", "dronenight", "droneday", "Jet", "238"} },
    Missile = { Enabled = true, Color = Color3.fromRGB(255, 255, 0), Names = {"Missile", "Rocket", "Projectile", "Neptune", "Нептун", "Ballistic"} },
    Givers = { Enabled = true, Color = Color3.fromRGB(0, 255, 255), Names = {"Giver", "Stand", "Table", "Стол", "Выдача"} },
    Universal = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
    Visuals = { FillOpacity = 0.5, OutlineOpacity = 0, Enabled = true }
}

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ESP Logic
local function ApplyESP(object, config, displayName)
    if not config.Enabled and not Settings.Universal.Enabled then return end
    
    local highlight = object:FindFirstChild("ESPHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = config.Color
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = Settings.Visuals.FillOpacity
        highlight.OutlineTransparency = Settings.Visuals.OutlineOpacity
        highlight.Adornee = object
        highlight.Parent = object
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPLabel"
        billboard.Size = UDim2.new(0, 150, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        
        local text = Instance.new("TextLabel")
        text.Parent = billboard
        text.BackgroundTransparency = 1
        text.Size = UDim2.new(1, 0, 1, 0)
        text.Text = displayName or object.Name
        text.TextColor3 = config.Color
        text.TextStrokeTransparency = 0.5
        text.TextStrokeColor3 = Color3.new(0, 0, 0)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 16
        
        billboard.Parent = object
    else
        highlight.Enabled = config.Enabled or Settings.Universal.Enabled
        highlight.FillColor = Settings.Universal.Enabled and Settings.Universal.Color or config.Color
        local label = object:FindFirstChild("ESPLabel")
        if label then 
            label.Enabled = highlight.Enabled 
            local txt = label:FindFirstChildOfClass("TextLabel")
            if txt then txt.TextColor3 = highlight.FillColor end
        end
    end
end

local function CheckObject(object)
    if not object:IsA("Model") and not object:IsA("BasePart") then return end
    
    local target = object
    if object:IsA("BasePart") and object.Parent and object.Parent:IsA("Model") and object.Parent ~= Workspace then
        target = object.Parent
    end

    if target:FindFirstChild("ESPHighlight") then return end
    local p = target.Parent
    while p and p ~= Workspace do
        if p:FindFirstChild("ESPHighlight") then return end
        p = p.Parent
    end

    local name = target.Name:lower()
    local partName = object.Name:lower()
    
    local NameMap = { ["bbrn"] = "Bober", ["grbrbl"] = "Gerbera", ["dronenight"] = "Shahed 136", ["droneday"] = "Shahed 136", ["ognik"] = "Ognik" }
    local displayName = NameMap[name] or target.Name:gsub("Meshes/", ""):gsub("_pCube%d+", ""):gsub("_polySurface%d+", ""):gsub("%d+", "")
    
    for _, n in ipairs(Settings.Givers.Names) do
        if name:find(n:lower()) or partName:find(n:lower()) then
            ApplyESP(target, Settings.Givers, displayName)
            return
        end
    end
    
    for _, n in ipairs(Settings.FPV.Names) do
        if name:find(n:lower()) or partName:find(n:lower()) then
            ApplyESP(target, Settings.FPV, displayName)
            return
        end
    end
    
    for _, n in ipairs(Settings.Shahed.Names) do
        if name:find(n:lower()) or partName:find(n:lower()) then
            ApplyESP(target, Settings.Shahed, displayName)
            return
        end
    end
    
    for _, n in ipairs(Settings.Missile.Names) do
        if name:find(n:lower()) or partName:find(n:lower()) then
            ApplyESP(target, Settings.Missile, displayName)
            return
        end
    end
    
    if target:FindFirstChild("Fuselage") or target:FindFirstChild("MainPart") or partName:find("wing") or partName:find("fuselage") then
        ApplyESP(target, Settings.FPV, displayName)
        return
    end

    if Settings.Universal.Enabled then
        ApplyESP(target, Settings.Universal, displayName)
    end
end

local function RefreshESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local highlight = obj:FindFirstChild("ESPHighlight")
        if highlight then
            if Settings.Universal.Enabled then
                highlight.Enabled = true
                highlight.FillColor = Settings.Universal.Color
            else
                local isFPV, isShahed, isMissile, isGiver = false, false, false, false
                local name = obj.Name:lower()
                for _, n in ipairs(Settings.FPV.Names) do if name:find(n:lower()) then isFPV = true break end end
                for _, n in ipairs(Settings.Shahed.Names) do if name:find(n:lower()) then isShahed = true break end end
                for _, n in ipairs(Settings.Missile.Names) do if name:find(n:lower()) then isMissile = true break end end
                for _, n in ipairs(Settings.Givers.Names) do if name:find(n:lower()) then isGiver = true break end end
                
                if isFPV then highlight.Enabled = Settings.FPV.Enabled highlight.FillColor = Settings.FPV.Color
                elseif isShahed then highlight.Enabled = Settings.Shahed.Enabled highlight.FillColor = Settings.Shahed.Color
                elseif isMissile then highlight.Enabled = Settings.Missile.Enabled highlight.FillColor = Settings.Missile.Color
                elseif isGiver then highlight.Enabled = Settings.Givers.Enabled highlight.FillColor = Settings.Givers.Color
                else highlight.Enabled = false end
            end
            local label = obj:FindFirstChild("ESPLabel")
            if label then label.Enabled = highlight.Enabled local txt = label:FindFirstChildOfClass("TextLabel") if txt then txt.TextColor3 = highlight.FillColor end end
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
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "DronePoint Ultimate"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local function CreateTab(name, xPos, width)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(width, 0, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = TabBar
    return btn
end

local DronesTab = CreateTab("Drones", 0, 0.33)
local RocketsTab = CreateTab("Rockets", 0.33, 0.33)
local DebugTab = CreateTab("Debug", 0.66, 0.34)

local DronesContent = Instance.new("Frame")
DronesContent.Name = "DronesContent"
DronesContent.Size = UDim2.new(1, 0, 1, -75)
DronesContent.Position = UDim2.new(0, 0, 0, 75)
DronesContent.BackgroundTransparency = 1
DronesContent.Visible = true
DronesContent.Parent = MainFrame

local RocketsContent = DronesContent:Clone()
RocketsContent.Name = "RocketsContent"
RocketsContent.Visible = false
RocketsContent.Parent = MainFrame

local DebugContent = DronesContent:Clone()
DebugContent.Name = "DebugContent"
DebugContent.Visible = false
DebugContent.Parent = MainFrame

local function SwitchTab(tabName)
    DronesContent.Visible = (tabName == "Drones")
    RocketsContent.Visible = (tabName == "Rockets")
    DebugContent.Visible = (tabName == "Debug")
    
    DronesTab.TextColor3 = (tabName == "Drones" and Color3.new(1,1,1) or Color3.new(0.7,0.7,0.7))
    RocketsTab.TextColor3 = (tabName == "Rockets" and Color3.new(1,1,1) or Color3.new(0.7,0.7,0.7))
    DebugTab.TextColor3 = (tabName == "Debug" and Color3.new(1,1,1) or Color3.new(0.7,0.7,0.7))
end

DronesTab.MouseButton1Click:Connect(function() SwitchTab("Drones") end)
RocketsTab.MouseButton1Click:Connect(function() SwitchTab("Rockets") end)
DebugTab.MouseButton1Click:Connect(function() SwitchTab("Debug") end)
SwitchTab("Drones")

-- Toggle Helper
local function CreateToggle(name, yPos, parent, callback, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.Position = UDim2.new(0.05, 0, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0.05, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(0.95, -40, 0.5, -10)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 0, 0)
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local active = default
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 0, 0)
        callback(active)
    end)
end

-- Add Content
CreateToggle("FPV ESP", 10, DronesContent, function(v) Settings.FPV.Enabled = v RefreshESP() end, Settings.FPV.Enabled)
CreateToggle("Shahed ESP", 60, DronesContent, function(v) Settings.Shahed.Enabled = v RefreshESP() end, Settings.Shahed.Enabled)

CreateToggle("Missile ESP", 10, RocketsContent, function(v) Settings.Missile.Enabled = v RefreshESP() end, Settings.Missile.Enabled)

CreateToggle("Givers ESP", 10, DebugContent, function(v) Settings.Givers.Enabled = v RefreshESP() end, Settings.Givers.Enabled)
CreateToggle("Universal ESP", 60, DebugContent, function(v) Settings.Universal.Enabled = v RefreshESP() end, Settings.Universal.Enabled)

local PrintBtn = Instance.new("TextButton")
PrintBtn.Size = UDim2.new(0.9, 0, 0, 40)
PrintBtn.Position = UDim2.new(0.05, 0, 0, 110)
PrintBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
PrintBtn.Text = "Print Names to Console (F9)"
PrintBtn.TextColor3 = Color3.new(1, 1, 1)
PrintBtn.Font = Enum.Font.Gotham
PrintBtn.Parent = DebugContent
Instance.new("UICorner", PrintBtn).CornerRadius = UDim.new(0, 6)

PrintBtn.MouseButton1Click:Connect(function()
    print("--- DronePoint Dump ---")
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then print("Model: " .. v.Name .. " | Parent: " .. tostring(v.Parent)) end
    end
    print("--- End ---")
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0, 30)
CloseBtn.Position = UDim2.new(0.05, 0, 1, -40)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBtn.Text = "Destroy GUI"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Draggable
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = MainFrame.Position end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Listeners
Workspace.DescendantAdded:Connect(function(obj) task.wait(0.1) CheckObject(obj) end)
for _, obj in ipairs(Workspace:GetDescendants()) do CheckObject(obj) end
print("[DronePoint ESP] Tabs Loaded!")

--[[
    DronePoint ESP Script with GUI
    Author: Antigravity AI
    Version: 1.1
]]

local Settings = {
    FPV = {
        Enabled = true,
        Color = Color3.fromRGB(255, 0, 0), -- Red
        Names = {"FPV", "Drone", "Quadcopter"}
    },
    Shahed = {
        Enabled = true,
        Color = Color3.fromRGB(255, 165, 0), -- Orange
        Names = {"Shahed", "Geran", "Kamikaze"}
    },
    Missile = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 0), -- Yellow
        Names = {"Missile", "Rocket", "Projectile"}
    },
    Visuals = {
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
local function ApplyESP(object, config)
    if not config.Enabled then return end
    
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
        
        if object:IsA("Model") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPLabel"
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.ExtentsOffset = Vector3.new(0, 3, 0)
            
            local text = Instance.new("TextLabel")
            text.Parent = billboard
            text.BackgroundTransparency = 1
            text.Size = UDim2.new(1, 0, 1, 0)
            text.Text = object.Name
            text.TextColor3 = config.Color
            text.TextStrokeTransparency = 0
            text.Font = Enum.Font.GothamBold
            text.TextSize = 14
            
            billboard.Parent = object
        end
    else
        highlight.Enabled = config.Enabled
        local label = object:FindFirstChild("ESPLabel")
        if label then label.Enabled = config.Enabled end
    end
end

local function CheckObject(object)
    if not object:IsA("Model") and not object:IsA("BasePart") then return end
    
    local name = object.Name:lower()
    
    -- Check FPV
    for _, n in ipairs(Settings.FPV.Names) do
        if name:find(n:lower()) then
            ApplyESP(object, Settings.FPV)
            return
        end
    end
    
    -- Check Shahed
    for _, n in ipairs(Settings.Shahed.Names) do
        if name:find(n:lower()) then
            ApplyESP(object, Settings.Shahed)
            return
        end
    end
    
    -- Check Missile
    for _, n in ipairs(Settings.Missile.Names) do
        if name:find(n:lower()) then
            ApplyESP(object, Settings.Missile)
            return
        end
    end
end

-- Refresh ESP function
local function RefreshESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local highlight = obj:FindFirstChild("ESPHighlight")
        if highlight then
            local isFPV = false
            local isShahed = false
            local isMissile = false
            
            local name = obj.Name:lower()
            for _, n in ipairs(Settings.FPV.Names) do if name:find(n:lower()) then isFPV = true break end end
            for _, n in ipairs(Settings.Shahed.Names) do if name:find(n:lower()) then isShahed = true break end end
            for _, n in ipairs(Settings.Missile.Names) do if name:find(n:lower()) then isMissile = true break end end
            
            if isFPV then highlight.Enabled = Settings.FPV.Enabled
            elseif isShahed then highlight.Enabled = Settings.Shahed.Enabled
            elseif isMissile then highlight.Enabled = Settings.Missile.Enabled end
            
            local label = obj:FindFirstChild("ESPLabel")
            if label then label.Enabled = highlight.Enabled end
        else
            CheckObject(obj)
        end
    end
end

-- GUI Implementation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DronePointGUI"
ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
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
Title.Text = "DronePoint ESP"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local function CreateToggle(name, yPos, callback, default)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0.9, 0, 0, 40)
    ToggleFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 40, 0, 20)
    Button.Position = UDim2.new(0.95, -40, 0.5, -10)
    Button.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 0, 0)
    Button.Text = ""
    Button.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = Button
    
    local active = default
    Button.MouseButton1Click:Connect(function()
        active = not active
        Button.BackgroundColor3 = active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 0, 0)
        callback(active)
    end)
end

-- Add Toggles
CreateToggle("FPV ESP", 60, function(v) Settings.FPV.Enabled = v RefreshESP() end, Settings.FPV.Enabled)
CreateToggle("Shahed ESP", 110, function(v) Settings.Shahed.Enabled = v RefreshESP() end, Settings.Shahed.Enabled)
CreateToggle("Missile ESP", 160, function(v) Settings.Missile.Enabled = v RefreshESP() end, Settings.Missile.Enabled)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0, 40)
CloseBtn.Position = UDim2.new(0.05, 0, 0, 230)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBtn.Text = "Destroy GUI"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Initial scan
for _, obj in ipairs(Workspace:GetDescendants()) do
    CheckObject(obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    CheckObject(obj)
end)

print("[DronePoint ESP] GUI Loaded Successfully!")

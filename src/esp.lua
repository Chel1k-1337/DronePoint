local ESP = {}
local Settings = nil

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DronePointESP_Container"
ScreenGui.IgnoreGuiInset = true

local ActiveESP = {}

function ESP.Init(settingsRef, guiParent)
    Settings = settingsRef
    ScreenGui.Parent = guiParent
    
    RunService.Heartbeat:Connect(function()
        local universalEnabled = Settings.Universal.Enabled
        
        for id, data in pairs(ActiveESP) do
            local obj = data.Object
            if not obj or not obj.Parent then
                if data.Box then data.Box:Destroy() end
                if data.Label then data.Label:Destroy() end
                if data.Highlight then data.Highlight:Destroy() end
                ActiveESP[id] = nil
                continue
            end
            
            local config = data.Config
            local isEnabled = (config.Enabled or universalEnabled)
            
            -- Immediate skip if disabled
            if not isEnabled then
                if data.Box then data.Box.Visible = false end
                if data.Label then data.Label.Enabled = false end
                if data.Highlight then data.Highlight.Enabled = false end
                continue
            end

            -- Update Visuals
            local style = Settings.Visuals.Style
            local color = universalEnabled and Settings.Universal.Color or config.Color
            
            -- Highlight Logic
            if style == "Highlight" then
                if not data.Highlight then
                    data.Highlight = Instance.new("Highlight")
                    data.Highlight.Adornee = obj
                    data.Highlight.Parent = obj
                end
                data.Highlight.Enabled = true
                data.Highlight.FillColor = color
                if data.Box then data.Box.Visible = false end
            elseif data.Highlight then
                data.Highlight.Enabled = false
            end
            
            -- 2D Box Logic (Enhanced)
            if style == "Box" then
                local cf, size = obj:GetBoundingBox()
                local screenPos, onScreen = Camera:WorldToViewportPoint(cf.Position)
                
                if onScreen then
                    -- Calculate 2D size based on distance and actual model size
                    local topPos = Camera:WorldToViewportPoint((cf * CFrame.new(0, size.Y/2, 0)).Position)
                    local bottomPos = Camera:WorldToViewportPoint((cf * CFrame.new(0, -size.Y/2, 0)).Position)
                    local height = math.abs(topPos.Y - bottomPos.Y)
                    local width = height * 0.75
                    
                    local boxPos = UDim2.new(0, screenPos.X - width/2, 0, screenPos.Y - height/2)
                    local boxSize = UDim2.new(0, width, 0, height)
                    
                    data.Box.Visible = true
                    data.Box.Position = boxPos
                    data.Box.Size = boxSize
                    
                    local boxStyle = Settings.Visuals.BoxStyle
                    local showOutline = Settings.Visuals.ShowOutline
                    
                    -- Update Box Parts
                    data.Box.Main.Visible = (boxStyle == "Full")
                    data.Box.Corners.Visible = (boxStyle == "Corners")
                    
                    if boxStyle == "Full" then
                        data.Box.Main.UIStroke.Color = color
                        data.Box.Main.UIStroke.Thickness = 1
                        if data.Box.Main:FindFirstChild("Outline") then
                            data.Box.Main.Outline.Enabled = showOutline
                        end
                    else
                        for _, corner in ipairs(data.Box.Corners:GetChildren()) do
                            if corner:IsA("Frame") then
                                corner.BackgroundColor3 = color
                                if corner:FindFirstChild("UIStroke") then
                                    corner.UIStroke.Enabled = showOutline
                                end
                            end
                        end
                    end
                else
                    data.Box.Visible = false
                end
            elseif data.Box then
                data.Box.Visible = false
            end
            
            -- Label Logic
            if data.Label then
                data.Label.Enabled = true
                data.Label.TextLabel.TextColor3 = color
            end
        end
    end)
end

function ESP.Apply(object, config, displayName)
    if not object or not object.Parent then return end
    local id = object:GetDebugId()
    
    if ActiveESP[id] then return end -- Already tracked
    
    local box = Instance.new("Frame")
    box.Name = "ESPBox"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Parent = ScreenGui
    
    -- Full Box Style
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundTransparency = 1
    main.BorderSizePixel = 0
    main.Parent = box
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = main
    
    local outline = Instance.new("UIStroke")
    outline.Name = "Outline"
    outline.Thickness = 2.5
    outline.Color = Color3.new(0, 0, 0)
    outline.Transparency = 0.6
    outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outline.Parent = main
    
    -- Corners Style
    local corners = Instance.new("Frame")
    corners.Name = "Corners"
    corners.Size = UDim2.new(1, 0, 1, 0)
    corners.BackgroundTransparency = 1
    corners.Parent = box
    
    local cornerData = {
        {UDim2.new(0, 0, 0, 0), UDim2.new(0, 2, 0, 10)}, -- TL Vertical
        {UDim2.new(0, 0, 0, 0), UDim2.new(0, 10, 0, 2)}, -- TL Horizontal
        {UDim2.new(1, -2, 0, 0), UDim2.new(0, 2, 0, 10)}, -- TR Vertical
        {UDim2.new(1, -10, 0, 0), UDim2.new(0, 10, 0, 2)}, -- TR Horizontal
        {UDim2.new(0, 0, 1, -10), UDim2.new(0, 2, 0, 10)}, -- BL Vertical
        {UDim2.new(0, 0, 1, -2), UDim2.new(0, 10, 0, 2)}, -- BL Horizontal
        {UDim2.new(1, -2, 1, -10), UDim2.new(0, 2, 0, 10)}, -- BR Vertical
        {UDim2.new(1, -10, 1, -2), UDim2.new(0, 10, 0, 2)} -- BR Horizontal
    }
    
    for i, d in ipairs(cornerData) do
        local c = Instance.new("Frame")
        c.Position = d[1]
        c.Size = d[2]
        c.BorderSizePixel = 0
        c.Parent = corners
        
        local cOutline = Instance.new("UIStroke")
        cOutline.Thickness = 1.5
        cOutline.Color = Color3.new(0, 0, 0)
        cOutline.Transparency = 0.5
        cOutline.Parent = c
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPLabel"
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    local text = Instance.new("TextLabel")
    text.Parent = billboard
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.TextStrokeTransparency = 0.5
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.Text = displayName or object.Name
    billboard.Parent = object
    
    ActiveESP[id] = {
        Object = object,
        Config = config,
        Name = displayName or object.Name,
        Highlight = nil,
        Box = box,
        Label = billboard
    }
end

function ESP.Check(object)
    -- PERFORMANCE CRITICAL: Only check Models or top-level BaseParts
    if not object:IsA("Model") and not (object:IsA("BasePart") and object.Parent == Workspace) then return end
    
    local player = Players:GetPlayerFromCharacter(object)
    if player then
        if player ~= LocalPlayer then ESP.Apply(object, Settings.Players, player.Name) end
        return
    end
    
    local name = object.Name:lower()
    local NameMap = { ["bbrn"] = "Bober", ["grbrbl"] = "Gerbera", ["dronenight"] = "Shahed 136", ["droneday"] = "Shahed 136", ["h"] = "Missile (H)", ["lancet"] = "Lancet" }
    
    -- Check Drones
    for droneType, config in pairs(Settings.Drones) do
        for _, n in ipairs(config.Names) do
            if name:find(n:lower()) then
                ESP.Apply(object, config, NameMap[name] or object.Name)
                return
            end
        end
    end
    
    -- Check Rockets
    for _, n in ipairs(Settings.Rockets.Missile.Names) do
        if name:find(n:lower()) then
            ESP.Apply(object, Settings.Rockets.Missile, NameMap[name] or "Missile")
            return
        end
    end
    
    -- Check Givers
    for _, n in ipairs(Settings.Givers.Names) do
        if name:find(n:lower()) then
            ESP.Apply(object, Settings.Givers, "Giver")
            return
        end
    end
    
    -- Universal check for drones without specific names
    if object:FindFirstChild("Fuselage") or object:FindFirstChild("MainPart") then
        ESP.Apply(object, Settings.Drones.FPV, "Drone")
        return
    end
end

return ESP

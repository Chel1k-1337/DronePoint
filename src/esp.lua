local ESP = {}
local Settings = nil -- Will be injected

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
    
    RunService.RenderStepped:Connect(function()
        for id, data in pairs(ActiveESP) do
            if not data.Object or not data.Object.Parent then
                if data.Box then data.Box:Destroy() end
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
                if data.Box then data.Box.Visible = false end
            end
            if data.Label then data.Label.Enabled = isEnabled end
            if data.Highlight then data.Highlight.Enabled = (isEnabled and Settings.Visuals.Style == "Highlight") end
        end
    end)
end

function ESP.Apply(object, config, displayName)
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
    
    if Settings.Visuals.Style == "Highlight" and isEnabled then
        if not data.Highlight then
            data.Highlight = Instance.new("Highlight")
            data.Highlight.Name = "ESPHighlight"
            data.Highlight.Adornee = object
            data.Highlight.Parent = object
        end
        data.Highlight.Enabled = true
        data.Highlight.FillColor = Settings.Universal.Enabled and Settings.Universal.Color or config.Color
    elseif data.Highlight then
        data.Highlight.Enabled = false
    end
    
    data.Box.UIStroke.Color = Settings.Universal.Enabled and Settings.Universal.Color or config.Color
    
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

function ESP.Check(object)
    if not object:IsA("Model") and not object:IsA("BasePart") then return end
    local player = Players:GetPlayerFromCharacter(object)
    if player then
        if player ~= LocalPlayer then ESP.Apply(object, Settings.Players, player.Name) end
        return
    end
    local target = object
    if object:IsA("BasePart") and object.Parent and object.Parent:IsA("Model") and object.Parent ~= Workspace then target = object.Parent end
    if ActiveESP[target:GetDebugId()] then return end
    
    local name = target.Name:lower()
    local partName = object.Name:lower()
    local NameMap = { ["bbrn"] = "Bober", ["grbrbl"] = "Gerbera", ["dronenight"] = "Shahed 136", ["droneday"] = "Shahed 136", ["h"] = "Missile (H)", ["lancet"] = "Lancet" }
    local displayName = NameMap[name] or target.Name:gsub("Meshes/", ""):gsub("_pCube%d+", ""):gsub("_polySurface%d+", ""):gsub("%d+", "")
    
    for _, n in ipairs(Settings.Givers.Names) do if name:find(n:lower()) or partName:find(n:lower()) then ESP.Apply(target, Settings.Givers, displayName) return end end
    for _, config in pairs(Settings.Drones) do for _, n in ipairs(config.Names) do if name:find(n:lower()) or partName:find(n:lower()) then ESP.Apply(target, config, displayName) return end end end
    for _, n in ipairs(Settings.Rockets.Missile.Names) do if name:find(n:lower()) or partName:find(n:lower()) then ESP.Apply(target, Settings.Rockets.Missile, displayName) return end end
    if target:FindFirstChild("Fuselage") or target:FindFirstChild("MainPart") or partName:find("wing") or partName:find("fuselage") then ESP.Apply(target, Settings.Drones.FPV, displayName) return end
end

return ESP

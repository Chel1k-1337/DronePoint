--[[
    DronePoint Ultimate v2.2 (Stability & Performance)
    Author: Antigravity AI
]]

local BaseURL = "https://raw.githubusercontent.com/Chel1k-1337/DronePoint/main/src/"

local function LoadModule(name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(BaseURL .. name .. ".lua"))()
    end)
    if success then return result end
    warn("[DronePoint] Failed to load module: " .. name .. " - " .. tostring(result))
    return nil
end

local Settings = LoadModule("settings")
local Utils = LoadModule("utils")
local ESP = LoadModule("esp")
local GUI = LoadModule("gui")

if not (Settings and Utils and ESP and GUI) then
    error("[DronePoint] Critical failure loading modules. Script terminated.")
end

-- Initialization
local ScreenGui = GUI.Init(Settings, Utils)
ESP.Init(Settings, ScreenGui)

-- PERFORMANCE OPTIMIZED TRACKING
local Workspace = game:GetService("Workspace")

-- Scan only Models in Workspace (where drones/players actually are)
local function InitialScan()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            ESP.Check(obj)
        end
    end
end

Workspace.ChildAdded:Connect(function(obj)
    -- Small delay to let the model load its name/parts
    task.wait(0.2)
    ESP.Check(obj)
end)

task.spawn(InitialScan)

print("[DronePoint] v2.2 Stability Update Loaded!")

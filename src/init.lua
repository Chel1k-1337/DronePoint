--[[
    DronePoint Ultimate v2.0 (Modular & Premium)
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

-- Object Tracking
local Workspace = game:GetService("Workspace")
Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    ESP.Check(obj)
end)

for _, obj in ipairs(Workspace:GetDescendants()) do
    ESP.Check(obj)
end

print("[DronePoint] v2.0 Premium Modular Loaded!")

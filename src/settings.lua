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
    Players = { Enabled = false, Color = Color3.fromRGB(0, 255, 0) },
    Givers = { Enabled = true, Color = Color3.fromRGB(0, 255, 255), Names = {"Giver", "Stand", "Table", "Стол", "Выдача"} },
    Universal = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
    Visuals = { Style = "Highlight", FillOpacity = 0.5, OutlineOpacity = 0 }
}

return Settings

--[[
    SPRP SYSTEM V31 - FULL ARCHITECTURE
    SYSTEM: PANTSIR ELITE ENGINE
    - REPRISTINADO: Aba Configs (Mobile Mode, Unload, Keybinds)
    - UPDATED: Premium ESP Module Integrated
    - NOVO: Auto Fire Module
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // [ MODULE 1: CORE SERVICES ]
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

-- // [ MODULE 2: SYSTEM STATE ]
local SPRP_SYSTEM = {
    Aimbot = {
        Enabled    = false,
        Smoothing  = 0.5,
        BodyPart   = "Head",
        WallCheck  = true,
        TeamCheck  = true,
        AutoFire   = false,
        FireRate   = 10, -- tiros por segundo
    },
    ESP = {
        Enabled               = false,
        TeamCheck             = false,
        HighlightTransparency = 0.5,
        FixedTextSize         = 13,
    },
    Visuals = {
        FOVVisible   = false,
        FOVRadius    = 100,
        FOVColor     = Color3.fromRGB(255, 0, 0),
        FOVThickness = 1,
    },
    Exploits = {
        Enabled   = false,
        WalkSpeed = 16,
    },
    Configs = {
        MobileMode = true,
        Keybind    = Enum.KeyCode.RightControl,
    }
}

local ESP_Objects    = {}
local FOV_Circle     = Drawing.new("Circle")
local LastFireTime   = 0  -- debounce do auto fire

-- // [ MODULE 3: UTILS ]
local function GetTeamColor(Player)
    return Player.TeamColor.Color
end

local function IsVisible(TargetPart, Character)
    if not SPRP_SYSTEM.Aimbot.WallCheck then return true end
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local Result = Workspace:Raycast(
        Camera.CFrame.Position,
        (TargetPart.Position - Camera.CFrame.Position).Unit * 500,
        RayParams
    )
    return Result and Result.Instance:IsDescendantOf(Character)
end

-- // [ MODULE 4: INTERFACE CONSTRUCTION ]
local Window = Rayfield:CreateWindow({
    Name                = "SPRP SYSTEM | V31 ELITE",
    LoadingTitle        = "Protocolo Eye Team",
    LoadingSubtitle     = "Full System Restore",
    ConfigurationSaving = { Enabled = false },
    Theme               = "Blood"
})

local TabAim      = Window:CreateTab("Aimbot Ultra",   4483362458)
local TabESP      = Window:CreateTab("ESP Advanced",   4483362458)
local TabVisuals  = Window:CreateTab("Visuals/Colors", "brush")
local TabExploits = Window:CreateTab("Exploits",       "zap")
local TabConfigs  = Window:CreateTab("Configs",        6031289225)

-- [ AIMBOT ]
TabAim:CreateSection("Aimbot Logic")
TabAim:CreateToggle({Name = "Ativar Aimbot", CurrentValue = false,
    Callback = function(v) SPRP_SYSTEM.Aimbot.Enabled = v end})
TabAim:CreateSlider({Name = "Suavização", Range = {1, 100}, Increment = 1, CurrentValue = 50,
    Callback = function(v) SPRP_SYSTEM.Aimbot.Smoothing = v / 100 end})
TabAim:CreateDropdown({Name = "Alvo", Options = {"Head", "HumanoidRootPart"}, CurrentOption = {"Head"},
    Callback = function(v) SPRP_SYSTEM.Aimbot.BodyPart = v[1] end})
TabAim:CreateToggle({Name = "Wall Check", CurrentValue = true,
    Callback = function(v) SPRP_SYSTEM.Aimbot.WallCheck = v end})
TabAim:CreateToggle({Name = "Team Check", CurrentValue = true,
    Callback = function(v) SPRP_SYSTEM.Aimbot.TeamCheck = v end})

TabAim:CreateSection("Auto Fire")
TabAim:CreateToggle({Name = "Ativar Auto Fire", CurrentValue = false,
    Callback = function(v) SPRP_SYSTEM.Aimbot.AutoFire = v end})
TabAim:CreateSlider({Name = "Fire Rate (tiros/s)", Range = {1, 30}, Increment = 1, CurrentValue = 10,
    Callback = function(v) SPRP_SYSTEM.Aimbot.FireRate = v end})

-- [ ESP ]
TabESP:CreateSection("Pantsir Vision")
TabESP:CreateToggle({Name = "Ativar ESP", CurrentValue = false,
    Callback = function(v) SPRP_SYSTEM.ESP.Enabled = v end})
TabESP:CreateSlider({Name = "Tamanho do Texto", Range = {10, 25}, Increment = 1, CurrentValue = 13,
    Callback = function(v) SPRP_SYSTEM.ESP.FixedTextSize = v end})
TabESP:CreateToggle({Name = "Team Check", CurrentValue = false,
    Callback = function(v) SPRP_SYSTEM.ESP.TeamCheck = v end})

-- [ VISUALS ]
TabVisuals:CreateSection("FOV Settings")
TabVisuals:CreateToggle({Name = "Mostrar FOV", CurrentValue = false,
    Callback = function(v) SPRP_SYSTEM.Visuals.FOVVisible = v end})
TabVisuals:CreateColorPicker({Name = "Cor do FOV", Color = SPRP_SYSTEM.Visuals.FOVColor,
    Callback = function(v) SPRP_SYSTEM.Visuals.FOVColor = v end})
TabVisuals:CreateSlider({Name = "Raio FOV", Range = {30, 800}, Increment = 5, CurrentValue = 100,
    Callback = function(v) SPRP_SYSTEM.Visuals.FOVRadius = v end})

-- [ EXPLOITS ]
TabExploits:CreateSection("Character Mods")
TabExploits:CreateToggle({Name = "Ativar Mods", CurrentValue = false,
    Callback = function(v) SPRP_SYSTEM.Exploits.Enabled = v end})
TabExploits:CreateSlider({Name = "Velocidade", Range = {16, 250}, Increment = 1, CurrentValue = 16,
    Callback = function(v) SPRP_SYSTEM.Exploits.WalkSpeed = v end})

-- [ CONFIGS ]
TabConfigs:CreateSection("System Management")
TabConfigs:CreateToggle({Name = "Mobile Mode (Auto-Lock)", CurrentValue = true,
    Callback = function(v) SPRP_SYSTEM.Configs.MobileMode = v end})
TabConfigs:CreateKeybind({
    Name           = "Menu Keybind",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag           = "MenuKey",
    Callback       = function(k) SPRP_SYSTEM.Configs.Keybind = k end,
})
TabConfigs:CreateButton({
    Name     = "Destruir Script",
    Callback = function() Rayfield:Destroy() end
})

-- // [ MODULE 5: PREMIUM ESP LOGIC ]
local function CreateESP(Player)
    if Player == LocalPlayer then return end

    local function CharacterAdded(Character)
        task.wait(0.5)
        if not Character or not Character.Parent then return end

        local Billboard       = Instance.new("BillboardGui")
        Billboard.Name        = "ESP_Billboard"
        Billboard.Adornee     = Character:WaitForChild("Head", 15)
        Billboard.Size        = UDim2.new(0, 200, 0, 50)
        Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        Billboard.AlwaysOnTop = true
        Billboard.Parent      = CoreGui

        local TextLabel                  = Instance.new("TextLabel")
        TextLabel.Parent                 = Billboard
        TextLabel.BackgroundTransparency = 1
        TextLabel.Size                   = UDim2.new(1, 0, 1, 0)
        TextLabel.Font                   = Enum.Font.GothamBold
        TextLabel.TextColor3             = Color3.new(1, 1, 1)
        TextLabel.TextStrokeTransparency = 0.5
        TextLabel.TextSize               = SPRP_SYSTEM.ESP.FixedTextSize
        TextLabel.Text                   = ""

        local Highlight            = Instance.new("Highlight")
        Highlight.Name             = "ESP_Highlight"
        Highlight.Parent           = Character
        Highlight.FillColor        = Player.TeamColor.Color
        Highlight.OutlineColor     = Color3.new(1, 1, 1)
        Highlight.FillTransparency = SPRP_SYSTEM.ESP.HighlightTransparency
        Highlight.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop

        ESP_Objects[Player] = { Gui = Billboard, Label = TextLabel, Highlight = Highlight }
    end

    if Player.Character then CharacterAdded(Player.Character) end
    Player.CharacterAdded:Connect(CharacterAdded)
end

-- // [ MODULE 6: MAIN LOOP ]
RunService.RenderStepped:Connect(function()

    -- FOV
    FOV_Circle.Visible   = SPRP_SYSTEM.Visuals.FOVVisible
    FOV_Circle.Radius    = SPRP_SYSTEM.Visuals.FOVRadius
    FOV_Circle.Color     = SPRP_SYSTEM.Visuals.FOVColor
    FOV_Circle.Position  = UserInputService:GetMouseLocation()
    FOV_Circle.Thickness = SPRP_SYSTEM.Visuals.FOVThickness

    -- Aimbot + Auto Fire
    local HasTarget = false

    if SPRP_SYSTEM.Aimbot.Enabled then
        local Target  = nil
        local MinDist = SPRP_SYSTEM.Visuals.FOVRadius
        local Mouse   = UserInputService:GetMouseLocation()

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer
                and p.Character
                and p.Character:FindFirstChild("Humanoid")
                and p.Character.Humanoid.Health > 0
            then
                if SPRP_SYSTEM.Aimbot.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local Part = p.Character:FindFirstChild(SPRP_SYSTEM.Aimbot.BodyPart)
                if Part and IsVisible(Part, p.Character) then
                    local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen then
                        local Mag = (Vector2.new(Pos.X, Pos.Y) - Mouse).Magnitude
                        if Mag < MinDist then
                            MinDist  = Mag
                            Target   = Part
                        end
                    end
                end
            end
        end

        if Target then
            HasTarget = true
            if SPRP_SYSTEM.Configs.MobileMode or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                Camera.CFrame = Camera.CFrame:Lerp(
                    CFrame.new(Camera.CFrame.Position, Target.Position),
                    SPRP_SYSTEM.Aimbot.Smoothing
                )
            end
        end
    end

    -- Auto Fire Engine
    if SPRP_SYSTEM.Aimbot.AutoFire and HasTarget then
        local Now      = tick()
        local Interval = 1 / SPRP_SYSTEM.Aimbot.FireRate
        if (Now - LastFireTime) >= Interval then
            LastFireTime = Now
            pcall(function()
                mouse1press()
                task.delay(0.05, function() mouse1release() end)
            end)
        end
    end

    -- Exploits
    if SPRP_SYSTEM.Exploits.Enabled
        and LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("Humanoid")
    then
        LocalPlayer.Character.Humanoid.WalkSpeed = SPRP_SYSTEM.Exploits.WalkSpeed
    end

    -- ESP Engine
    for Player, Objects in pairs(ESP_Objects) do
        if not Player or not Player.Parent then
            if Objects.Gui       then Objects.Gui:Destroy()       end
            if Objects.Highlight then Objects.Highlight:Destroy() end
            ESP_Objects[Player] = nil
            continue
        end

        local Character = Player.Character
        local LocalChar = LocalPlayer.Character

        if Character
            and Character:FindFirstChild("HumanoidRootPart")
            and Character:FindFirstChild("Humanoid")
            and LocalChar
            and LocalChar:FindFirstChild("HumanoidRootPart")
            and SPRP_SYSTEM.ESP.Enabled
        then
            if SPRP_SYSTEM.ESP.TeamCheck and Player.Team == LocalPlayer.Team then
                if Objects.Gui       then Objects.Gui.Enabled       = false end
                if Objects.Highlight then Objects.Highlight.Enabled = false end
                continue
            end

            local RootPart = Character.HumanoidRootPart
            local Humanoid = Character.Humanoid
            local Distance = math.floor((LocalChar.HumanoidRootPart.Position - RootPart.Position).Magnitude)

            Objects.Gui.Enabled                = true
            Objects.Highlight.Enabled          = true
            Objects.Label.TextSize             = SPRP_SYSTEM.ESP.FixedTextSize
            Objects.Label.Text                 = string.format(
                "Name: %s | Health: %d | Distance: %d",
                Player.Name, math.floor(Humanoid.Health), Distance
            )
            Objects.Label.TextColor3           = GetTeamColor(Player)
            Objects.Highlight.FillColor        = GetTeamColor(Player)
            Objects.Highlight.FillTransparency = SPRP_SYSTEM.ESP.HighlightTransparency
        else
            if Objects.Gui       then Objects.Gui.Enabled       = false end
            if Objects.Highlight then Objects.Highlight.Enabled = false end
        end
    end
end)

-- // [ MODULE 7: INIT & CLEANUP ]
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

Players.PlayerRemoving:Connect(function(Player)
    if ESP_Objects[Player] then
        if ESP_Objects[Player].Gui       then ESP_Objects[Player].Gui:Destroy()       end
        if ESP_Objects[Player].Highlight then ESP_Objects[Player].Highlight:Destroy() end
        ESP_Objects[Player] = nil
    end
end)

Rayfield:Notify({Title = "V31 RESTORED", Content = "Configs e Sistemas Ativos.", Duration = 5})

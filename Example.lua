local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local DandysUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/alihusam078588-web/DandysUI/refs/heads/main/DandysUI.lua"))()

local Window = DandysUI:CreateWindow({
    Title = "DandysUI Demo",
    Subtitle = "Toggle and Slider Examples",
    Footer = "DandysUI",
    Size = UDim2.fromOffset(600, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    InfoPanel = true,
    InfoText = "Hover over a control to view its description.",
    OpenButton = true,
    OpenText = "Open UI",
})

local PlayerTab = Window:CreateTab("Player")
local VisualTab = Window:CreateTab("Visuals")

local highlightEnabled = false
local highlights = {}
local characterConnections = {}

local function removeHighlight(player)
    local highlight = highlights[player]
    if highlight then
        highlight:Destroy()
        highlights[player] = nil
    end
end

local function addHighlight(player)
    if not highlightEnabled or player == LocalPlayer then
        return
    end

    local character = player.Character
    if not character or not character.Parent then
        return
    end

    local existing = highlights[player]
    if existing and existing.Parent == character then
        return
    end

    removeHighlight(player)

    local highlight = Instance.new("Highlight")
    highlight.Name = "DandysUI_PlayerHighlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 200, 60)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = character

    highlights[player] = highlight
end

local function watchPlayer(player)
    if player == LocalPlayer or characterConnections[player] then
        return
    end

    characterConnections[player] = player.CharacterAdded:Connect(function(character)
        removeHighlight(player)
        if highlightEnabled then
            task.defer(function()
                if highlightEnabled and player.Character == character then
                    addHighlight(player)
                end
            end)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    watchPlayer(player)
    if highlightEnabled then
        task.defer(function()
            addHighlight(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeHighlight(player)
    local connection = characterConnections[player]
    if connection then
        connection:Disconnect()
        characterConnections[player] = nil
    end
end)

PlayerTab:CreateSection("Player")

PlayerTab:CreateToggle({
    Name = "Highlight Players",
    Default = false,
    Flag = "PlayerHighlights",
    Description = "Highlights other players' characters on your client. The highlight respects walls.",
    Callback = function(enabled)
        highlightEnabled = enabled

        if enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                watchPlayer(player)
                addHighlight(player)
            end
        else
            for player in pairs(highlights) do
                removeHighlight(player)
            end
        end
    end,
})

local walkSpeed = 16
local jumpPower = 50

local function applyMovement()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    humanoid.WalkSpeed = walkSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = jumpPower
end

LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid then
        humanoid.WalkSpeed = walkSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = jumpPower
    end
end)

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 40,
    Default = 16,
    Increment = 1,
    Suffix = " studs/s",
    Flag = "WalkSpeed",
    Description = "Changes the local character Humanoid's WalkSpeed.",
    Callback = function(value)
        walkSpeed = value
        applyMovement()
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 100,
    Default = 50,
    Increment = 5,
    Suffix = "",
    Flag = "JumpPower",
    Description = "Changes the local character Humanoid's JumpPower.",
    Callback = function(value)
        jumpPower = value
        applyMovement()
    end,
})

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
}

VisualTab:CreateSection("Visual Effects")

VisualTab:CreateToggle({
    Name = "Full Bright",
    Default = false,
    Flag = "FullBright",
    Description = "Adjusts local Lighting settings and restores their original values when switched off.",
    Callback = function(enabled)
        if enabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.FogEnd = originalLighting.FogEnd
        end
    end,
})

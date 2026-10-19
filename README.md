# DandysUI

A Roblox UI library styled after the Dandy's World menus: dark striped panels with thick black outlines, Fredoka One text with a silver gradient, yellow section headers, `◀ ON ▶` toggles, orange `— / +` sliders, a hover info side panel, purchase-style dialogs, big floating messages, and UI sounds.

## Setup

### Load from a raw GitHub URL

1. Upload `DandysUI.lua` to your GitHub repository.
2. Open the file on GitHub and select **Raw**.
3. Copy the raw URL and put it inside `game:HttpGet("...")`.
4. Run your example in an environment that supports `loadstring` and `game:HttpGet`.

```lua
local DandysUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/alihusam078588-web/DandysUI/refs/heads/main/DandysUI.lua"))()
```

**Note:** `loadstring`/`HttpGet` loading is environment-dependent and is not the normal way to load UI libraries in a published Roblox experience.

### Load in Roblox Studio

1. Create a `ModuleScript` named `DandysUI`, for example inside `ReplicatedStorage`.
2. Paste the contents of `DandysUI.lua` into that ModuleScript.
3. From a `LocalScript`, require the ModuleScript:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DandysUI = require(ReplicatedStorage:WaitForChild("DandysUI"))
```

## Quick Start

```lua
local DandysUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/alihusam078588-web/DandysUI/refs/heads/main/DandysUI.lua"))()

local Window = DandysUI:CreateWindow({
    Title = "My Script",
    Subtitle = "Example controls",
    Footer = "DandysUI",
    Size = UDim2.fromOffset(600, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    InfoPanel = true,
    InfoText = "Hover over a control to read its description.",
    OpenButton = true,
    OpenText = "Open UI",
})

local Tab = Window:CreateTab("Main")
Tab:CreateSection("Examples")

Tab:CreateButton({
    Name = "Say Hello",
    Color = "Yellow",
    Description = "Prints a message to the output.",
    Callback = function()
        print("Hello from DandysUI!")
    end,
})

Tab:CreateToggle({
    Name = "Example Toggle",
    Default = false,
    Flag = "ExampleToggle",
    Description = "Runs code when switched on or off.",
    Callback = function(enabled)
        print("Toggle state:", enabled)
    end,
})

Tab:CreateSlider({
    Name = "Example Slider",
    Min = 1,
    Max = 100,
    Default = 25,
    Increment = 1,
    Suffix = "%",
    Flag = "ExampleSlider",
    Description = "Runs code when the slider value changes.",
    Callback = function(value)
        print("Slider value:", value)
    end,
})
```

## Complete Example Script

The following example demonstrates real callbacks for a few common controls: a local player-highlight toggle, walk-speed and jump-power sliders, and a local full-bright toggle. These are examples to adapt to your own experience; a game's scripts or server may override client-side changes.

Save this as `Example.lua` (also included as a separate file in this package).

```lua
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

-- PLAYER HIGHLIGHT TOGGLE
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

-- MOVEMENT SLIDERS
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

-- FULL-BRIGHT TOGGLE
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
```

## Window API

```lua
local Window = DandysUI:CreateWindow({
    Title = "Window Title",
    Subtitle = "Optional subtitle",
    Footer = "Optional footer",
    Size = UDim2.fromOffset(600, 420),
    ToggleKey = Enum.KeyCode.RightControl,
    InfoPanel = true,
    InfoText = "Hover description",
    OpenButton = true,
    OpenText = "Open UI",
})

local Tab = Window:CreateTab({ Name = "Main", Icon = "star" })
-- Or: local Tab = Window:CreateTab("Main")
Tab:CreateSection("Section Name")
```

## Elements

Every element can accept `Description = "..."`; the description appears in the info panel when the element is hovered.

```lua
Tab:CreateButton({ Name, Color, Description, Callback })
-- Button methods: :SetText(text), :SetColor(color)

Tab:CreateToggle({ Name, Default, Flag, Description, Callback })
-- Callback receives the new boolean state. Toggle methods: :Set(bool), :Get()

Tab:CreateSlider({ Name, Min, Max, Default, Increment, Suffix, Flag, Description, Callback })
-- Callback receives the new numeric value.

Tab:CreateDropdown({ Name, Options, Default, Multi, Flag, Description, Callback })
-- Dropdown methods: :Refresh(list), :Set(value), :Get()

Tab:CreateTextbox({ Name, Placeholder, Default, NumbersOnly, ClearOnSubmit, Description, Callback })
-- Callback receives: Callback(text, enter)

Tab:CreateKeybind({ Name, Default, Changed, Description, Callback })
Tab:CreateColorPicker({ Name, Default, Description, Callback })
Tab:CreateParagraph({ Title, Content })
Tab:CreateLabel("Label text")
```

## Window Controls, Messages, and Sounds

```lua
Window:Notify({ Title = "Notice", Content = "Something happened", Duration = 3, Color = "Yellow" })
Window:Message("Not enough Ichor!", { Error = true, Duration = 2 })

Window:Dialog({
    Title = "Confirm",
    Content = "Do you want to continue?",
    ConfirmText = "Yes",
    CancelText = "No",
    Callback = function(ok)
        print("Confirmed:", ok)
    end,
})

Window:Toggle()
Window:SetVisible(false)
Window:SelectTab("Main")
Window:Destroy()

DandysUI:SetSoundsEnabled(true)
DandysUI:SetVolume(1) -- accepted range: 0 to 3
DandysUI:PlaySound("Click")
DandysUI.Flags["MyFlag"]
DandysUI:Destroy()
```

To replace sound IDs, edit `DandysUI.Sounds`, then call `DandysUI:LoadSounds()`.

Available sound names: `Click`, `Hover`, `Toggle`, `Tick`, `Tab`, `Open`, `Close`, `Notify`, `Error`, `Purchase`.

## Colors and Themes

Built-in color names: `Grey`, `Green`, `Red`, `Yellow`, `Orange`, `Blue`, `Purple`, `Pink`, `Black`. You can also provide a `Color3` value.

Edit `DandysUI.Theme` or `DandysUI.Colors` before calling `CreateWindow` to customize theme colors.

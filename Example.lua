--[[
    DandysUI - Complete Example
    Demonstrates every UI element type and the main window/library methods.

    Executor-style loader:
    This requires an environment that supports loadstring and game:HttpGet.

    Roblox Studio:
    Put DandysUI.lua in a ModuleScript and replace the loader line with:
        local DandysUI = require(game:GetService("ReplicatedStorage"):WaitForChild("DandysUI"))
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local DandysUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/alihusam078588-web/DandysUI/refs/heads/main/DandysUI.lua"))()

local Window = DandysUI:CreateWindow({
    Title = "DandysUI Demo",
    Subtitle = "Complete Element Showcase",
    Footer = "DandysUI | Example.lua",
    Size = UDim2.fromOffset(650, 480),
    ToggleKey = Enum.KeyCode.RightControl,
    InfoPanel = true,
    InfoText = "Hover over controls to read their descriptions.",
    OpenButton = true,
    OpenText = "Open DandysUI",
})

-- Demonstrates both supported CreateTab formats.
local PlayerTab = Window:CreateTab("Player")
local VisualTab = Window:CreateTab({ Name = "Visuals", Icon = "⭐" })
local WidgetsTab = Window:CreateTab({ Name = "Widgets", Icon = "🧩" })
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "⚙️" })

-- State used by the example features.
local highlightEnabled = false
local highlightColor = Color3.fromRGB(255, 200, 60)
local highlightTransparency = 75
local highlights = {}
local characterConnections = {}
local movementDefaults = setmetatable({}, { __mode = "k" })

local walkSpeed = 16
local jumpPower = 50
local highlightToggle
local fullBrightToggle
local soundToggle
local colorDropdown
local primaryButton
local textBoxValue = "Hello from DandysUI!"
local windowVisible = true

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
}

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
        existing.FillColor = highlightColor
        existing.FillTransparency = math.clamp(highlightTransparency / 100, 0, 1)
        return
    end

    removeHighlight(player)

    local highlight = Instance.new("Highlight")
    highlight.Name = "DandysUI_PlayerHighlight"
    highlight.Adornee = character
    highlight.FillColor = highlightColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = math.clamp(highlightTransparency / 100, 0, 1)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = character

    highlights[player] = highlight
end

local function refreshHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if highlightEnabled then
                addHighlight(player)
            else
                removeHighlight(player)
            end
        end
    end
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

local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
    watchPlayer(player)
    if highlightEnabled then
        task.defer(function()
            addHighlight(player)
        end)
    end
end)

local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
    removeHighlight(player)
    local connection = characterConnections[player]
    if connection then
        connection:Disconnect()
        characterConnections[player] = nil
    end
end)

local function rememberMovementDefaults(humanoid)
    if not movementDefaults[humanoid] then
        movementDefaults[humanoid] = {
            WalkSpeed = humanoid.WalkSpeed,
            UseJumpPower = humanoid.UseJumpPower,
            JumpPower = humanoid.JumpPower,
            JumpHeight = humanoid.JumpHeight,
        }
    end
end

local function applyMovement()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    rememberMovementDefaults(humanoid)
    humanoid.WalkSpeed = walkSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = jumpPower
end

local localCharacterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid then
        applyMovement()
    end
end)

local function applyFullBright(enabled)
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
end

--==============================================================
-- PLAYER TAB: section, toggle, sliders, button
--==============================================================
PlayerTab:CreateSection("Player Controls")

PlayerTab:CreateLabel("Local movement and player highlight examples")

highlightToggle = PlayerTab:CreateToggle({
    Name = "Highlight Players",
    Default = false,
    Flag = "PlayerHighlights",
    Description = "Adds a client-side Highlight to other players. The highlight respects walls.",
    Callback = function(enabled)
        highlightEnabled = enabled
        refreshHighlights()
    end,
})

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 40,
    Default = 16,
    Increment = 1,
    Suffix = " studs/s",
    Flag = "WalkSpeed",
    Description = "Changes the local character Humanoid WalkSpeed. A game can override this value.",
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
    Description = "Changes the local character Humanoid JumpPower while UseJumpPower is enabled.",
    Callback = function(value)
        jumpPower = value
        applyMovement()
    end,
})

PlayerTab:CreateButton({
    Name = "Reset Movement Values",
    Color = "Green",
    Description = "Returns the example sliders to their default values.",
    Callback = function()
        walkSpeed = 16
        jumpPower = 50
        applyMovement()
        Window:Notify({
            Title = "Movement Reset",
            Content = "Walk speed: 16 | Jump power: 50",
            Duration = 3,
            Color = "Green",
        })
    end,
})

PlayerTab:CreateButton({
    Name = "Toggle Highlights Using Set/Get",
    Color = "Yellow",
    Description = "Demonstrates the Toggle element's :Get() and :Set(bool) methods.",
    Callback = function()
        if highlightToggle then
            highlightToggle:Set(not highlightToggle:Get())
        end
    end,
})

--==============================================================
-- VISUAL TAB: toggle, sliders, dropdown, color picker
--==============================================================
VisualTab:CreateSection("Visual Effects")

fullBrightToggle = VisualTab:CreateToggle({
    Name = "Full Bright",
    Default = false,
    Flag = "FullBright",
    Description = "Changes local Lighting settings. Switching it off restores the original settings.",
    Callback = function(enabled)
        applyFullBright(enabled)
    end,
})

VisualTab:CreateSlider({
    Name = "Highlight Transparency",
    Min = 0,
    Max = 100,
    Default = 75,
    Increment = 5,
    Suffix = "%",
    Flag = "HighlightTransparency",
    Description = "Adjusts the fill transparency of player highlights; 0 is solid and 100 is invisible.",
    Callback = function(value)
        highlightTransparency = value
        for _, highlight in pairs(highlights) do
            if highlight.Parent then
                highlight.FillTransparency = math.clamp(value / 100, 0, 1)
            end
        end
    end,
})

local colorPresets = {
    "Gold",
    "Red",
    "Green",
    "Blue",
    "Purple",
    "Pink",
}

local colorMap = {
    Gold = Color3.fromRGB(255, 200, 60),
    Red = Color3.fromRGB(255, 70, 70),
    Green = Color3.fromRGB(80, 255, 130),
    Blue = Color3.fromRGB(80, 170, 255),
    Purple = Color3.fromRGB(185, 100, 255),
    Pink = Color3.fromRGB(255, 120, 190),
}

colorDropdown = VisualTab:CreateDropdown({
    Name = "Highlight Color Preset",
    Options = colorPresets,
    Default = "Gold",
    Multi = false,
    Flag = "HighlightColorPreset",
    Description = "Choose a preset color for the player highlight. You can also use the color picker below.",
    Callback = function(selection)
        local selected = selection
        if type(selection) == "table" then
            selected = selection[1]
        end
        if colorMap[selected] then
            highlightColor = colorMap[selected]
            refreshHighlights()
        end
    end,
})

VisualTab:CreateDropdown({
    Name = "Demo Multi-Select",
    Options = { "ESP", "Movement", "Sounds", "Notifications" },
    Default = { "ESP", "Notifications" },
    Multi = true,
    Flag = "DemoMultiSelect",
    Description = "Demonstrates a multi-select dropdown. Selected values are displayed in a notification.",
    Callback = function(selection)
        local selectedText
        if type(selection) == "table" then
            selectedText = table.concat(selection, ", ")
        else
            selectedText = tostring(selection)
        end
        Window:Notify({
            Title = "Multi-Select Changed",
            Content = "Selected: " .. selectedText,
            Duration = 3,
            Color = "Purple",
        })
    end,
})

VisualTab:CreateColorPicker({
    Name = "Custom Highlight Color",
    Default = highlightColor,
    Description = "Choose any Color3 value for the highlight fill.",
    Callback = function(color)
        if typeof(color) == "Color3" then
            highlightColor = color
            refreshHighlights()
        end
    end,
})

VisualTab:CreateButton({
    Name = "Refresh Color Dropdown",
    Color = "Orange",
    Description = "Demonstrates Dropdown :Refresh(list), :Set(value), and :Get().",
    Callback = function()
        colorDropdown:Refresh(colorPresets)
        colorDropdown:Set("Gold")
        local selected = colorDropdown:Get()
        Window:Notify({
            Title = "Dropdown Updated",
            Content = "Available presets refreshed. Selected: " .. tostring(selected),
            Duration = 3,
            Color = "Orange",
        })
    end,
})

--==============================================================
-- WIDGETS TAB: every other element and dialog/message APIs
--==============================================================
WidgetsTab:CreateSection("Button Examples")
WidgetsTab:CreateParagraph({
    Title = "Welcome to DandysUI",
    Content = "This paragraph demonstrates the Title and Content fields. Hover over controls to see their descriptions in the info panel.",
})
WidgetsTab:CreateLabel("Labels are useful for short, non-interactive notes.")

primaryButton = WidgetsTab:CreateButton({
    Name = "Click Me",
    Color = "Yellow",
    Description = "A simple button. The callback displays a notification.",
    Callback = function()
        Window:Notify({
            Title = "Button Clicked",
            Content = "The button callback ran successfully!",
            Duration = 3,
            Color = "Yellow",
        })
    end,
})

WidgetsTab:CreateButton({
    Name = "Change Button Text",
    Color = "Blue",
    Description = "Demonstrates Button :SetText(text).",
    Callback = function()
        if primaryButton then
            primaryButton:SetText("Text Changed!")
        end
    end,
})

WidgetsTab:CreateButton({
    Name = "Change Button Color",
    Color = "Purple",
    Description = "Demonstrates Button :SetColor(color).",
    Callback = function()
        if primaryButton then
            primaryButton:SetColor("Purple")
        end
    end,
})

WidgetsTab:CreateSection("Textbox and Keybind")

WidgetsTab:CreateTextbox({
    Name = "Notification Text",
    Placeholder = "Type a message and press Enter",
    Default = textBoxValue,
    NumbersOnly = false,
    ClearOnSubmit = false,
    Description = "Type a custom message. Press Enter to save it for the notification button.",
    Callback = function(text, enter)
        textBoxValue = text
        if enter then
            Window:Notify({
                Title = "Text Saved",
                Content = "Your message is ready to display.",
                Duration = 2,
                Color = "Green",
            })
        end
    end,
})

WidgetsTab:CreateButton({
    Name = "Show Typed Message",
    Color = "Green",
    Description = "Displays the last text entered in the textbox.",
    Callback = function()
        Window:Notify({
            Title = "Your Message",
            Content = textBoxValue,
            Duration = 4,
            Color = "Green",
        })
    end,
})

WidgetsTab:CreateKeybind({
    Name = "Demo Notification Key",
    Default = Enum.KeyCode.G,
    Description = "Press the configured key to show a notification. Use the control to change the key.",
    Callback = function()
        Window:Notify({
            Title = "Keybind Pressed",
            Content = "The demo keybind was activated.",
            Duration = 2,
            Color = "Blue",
        })
    end,
    Changed = function(newKey)
        Window:Notify({
            Title = "Keybind Changed",
            Content = "New key: " .. tostring(newKey),
            Duration = 2,
            Color = "Blue",
        })
    end,
})

WidgetsTab:CreateSection("Messages and Dialogs")

WidgetsTab:CreateButton({
    Name = "Show Message",
    Color = "Orange",
    Description = "Demonstrates the large floating Window:Message() style.",
    Callback = function()
        Window:Message("Welcome to DandysUI!", { Duration = 2 })
    end,
})

WidgetsTab:CreateButton({
    Name = "Show Error Message",
    Color = "Red",
    Description = "Demonstrates the error-style Window:Message() option.",
    Callback = function()
        Window:Message("Demo error message", { Error = true, Duration = 2 })
    end,
})

WidgetsTab:CreateButton({
    Name = "Open Confirm Dialog",
    Color = "Yellow",
    Description = "Demonstrates Window:Dialog() with ConfirmText, CancelText, and Callback(ok).",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Action",
            Content = "Would you like to show a confirmation notification?",
            ConfirmText = "Yes",
            CancelText = "No",
            Callback = function(confirmed)
                if confirmed then
                    Window:Notify({
                        Title = "Confirmed",
                        Content = "You selected Yes.",
                        Duration = 2,
                        Color = "Green",
                    })
                else
                    Window:Notify({
                        Title = "Cancelled",
                        Content = "You selected No.",
                        Duration = 2,
                        Color = "Red",
                    })
                end
            end,
        })
    end,
})

WidgetsTab:CreateButton({
    Name = "Open Multi-Button Dialog",
    Color = "Purple",
    Description = "Demonstrates the Dialog Buttons = {{Text, Color, Callback}, ...} format.",
    Callback = function()
        Window:Dialog({
            Title = "Choose an Option",
            Content = "Select one of the demo actions.",
            Buttons = {
                {
                    Text = "Notify",
                    Color = "Green",
                    Callback = function()
                        Window:Notify({
                            Title = "Option Selected",
                            Content = "You selected Notify.",
                            Duration = 2,
                            Color = "Green",
                        })
                    end,
                },
                {
                    Text = "Message",
                    Color = "Orange",
                    Callback = function()
                        Window:Message("You selected Message!", { Duration = 2 })
                    end,
                },
                {
                    Text = "Cancel",
                    Color = "Red",
                    Callback = function() end,
                },
            },
        })
    end,
})

WidgetsTab:CreateButton({
    Name = "Show Library Flags",
    Color = "Blue",
    Description = "Reads values stored by toggles and other controls in DandysUI.Flags.",
    Callback = function()
        local highlightFlag = DandysUI.Flags and DandysUI.Flags.PlayerHighlights
        local brightFlag = DandysUI.Flags and DandysUI.Flags.FullBright
        Window:Notify({
            Title = "Current Flags",
            Content = "PlayerHighlights = " .. tostring(highlightFlag) .. " | FullBright = " .. tostring(brightFlag),
            Duration = 4,
            Color = "Blue",
        })
    end,
})

--==============================================================
-- SETTINGS TAB: sounds and window methods
--==============================================================
SettingsTab:CreateSection("Sound Settings")

soundToggle = SettingsTab:CreateToggle({
    Name = "UI Sounds Enabled",
    Default = true,
    Flag = "UISoundsEnabled",
    Description = "Enables or disables DandysUI sounds.",
    Callback = function(enabled)
        DandysUI:SetSoundsEnabled(enabled)
    end,
})

SettingsTab:CreateSlider({
    Name = "Sound Volume",
    Min = 0,
    Max = 3,
    Default = 1,
    Increment = 1,
    Suffix = "x",
    Flag = "SoundVolume",
    Description = "Sets the DandysUI sound volume from 0 to 3.",
    Callback = function(value)
        DandysUI:SetVolume(value)
    end,
})

SettingsTab:CreateButton({
    Name = "Play Click Sound",
    Color = "Yellow",
    Description = "Demonstrates DandysUI:PlaySound(soundName).",
    Callback = function()
        DandysUI:PlaySound("Click")
    end,
})

SettingsTab:CreateButton({
    Name = "Toggle Sounds Using Set/Get",
    Color = "Green",
    Description = "Demonstrates the sound toggle's :Get() and :Set(bool) methods.",
    Callback = function()
        if soundToggle then
            soundToggle:Set(not soundToggle:Get())
        end
    end,
})

-- To replace the sound asset IDs, edit only the IDs you want to change and reload them:
-- DandysUI.Sounds.Click = "rbxassetid://YOUR_SOUND_ID"
-- DandysUI.Sounds.Hover = "rbxassetid://YOUR_SOUND_ID"
-- DandysUI:LoadSounds()

SettingsTab:CreateSection("Window Controls")

SettingsTab:CreateButton({
    Name = "Select Player Tab",
    Color = "Blue",
    Description = "Demonstrates Window:SelectTab(tabName).",
    Callback = function()
        Window:SelectTab("Player")
    end,
})

SettingsTab:CreateButton({
    Name = "Toggle Window",
    Color = "Purple",
    Description = "Demonstrates Window:Toggle().",
    Callback = function()
        windowVisible = not windowVisible
        Window:Toggle()
    end,
})

SettingsTab:CreateButton({
    Name = "Set Window Visible",
    Color = "Green",
    Description = "Demonstrates Window:SetVisible(bool).",
    Callback = function()
        windowVisible = true
        Window:SetVisible(true)
    end,
})

local function cleanupDemo()
    for player in pairs(highlights) do
        removeHighlight(player)
    end

    for player, connection in pairs(characterConnections) do
        connection:Disconnect()
        characterConnections[player] = nil
    end

    playerAddedConnection:Disconnect()
    playerRemovingConnection:Disconnect()
    localCharacterConnection:Disconnect()

    applyFullBright(false)

    for humanoid, defaults in pairs(movementDefaults) do
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = defaults.WalkSpeed
            humanoid.UseJumpPower = defaults.UseJumpPower
            humanoid.JumpPower = defaults.JumpPower
            humanoid.JumpHeight = defaults.JumpHeight
        end
    end
end

SettingsTab:CreateButton({
    Name = "Destroy Window / Library",
    Color = "Red",
    Description = "Opens a confirmation dialog before destroying the example UI and restoring changed settings.",
    Callback = function()
        Window:Dialog({
            Title = "Destroy DandysUI?",
            Content = "This closes the demo and restores the example's lighting and movement changes.",
            Buttons = {
                {
                    Text = "Destroy Window",
                    Color = "Orange",
                    Callback = function()
                        cleanupDemo()
                        Window:Destroy()
                    end,
                },
                {
                    Text = "Destroy Library",
                    Color = "Red",
                    Callback = function()
                        cleanupDemo()
                        DandysUI:Destroy()
                    end,
                },
                {
                    Text = "Cancel",
                    Color = "Grey",
                    Callback = function() end,
                },
            },
        })
    end,
})

-- Initial values are applied only when the UI creates the controls;
-- changing the sliders/toggles runs the callbacks above.

# DandysUI

Roblox UI library styled after the Dandy's World menus: dark striped panels with thick black outlines, Fredoka One text with a silver gradient, yellow section headers, `◀ ON ▶` toggles, orange `— / +` sliders, a hover info side panel, purchase-style dialogs, big floating messages and the game's UI sounds.

## Setup
1. Put `DandysUI.lua` in a GitHub repo.
2. Open the file on GitHub, click **Raw**, and copy the URL.
3. Paste that URL into the `loadstring(game:HttpGet("..."))` line of `Example.lua` and run it.
   (In Studio: put `DandysUI.lua` in a ModuleScript and `require` it from a LocalScript.)

## API
```lua
local DandysUI = loadstring(game:HttpGet(https://raw.githubusercontent.com/alihusam078588-web/DandysUI/refs/heads/main/DandysUI.lua))()

local Window = DandysUI:CreateWindow({ Title, Subtitle, Footer, Size, ToggleKey, InfoPanel, InfoText, OpenButton, OpenText })
local Tab    = Window:CreateTab({ Name, Icon })              -- or Window:CreateTab("Name")
Tab:CreateSection("Gameplay")

-- every element accepts Description = "..." (shown in the info panel on hover)
Tab:CreateButton({ Name, Color, Callback })                  -- :SetText, :SetColor
Tab:CreateToggle({ Name, Default, Flag, Callback })          -- :Set(bool), :Get()
Tab:CreateSlider({ Name, Min, Max, Default, Increment, Suffix, Flag, Callback })
Tab:CreateDropdown({ Name, Options, Default, Multi, Flag, Callback })  -- :Refresh(list), :Set, :Get
Tab:CreateTextbox({ Name, Placeholder, Default, NumbersOnly, ClearOnSubmit, Callback(text, enter) })
Tab:CreateKeybind({ Name, Default, Callback, Changed })
Tab:CreateColorPicker({ Name, Default, Callback })
Tab:CreateParagraph({ Title, Content })
Tab:CreateLabel("text")

Window:Notify({ Title, Content, Duration, Color })
Window:Message("Not enough Ichor!", { Error = true, Duration = 2 })
Window:Dialog({ Title, Content, ConfirmText, CancelText, Callback(ok) })  -- or Buttons = {{Text, Color, Callback}, ...}
Window:Toggle() / Window:SetVisible(bool) / Window:SelectTab("Name") / Window:Destroy()

DandysUI:SetSoundsEnabled(bool)  DandysUI:SetVolume(0..3)  DandysUI:PlaySound("Click")
DandysUI.Flags[flag]  DandysUI:Destroy()
```
Colors: `Grey, Green, Red, Yellow, Orange, Blue, Purple, Pink, Black` (or any `Color3`).
Sounds: `Click, Hover, Toggle, Tick, Tab, Open, Close, Notify, Error, Purchase` — edit `DandysUI.Sounds` and call `DandysUI:LoadSounds()` to swap ids.
Theme colours live in `DandysUI.Theme` / `DandysUI.Colors`; change them before `CreateWindow`.

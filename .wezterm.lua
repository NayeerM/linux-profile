-- ~/.wezterm.lua
-- WezTerm config styled to behave like Windows Terminal
-- Place this file at: ~/.wezterm.lua (Linux) or %USERPROFILE%\.wezterm.lua (Windows)

local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- ─────────────────────────────────────────────
-- APPEARANCE — matches Windows Terminal defaults
-- ─────────────────────────────────────────────

-- Campbell is Windows Terminal's default color scheme
config.color_scheme = "Campbell (Gogh)"

-- Font
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size = 12.0

-- Enable ligatures (JetBrains Mono supports them)
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Acrylic/transparency effect (Windows only; ignored on Linux)
config.window_background_opacity = 0.95
config.win32_system_backdrop = "Acrylic"

-- Tab bar styled to sit at the top like Windows Terminal
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32

-- Window padding similar to WT's default
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- Show scrollbar like Windows Terminal
config.enable_scroll_bar = true

-- Cursor style matching WT default (blinking bar)
config.default_cursor_style = "BlinkingBar"

-- ─────────────────────────────────────────────
-- SHELL PROFILES
-- WezTerm equivalent of WT's profile list.
-- Uncomment/adjust based on your OS.
-- ─────────────────────────────────────────────

-- Windows: default to PowerShell 7 (pwsh), fallback to PowerShell 5
-- config.default_prog = { "pwsh.exe", "-NoLogo" }

-- Linux: default shell
-- config.default_prog = { "/bin/bash" }

-- WSL (Windows only) — opens your default WSL distro
-- config.default_prog = { "wsl.exe" }

-- ─────────────────────────────────────────────
-- KEYBINDINGS — mirrors Windows Terminal shortcuts
-- ─────────────────────────────────────────────

config.keys = {
  -- New tab: Ctrl+Shift+T
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },

  -- Close tab: Ctrl+Shift+W
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

  -- Next tab: Ctrl+Tab
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },

  -- Previous tab: Ctrl+Shift+Tab
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

  -- Switch to tab by number: Ctrl+Shift+1 through 9
  { key = "1", mods = "CTRL|SHIFT", action = act.ActivateTab(0) },
  { key = "2", mods = "CTRL|SHIFT", action = act.ActivateTab(1) },
  { key = "3", mods = "CTRL|SHIFT", action = act.ActivateTab(2) },
  { key = "4", mods = "CTRL|SHIFT", action = act.ActivateTab(3) },
  { key = "5", mods = "CTRL|SHIFT", action = act.ActivateTab(4) },
  { key = "6", mods = "CTRL|SHIFT", action = act.ActivateTab(5) },
  { key = "7", mods = "CTRL|SHIFT", action = act.ActivateTab(6) },
  { key = "8", mods = "CTRL|SHIFT", action = act.ActivateTab(7) },
  { key = "9", mods = "CTRL|SHIFT", action = act.ActivateTab(8) },

  -- Split pane horizontally: Alt+Shift+D (like WT)
  { key = "d", mods = "ALT|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- Split pane vertically
  { key = "d", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Navigate between panes: Alt+Arrow keys
  { key = "LeftArrow",  mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow",    mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow",  mods = "ALT", action = act.ActivatePaneDirection("Down") },

  -- Copy: Ctrl+Shift+C
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },

  -- Paste: Ctrl+Shift+V
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- Find/search: Ctrl+Shift+F
  { key = "f", mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },

  -- Increase font size: Ctrl+=
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },

  -- Decrease font size: Ctrl+-
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },

  -- Reset font size: Ctrl+0
  { key = "0", mods = "CTRL", action = act.ResetFontSize },

  -- Toggle fullscreen: Alt+Enter (like WT)
  { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },

  -- Command palette: Ctrl+Shift+P
  { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },

  -- Enter copy mode: Ctrl+Shift+X
  -- Once inside: Shift+Arrows to select, Ctrl+Shift+C to copy, Esc to exit
  { key = "x", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
}

-- ─────────────────────────────────────────────
-- COPY MODE — Shift+Arrow keys to select text
-- (only active after pressing Ctrl+Shift+X)
-- ─────────────────────────────────────────────

local copy_mode = wezterm.gui.default_key_tables().copy_mode

-- Shift+Arrow: start selection and move
table.insert(copy_mode, { key = "LeftArrow",  mods = "SHIFT", action = act.Multiple({
  act.CopyMode({ SetSelectionMode = "Cell" }),
  act.CopyMode("MoveLeft"),
})})
table.insert(copy_mode, { key = "RightArrow", mods = "SHIFT", action = act.Multiple({
  act.CopyMode({ SetSelectionMode = "Cell" }),
  act.CopyMode("MoveRight"),
})})
table.insert(copy_mode, { key = "UpArrow",    mods = "SHIFT", action = act.Multiple({
  act.CopyMode({ SetSelectionMode = "Cell" }),
  act.CopyMode("MoveUp"),
})})
table.insert(copy_mode, { key = "DownArrow",  mods = "SHIFT", action = act.Multiple({
  act.CopyMode({ SetSelectionMode = "Cell" }),
  act.CopyMode("MoveDown"),
})})

-- Ctrl+Shift+Arrow: select word by word
table.insert(copy_mode, { key = "LeftArrow",  mods = "CTRL|SHIFT", action = act.Multiple({
  act.CopyMode({ SetSelectionMode = "Cell" }),
  act.CopyMode("MoveBackwardWord"),
})})
table.insert(copy_mode, { key = "RightArrow", mods = "CTRL|SHIFT", action = act.Multiple({
  act.CopyMode({ SetSelectionMode = "Cell" }),
  act.CopyMode("MoveForwardWord"),
})})

config.key_tables = {
  copy_mode = copy_mode,
}

-- ─────────────────────────────────────────────
-- MOUSE — right-click to paste, like WT
-- ─────────────────────────────────────────────

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },
}

config.selection_word_boundary = " \t\n{}[]()\"'`,;:@│"

-- ─────────────────────────────────────────────
-- SCROLLBACK — WT defaults to 9001 lines
-- ─────────────────────────────────────────────

config.scrollback_lines = 9001

-- ─────────────────────────────────────────────
-- MISC
-- ─────────────────────────────────────────────

config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
}

config.window_close_confirmation = "AlwaysPrompt"
config.max_fps = 60

return config

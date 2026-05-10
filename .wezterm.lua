local wezterm = require("wezterm")
local config = wezterm.config_builder()
local launch_menu = {}
local act = wezterm.action

local isWindows = wezterm.target_triple:find("windows")

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
resurrect.state_manager.periodic_save({
    interval_seconds = 60,
    save_workspaces = true,
    save_windows = true,
    save_tabs = true,
})

wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

wezterm.on("augment-command-palette", function(window, pane)
  local workspace_state = resurrect.workspace_state
  return {
    {
      brief = "Window | Workspadce: Switch Workspace",
      icon = "md_briefcase_arrow_up_down",
      action = workspace_switcher.switch_workspace(),
    },
    {
      brief = "Window | Workspace: Rename Workspace",
      icon = "md_briefcase_edit",
      action = wezterm.action.PromptInputLine({
        description = "Enter new name for workspace",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
            resurrect.state_manager.save_state(workspace_state.get_workspace_state())
          end
        end),
      }),
    },
  }
end)

-- ─────────────────────────────────────────────
-- THEME
-- ─────────────────────────────────────────────

local tab_style    = "square"
local leader_prefix = utf8.char(0x1f30a) -- 🌊

config.color_scheme = "Catppuccin Macchiato"

-- Catppuccin Macchiato palette
local colors = {
    mauve    = "#c6a0f6",
    lavender = "#b7bdf8",
    crust    = "#181926",
    text     = "#cad3f5",
}

-- Semantic aliases used throughout
local ui = {
    border              = colors.lavender,
    tab_active_fg       = colors.mauve,
    tab_active_bg       = colors.crust,
    tab_text            = colors.crust,
    leader_arrow_fg     = colors.lavender,
    leader_arrow_bg     = colors.crust,
}

-- ─────────────────────────────────────────────
-- APPEARANCE
-- ─────────────────────────────────────────────

config.font            = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size       = 12.0
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

config.window_decorations      = "RESIZE"
config.window_background_opacity = 0.95
config.win32_system_backdrop   = "Acrylic"
config.window_padding          = { left = 8, right = 8, top = 8, bottom = 8 }
config.initial_cols            = 120
config.initial_rows            = 40

-- config.window_frame = {
--     border_left_width   = "0.2cell",
--     border_right_width  = "0.2cell",
--     border_bottom_height = "0.15cell",
--     border_top_height   = "0.15cell",
--     border_left_color   = ui.border,
--     border_right_color  = ui.border,
--     border_bottom_color = ui.border,
--     border_top_color    = ui.border,
-- }

config.default_cursor_style = "BlinkingBar"
config.enable_scroll_bar    = true

-- ─────────────────────────────────────────────
-- TAB BAR
-- ─────────────────────────────────────────────

config.tab_bar_at_bottom            = true
config.use_fancy_tab_bar            = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_and_split_indices_are_zero_based = true
config.tab_max_width                = 32

local function tab_title(tab_info)
    local title = tab_info.tab_title
    if title and #title > 0 then return title end
    return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local left_edge, right_edge = "", ""
    local title = " " .. tab.tab_index .. ": " .. tab_title(tab) .. " "

    if tab_style == "rounded" then
        title      = wezterm.truncate_right(tab.tab_index .. ": " .. tab_title(tab), max_width - 2)
        left_edge  = wezterm.nerdfonts.ple_left_half_circle_thick
        right_edge = wezterm.nerdfonts.ple_right_half_circle_thick
    end

    if tab.is_active then
        return {
            { Background = { Color = ui.tab_active_bg } },
            { Foreground = { Color = ui.tab_active_fg } },
            { Text = left_edge },
            { Background = { Color = ui.tab_active_fg } },
            { Foreground = { Color = ui.tab_text } },
            { Text = title },
            { Background = { Color = ui.tab_active_bg } },
            { Foreground = { Color = ui.tab_active_fg } },
            { Text = right_edge },
        }
    end
end)

-- ─────────────────────────────────────────────
-- LEADER KEY STATUS
-- ─────────────────────────────────────────────

wezterm.on("update-status", function(window, _)
    local arrow    = ""
    local arrow_fg = { Foreground = { Color = ui.leader_arrow_fg } }
    local arrow_bg = { Background = { Color = ui.leader_arrow_bg } }
    local prefix   = ""

    if window:leader_is_active() then
        prefix = " " .. leader_prefix
        arrow  = wezterm.nerdfonts.pl_left_hard_divider

        for _, tab_info in ipairs(window:mux_window():tabs_with_info()) do
            if tab_info.is_active and tab_info.index == 0 then
                arrow_bg = { Foreground = { Color = ui.tab_active_fg } }
                arrow    = wezterm.nerdfonts.pl_right_hard_divider
                break
            end
        end
    end

    window:set_left_status(wezterm.format {
        { Background = { Color = ui.leader_arrow_fg } },
        { Text = prefix },
        arrow_fg,
        arrow_bg,
        { Text = arrow },
    })
end)

-- ─────────────────────────────────────────────
-- KEYBINDINGS
-- ─────────────────────────────────────────────

config.leader = { key = "q", mods = "ALT", timeout_milliseconds = 2000 }

config.keys = {
    -- Tabs
    { key = "t",   mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "w",   mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
    { key = "Tab", mods = "CTRL",       action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

    -- Pane splitting
    { key = "d", mods = "ALT|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d", mods = "ALT",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Pane navigation
    { key = "LeftArrow",  mods = "ALT", action = act.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
    { key = "UpArrow",    mods = "ALT", action = act.ActivatePaneDirection("Up") },
    { key = "DownArrow",  mods = "ALT", action = act.ActivatePaneDirection("Down") },

    -- Clipboard
    { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

    -- Misc
    { key = "f",     mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "=",     mods = "CTRL",       action = act.IncreaseFontSize },
    { key = "-",     mods = "CTRL",       action = act.DecreaseFontSize },
    { key = "0",     mods = "CTRL",       action = act.ResetFontSize },
    { key = "Enter", mods = "ALT",        action = act.ToggleFullScreen },
    { key = "p",     mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
    { key = "x",     mods = "CTRL|SHIFT", action = act.ActivateCopyMode },

    -- Save workspaces
    {
        key = "w",
        mods = "LEADER",
        action = wezterm.action_callback(function(win, pane)
            resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
        end),
    },
    {
        key = "W",
        mods = "LEADER",
        action = resurrect.window_state.save_window_action(),
    },
    {
        key = "T",
        mods = "LEADER",
        action = resurrect.tab_state.save_tab_action(),
    },
    { key = "s", mods = "LEADER", action = wezterm.action_callback(function(win, pane)
        win:perform_action(act.PromptInputLine({
        description = "Name this session (leave blank for default):",
        action = wezterm.action_callback(function(win, pane, line)
            local state = resurrect.workspace_state.get_workspace_state()
            if line and #line > 0 then
            resurrect.state_manager.save_state(state, line)
            else
            resurrect.state_manager.save_state(state)
            end
        end),
        }), pane)
        end)
    },
    {
        key = "r",
        mods = "LEADER",
        action = wezterm.action_callback(function(win, pane)
            resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
                local type = string.match(id, "^([^/]+)") -- match before '/'
                id = string.match(id, "([^/]+)$") -- match after '/'
                id = string.match(id, "(.+)%..+$") -- remove file extention
                local opts = {
                    close_open_tabs = true,
                    window = pane:window(),
                    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                    relative = true,
                    restore_text = true,
                }
                if type == "workspace" then
                local state = resurrect.state_manager.load_state(id, "workspace")
                resurrect.workspace_state.restore_workspace(state, opts)
                elseif type == "window" then
                local state = resurrect.state_manager.load_state(id, "window")
                resurrect.window_state.restore_window(pane:window(), state, opts)
                elseif type == "tab" then
                local state = resurrect.state_manager.load_state(id, "tab")
                resurrect.tab_state.restore_tab(pane:tab(), state, opts)
                end
            end)
        end),
    },
    {
        key = "d",
        mods = "LEADER",
        action = wezterm.action_callback(function(win, pane)
        resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
            resurrect.state_manager.delete_state(id)
            end,
            {
            title = "Delete State",
            description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
            fuzzy_description = "Search State to Delete: ",
            is_fuzzy = true,
            })
        end),
    },
}

-- Leader + 0–9 to switch tabs
for i = 0, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i),
    })
end

-- ─────────────────────────────────────────────
-- MOUSE
-- ─────────────────────────────────────────────

config.mouse_bindings = {
    {
        event  = { Down = { streak = 1, button = "Right" } },
        mods   = "NONE",
        action = act.PasteFrom("Clipboard"),
    },
}

config.selection_word_boundary = " \t\n{}[]()\"'`,;:@│"

-- ─────────────────────────────────────────────
-- MISC
-- ─────────────────────────────────────────────

config.scrollback_lines         = 9001
config.audible_bell             = "Disabled"
config.visual_bell              = { fade_in_duration_ms = 75, fade_out_duration_ms = 75 }
config.window_close_confirmation = "AlwaysPrompt"
config.max_fps                  = 60

if isWindows then
  table.insert(launch_menu, {
    label = 'PowerShell',
    args = { 'powershell.exe', '-NoLogo' },
  })
else
  table.insert(launch_menu, {
    label = 'Zsh',
    args = { 'zsh' },
  })
  table.insert(launch_menu, {
    label = 'Bash',
    args = { 'bash' },
  })
end

config.launch_menu = launch_menu

config.unix_domains = {
  {
    name = 'unix',
  },
}

config.default_gui_startup_args = { 'connect', 'unix' }

return config

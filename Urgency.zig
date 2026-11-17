//! An urgency section: what changes for every notification of that urgency, written like a
//! rule's modifying options. null fields are not written, leaving them to dunstrc and dunst's
//! defaults.

const Urgency = @This();

const kosm = @import("kosm");
const App = @import("App.zig");

/// `background`: the notification's background. null: dunst's.
background: ?kosm.Color = null,
/// `foreground`: its text. null: dunst's.
foreground: ?kosm.Color = null,
/// `highlight`: the progress bar, one color or a gradient along it. null: dunst's.
highlight: ?App.Highlight = null,
/// `format`: its text, like `[global]`'s `format`. null: the global one.
format: ?[]const u8 = null,
/// `frame_color`: its frame. null: dunst's.
frame_color: ?kosm.Color = null,
/// `fullscreen`: what happens while a fullscreen window is focused. null: dunst's default,
/// `show`.
fullscreen: ?App.Fullscreen = null,
/// `min_icon_size`: smaller icons are scaled up to this, in pixels. null: the global one.
min_icon_size: ?u32 = null,
/// `max_icon_size`: larger icons are scaled down to this in pixels, 0 to never scale down. null:
/// the global one.
max_icon_size: ?u32 = null,
/// `new_icon`: an icon path or name replacing the one sent. null: the sent one.
new_icon: ?[]const u8 = null,
/// `icon_position`: where the icon sits, `off` for none. null: the global one.
icon_position: ?App.IconPosition = null,
/// `default_icon`: an icon path or name for notifications sent without one. null: none.
default_icon: ?[]const u8 = null,
/// `set_stack_tag`: a stack tag; notifications of one app with the same tag replace each other.
/// null: the sent one.
set_stack_tag: ?[]const u8 = null,
/// `set_transient`: whether notifications time out even while the user is idle. null: the sent
/// hint, off without one.
set_transient: ?bool = null,
/// `set_category`: a freedesktop notification category. null: the sent one.
set_category: ?[]const u8 = null,
/// `timeout`: how long notifications show, 0 for until closed. null: dunst's default, 10
/// seconds for low and normal urgency, 0 for critical.
timeout: ?App.Time = null,
/// `override_dbus_timeout`: a timeout winning over the one sent and over `timeout`. null: none.
override_dbus_timeout: ?App.Time = null,
/// `urgency`: changes the urgency, seen only by rules defined later. null: unchanged.
urgency: ?App.Level = null,
/// `override_pause_level`: notifications show while paused below this level, 0 to 100. null:
/// the global one.
override_pause_level: ?u8 = null,
/// `skip_display`: keep notifications in history without showing them. null: dunst's default,
/// off.
skip_display: ?bool = null,
/// `history_ignore`: show notifications but keep them out of history. null: dunst's default,
/// off.
history_ignore: ?bool = null,
/// `action_name`: the action `do_action` invokes. null: dunst's default, `default`.
action_name: ?[]const u8 = null,
/// `word_wrap`: wrap lines too long for the window. null: dunst's default, on.
word_wrap: ?bool = null,
/// `ellipsize`: where lines too long are cut. null: the global one.
ellipsize: ?App.Ellipsize = null,
/// `alignment`: how the text is aligned. null: the global one.
alignment: ?App.HorizontalAlignment = null,
/// `hide_text`: show only the icon and progress bar. null: dunst's default, off.
hide_text: ?bool = null,
/// `markup`: how markup in notifications is handled. null: the global one.
markup: ?App.Markup = null,
/// `script`: a program run for every notification, given its details in `DUNST_*` variables.
/// null: none.
script: ?[]const u8 = null,

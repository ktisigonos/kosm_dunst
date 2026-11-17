//! Dunst's `[global]` options. null fields are not written, leaving them to dunstrc and dunst's
//! defaults.

const Global = @This();

const kosm = @import("kosm");
const App = @import("App.zig");

/// `default_pause_level`: the pause level dunst starts at, 0 to 100; only notifications whose
/// `override_pause_level` is higher show. null: dunst's default, 0.
default_pause_level: ?u8 = null,
/// `monitor`: the monitor notifications show on, by number from 0 or by name; `follow` other
/// than `none` overrides it. null: dunst's default, 0.
monitor: ?App.Monitor = null,
/// `follow`: which monitor notifications follow. null: dunst's default, `none`.
follow: ?App.Follow = null,
/// `enable_posix_regex`: rules match with POSIX extended regular expressions instead of
/// fnmatch(3). null: dunst's default, off.
enable_posix_regex: ?bool = null,
/// `width`: the window's width in pixels, fixed or growing within a range. null: dunst's
/// default, 300.
width: ?App.Length = null,
/// `height`: each notification's height in pixels, fixed or growing within a range. null:
/// dunst's default, from 0 to 300.
height: ?App.Length = null,
/// `notification_limit`: how many notifications show at once, 0 for no limit. null: dunst's
/// default, 20.
notification_limit: ?u32 = null,
/// `origin`: the screen corner or edge the window is placed from. null: dunst's default,
/// `top_right`.
origin: ?App.Origin = null,
/// `offset`: the window's distance from `origin`, in pixels. null: dunst's default, 10 and 50.
offset: ?App.Offset = null,
/// `scale`: the factor sizes are scaled by, 0 to detect it. X11 only. null: dunst's default, 0.
scale: ?f64 = null,
/// `progress_bar`: draw a progress bar for notifications with a value hint. null: dunst's
/// default, on.
progress_bar: ?bool = null,
/// `progress_bar_horizontal_alignment`: where the progress bar sits. null: dunst's default,
/// `center`.
progress_bar_horizontal_alignment: ?App.HorizontalAlignment = null,
/// `progress_bar_height`: the progress bar's height in pixels, its frame included. null: dunst's
/// default, 10.
progress_bar_height: ?u32 = null,
/// `progress_bar_min_width`: in pixels. null: dunst's default, 150.
progress_bar_min_width: ?u32 = null,
/// `progress_bar_max_width`: in pixels. null: dunst's default, 300.
progress_bar_max_width: ?u32 = null,
/// `progress_bar_frame_width`: in pixels. null: dunst's default, 1.
progress_bar_frame_width: ?u32 = null,
/// `progress_bar_corner_radius`: in pixels. null: dunst's default, 0.
progress_bar_corner_radius: ?u32 = null,
/// `progress_bar_corners`: which of the progress bar's corners are rounded. null: dunst's
/// default, `all`.
progress_bar_corners: ?[]const App.Corner = null,
/// `icon_corner_radius`: in pixels. null: dunst's default, 0.
icon_corner_radius: ?u32 = null,
/// `icon_corners`: which of the icon's corners are rounded. null: dunst's default, `all`.
icon_corners: ?[]const App.Corner = null,
/// `indicate_hidden`: the last slot shows how many notifications `notification_limit` hides.
/// null: dunst's default, on.
indicate_hidden: ?bool = null,
/// `transparency`: how transparent the whole window is, 0 (opaque) to 100. X11 only; on Wayland
/// give the colors alpha instead. null: dunst's default, 0.
transparency: ?u8 = null,
/// `separator_height`: the line between notifications in pixels, 0 for none; ignored with a
/// `gap_size`. null: dunst's default, 2.
separator_height: ?u32 = null,
/// `padding`: from the text to the separator or frame, vertically, in pixels. null: dunst's
/// default, 8.
padding: ?u32 = null,
/// `horizontal_padding`: from the text to the frame, horizontally, in pixels. null: dunst's
/// default, 8.
horizontal_padding: ?u32 = null,
/// `text_icon_padding`: from the text to the icon, in pixels. null: dunst's default, 0.
text_icon_padding: ?u32 = null,
/// `frame_width`: the frame around each notification, in pixels. null: dunst's default, 3.
frame_width: ?u32 = null,
/// `frame_color`: the frame of every notification, unless its urgency sets one. null: dunst's.
frame_color: ?kosm.Color = null,
/// `gap_size`: the gap between notifications in pixels, each framed then. Needs a compositor.
/// null: dunst's default, 0.
gap_size: ?u32 = null,
/// `separator_color`: the line between stacked notifications. null: dunst's default, `.frame`.
separator_color: ?App.SeparatorColor = null,
/// `sort`: the order notifications stack in. null: dunst's default, `urgency_descending`.
sort: ?App.Sort = null,
/// `idle_threshold`: notifications don't time out while the user is idle this long, 0 to
/// disable. null: dunst's default, 0.
idle_threshold: ?App.Time = null,
/// `layer`: the Wayland layer notifications show on. null: dunst's default, `overlay`.
layer: ?App.Layer = null,
/// `force_xwayland`: use X11 output even on Wayland. null: dunst's default, off.
force_xwayland: ?bool = null,
/// `font`: the families in fallback order and a size. null: dunst's default, `Monospace 8`.
font: ?App.Font = null,
/// `line_height`: extra space between text lines, in pixels. null: dunst's default, 0.
line_height: ?u32 = null,
/// `markup`: how markup in notifications is handled. null: dunst's default, `no`.
markup: ?App.Markup = null,
/// `format`: the notification's text, Pango markup with `%a` appname, `%s` summary, `%b` body,
/// `%c` category, `%S` stack tag, `%i`/`%I` icon with/without path, `%p`/`%n` progress, `%%`.
/// null: dunst's default, `<b>%s</b>\n%b`.
format: ?[]const u8 = null,
/// `alignment`: how the text is aligned. null: dunst's default, `left`.
alignment: ?App.HorizontalAlignment = null,
/// `vertical_alignment`: how the text and icon are aligned. null: dunst's default, `center`.
vertical_alignment: ?App.VerticalAlignment = null,
/// `show_age_threshold`: show a notification's age once it is this old. null: dunst's default,
/// after 60 seconds.
show_age_threshold: ?App.AgeThreshold = null,
/// `ellipsize`: where lines too long are cut. null: dunst's default, `middle`.
ellipsize: ?App.Ellipsize = null,
/// `ignore_newline`: replace newlines in notifications with spaces. null: dunst's default, off.
ignore_newline: ?bool = null,
/// `stack_duplicates`: stack identical notifications into one. null: dunst's default, on.
stack_duplicates: ?bool = null,
/// `hide_duplicate_count`: hide how many duplicates are stacked. null: dunst's default, off.
hide_duplicate_count: ?bool = null,
/// `show_indicators`: mark notifications that have actions or URLs. null: dunst's default, on.
show_indicators: ?bool = null,
/// `icon_position`: where the icon sits, `off` for none. null: dunst's default, `left`.
icon_position: ?App.IconPosition = null,
/// `min_icon_size`: smaller icons are scaled up to this, in pixels. null: dunst's default, 32.
min_icon_size: ?u32 = null,
/// `max_icon_size`: larger icons are scaled down to this in pixels, 0 to never scale down. null:
/// dunst's default, 128.
max_icon_size: ?u32 = null,
/// `icon_path`: the folders searched for icons, not recursively; none may hold `:`. null:
/// dunst's default, GNOME's 16x16 status and devices icons.
icon_path: ?[]const []const u8 = null,
/// `icon_theme`: icon theme folder names, most important first, used with
/// `enable_recursive_icon_lookup`; none may hold `,`. null: dunst's default, `Adwaita`.
icon_theme: ?[]const []const u8 = null,
/// `enable_recursive_icon_lookup`: look icons up in `icon_theme` instead of `icon_path`. null:
/// dunst's default, off.
enable_recursive_icon_lookup: ?bool = null,
/// `sticky_history`: notifications recalled from history don't time out. null: dunst's
/// default, on.
sticky_history: ?bool = null,
/// `history_length`: how many notifications history keeps. null: dunst's default, 20.
history_length: ?u32 = null,
/// `dmenu`: the dmenu-like command the context menu runs. null: dunst's default,
/// `/usr/bin/dmenu -p dunst`.
dmenu: ?[]const u8 = null,
/// `browser`: the command URLs are opened with, the URL appended. null: dunst's default,
/// `/usr/bin/xdg-open`.
browser: ?[]const u8 = null,
/// `always_run_script`: run rules' scripts even for notifications whose format is empty. null:
/// dunst's default, on.
always_run_script: ?bool = null,
/// `title`: the windows' title. X11 only. null: dunst's default, `Dunst`.
title: ?[]const u8 = null,
/// `class`: the windows' class. X11 only. null: dunst's default, `Dunst`.
class: ?[]const u8 = null,
/// `force_xinerama`: use Xinerama instead of RandR, for old nVidia drivers. X11 only. null:
/// dunst's default, off.
force_xinerama: ?bool = null,
/// `corner_radius`: how round each notification's corners are, in pixels. null: dunst's
/// default, 0.
corner_radius: ?u32 = null,
/// `corners`: which of the window's corners are rounded. null: dunst's default, `all`.
corners: ?[]const App.Corner = null,
/// `mouse_left_click`: what a left click (or a touch) does, in order. null: dunst's default,
/// `close_current`.
mouse_left_click: ?[]const App.MouseAction = null,
/// `mouse_middle_click`: what a middle click does, in order. null: dunst's default, `do_action`
/// then `remove_current`.
mouse_middle_click: ?[]const App.MouseAction = null,
/// `mouse_right_click`: what a right click does, in order. null: dunst's default, `close_all`.
mouse_right_click: ?[]const App.MouseAction = null,
/// `ignore_dbusclose`: ignore apps closing their notifications, so every timeout is kept. null:
/// dunst's default, off.
ignore_dbusclose: ?bool = null,
/// `override_pause_level`: notifications show while paused below this level, 0 to 100. null:
/// dunst's default, 0.
override_pause_level: ?u8 = null,
/// `close`: the shortcut closing a notification, like `ctrl+space`. X11 only. null: none.
close: ?[]const u8 = null,
/// `close_all`: the shortcut closing every notification. X11 only. null: none.
close_all: ?[]const u8 = null,
/// `history`: the shortcut recalling one notification from history. X11 only. null: none.
history: ?[]const u8 = null,
/// `context`: the shortcut opening the context menu. X11 only. null: none.
context: ?[]const u8 = null,

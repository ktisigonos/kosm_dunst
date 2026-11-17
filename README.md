# kosm_dunst

Dunst for kosm: the `dunst` adapter (an INI dialect: `key = "value"`, `#rrggbbaa` colors) and
the dunst app, covering every documented option of dunst's `[global]`, `[experimental]` and
urgency sections.

The app writes only the options that are set to the drop-in
`~/.config/dunst/dunstrc.d/50-kosm.conf`. Dunst reads drop-ins after `dunstrc` with no setup;
delete the colors and font `dunstrc` sets itself so there is one place for them. After every
apply the app runs `dunstctl reload`; with no dunst running, kosm warns and carries on.

`from(theme)` sets every urgency's colors: the background from the theme's background role
with the theme's `background_alpha`, the text from the foreground (muted for low urgency), the
frame the accent (the error role when critical) and the progress bar a strong foreground. The separator takes
the frame's color. The font is left alone.

## Fields

Every option is null by default, which leaves it to `dunstrc` and dunst's defaults. Names are
dunst's (`man 5 dunst`); the values below are their Zig types.

| Field | Default |
|---|---|
| `file` | `~/.config/dunst/dunstrc.d/50-kosm.conf` |
| `format` | the adapter's: `#rrggbbaa`, `true`/`false` |
| `global.font` | `.{ .families = &.{ "Iosevka", "Noto Color Emoji" }, .size = 13 }` |
| `global.separator_color` | `.auto`, `.foreground`, `.frame` or `.{ .color = ... }`; `from`: `.frame` |
| `global.monitor` | `.{ .index = 0 }` or `.{ .name = "DP-1" }` |
| `global.width`, `global.height` | `.{ .fixed = 300 }` or `.{ .range = .{ .min = 0, .max = 300 } }` |
| `global.offset` | `.{ .horizontal = 10, .vertical = 50 }` |
| `global.origin` | `.top_left`, `.top_center`, `.top_right`, `.bottom_left`, `.bottom_center`, `.bottom_right`, `.left_center`, `.center`, `.right_center` |
| `global.corners`, `global.progress_bar_corners`, `global.icon_corners` | a list of `.none`, `.all`, `.top_left`, `.top_right`, `.bottom_left`, `.bottom_right`, `.top`, `.bottom`, `.left`, `.right` |
| `global.mouse_left_click`, `global.mouse_middle_click`, `global.mouse_right_click` | a list of `.none`, `.do_action`, `.open_url`, `.close_current`, `.close_all`, `.remove_current`, `.context`, `.context_all` |
| `global.idle_threshold` | a time: `.{ .milliseconds = 500 }`, `.seconds`, `.minutes`, `.hours`, `.days` |
| `global.show_age_threshold` | `.never` or `.{ .after = .{ .seconds = 60 } }` |
| `global.icon_path`, `global.icon_theme` | lists of folders and theme names |
| `global.follow` | `.none`, `.mouse`, `.keyboard` |
| `global.sort` | `.urgency_descending`, `.urgency_ascending`, `.id`, `.update` |
| `global.layer` | `.bottom`, `.top`, `.overlay` |
| `global.default_pause_level`, `global.override_pause_level`, `global.transparency` | 0 to 100 |
| `global.scale` | a factor, 0 to detect it |
| `global.frame_color`, `global.markup`, `global.format`, `global.alignment`, `global.vertical_alignment`, `global.ellipsize`, `global.icon_position`, `global.min_icon_size`, `global.max_icon_size`, `global.progress_bar_horizontal_alignment` | as in the urgency sections |
| every other `[global]` option | a number of pixels or items, a bool, or text: `notification_limit`, `progress_bar`, `progress_bar_height`, `progress_bar_min_width`, `progress_bar_max_width`, `progress_bar_frame_width`, `progress_bar_corner_radius`, `icon_corner_radius`, `indicate_hidden`, `separator_height`, `padding`, `horizontal_padding`, `text_icon_padding`, `frame_width`, `gap_size`, `force_xwayland`, `line_height`, `ignore_newline`, `stack_duplicates`, `hide_duplicate_count`, `show_indicators`, `enable_recursive_icon_lookup`, `enable_posix_regex`, `sticky_history`, `history_length`, `dmenu`, `browser`, `always_run_script`, `title`, `class`, `force_xinerama`, `corner_radius`, `ignore_dbusclose`, and the X11 shortcuts `close`, `close_all`, `history`, `context` |
| `experimental` | `per_monitor_dpi`, `pause_on_mouse_over`, `enable_pcre_regex` |
| `urgency_low`, `urgency_normal`, `urgency_critical` | every modifying rule option: `background`, `foreground`, `frame_color` (colors); `highlight` (`.{ .color = ... }` or `.{ .gradient = &.{ ... } }`); `format`; `fullscreen` (`.show`, `.delay`, `.pushback`, `.suppress`); `min_icon_size`, `max_icon_size`; `new_icon`, `default_icon`; `icon_position` (`.left`, `.right`, `.top`, `.off`); `set_stack_tag`, `set_transient`, `set_category`; `timeout`, `override_dbus_timeout` (times); `urgency` (`.low`, `.normal`, `.critical`); `override_pause_level`; `skip_display`, `history_ignore`; `action_name`; `word_wrap`, `hide_text`; `ellipsize` (`.start`, `.middle`, `.end`); `alignment` (`.left`, `.center`, `.right`); `markup` (`.full`, `.strip`, `.no`); `script`. `from` sets the colors. |
| `extra` | none; other options and rules by `section.option`: `.{ .path = "spotify.appname", .value = .{ .string = "Spotify" } }` |

Values dunst would misread fail the apply naming the option: a level above 100, a range whose
`min` exceeds its `max`, an empty list, or a list item holding its separator. A monitor given by
name makes dunst log `No digits found` before it uses the name.

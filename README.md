# kosm_dunst

Dunst for kosm: the `dunst` adapter (an INI dialect: `key = "value"`, `#rrggbbaa` colors) and
the dunst app, covering dunst's font and the colors of each urgency.

The app writes only the options that are set to the drop-in
`~/.config/dunst/dunstrc.d/50-kosm.conf`. Dunst reads drop-ins after `dunstrc` with no setup;
delete the colors and font `dunstrc` sets itself so there is one place for them. After every
apply the app runs `dunstctl reload`; with no dunst running, kosm warns and carries on.

`from(theme)` sets every urgency's colors: the background from the theme's background role
with the theme's `background_alpha`, the text from the foreground (muted for low urgency), the
frame the accent (the error role when critical) and the progress bar a strong foreground. The separator takes
the frame's color. The font is left alone.

## Fields

| Field | Default |
|---|---|
| `file` | `~/.config/dunst/dunstrc.d/50-kosm.conf` |
| `format` | the adapter's: `#rrggbbaa`, `true`/`false` |
| `global.font` | null; `.{ .families = &.{ "Iosevka", "Noto Color Emoji" }, .size = 13 }` |
| `global.separator_color` | null; `.auto`, `.foreground`, `.frame` or `.{ .color = ... }` |
| `urgency_low`, `urgency_normal`, `urgency_critical` | `background`, `foreground`, `frame_color`, `highlight`; null leaves each to dunst |
| `extra` | none; other options by `section.option`: `.{ .path = "global.corner_radius", .value = .{ .integer = 10 } }` |

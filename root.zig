//! Dunst: its font and notification colors, in a drop-in file dunst reads after dunstrc.

const std = @import("std");
const kosm_ini = @import("kosm_ini");

/// Dunst's font and colors; build one with `from`.
pub const App = @import("App.zig");
/// Colors from the theme.
pub const from = App.from;
/// dunstrc's INI: `key = "value"`, `#` comments, `#rrggbbaa` colors and `true`/`false`.
pub const adapter = kosm_ini.dialect(.{
    .name = "dunst",
    .default_format = .{ .color = .hex8, .boolean = .true_false },
    .comments = &.{"#"},
    .nested_headers = false,
    .top_level_keys = false,
    .strings = .quoted,
});

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(App);
}

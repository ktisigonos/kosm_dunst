//! Dunst's font and notification colors. `generate` writes the set ones to `file`, a drop-in
//! dunst reads after `dunstrc`, so they win over it; null options are left to dunstrc and
//! dunst's defaults. Field names are dunst's.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");

/// The drop-in kosm owns. Dunst reads `dunstrc.d/*.conf` beside the dunstrc it uses, later
/// names winning. Default: `~/.config/dunst/dunstrc.d/50-kosm.conf`.
file: []const u8 = "~/.config/dunst/dunstrc.d/50-kosm.conf",
/// How values are spelled. Null fields take the dunst adapter's: `#rrggbbaa`, `true`/`false`.
format: kosm.Format = .{},
/// Dunst's `[global]` options.
global: Global = .{},
/// Colors of low-urgency notifications.
urgency_low: Urgency = .{},
/// Colors of normal notifications, most of them.
urgency_normal: Urgency = .{},
/// Colors of critical notifications.
urgency_critical: Urgency = .{},
/// Options the app doesn't cover, by `section.option`:
/// `.{ .path = "global.corner_radius", .value = .{ .integer = 10 } }`. One that repeats a set
/// option or another extra fails the apply. Default: none.
extra: []const kosm.Setting = &.{},

/// The `[global]` options the app covers.
pub const Global = struct {
    /// `font`: the families in fallback order and a size. null: dunst's default, `Monospace 8`.
    font: ?Font = null,
    /// `separator_color`: the line between stacked notifications. null: dunst's default, `.frame`.
    separator_color: ?SeparatorColor = null,
};

/// A Pango font description, written `Family, Fallback 13`.
pub const Font = struct {
    /// Family names in fallback order. None may hold `,`, which separates them.
    families: []const []const u8,
    /// The size in points. null: Pango's.
    size: ?f64 = null,
};

/// What the separator between notifications is drawn in.
pub const SeparatorColor = union(enum) {
    /// A color chosen from the notification's.
    auto,
    /// The notification's foreground.
    foreground,
    /// The notification's frame color.
    frame,
    /// A color of its own.
    color: kosm.Color,
};

/// The colors of one urgency.
pub const Urgency = struct {
    /// The notification's background. null: dunst's.
    background: ?kosm.Color = null,
    /// Its text. null: dunst's.
    foreground: ?kosm.Color = null,
    /// Its frame. null: dunst's.
    frame_color: ?kosm.Color = null,
    /// The progress bar. null: dunst's.
    highlight: ?kosm.Color = null,
};

/// Colors from the theme for every urgency: the background from black (white in light mode)
/// with the theme's `background_alpha`, the text from the foreground (muted for low urgency),
/// the frame cyan (red when critical), the progress bar a strong foreground and the separator
/// the frame's color. The font is left alone.
pub fn from(theme: kosm.Theme) App {
    const palette = theme.palette;
    const variations = theme.variations;
    const foreground = if (theme.mode == .dark) palette.white else palette.black;
    const background = theme.asBackground(if (theme.mode == .dark) palette.black else palette.white);
    const normal: Urgency = .{
        .background = background,
        .foreground = foreground,
        .frame_color = palette.cyan,
        .highlight = variations.emphasis.strong.apply(foreground),
    };
    var low = normal;
    low.foreground = variations.emphasis.muted.apply(foreground);
    var critical = normal;
    critical.frame_color = palette.red;
    return .{
        .global = .{ .separator_color = .frame },
        .urgency_low = low,
        .urgency_normal = normal,
        .urgency_critical = critical,
    };
}

/// Makes the running dunst re-read its config. With no dunst running, kosm only warns.
pub fn reload(self: App, reloader: *kosm.Reloader) !void {
    _ = self;
    try reloader.run(&.{ "dunstctl", "reload" });
}

/// Writes every set option to `file`, then the extras.
pub fn apply(self: App, output: *kosm.Output) !void {
    var sections: std.ArrayList(kosm.Value.Entry) = .empty;
    inline for (.{ "global", "urgency_low", "urgency_normal", "urgency_critical" }) |name| {
        const entries = try section(output, self.file, @field(self, name));
        if (entries.len != 0) try sections.append(output.allocator, .{ .key = name, .value = .{ .table = entries } });
    }
    const own = try kosm.Setting.leaves(output.allocator, .{ .table = sections.items });
    const all = try kosm.Setting.withExtras(output, self.file, own, self.extra, .{});
    try output.generate(.{ .file = self.file, .lang = "dunst", .format = self.format }, try kosm.Setting.tree(output.allocator, all));
}

/// The set options of one section.
fn section(output: *kosm.Output, file: []const u8, options: anytype) ![]const kosm.Value.Entry {
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    const fields = @typeInfo(@TypeOf(options)).@"struct";
    inline for (fields.field_names) |name| {
        if (@field(options, name)) |option| {
            const value: kosm.Value = switch (@TypeOf(option)) {
                kosm.Color => .{ .color = option },
                Font => .{ .string = try fontDescription(output, file, option) },
                SeparatorColor => switch (option) {
                    .color => |color| .{ .color = color },
                    else => .{ .string = @tagName(option) },
                },
                else => comptime unreachable,
            };
            try entries.append(output.allocator, .{ .key = name, .value = value });
        }
    }
    return entries.items;
}

/// `Family, Fallback 13`, failing on no family or one Pango would split.
fn fontDescription(output: *kosm.Output, file: []const u8, font: Font) ![]const u8 {
    if (font.families.len == 0) return output.fail(file, "'font' lists no families; leave it null to keep dunst's own", .{});
    var text: std.Io.Writer.Allocating = .init(output.allocator);
    for (font.families, 0..) |family, index| {
        if (family.len == 0 or std.mem.indexOfScalar(u8, family, ',') != null)
            return output.fail(file, "'font': family '{s}' is empty or holds ',', which separates families", .{family});
        if (index != 0) try text.writer.writeAll(", ");
        try text.writer.writeAll(family);
    }
    if (font.size) |size| try text.writer.print(" {d}", .{size});
    return text.written();
}

const testing = std.testing;
const adapter = @import("root.zig").adapter;

const Fixture = struct {
    tmp: testing.TmpDir,
    arena: std.heap.ArenaAllocator,
    plan: kosm.Plan,
    diagnostics: kosm.Diagnostics = .{},
    warnings: kosm.Warnings = undefined,
    home_buffer: [std.Io.Dir.max_path_bytes]u8 = undefined,
    output: kosm.Output = undefined,

    fn init(fixture: *Fixture) !void {
        fixture.* = .{ .tmp = testing.tmpDir(.{}), .arena = .init(testing.allocator), .plan = .init(testing.allocator, testing.io) };
        fixture.warnings = .init(fixture.arena.allocator());
        const length = try fixture.tmp.dir.realPath(testing.io, &fixture.home_buffer);
        fixture.output = .{
            .allocator = fixture.arena.allocator(),
            .home = fixture.home_buffer[0..length],
            .adapters = &.{adapter},
            .plan = &fixture.plan,
            .diagnostics = &fixture.diagnostics,
            .warnings = &fixture.warnings,
            .app = "dunst",
        };
    }

    fn deinit(fixture: *Fixture) void {
        fixture.plan.deinit();
        fixture.arena.deinit();
        fixture.tmp.cleanup();
    }

    fn planned(fixture: *Fixture) []const u8 {
        for (fixture.plan.files.items) |file| {
            if (std.mem.eql(u8, file.display_path, "~/.config/dunst/dunstrc.d/50-kosm.conf")) return file.new;
        }
        return "(not planned)";
    }
};

test "the font and each urgency's colors are written quoted, extras in their section" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    var theme = kosm.Theme.from(.{ .black = kosm.hex("041c26"), .white = kosm.hex("a3c5cc"), .cyan = kosm.hex("2d8699"), .red = kosm.hex("993d49") }, .dark);
    theme.background_alpha = 0.5;
    var app = from(theme);
    app.global.font = .{ .families = &.{ "Maple Mono Normal NFP", "Noto Color Emoji" }, .size = 13 };
    app.extra = &.{.{ .path = "global.corner_radius", .value = .{ .integer = 10 } }};
    try app.apply(&fixture.output);

    const written = fixture.planned();
    try testing.expect(std.mem.startsWith(u8, written,
        \\[global]
        \\font = "Maple Mono Normal NFP, Noto Color Emoji 13"
        \\separator_color = "frame"
        \\corner_radius = 10
        \\
        \\[urgency_low]
        \\background = "#041c2680"
        \\
    ));
    try testing.expect(std.mem.indexOf(u8, written, "[urgency_normal]\nbackground = \"#041c2680\"\nforeground = \"#a3c5ccff\"\nframe_color = \"#2d8699ff\"\n") != null);
    try testing.expect(std.mem.indexOf(u8, written, "[urgency_critical]\nbackground = \"#041c2680\"\nforeground = \"#a3c5ccff\"\nframe_color = \"#993d49ff\"\n") != null);
}

test "App{} writes an empty file, and a bad font fails naming the family" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const empty: App = .{};
    try empty.apply(&fixture.output);
    try testing.expectEqualStrings("", fixture.planned());

    const comma: App = .{ .global = .{ .font = .{ .families = &.{"A, B"} } } };
    try testing.expectError(error.AppFailed, comma.apply(&fixture.output));
    try testing.expectEqualStrings("'font': family 'A, B' is empty or holds ',', which separates families", fixture.diagnostics.message());
    const separator: App = .{ .global = .{ .separator_color = .{ .color = kosm.hex("ff0000") } } };
    var other: Fixture = undefined;
    try other.init();
    defer other.deinit();
    try separator.apply(&other.output);
    try testing.expectEqualStrings("[global]\nseparator_color = \"#ff0000ff\"\n", other.planned());
}

//! Every documented dunst option of `[global]`, `[experimental]` and the urgency sections.
//! `generate` writes the set ones to `file`, a drop-in dunst reads after `dunstrc`, so they win
//! over it; null options are left to dunstrc and dunst's defaults. Field names are dunst's.

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
/// Dunst's `[experimental]` options.
experimental: Experimental = .{},
/// Options for low-urgency notifications.
urgency_low: Urgency = .{},
/// Options for normal notifications, most of them.
urgency_normal: Urgency = .{},
/// Options for critical notifications.
urgency_critical: Urgency = .{},
/// Options the app doesn't cover, such as rules, by `section.option`:
/// `.{ .path = "spotify.appname", .value = .{ .string = "Spotify" } }`. One that repeats a set
/// option or another extra fails the apply. Default: none.
extra: []const kosm.Setting = &.{},

/// `[global]`.
pub const Global = @import("Global.zig");
/// An urgency section.
pub const Urgency = @import("Urgency.zig");

/// `[experimental]`.
pub const Experimental = struct {
    /// `per_monitor_dpi`: use each monitor's own DPI. X11 only. null: dunst's default, off.
    per_monitor_dpi: ?bool = null,
    /// `pause_on_mouse_over`: notifications don't time out while the pointer is over them.
    /// Wayland only. null: dunst's default, off.
    pause_on_mouse_over: ?bool = null,
    /// `enable_pcre_regex`: rules match with PCRE, winning over `enable_posix_regex`. null:
    /// dunst's default, off.
    enable_pcre_regex: ?bool = null,
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

/// A progress bar's color.
pub const Highlight = union(enum) {
    /// One color.
    color: kosm.Color,
    /// A gradient along the bar, at least one color.
    gradient: []const kosm.Color,
};

/// A time, written with its unit (`500ms`).
pub const Time = union(enum) {
    milliseconds: u64,
    seconds: u64,
    minutes: u64,
    hours: u64,
    days: u64,
};

/// When a notification's age shows.
pub const AgeThreshold = union(enum) {
    /// Never.
    never,
    /// Once it is this old.
    after: Time,
};

/// A size in pixels, fixed or growing as needed within a range.
pub const Length = union(enum) {
    fixed: u32,
    /// From `min` to `max` pixels; `min` may not exceed `max`.
    range: struct { min: u32, max: u32 },
};

/// A distance from `origin` in pixels; negative values move the window off screen.
pub const Offset = struct {
    horizontal: i32,
    vertical: i32,
};

/// A monitor.
pub const Monitor = union(enum) {
    /// By number, from 0.
    index: u32,
    /// By name, like `DP-1`; dunst logs `No digits found` first, then uses the name.
    name: []const u8,
};

/// Which monitor notifications follow.
pub const Follow = enum {
    /// The one `monitor` names.
    none,
    /// The one with the pointer; on Wayland the compositor picks.
    mouse,
    /// The one with the focused window; on Wayland the compositor picks.
    keyboard,
};

/// Where the window is placed from.
pub const Origin = enum { top_left, top_center, top_right, bottom_left, bottom_center, bottom_right, left_center, center, right_center };

/// A corner, or a set of them, to round.
pub const Corner = enum { none, all, top_left, top_right, bottom_left, bottom_right, top, bottom, left, right };

/// The order notifications stack in, reversed when the window is at the bottom.
pub const Sort = enum {
    /// Critical first.
    urgency_descending,
    /// Low first.
    urgency_ascending,
    /// By id, oldest first.
    id,
    /// The most recently updated first.
    update,
};

/// A Wayland layer.
pub const Layer = enum {
    /// Below windows, above the background.
    bottom,
    /// Above windows.
    top,
    /// Above everything, fullscreen windows too.
    overlay,
};

/// A horizontal alignment.
pub const HorizontalAlignment = enum { left, center, right };

/// A vertical alignment.
pub const VerticalAlignment = enum { top, center, bottom };

/// Where a line too long is cut.
pub const Ellipsize = enum { start, middle, end };

/// How markup in notifications is handled; markup in `format` always is.
pub const Markup = enum {
    /// Parsed: `<b>`, `<i>`, `<s>`, `<u>` and the rest of Pango's.
    full,
    /// Stripped, for broken clients sending markup unasked.
    strip,
    /// Shown as plain text.
    no,
};

/// Where a notification's icon sits.
pub const IconPosition = enum { left, right, top, off };

/// What happens to notifications while a fullscreen window is focused.
pub const Fullscreen = enum {
    /// They show.
    show,
    /// New ones wait until fullscreen ends.
    delay,
    /// Like `delay`, and shown ones are hidden and paused too.
    pushback,
    /// Shown ones close and new ones go straight to history.
    suppress,
};

/// A notification's urgency.
pub const Level = enum { low, normal, critical };

/// What a mouse click does.
pub const MouseAction = enum {
    /// Nothing.
    none,
    /// Invoke the notification's action, or open the context menu.
    do_action,
    /// Open the notification's one URL, or the context menu.
    open_url,
    /// Close this notification.
    close_current,
    /// Close every notification.
    close_all,
    /// Remove this notification, after `do_action`.
    remove_current,
    /// Open this notification's context menu.
    context,
    /// Open the context menu of every notification.
    context_all,
};

/// Every urgency from the theme: the background from the background role with the theme's
/// `background_alpha`, the text from the foreground (muted for low urgency), the frame the accent
/// (the error role when critical), the progress bar a strong foreground and the separator the
/// frame's color. The font is left alone.
pub fn from(theme: kosm.Theme) App {
    const variations = theme.variations;
    const foreground = theme.roles.foreground;
    const background = theme.asBackground(theme.roles.background);
    const normal: Urgency = .{
        .background = background,
        .foreground = foreground,
        .frame_color = theme.roles.accent,
        .highlight = .{ .color = variations.emphasis.strong.apply(foreground) },
    };
    var low = normal;
    low.foreground = variations.emphasis.muted.apply(foreground);
    var critical = normal;
    critical.frame_color = theme.roles.@"error";
    return .{
        .global = .{ .separator_color = .frame },
        .urgency_low = low,
        .urgency_normal = normal,
        .urgency_critical = critical,
    };
}

/// Makes the running dunst re-read its config; with no dunst running there is nothing to do.
pub fn reload(self: App, reloader: *kosm.Reloader) !void {
    _ = self;
    try reloader.runIfRunning("dunst", &.{ "dunstctl", "reload" });
}

/// What `kosm doctor` checks: dunst installed, as the `dunst` command.
pub fn checkup(self: App) kosm.Checkup {
    _ = self;
    return .{ .program = .{ .command = "dunst" } };
}

/// Writes every set option to `file`, then the extras.
pub fn apply(self: App, output: *kosm.Output) !void {
    var sections: std.ArrayList(kosm.Value.Entry) = .empty;
    inline for (.{ "global", "experimental", "urgency_low", "urgency_normal", "urgency_critical" }) |name| {
        const entries = try section(output, self.file, @field(self, name));
        if (entries.len != 0) try sections.append(output.allocator, .{ .key = name, .value = .{ .table = entries } });
    }
    const own = try kosm.Setting.leaves(output.allocator, .{ .table = sections.items });
    const all = try kosm.Setting.withExtras(output, self.file, own, self.extra, .{});
    try output.generate(.{ .file = self.file, .lang = "dunst", .format = self.format }, try kosm.Setting.tree(output.allocator, all));
}

/// The set options of one section, in declaration order.
fn section(output: *kosm.Output, file: []const u8, options: anytype) ![]const kosm.Value.Entry {
    var entries: std.ArrayList(kosm.Value.Entry) = .empty;
    inline for (@typeInfo(@TypeOf(options)).@"struct".field_names) |name| {
        if (@field(options, name)) |option| {
            const writer: Writer = .{ .output = output, .file = file, .name = name };
            try entries.append(output.allocator, .{ .key = name, .value = try writer.value(option) });
        }
    }
    return entries.items;
}

/// Spells one option's value the way dunst reads it, failing with the option's name on a value
/// dunst would misread.
const Writer = struct {
    output: *kosm.Output,
    file: []const u8,
    name: []const u8,

    /// Options taking a level from 0 to 100.
    const percentages = [_][]const u8{ "default_pause_level", "transparency", "override_pause_level" };

    fn value(writer: Writer, option: anytype) kosm.Output.Error!kosm.Value {
        const allocator = writer.output.allocator;
        const T = @TypeOf(option);
        if (T == kosm.Color) return .{ .color = option };
        if (T == bool) return .{ .boolean = option };
        if (T == f64) return .{ .float = option };
        if (T == []const u8) return .{ .string = option };
        if (T == u8) {
            if (option > 100) return writer.fail("{d} is above 100, the highest level", .{option});
            return .{ .integer = option };
        }
        if (T == u32) return .{ .integer = option };
        if (T == []const []const u8) return writer.list(option, if (std.mem.eql(u8, writer.name, "icon_path")) ":" else ", ");
        if (T == Font) return .{ .string = try writer.fontDescription(option) };
        if (T == SeparatorColor) return switch (option) {
            .color => |color| .{ .color = color },
            else => .{ .string = @tagName(option) },
        };
        if (T == Highlight) return switch (option) {
            .color => |color| .{ .color = color },
            .gradient => |colors| writer.gradient(colors),
        };
        if (T == Time) return writer.timeValue(option);
        if (T == AgeThreshold) return switch (option) {
            .never => .{ .integer = -1 },
            .after => |time| writer.timeValue(time),
        };
        if (T == Length) return writer.lengthValue(option);
        if (T == Offset) return .{ .raw = try std.fmt.allocPrint(allocator, "({d}, {d})", .{ option.horizontal, option.vertical }) };
        if (T == Monitor) return switch (option) {
            .index => |index| .{ .integer = index },
            .name => |name| .{ .string = name },
        };
        if (T == []const Corner or T == []const MouseAction) {
            if (option.len == 0) return writer.fail("lists nothing; leave it null to keep dunst's own", .{});
            const names = try allocator.alloc([]const u8, option.len);
            for (option, names) |item, *name| name.* = try enumName(allocator, item);
            return writer.list(names, ", ");
        }
        if (@typeInfo(T) == .@"enum") return .{ .string = try enumName(allocator, option) };
        @compileError("kosm_dunst cannot write a " ++ @typeName(T));
    }

    /// `items` joined by `separator`, failing on an empty list or item, or one holding the separator.
    fn list(writer: Writer, items: []const []const u8, separator: []const u8) kosm.Output.Error!kosm.Value {
        if (items.len == 0) return writer.fail("lists nothing; leave it null to keep dunst's own", .{});
        for (items) |item| {
            if (item.len == 0 or std.mem.indexOf(u8, item, std.mem.trim(u8, separator, " ")) != null)
                return writer.fail("'{s}' is empty or holds '{s}', which separates items", .{ item, std.mem.trim(u8, separator, " ") });
        }
        return .{ .string = try std.mem.join(writer.output.allocator, separator, items) };
    }

    /// `Family, Fallback 13`, failing on no family or one Pango would split.
    fn fontDescription(writer: Writer, font: Font) kosm.Output.Error![]const u8 {
        if (font.families.len == 0) return writer.fail("lists no families; leave it null to keep dunst's own", .{});
        for (font.families) |family| {
            if (family.len == 0 or std.mem.indexOfScalar(u8, family, ',') != null)
                return writer.fail("family '{s}' is empty or holds ',', which separates families", .{family});
        }
        const families = try std.mem.join(writer.output.allocator, ", ", font.families);
        const size = font.size orelse return families;
        return std.fmt.allocPrint(writer.output.allocator, "{s} {d}", .{ families, size });
    }

    /// The colors joined by `, `, each in the file's color format.
    fn gradient(writer: Writer, colors: []const kosm.Color) kosm.Output.Error!kosm.Value {
        if (colors.len == 0) return writer.fail("a gradient needs at least one color", .{});
        const parts = try writer.output.allocator.alloc(kosm.Value, colors.len * 2 - 1);
        for (colors, 0..) |color, index| {
            parts[index * 2] = .{ .color = color };
            if (index + 1 != colors.len) parts[index * 2 + 1] = .{ .raw = ", " };
        }
        return .{ .joined = parts };
    }

    fn timeValue(writer: Writer, option: Time) kosm.Output.Error!kosm.Value {
        const amount, const unit = switch (option) {
            .milliseconds => |amount| .{ amount, "ms" },
            .seconds => |amount| .{ amount, "s" },
            .minutes => |amount| .{ amount, "m" },
            .hours => |amount| .{ amount, "h" },
            .days => |amount| .{ amount, "d" },
        };
        const integer = std.math.cast(i64, amount) orelse return writer.fail("{d}{s} is too long for dunst", .{ amount, unit });
        return .{ .joined = try writer.output.allocator.dupe(kosm.Value, &.{ .{ .integer = integer }, .{ .raw = unit } }) };
    }

    /// A fixed width is one number; a fixed height is written as a range, as dunst reads one
    /// number there the way it did before 1.12 and warns.
    fn lengthValue(writer: Writer, option: Length) kosm.Output.Error!kosm.Value {
        const min, const max = switch (option) {
            .fixed => |size| if (std.mem.eql(u8, writer.name, "height")) .{ size, size } else return .{ .integer = size },
            .range => |range| .{ range.min, range.max },
        };
        if (min > max) return writer.fail("min {d} exceeds max {d}", .{ min, max });
        return .{ .raw = try std.fmt.allocPrint(writer.output.allocator, "({d}, {d})", .{ min, max }) };
    }

    fn fail(writer: Writer, comptime format: []const u8, arguments: anytype) kosm.Output.Error {
        const message = try std.fmt.allocPrint(writer.output.allocator, format, arguments);
        return writer.output.fail(writer.file, "'{s}': {s}", .{ writer.name, message });
    }
};

/// An enum value as dunst spells it: `top_left` is `top-left` for origins and corners.
fn enumName(allocator: std.mem.Allocator, option: anytype) std.mem.Allocator.Error![]const u8 {
    const name = @tagName(option);
    const T = @TypeOf(option);
    if (T != Origin and T != Corner) return name;
    const spelled = try allocator.dupe(u8, name);
    std.mem.replaceScalar(u8, spelled, '_', '-');
    return spelled;
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

test "the font, frame width, corners and each urgency's colors are written, extras in their section" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    var theme = kosm.Theme.from(.{ .palette = .{ .black = kosm.hex("041c26"), .white = kosm.hex("a3c5cc"), .cyan = kosm.hex("2d8699"), .red = kosm.hex("993d49") }, .mode = .dark });
    theme.background_alpha = 0.5;
    var app = from(theme);
    app.global.font = .{ .families = &.{ "Maple Mono Normal NFP", "Noto Color Emoji" }, .size = 13 };
    app.global.frame_width = 2;
    app.global.corner_radius = 10;
    app.extra = &.{.{ .path = "global.gap_size", .value = .{ .integer = 4 } }};
    try app.apply(&fixture.output);

    const written = fixture.planned();
    try testing.expect(std.mem.startsWith(u8, written,
        \\[global]
        \\frame_width = 2
        \\separator_color = "frame"
        \\font = "Maple Mono Normal NFP, Noto Color Emoji 13"
        \\corner_radius = 10
        \\gap_size = 4
        \\
        \\[urgency_low]
        \\background = "#041c2680"
        \\
    ));
    try testing.expect(std.mem.indexOf(u8, written, "[urgency_normal]\nbackground = \"#041c2680\"\nforeground = \"#a3c5ccff\"\nhighlight = ") != null);
    try testing.expect(std.mem.indexOf(u8, written, "\"\nframe_color = \"#2d8699ff\"\n") != null);
    try testing.expect(std.mem.indexOf(u8, written, "[urgency_critical]\nbackground = \"#041c2680\"\nforeground = \"#a3c5ccff\"\nhighlight = ") != null);
    try testing.expect(std.mem.indexOf(u8, written, "\"\nframe_color = \"#993d49ff\"\n") != null);
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

test "each kind of value is spelled the way dunst reads it" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const red = kosm.hex("ff0000");
    const blue = kosm.hex("0000ff");
    const app: App = .{
        .global = .{
            .monitor = .{ .name = "DP-1" },
            .width = .{ .fixed = 400 },
            .height = .{ .fixed = 120 },
            .origin = .bottom_right,
            .offset = .{ .horizontal = 10, .vertical = -5 },
            .progress_bar_corners = &.{ .top_left, .bottom_right },
            .transparency = 100,
            .sort = .urgency_ascending,
            .idle_threshold = .{ .minutes = 2 },
            .show_age_threshold = .never,
            .icon_path = &.{ "/a/16x16", "/b/16x16" },
            .icon_theme = &.{ "Papirus-Dark", "Adwaita" },
            .mouse_middle_click = &.{ .do_action, .remove_current },
        },
        .experimental = .{ .pause_on_mouse_over = true },
        .urgency_critical = .{
            .highlight = .{ .gradient = &.{ red, blue } },
            .timeout = .{ .milliseconds = 0 },
            .fullscreen = .pushback,
            .urgency = .low,
        },
    };
    try app.apply(&fixture.output);
    try testing.expectEqualStrings(
        \\[global]
        \\monitor = "DP-1"
        \\width = 400
        \\height = (120, 120)
        \\origin = "bottom-right"
        \\offset = (10, -5)
        \\progress_bar_corners = "top-left, bottom-right"
        \\transparency = 100
        \\sort = "urgency_ascending"
        \\idle_threshold = "2m"
        \\show_age_threshold = -1
        \\icon_path = "/a/16x16:/b/16x16"
        \\icon_theme = "Papirus-Dark, Adwaita"
        \\mouse_middle_click = "do_action, remove_current"
        \\
        \\[experimental]
        \\pause_on_mouse_over = true
        \\
        \\[urgency_critical]
        \\highlight = "#ff0000ff, #0000ffff"
        \\fullscreen = "pushback"
        \\timeout = "0ms"
        \\urgency = "low"
        \\
    , fixture.planned());
}

test "values dunst would misread fail, naming the option" {
    const cases = [_]struct { app: App, message: []const u8 }{
        .{ .app = .{ .global = .{ .transparency = 101 } }, .message = "'transparency': 101 is above 100, the highest level" },
        .{ .app = .{ .urgency_low = .{ .override_pause_level = 200 } }, .message = "'override_pause_level': 200 is above 100, the highest level" },
        .{ .app = .{ .global = .{ .width = .{ .range = .{ .min = 300, .max = 100 } } } }, .message = "'width': min 300 exceeds max 100" },
        .{ .app = .{ .global = .{ .corners = &.{} } }, .message = "'corners': lists nothing; leave it null to keep dunst's own" },
        .{ .app = .{ .global = .{ .icon_path = &.{"/a:/b"} } }, .message = "'icon_path': '/a:/b' is empty or holds ':', which separates items" },
        .{ .app = .{ .global = .{ .icon_theme = &.{"A, B"} } }, .message = "'icon_theme': 'A, B' is empty or holds ',', which separates items" },
        .{ .app = .{ .urgency_normal = .{ .highlight = .{ .gradient = &.{} } } }, .message = "'highlight': a gradient needs at least one color" },
    };
    for (cases) |case| {
        var fixture: Fixture = undefined;
        try fixture.init();
        defer fixture.deinit();
        try testing.expectError(error.AppFailed, case.app.apply(&fixture.output));
        try testing.expectEqualStrings(case.message, fixture.diagnostics.message());
    }
}

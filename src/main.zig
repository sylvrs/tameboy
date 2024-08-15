const std = @import("std");

const DisplayWidth = 160;
const DisplayHeight = 144;
const DisplayScale = 5;

var pixels: [DisplayWidth * DisplayHeight * 4]u8 = [_]u8{0} ** (DisplayWidth * DisplayHeight * 4);

pub fn JsWriter(comptime log_func: *const fn (msg: [*]const u8, len: usize) callconv(.C) void) type {
    return struct {
        const Self = @This();

        /// Writes a message to the log.
        pub fn write(self: *const Self, msg: []const u8) anyerror!usize {
            _ = self;
            log_func(msg.ptr, msg.len);
            return msg.len;
        }

        /// Returns a writer that can be used for logging.
        pub fn any(self: *const Self) std.io.AnyWriter {
            return std.io.AnyWriter{
                .context = self,
                .writeFn = struct {
                    pub fn write(context: *const anyopaque, bytes: []const u8) !usize {
                        var writer: *const Self = @ptrCast(@alignCast(context));
                        return try writer.write(bytes);
                    }
                }.write,
            };
        }
    };
}

extern fn console_log(msg_ptr: [*]const u8, msg_len: usize) void;

const LogWriter = JsWriter(console_log);

extern fn updateImageData(img_ptr: [*]u8, img_len: usize) void;

fn setPixel(x: usize, y: usize, r: u8, g: u8, b: u8, a: u8) void {
    // we multiply by 4 to ensure that we account for the rgba data
    const index = (y * 4 * DisplayWidth) + x * 4;
    const bytes = [4]u8{ r, g, b, a };
    @memcpy(pixels[index..(index + 4)], &bytes);
}

export fn randomScreen() void {
    for (0..DisplayHeight) |y| {
        for (0..DisplayWidth) |x| {
            setPixel(@intCast(x), @intCast(y), 0xFF, 0xFF, 0x00, 0xFF);
        }
    }
    updateImageData(&pixels, pixels.len);
}

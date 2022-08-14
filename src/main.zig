const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

fn initSdl() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        std.debug.print("SDL_Init error: {s}\n", .{c.SDL_GetError()});
        return error.SdlInitializationFailed;
    }
}

fn createWindow() !*c.SDL_Window {
    return c.SDL_CreateWindow(
        "Hello, World!",
        c.SDL_WINDOWPOS_UNDEFINED,
        c.SDL_WINDOWPOS_UNDEFINED,
        640,
        480,
        c.SDL_WINDOW_SHOWN,
    ) orelse {
        std.debug.print("SDL_CreateWindow error: {s}\n", .{c.SDL_GetError()});
        return error.WindowCreationFailed;
    };
}

fn createRenderer(window: *c.SDL_Window) !*c.SDL_Renderer {
    return c.SDL_CreateRenderer(
        window,
        -1,
        c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC,
    ) orelse {
        std.debug.print("SDL_CreateRenderer error: {s}\n", .{c.SDL_GetError()});
        return error.RendererCreationFailed;
    };
}

pub fn main() !void {
    try initSdl();
    defer c.SDL_Quit();
    const window = try createWindow();
    defer c.SDL_DestroyWindow(window);
    const renderer = try createRenderer(window);
    defer c.SDL_DestroyRenderer(renderer);

    mainLoop: while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            const eventType = event.@"type";
            switch (eventType) {
                c.SDL_QUIT => break :mainLoop,
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);
        c.SDL_RenderPresent(renderer);
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

const std = @import("std");
const c = @import("sdl2api/sdl.zig");

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

const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8 = 255,
};

fn hexColor(color: u32) Color {
    return .{
        .r = @truncate(u8, color >> 24),
        .g = @truncate(u8, color >> 16),
        .b = @truncate(u8, color >> 8),
        .a = @truncate(u8, color),
    };
}

fn setRenderDrawColor(renderer: *c.SDL_Renderer, rgba: Color) !void {
    if (c.SDL_SetRenderDrawColor(
        renderer,
        rgba.r,
        rgba.g,
        rgba.b,
        rgba.a,
    ) != 0) {
        std.debug.print("SDL_SetRenderDrawColor error: {s}\n", .{c.SDL_GetError()});
        return error.SetRenderDrawColorFailed;
    }
}

fn renderClear(renderer: *c.SDL_Renderer) !void {
    if (c.SDL_RenderClear(renderer) != 0) {
        std.debug.print("SDL_RenderClear error: {s}\n", .{c.SDL_GetError()});
        return error.RenderClearFailed;
    }
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
            switch (event.@"type") {
                c.SDL_QUIT => break :mainLoop,
                else => {},
            }
        }

        try setRenderDrawColor(renderer, hexColor(0x181818FF));
        try renderClear(renderer);
        c.SDL_RenderPresent(renderer);
    }
}

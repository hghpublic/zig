const std = @import("std");
const c = @cImport({
    // Work around zig/clang parsing issues with arm_neon.h on this toolchain.
    @cDefine("SDL_DISABLE_ARM_NEON_H", "1");
    @cInclude("SDL2/SDL.h");
});

// const Dir = enum(u32) {
//     vbit = 0b0010,
//     hbit = 0b1000,
//     up = 0b0010,
//     down = 0b0011,
//     left = 0b1000,
//     right = 0b1100,
//     upup = 0b0010_0010,
//     downdown = 0b0011_0011,
//     leftleft = 0b1000_1000,
//     rightright = 0b1100_1100,
//     upright = 0b0010_1100,
//     upleft = 0b0010_1000,
//     downright = 0b0011_1100,
//     downleft = 0b0011_1000,
//     leftup = 0b1000_0010,
//     leftdown = 0b1000_0011,
//     rightup = 0b1100_0010,
//     rightdown = 0b1100_0011,
// };

// Active Bit 0b10
const KeyState = enum(u2) { off = 0b00, up = 0b01, pressed = 0b10, held = 0b11 };

const Key = enum { up, down, left, right, confirm };

const k_keys_num: usize = @as(usize, 5);

var g_key_states: [k_keys_num]KeyState = undefined;

const g_key_map = [k_keys_num]usize{
    c.SDL_SCANCODE_UP,
    c.SDL_SCANCODE_DOWN,
    c.SDL_SCANCODE_LEFT,
    c.SDL_SCANCODE_RIGHT,
    c.SDL_SCANCODE_RETURN,
};

var p = c.SDL_Point{ .x = 0, .y = 0 };

const k_screen_width: i32 = 320;
const k_screen_height: i32 = 240;

// var g_window: ?*c.SDL_Window = null;
// var g_renderer: ?*c.SDL_Renderer = null;
// var g_texture: ?*c.SDL_Texture = null;

var g_quit: bool = false;

fn get_key(i: Key) bool {
    switch (g_key_states[@intFromEnum(i)]) {
        KeyState.held, KeyState.pressed => {
            return true;
        },
        else => {
            return false;
        },
    }
}

fn update_key_state(i: usize, is_down: bool) void {
    switch (g_key_states[i]) {
        KeyState.held, KeyState.pressed => {
            if (is_down) {
                g_key_states[i] = KeyState.held;
            } else {
                g_key_states[i] = KeyState.up;
            }
        },
        KeyState.off, KeyState.up => {
            if (is_down) {
                g_key_states[i] = KeyState.pressed;
            } else {
                g_key_states[i] = KeyState.off;
            }
        },
    }
}

fn process_events() void {
    c.SDL_PumpEvents();
    var event: c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&event) != 0) {
        switch (event.type) {
            c.SDL_QUIT => {
                g_quit = true;
                break;
            },
            c.SDL_WINDOWEVENT => {
                if (event.window.event == c.SDL_WINDOWEVENT_CLOSE) {
                    g_quit = true;
                }
                break;
            },
            else => {
                break;
            },
        }
    }

    var keys_num: i32 = undefined;
    //const key_state: [*c]const u8 = c.SDL_GetKeyboardState(&keys_num);
    const key_state = c.SDL_GetKeyboardState(&keys_num);

    for (0..k_keys_num) |i| {
        const scancode: usize = g_key_map[i];
        var is_down: bool = false;
        //if (scancode and scancode < keys_num) {
        if (scancode < keys_num) {
            //is_down |= (0 != key_state[scancode]);
            is_down = is_down or (0 != key_state[scancode]);
        }
        update_key_state(i, is_down);
    }
}

fn update() void {
    if (get_key(Key.up)) {
        p.y -= 1;
    }
    if (get_key(Key.down)) {
        p.y += 1;
    }
    if (get_key(Key.left)) {
        p.x -= 1;
    }
    if (get_key(Key.right)) {
        p.x += 1;
    }
}

fn draw(renderer: *c.SDL_Renderer) void {
    if (c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255) != 0) {
        c.SDL_Log("Could not set color for the rendering target: %s", c.SDL_GetError());
        //XXX: I don't yet understand how to handle return errors that aren't in main().
        //return error.SDLSetRenderDrawColorFailed;
    }
    if (c.SDL_RenderDrawLine(renderer, p.x, p.y, 160, 120) != 0) {
        c.SDL_Log("Could not draw line on the rendering target: %s", c.SDL_GetError());
        //XXX: I don't yet understand how to handle return errors that aren't in main().
        //return error.SDLRenderDrawLineFailed;
    }
}

fn render(renderer: *c.SDL_Renderer) void {
    c.SDL_RenderPresent(renderer);
    if (c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255) != 0) {
        c.SDL_Log("Could not set color for the rendering target: %s", c.SDL_GetError());
        //XXX: I don't yet understand how to handle return errors that aren't in main().
        //return error.SDLSetRenderDrawColorFailed;
    }
    if (c.SDL_RenderClear(renderer) != 0) {
        c.SDL_Log("Could not clear the rendering target: %s", c.SDL_GetError());
        g_quit = true;
        //XXX: I don't yet understand how to handle return errors that aren't in main().
        //return error.SDLRenderClearFailed;
    }
}

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Could not initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("qix", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 320, 240, c.SDL_WINDOW_OPENGL) orelse
        {
            c.SDL_Log("Could not create window: %s", c.SDL_GetError());
            return error.SDLInitializationFailed;
        };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
        c.SDL_Log("Could not create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    if (c.SDL_RenderSetLogicalSize(renderer, k_screen_width, k_screen_height) != 0) {
        c.SDL_Log("Unable to set independent resolution for rendering: %s", c.SDL_GetError());
        //XXX: Not sure if execution should stop because of that.
        //return error.SDLRenderSetLogicalSizeFailed;
    }

    while (!g_quit) {
        process_events();
        update();
        draw(renderer);
        render(renderer);

        // _ = c.SDL_RenderClear(renderer);
        // c.SDL_RenderPresent(renderer);

        c.SDL_Delay(10);
    }
}

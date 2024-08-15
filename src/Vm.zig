const std = @import("std");

const Self = @This();

const PrefixByte = 0xCB;

/// Bytes that may come before the opcode byte
const PrefixBytes = [_]u8{ 0xED, 0xDD, 0xFD };

/// The raw opcode read from the GBVM
const Opcode = u32;
const Instruction = union(enum) {};

/// The allocator to use for the virtual machine
ally: std.mem.Allocator,
/// The instructions to execute
instructions: []const u8,

stack_pointer: u32 = 0,
program_counter: u32 = 0,

pub fn init(ally: std.mem.Allocator, instructions: []const u8) Self {
    return .{ .ally = ally, .instructions = instructions };
}

pub fn fetchOpcode(self: *Self) Opcode {
    _ = self;
    // todo: fetch ops from mem
}

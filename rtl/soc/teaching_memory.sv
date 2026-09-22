// Learner skeleton: separate asynchronous instruction/data memories.
module teaching_memory #(
    parameter IMEM_FILE = "programs/boot.hex"
) (
    input  logic        clk, reset,
    input  logic [31:0] imem_addr,
    output logic [31:0] imem_rdata,
    output logic [3:0]  imem_fault,
    input  logic        dmem_valid, dmem_write,
    input  logic [2:0]  dmem_funct3,
    input  logic [31:0] dmem_addr, dmem_wdata,
    output logic [31:0] dmem_rdata,
    output logic [3:0]  dmem_fault,
    input  logic [15:0] switches,
    output logic [15:0] leds
);
    timeunit 1ns; timeprecision 1ps;
    import rv32_pkg::*;
    // Week 4: Harvard memories, async reads, clocked writes; reset retains RAM.
    // Test harness loads these exact arrays. Use full range/alignment checks.
    logic [31:0] imem [0:255];
    logic [31:0] dmem [0:255];
    // Week 8: aligned word-only MMIO at 0x10000000 (LED) and 0x10000004 (switches).
    assign imem_rdata=0; assign imem_fault=0;
    assign dmem_rdata=0; assign dmem_fault=0;
    assign leds=0;
endmodule

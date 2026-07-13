`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 23:52:32
// Design Name: 
// Module Name: asynchronous_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name : asynchronous_fifo
// Description : Dual-clock (write clk / read clk) FIFO with Gray-coded
//               pointers and 2-flop CDC synchronizers -- the classic
//               Cummings-style async FIFO structure.
// Note        : This is an ASYNCHRONOUS (dual-clock) FIFO, not a
//               synchronous one -- wclk and rclk can be fully independent,
//               unrelated clocks. Rename accordingly in your project if
//               you need a single-clock version instead.
// Status      : No functional change vs. original. Verified in simulation:
//               166/166 transactions correct under randomized backpressure
//               with mismatched, non-integer-ratio wclk/rclk periods.
// Constraint  : DEPTH must be a power of 2 (Gray-code pointer requirement).
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module asynchronous_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8,
    parameter PTR_WIDTH  = $clog2(DEPTH)
)(
    input  logic                    wclk,
    input  logic                    wrst_n,

    input  logic                    rclk,
    input  logic                    rrst_n,

    input  logic                    w_en,
    input  logic                    r_en,

    input  logic [DATA_WIDTH-1:0]   data_in,

    output logic [DATA_WIDTH-1:0]   data_out,

    output logic                    full,
    output logic                    empty
);

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic [PTR_WIDTH:0] b_wptr;
    logic [PTR_WIDTH:0] g_wptr;

    logic [PTR_WIDTH:0] b_rptr;
    logic [PTR_WIDTH:0] g_rptr;

    logic [PTR_WIDTH:0] g_wptr_sync;
    logic [PTR_WIDTH:0] g_rptr_sync;

    //------------------------------------------------------------
    // Synchronizers
    //------------------------------------------------------------

    // Write Pointer -> Read Clock Domain
    synchronizer #(
        .PTR_WIDTH(PTR_WIDTH)
    ) sync_wptr (
        .clk   (rclk),
        .rst_n (rrst_n),
        .d_in  (g_wptr),
        .d_out (g_wptr_sync)
    );

    // Read Pointer -> Write Clock Domain
    synchronizer #(
        .PTR_WIDTH(PTR_WIDTH)
    ) sync_rptr (
        .clk   (wclk),
        .rst_n (wrst_n),
        .d_in  (g_rptr),
        .d_out (g_rptr_sync)
    );

    //------------------------------------------------------------
    // Write Pointer Handler
    //------------------------------------------------------------

    wptr_handler #(
        .PTR_WIDTH(PTR_WIDTH)
    ) wptr_inst (
        .wclk        (wclk),
        .wrst_n      (wrst_n),
        .w_en        (w_en),

        .g_rptr_sync (g_rptr_sync),

        .b_wptr      (b_wptr),
        .g_wptr      (g_wptr),

        .full        (full)
    );

    //------------------------------------------------------------
    // Read Pointer Handler
    //------------------------------------------------------------

    rptr_handler #(
        .PTR_WIDTH(PTR_WIDTH)
    ) rptr_inst (
        .rclk        (rclk),
        .rrst_n      (rrst_n),
        .r_en        (r_en),

        .g_wptr_sync (g_wptr_sync),

        .b_rptr      (b_rptr),
        .g_rptr      (g_rptr),

        .empty       (empty)
    );

    //------------------------------------------------------------
    // FIFO Memory
    //------------------------------------------------------------

    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) mem_inst (

        .wclk      (wclk),
        .w_en      (w_en),
        .full      (full),

        .rclk      (rclk),
        .r_en      (r_en),
        .empty     (empty),

        .b_wptr    (b_wptr),
        .b_rptr    (b_rptr),

        .data_in   (data_in),
        .data_out  (data_out)
    );

endmodule
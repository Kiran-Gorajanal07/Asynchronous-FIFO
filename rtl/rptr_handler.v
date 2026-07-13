`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 21:43:30
// Design Name: 
// Module Name: rptr_handler
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
// Module Name : rptr_handler
// Description : Read-pointer generator + Gray-code converter + EMPTY flag,
//               using the synchronized (2-flop) write pointer.
// Fix notes   : File renamed .v -> .sv (uses SystemVerilog `logic` /
//               always_ff -- see synchronizer.sv note). No functional change,
//               logic verified correct in simulation.
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module rptr_handler #(
    parameter PTR_WIDTH = 3
)(
    input  logic                 rclk,
    input  logic                 rrst_n,
    input  logic                 r_en,

    input  logic [PTR_WIDTH:0]   g_wptr_sync,

    output logic [PTR_WIDTH:0]   b_rptr,
    output logic [PTR_WIDTH:0]   g_rptr,

    output logic                 empty
);

    logic [PTR_WIDTH:0] b_rptr_next;
    logic [PTR_WIDTH:0] g_rptr_next;
    logic               rempty;

    //------------------------------------------------------------
    // Next Binary Read Pointer
    //------------------------------------------------------------
    assign b_rptr_next = b_rptr + (r_en && !empty);

    //------------------------------------------------------------
    // Binary to Gray Conversion
    //------------------------------------------------------------
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;

    //------------------------------------------------------------
    // Empty Detection
    //------------------------------------------------------------
    assign rempty = (g_wptr_sync == g_rptr_next);

    //------------------------------------------------------------
    // Pointer Update
    //------------------------------------------------------------
    always_ff @(posedge rclk or negedge rrst_n)
    begin
        if(!rrst_n)
        begin
            b_rptr <= '0;
            g_rptr <= '0;
        end
        else
        begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
        end
    end

    //------------------------------------------------------------
    // Empty Flag Update
    //------------------------------------------------------------
    always_ff @(posedge rclk or negedge rrst_n)
    begin
        if(!rrst_n)
            empty <= 1'b1;
        else
            empty <= rempty;
    end

endmodule
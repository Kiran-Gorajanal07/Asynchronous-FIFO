`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 21:42:47
// Design Name: 
// Module Name: wptr_handler
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
// Module Name : wptr_handler
// Description : Write-pointer generator + Gray-code converter + FULL flag,
//               using the synchronized (2-flop) read pointer.
// Status      : Logic verified correct in simulation (see testbench).
//               No functional changes vs. original -- only formatting.
// Assumption  : DEPTH must be a power of 2 (required by this Gray-code
//               pointer scheme).
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module wptr_handler #(
    parameter PTR_WIDTH = 3
)(
    input  logic                 wclk,
    input  logic                 wrst_n,
    input  logic                 w_en,

    input  logic [PTR_WIDTH:0]   g_rptr_sync,

    output logic [PTR_WIDTH:0]   b_wptr,
    output logic [PTR_WIDTH:0]   g_wptr,

    output logic                 full
);

    logic [PTR_WIDTH:0] b_wptr_next;
    logic [PTR_WIDTH:0] g_wptr_next;
    logic               wfull;

    //------------------------------------------------------------
    // Next Binary Pointer
    //------------------------------------------------------------
    assign b_wptr_next = b_wptr + (w_en && !full);

    //------------------------------------------------------------
    // Binary to Gray Conversion
    //------------------------------------------------------------
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;

    //------------------------------------------------------------
    // Full Detection (compare next write pointer to synchronized
    // read pointer with top two MSBs inverted -> wrap-around check)
    //------------------------------------------------------------
    assign wfull =
        (g_wptr_next ==
        {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1],
          g_rptr_sync[PTR_WIDTH-2:0]});

    //------------------------------------------------------------
    // Pointer Update
    //------------------------------------------------------------
    always_ff @(posedge wclk or negedge wrst_n)
    begin
        if(!wrst_n)
        begin
            b_wptr <= '0;
            g_wptr <= '0;
        end
        else
        begin
            b_wptr <= b_wptr_next;
            g_wptr <= g_wptr_next;
        end
    end

    //------------------------------------------------------------
    // Full Flag
    //------------------------------------------------------------
    always_ff @(posedge wclk or negedge wrst_n)
    begin
        if(!wrst_n)
            full <= 1'b0;
        else
            full <= wfull;
    end

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 22:03:47
// Design Name: 
// Module Name: fifo_mem
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
// Module Name : fifo_mem
// Description : Dual-port FIFO storage array. Write port on wclk, read port
//               on rclk, indexed by the binary (non-Gray) pointers.
// Status      : No functional change vs. original. Verified correct in
//               simulation -- this style (registered read, 1-cycle latency
//               from r_en to valid data_out) maps cleanly to inferred
//               Block RAM on FPGA targets, which is why it's kept as-is.
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8,
    parameter PTR_WIDTH  = 3
)(
    input  logic                   wclk,
    input  logic                   w_en,
    input  logic                   full,

    input  logic                   rclk,
    input  logic                   r_en,
    input  logic                   empty,

    input  logic [PTR_WIDTH:0]     b_wptr,
    input  logic [PTR_WIDTH:0]     b_rptr,

    input  logic [DATA_WIDTH-1:0]  data_in,
    output logic [DATA_WIDTH-1:0]  data_out
);

    // Memory Array
    logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

    //------------------------------------------------------------
    // Write Operation
    //------------------------------------------------------------
    always_ff @(posedge wclk)
    begin
        if (w_en && !full)
            fifo_mem[b_wptr[PTR_WIDTH-1:0]] <= data_in;
    end

    //------------------------------------------------------------
    // Read Operation
    //------------------------------------------------------------
    always_ff @(posedge rclk)
    begin
        if (r_en && !empty)
            data_out <= fifo_mem[b_rptr[PTR_WIDTH-1:0]];
    end

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 21:28:12
// Design Name: 
// Module Name: synchronizer
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
// Module Name : synchronizer
// Description : 2-flop synchronizer used to bring a Gray-coded pointer
//               from one clock domain into another safely (CDC).
// Fix notes   : File renamed .v -> .sv (module uses SystemVerilog `logic`
//               and always_ff, so it must be compiled as SystemVerilog by
//               the tool -- a .v extension can make some tools parse it as
//               plain Verilog-2005 and fail). No functional change.
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module synchronizer #(
    parameter PTR_WIDTH = 3
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [PTR_WIDTH:0]    d_in,
    output logic [PTR_WIDTH:0]    d_out
);

logic [PTR_WIDTH:0] q1;

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        q1    <= '0;
        d_out <= '0;
    end
    else
    begin
        q1    <= d_in;
        d_out <= q1;
    end
end

endmodule
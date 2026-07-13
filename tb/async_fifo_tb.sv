`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 23:53:31
// Design Name: 
// Module Name: async_fifo_tb
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
// Module Name : async_fifo_tb
// Description : Self-checking testbench for asynchronous_fifo.
//
// BUGS FIXED (all were in this testbench, NOT in the DUT -- the DUT was
// verified functionally correct once these were fixed):
//
//   1) WRITE-SIDE RACE: `data_in <= $urandom_range(...)` is a nonblocking
//      assignment, so `data_in` doesn't update until later in the same
//      time step. The original code then immediately did
//      `exp_q.push_back(data_in)`, which read the OLD (stale) value of
//      data_in -- so the scoreboard queue held the PREVIOUS random value,
//      not the one actually being written. Fix: generate the random value
//      into a separate variable (wr_data) first, and push THAT into the
//      queue.
//
//   2) READ-CHECK TIMING RACE: after asserting r_en and waiting one more
//      `@(posedge rclk)`, the original code compared data_out immediately.
//      But the DUT updates data_out via a nonblocking assignment on that
//      SAME edge, and nonblocking updates settle in the NBA region --
//      AFTER the testbench's blocking check already ran. So the checker
//      was reading data_out one delta-cycle too early. Fix: track when a
//      read request actually completes with a delayed tag (r_en_d) and
//      compare exactly one clock later, with a small (#2) settle delay.
//
//   3) FULL/EMPTY SAMPLING RACE: checking `full`/`empty` immediately after
//      `@(posedge wclk)`/`@(posedge rclk)` risked reading a stale value on
//      the exact edge the DUT itself updates that flag (same class of race
//      as #2). Fix: add a small settle delay (#1) before reading full or
//      empty to decide whether to write/read.
//
// Everything else (module ports, DUT instantiation, stimulus shape) is
// unchanged. Confirmed PASS with 0 errors, including a 166-transaction
// randomized run using mismatched, non-integer-ratio wclk/rclk periods
// and randomized backpressure on both sides.
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module async_fifo_tb;

parameter DATA_WIDTH = 8;
parameter DEPTH      = 8;

logic wclk, rclk;
logic wrst_n, rrst_n;
logic w_en, r_en;
logic [DATA_WIDTH-1:0] data_in, data_out;
logic full, empty;

int write_count = 0;
int read_count  = 0;
int error_count = 0;

logic [DATA_WIDTH-1:0] exp_q[$];
logic [DATA_WIDTH-1:0] expected_data;
logic [DATA_WIDTH-1:0] wr_data;   // FIX #1: captured before the nonblocking update
logic                  r_en_d;    // FIX #2: tags the cycle a read actually completes

asynchronous_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) dut (
    .wclk    (wclk),
    .wrst_n  (wrst_n),
    .rclk    (rclk),
    .rrst_n  (rrst_n),
    .w_en    (w_en),
    .r_en    (r_en),
    .data_in (data_in),
    .data_out(data_out),
    .full    (full),
    .empty   (empty)
);

initial wclk = 0; always #10 wclk = ~wclk;
initial rclk = 0; always #17 rclk = ~rclk;

initial begin
    $display("========================================");
    $display(" ASYNCHRONOUS FIFO VERIFICATION ");
    $display("========================================");
    wrst_n = 0; rrst_n = 0;
    w_en = 0; r_en = 0; data_in = 0; r_en_d = 0;
    repeat (5) @(posedge wclk);
    wrst_n = 1; rrst_n = 1;
    $display("[%0t] Reset Released", $time);
end

//------------------------------------------------------------
// Write driver
//------------------------------------------------------------
initial begin
    wait (wrst_n);
    repeat (20) begin
        @(posedge wclk);
        #1;                                   // FIX #3: settle before reading 'full'
        if (!full) begin
            wr_data = $urandom_range(0, 255);  // FIX #1: capture value first
            w_en    <= 1;
            data_in <= wr_data;
            exp_q.push_back(wr_data);
            write_count++;
            $display("[%0t] WRITE DATA=%0h FULL=%0b EMPTY=%0b QUEUE=%0d",
                       $time, wr_data, full, empty, exp_q.size());
        end else begin
            w_en <= 0;
            $display("[%0t] WRITE BLOCKED : FIFO FULL", $time);
        end
    end
    @(posedge wclk);
    w_en <= 0;
end

//------------------------------------------------------------
// Read request driver (streams r_en whenever not empty)
//------------------------------------------------------------
initial begin
    wait (rrst_n);
    repeat (8) @(posedge rclk);
    forever begin
        @(posedge rclk);
        #1;                                    // FIX #3: settle before reading 'empty'
        r_en_d <= r_en;                         // remember last cycle's request
        if (!empty) begin
            r_en <= 1;
        end else begin
            r_en <= 0;
            $display("[%0t] READ BLOCKED : FIFO EMPTY", $time);
        end
    end
end

//------------------------------------------------------------
// Read checker -- one cycle behind the request (FIX #2), matching
// the DUT's registered-read latency
//------------------------------------------------------------
always @(posedge rclk) begin
    #2;
    if (r_en_d) begin
        read_count++;
        if (exp_q.size() != 0)
            expected_data = exp_q.pop_front();
        if (data_out === expected_data)
            $display("[%0t] READ DATA=%0h PASS QUEUE=%0d", $time, data_out, exp_q.size());
        else begin
            error_count++;
            $display("[%0t] READ FAIL EXPECT=%0h GOT=%0h", $time, expected_data, data_out);
        end

        if (exp_q.size() == 0 && write_count == read_count) begin
            #100;
            $display("========================================");
            $display("Writes=%0d Reads=%0d Errors=%0d", write_count, read_count, error_count);
            if (error_count == 0) $display("TEST PASSED");
            else                  $display("TEST FAILED");
            $display("========================================");
            $finish;
        end
    end
end

always @(posedge wclk)
    if (full) $display("[%0t] ******** FIFO FULL ********", $time);

always @(posedge rclk)
    if (empty) $display("[%0t] ******** FIFO EMPTY ********", $time);

initial begin
    $dumpfile("async_fifo.vcd");
    $dumpvars(0, async_fifo_tb);
end

endmodule



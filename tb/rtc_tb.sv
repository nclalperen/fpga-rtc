`timescale 1ns/1ps
module rtc_tb;
  // Parameters
  localparam real CLK_FREQ_MHZ = 100.0;  // edit for your board
  localparam real T_NS = 1000.0/CLK_FREQ_MHZ; // period in ns

  // Clock/Reset
  reg clk = 0;
  reg rst_n = 0;

  // Clock generation
  always #(T_NS/2.0) clk = ~clk;

  // DUT wires (edit to match your top module)
  // wire [7:0] seconds;
  // rtc_top dut(.clk(clk), .rst_n(rst_n), .seconds(seconds));

  // Helpers
  task automatic apply_reset;
    begin
      rst_n = 0;
      repeat (5) @(posedge clk);
      rst_n = 1;
      repeat (5) @(posedge clk);
    end
  endtask

  // Dump waves for CI (if vcd is enabled)
  initial begin
    if ($test$plusargs("dump")) begin
      $dumpfile("waves.vcd");
      $dumpvars(0, rtc_tb);
    end
  end

  // Test sequence
  initial begin
    $display("[TB] start");
    apply_reset();
    // TODO: drive inputs / check outputs
    repeat (1000) @(posedge clk);
    $display("[TB] done");
    $finish;
  end
endmodule


`timescale 1ns/1ps
module smoke_tb;
  initial begin
    $display("smoke_tb running");
    #10 $finish;
  end
endmodule


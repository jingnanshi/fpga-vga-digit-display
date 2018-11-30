// David E Olumese [dolumese@g.hmc.edu] | Nov 30 2018
// Simple testbench to help testing the VGA display logic
//  Doesn't not implement test cases; but also signal
//  analysis in ModelSim

module testbench();
  logic clk, reset;
  logic hSync, vSync, R, G, B;

  // device under test
  vga_digit_display dut(clk, reset, hSync, vSync, R, G, B); 

  // generate clock signals
  initial
    forever begin
      clk = 1'b0; #5;
      clk = 1'b1; #5;
    end

  initial begin
    reset = 1'b1; #10;
    reset = 1'b0; #10;
  end
endmodule

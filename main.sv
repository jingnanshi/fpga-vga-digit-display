// Top-level module of VGA digit display
// Jingnan Shi | David E Olumese
// 11/26/2018
// 
// Some good references:
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-01
// https://www.digikey.com/eewiki/pages/viewpage.action?pageId=15925278
// http://www.righto.com/2018/04/fizzbuzz-hard-way-generating-vga-video.html
// https://dekunukem.wordpress.com/2016/03/04/putting-the-f-in-fap-vga-controller-part-1-character-generator/
// http://blog.andyselle.com/2014/12/04/vga-character-generator-on-an-fpga/
// https://www.fpga4fun.com/PongGame.html
module vga_digit_display(input  logic clk, reset,
			 output logic hSync, vSync, R, G, B);

  logic [9:0] x, y;
  logic valid;
  
  // Create 25.175 MHz pixel clock for the VGA
  vga_pll vga_pll(.inclk0(clk), .c0(pix_clk));
	
  // driver module
  vga_driver driver(pix_clk, reset, hSync, vSync, x, y, valid);

  // draw a red square
  gen_red_square grs(x, y, R, G, B);
endmodule 

// Module for generating x, y, hsync, vsync, valid
// pix_clk: 25.175 MHz
// Screen Refresh Rate: 60 Hz
//
// VGA Timing data: http://martin.hinner.info/vga/timing.html
// Horizontal => Pixels
// Vertical => Lines
// AV  => Active Video
// FP  => Front Porch
// SP  => Sync Pulse
// BP  => Back Porch
// END => Total pixels
module vga_driver#(parameter H_AV  = 10'd640,
			     H_FP  = 10'd16,
			     H_SP  = 10'd96, 
			     H_BP  = 10'd48,
			     H_END = H_AV + H_FP + H_SP + H_BP,
			     V_AV  = 10'd480,
			     V_FP  = 10'd11,
			     V_SP  = 10'd2, 
			     V_BP  = 10'd32,
			     V_END = V_AV + V_FP + V_SP + V_BP)
		 (input  logic       pix_clk, reset,
		  output logic       hSync, vSync,
		  output logic [9:0] x, y,
		  output logic       valid);
						
  // Set hSync & vSync low during their sync pulses
  assign hsync = ~((x >= (H_AV + H_FP)) & (x < (H_AV + H_FP + H_SP)));
  assign vsync = ~((y >= (V_AV + V_FP)) & (y < (V_AV + V_FP + V_SP)));

  // Video is only valid within the x & y active video ranges
  assign valid = (x < H_AV) & (y < V_AV);

  // Generate x and y
  always @(posedge pix_clk, posedge reset) begin
    if (reset) begin
      x <= 0;
      y <= 0;
    end else begin
      x <= x + 10'd1;           // increment pixel count
      if (x >= H_END) begin
        x <= 0;                 // reset pixel count
        y <= y + 10'd1;         // increment line count 

        if (y >= V_END) y <= 0; // reset line count
      end
    end
  end
endmodule

// Digit generation (320x320 digit horizontally centered on screen)
//  using a 10 digit 6x8 ROM from a text file
module dig_gen_rom#(parameter SIZE    = 320,
			      X_START = 160,
			      X_END   = X_START + SIZE,
			      X_DIV   = 53,  // SIZE / 6 (cols of digit)
			      Y_START = 20,
			      Y_END   = X_START + SIZE,
			      Y_DIV   = 40)  // SIZE / 8 (rows of digit)
                  (input  logic [3:0] digit,
		   input  logic [9:0] x, y,
                   output logic       pixel);

  logic [5:0] digrom[3:0]; // digit generator ROM
  logic [5:0] line;        // a line of the digit
  logic xoff, yoff, valid;

  assign valid = (x >= X_START & x < X_END) &
		 (y >= Y_START & y < Y_END);

  // Scale the digit to 320x320 using divider
  assign xoff = (valid) ? (x - X_START) / X_DIV : 0;
  assign yoff = (valid) ? (y - Y_START) / Y_DIV : 0;

  // initialize the ROM from file
  initial
    $readmemb("digrom.txt", digrom);

  // extract the current line from the desired digit
  //  6x8 digit; digit * 8 + curr_y give the line from ROM
  assign line = {digrom[yoff+(digit, 3'b000}]};

  // reverse the bit order and extract current pixel
  assign pixel = (valid) ? line[3'd5 - xoff] : 0;

endmodule

// Simple test module: Draw a red square to the screen
module gen_red_square(input  logic [9:0] x, y,
		      output logic       R, G, B);

  assign R = ((x > 10'd200) && (y > 10'd120) && (x < 10'd360) && (y < 10'd280));
  assign G = 0;
  assign B = 0;

endmodule

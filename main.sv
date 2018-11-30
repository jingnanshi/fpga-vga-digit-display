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
module vga_digit_display(input  logic clk,
			 input  logic reset,
			 output logic hSync,
			 output logic vSync,
			 output logic R,
			 output logic G,
			 output logic B);

	// TODO: Consider using phased lock loop clk generate for more pression

	// generates a 25 MHz pixel clock
	// p = 5; N = 3;
	// 40 MHz * p / 2^N = 25 MHz 
	// (close to 25.175 MHz)
	logic [2:0] q;
	always_ff @(posedge clk, posedge reset) begin
		if (reset) q <= 0;
		else       q <= q + 3'd5;
	end
	logic pix_clk;
	assign pix_clk = q[2];
	
	// driver module
	logic [9:0] x;
	logic [9:0] y;
	logic valid;
	vga_driver driver(pix_clk, reset, hSync, vSync, x, y, valid);

	// draw a red square
	assign R = ((x > 10'd200) && (y > 10'd120) && (x < 10'd360) && (y < 10'd280));
	assign G = 0;
	assign B = 0;
endmodule 


// Module for generating x,y,hsync,vsync,valid
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
		 (input  logic       pix_clk,
		  input  logic       reset,
		  output logic       hSync,
		  output logic       vSync,
		  output logic [9:0] x,
		  output logic [9:0] y,
		  output logic       valid);
						
	// hSync is low for [H_AV + H_FP, H_AV + H_FP + H_SP]	
	assign hsync = ~((x >= (H_AV + H_FP)) & (x < (H_AV + H_FP + H_SP)));

	// vSync is low for [V_AV + V_FP, V_AV + V_FP + V_SP]	
	assign vsync = ~((y >= (V_AV + V_FP)) & (y < (V_AV + V_FP + V_SP)));
	
	// Valid region of pixels: x < H_ACTIVE_VIDEO & y < V_ACTIVE_VIDEO
	assign valid = (x < H_AV) & (y < V_AV);
	
	// Generate x and y
	always @(posedge pix_clk, posedge reset) begin
		if (reset) begin
			x <= 0;
			y <= 0;
		end else begin
			x <= x + 10'd1;         // increment pixel
			if (x >= H_END) begin 
				x <= 0;
				y <= y + 10'd1; // increment line 

				if (y >= V_END) y <= 0;
			end
		end
	end
endmodule

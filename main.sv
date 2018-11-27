// Top-level module of VGA digit display
// Jingnan Shi
// 11/26/2018
// 
// Some good references:
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-01
// https://www.digikey.com/eewiki/pages/viewpage.action?pageId=15925278
// http://www.righto.com/2018/04/fizzbuzz-hard-way-generating-vga-video.html
// https://dekunukem.wordpress.com/2016/03/04/putting-the-f-in-fap-vga-controller-part-1-character-generator/
// http://blog.andyselle.com/2014/12/04/vga-character-generator-on-an-fpga/
// https://www.fpga4fun.com/PongGame.html
module vga_digit_display(input logic clk,
								 input logic reset,
								 output logic hsync,
								 output logic vsync,
								 output logic VGA_R,
								 output logic VGA_G,
								 output logic VGA_B);
	
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
	logic [8:0] y;
	logic valid;
	vga_driver driver(pix_clk, reset, hsync, vsync, x, y, valid);

	// draw a red square
	assign VGA_R = ((x > 10'd200) && (y > 10'd120) && (x < 10'd360) && (y < 10'd280));
	assign VGA_G = 0;
	assign VGA_B = 0;
endmodule 


// Module for generating x,y,hsync,vsync,valid
// pix_clk: 25.175 MHz
module vga_driver(input logic pix_clk, 
						input logic reset, 
						output logic hsync, 
						output logic vsync,
						output logic [9:0] x,
						output logic [8:0] y,
						output logic valid);
						
	// VGA Timing data: http://martin.hinner.info/vga/timing.html
	// 
	// Horizontal Pixel Timings
	// Active Video: 640
	// Front Porch: 16
	// Sync Pulse: 96
	// Back Porch: 48
	// Total pixels: 800
	//
	// Vertical Line Timings
	// Active Video: 480
	// Front Porch: 11
	// Sync Pulse: 2
	// Back Porch: 31
	// Total lines: 524
	// Horizontal timing information
	localparam H_ACTIVE_VIDEO = 10'd640;
	localparam H_FRONT_PORCH = 10'd16;
	localparam H_SYNC_PULSE = 10'd96;
	localparam H_BACK_PORCH = 10'd48;
	localparam H_END = H_ACTIVE_VIDEO + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
	
	// Vertical timing information
	localparam V_ACTIVE_VIDEO = 9'd480;
	localparam V_FRONT_PORCH = 9'd11;
	localparam V_SYNC_PULSE = 9'd2;
	localparam V_BACK_PORCH = 9'd31;
	localparam V_END = V_ACTIVE_VIDEO + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;
	
	// hsync is low at (h active video + h front porch, 
   //                  h active video + h front porch + h sync pulse)	
	assign hsync = ~((x >= (H_ACTIVE_VIDEO + H_FRONT_PORCH))
						& (x <  (H_ACTIVE_VIDEO + H_FRONT_PORCH + H_SYNC_PULSE)));

	// vsync is low at (v active video + v front porch, 
	//                  v active video + v front porch + v sync pulse)
	assign vsync = ~((y >= (V_ACTIVE_VIDEO + V_FRONT_PORCH)) 
						& (y <  (V_ACTIVE_VIDEO + V_FRONT_PORCH + V_SYNC_PULSE)));
	
	// Valid region of pixels: x < H_ACTIVE_VIDEO & y < V_ACTIVE_VIDEO
	assign valid = (x < H_ACTIVE_VIDEO) & (y < V_ACTIVE_VIDEO);
	
	// Generate x
	always @(posedge pix_clk, posedge reset) begin
		if (reset) begin
			x <= 0;
		end else begin
			if (x == H_END) x<= 0;
			else x<=x + 10'd1;
		end
	end
	
	// Generate y
	always @(posedge pix_clk, posedge reset) begin
		if (reset) begin
			y <= 0;
		end else begin
			if (y == V_END) y<= 0;
			else y<=y + 9'd1;
		end
	end
	
endmodule 

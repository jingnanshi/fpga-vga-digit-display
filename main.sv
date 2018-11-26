module top();

endmodule 

// Some good references:
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-01
// https://www.digikey.com/eewiki/pages/viewpage.action?pageId=15925278
// http://www.righto.com/2018/04/fizzbuzz-hard-way-generating-vga-video.html
// https://dekunukem.wordpress.com/2016/03/04/putting-the-f-in-fap-vga-controller-part-1-character-generator/
// http://blog.andyselle.com/2014/12/04/vga-character-generator-on-an-fpga/
// https://www.fpga4fun.com/PongGame.html
module vga_driver(input logic clk, 
						input logic pix_clk, 
						input logic reset, 
						output logic hsync, 
						output logic vsync,
						output logic [9:0] x,
						output logic [8:0] y,
						output logic valid);
endmodule 

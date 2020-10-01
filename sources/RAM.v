`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:45:35 09/22/2020 
// Design Name: 
// Module Name:    RAM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RAM(
	input [31:0] address,
	output [63:0] data_block,	
	input hit_miss,	//0-hit,1-miss(access RAM)
	input r_w,	//0-read,1-write
	input clk,
	input reset,
	output reg access_done	//becomes 1 after 10 clk cycles
    );

	reg [7:0] ram_mem [127:0];	//byte addressable,128 bytes		
	reg [3:0] cc_counter;	//for clock cycles
	
	assign data_block = (access_done&&(~r_w)) ? 
	               (address%8==0) ? ({ram_mem[address+7], ram_mem[address+6], ram_mem[address+5], 
	                ram_mem[address+4], ram_mem[address+3], ram_mem[address+2], ram_mem[address+1], ram_mem[address]}) :
	                ({ram_mem[address+4], ram_mem[address+3], ram_mem[address+2], ram_mem[address+1], ram_mem[address], 
	                ram_mem[address-1], ram_mem[address-2], ram_mem[address-3], ram_mem[address-4]}) : 'bz; //TO CHANGE??
	
	always@(negedge reset)
	begin
		$readmemh("RAM.mem", ram_mem);
		access_done = 1'b0;
		cc_counter = 0;
	end
	
	always@(posedge clk)
	begin
		if(hit_miss == 1)	//Only for Miss, access RAM
		begin
			if(r_w == 0);	//read
		
			if(r_w == 1)	//write
				ram_mem[address] = data_block;	
		end
	end
	
	always@(negedge clk)	//or negedge?
	begin
		if(access_done == 1) begin
			access_done = 0;	//for next access	
			cc_counter = 0;
			end
			
		if(hit_miss == 1)
		begin
			if(cc_counter == 8)	//10 cc done, RAM access over
				access_done = 1;
			cc_counter = cc_counter+1;
			if(cc_counter == 9)
				cc_counter = 0;
		end
	end
	
	
	
	
endmodule
	
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2020 14:15:33
// Design Name: 
// Module Name: Cache_controller
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


module Cache_controller(
    input [31:0] address_from_proc,
    input clk,
    input reset,
    input r_w,
    output hit_miss,
    output [31:0] data_to_proc
    );
    wire [63:0] data_from_ram;
    wire ram_access_done;
    wire [31:0] address_to_ram;
    wire hit_miss;
    wire [31:0] data_to_proc;
    Instr_Cache IC_uut(address_from_proc, clk, reset, r_w, data_from_ram, ram_access_done,
                        address_to_ram, hit_miss, data_to_proc);
    RAM ram_uut(address_to_ram, data_from_ram, hit_miss, r_w, clk, reset, ram_access_done);
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2020 14:26:26
// Design Name: 
// Module Name: Cache_TB
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


module Cache_TB(

    );
    reg [31:0] address;
    reg clk,reset,r_w;
    wire hit_miss;
    wire [31:0] data;
    reg [31:0] address_list [9:0];  //stores input addresses
    reg [3:0] instruction;  //Like IPointer
    
    Cache_controller CC_uut(address, clk, reset, r_w, hit_miss, data);
    
    initial begin
        clk = 0;    reset = 1;  r_w = 0;   #10;
    end
    
    //always #5 clk = ~clk;
    
    initial begin
        reset = 0; #3;
        $readmemh("addresses.mem", address_list);
        instruction = 0;
        #5;
        repeat(1000) 
        begin
            address = address_list[instruction];
            clk = ~clk; #5;
            
            if(hit_miss==0)     //only if hit, send next instr
                instruction = instruction+1;
            clk = ~clk;#5;
            if(instruction==11)
                $finish;
        end
    end
endmodule

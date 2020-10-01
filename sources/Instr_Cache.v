`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:08:28 09/23/2020 
// Design Name: 
// Module Name:    Instr_Cache 
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
module Instr_Cache(
	input [31:0] address_from_proc,
	input clk,
	input reset,
	input r_w,
	input [63:0] data_from_ram,
	input ram_access_done,
	output reg [31:0] address_to_ram,
	output reg hit_miss,
	output reg [31:0] data_to_proc
    );

//2way , 4sets - set0,set1,set2,set3
//Each way implemented seperately with reg, in every set, 2ways, in a way 2 words/64bits
//1 word selected through block-offset

//Way 1 cache
reg valid1[0:3];	//valid1[0] for Set0,way1   valid1[1] for Set1,way1 ...array
reg lru1[0:3];		//Each location has 1-bit for lru. 0-LRU-replace, 1-MRU-just accessed
reg [26:0] tag1[0:3];	//array of 4 locations with each entry a 27 bit vector
reg [63:0] mem1[0:3];	//data, has two words, choose[63:32]/[31:0] based on block offset

//Way 2 cache
reg valid2[0:3];	
reg lru2[0:3];		
reg [26:0] tag2[0:3];	
reg [63:0] mem2[0:3];

//Other fields frm address
wire block_offset;		//0-choose word1, 1-choose word2
wire [1:0] index;
wire [26:0] in_tag;	//can go to either way(i.e tag1/tag2), depending on availability 
integer k;

//Initially reset everything
always@(negedge reset)
begin
	for(k=0;k<=3;k=k+1)
		begin
			valid1[k]=0; lru1[k]=0; 
			valid2[k]=0; lru2[k]=0;
		end
	$display("Intially hit_miss=1 i.e miss");
	hit_miss = 1;
end
	assign block_offset = address_from_proc[2];	//0,1 bits always 0
	assign index = address_from_proc[4:3];			//Gives set number
	assign in_tag = address_from_proc[31:5];
//assign data_to_proc = (hit_miss==0) ? ((block_offset==0) ? ) : 32'bz;

always@(*)	//make tag,block offset bits whenver add. from proc. changes
begin
	/*block_offset = address_from_proc[2];	//0,1 bits always 0
	index = address_from_proc[4:3];			//Gives set number
	in_tag = address_from_proc[31:5];	*/
	
	if(valid1[index]==1 && (in_tag==tag1[index]))  //Way1 hit
	begin
	   data_to_proc = (block_offset==0) ? mem1[index][31:0]:mem1[index][63:32];
	   hit_miss = 0;
	   lru1[index] = 1;
	   lru2[index] = 0;
	end
	else if(valid2[index]==1 && (in_tag==tag2[index])) //Way2 hit
	begin
	   data_to_proc = (block_offset==0) ? mem2[index][31:0]:mem2[index][63:32];
	   hit_miss = 0;
	   lru1[index] = 0;
	   lru2[index] = 1;
	end	
	/*case(in_tag)
	   tag1[index]: hit_miss = 0;  //Tag matched with way1
	   tag2[index]: hit_miss = 0;  //Tag matched with way2
	   default : hit_miss = 1;     //Miss
	endcase*/
	$display("Incoming request: BOffset=%b  set_index=%b  tag=%b hit_miss=%b",block_offset,index,in_tag,hit_miss);
end

always@(posedge clk)
begin
    address_to_ram = address_from_proc;
    
    if(hit_miss==0) //Hit, send the data to proc.
       begin     
        hit_miss=1; //for next  
       end
       
    if(hit_miss==1 && ram_access_done==1)   //Miss, enter this blk after ram_access is done,perform eviction
    begin
        if((valid1[index]==0)&&(valid2[index]==0))  //Both invalid, fill anywhere
        begin
            $display("Set%d : All ways invalid, filling first way",index);
            mem1[index] = data_from_ram;
            tag1[index] = in_tag;
            valid1[index] = 1'b1;
            lru1[index] = 1;
            hit_miss = 1;       //Data bought from ram, make it a hit
        end
        else if((valid1[index]==0)&&(valid2[index]==1))  //Put in way1, since it has invalid data
        begin
            $display("Set %d:Putting block in way1, as it contains invalid data",index);
            mem1[index] = data_from_ram;
            tag1[index] = in_tag;
            valid1[index] = 1'b1;
            lru1[index] = 1;
            lru2[index] = 0;
            hit_miss = 1;
        end
        else if((valid1[index]==1)&&(valid2[index]==0))  //Put in way2, since it has invalid data
        begin
            $display("Set %d:Putting block in way2, as it contains invalid data",index);
            mem2[index] = data_from_ram;
            tag2[index] = in_tag;
            valid2[index] = 1'b1;
            lru2[index] = 1;
            lru1[index] = 0;
            hit_miss = 1;
        end
       else //Both ways have valid data, need to evict one based on LRU
       begin
            if(lru1[index] == 0)    //Replacing way1 since its least recently used    
            begin
                $display("Set %d:Replacing block in Way1",index);
                mem1[index] = data_from_ram;
                tag1[index] = in_tag;
                lru1[index] = 1;
                lru2[index] = 0;
            end
            else if(lru2[index] == 0)   //Replacing way2 since its least recently used   
            begin
                $display("Set %d:Replacing block in Way2",index);
                mem2[index] = data_from_ram;
                tag2[index] = in_tag;
                lru1[index] = 0;
                lru2[index] = 1;            
            end
       end 
    end
end
endmodule

`timescale 1ns / 1ps


module myFIFO
#(parameter ADDR_WIDTH = 4,
  parameter FIFO_DEPTH = 16,
  parameter FIFO_WIDTH = 16
)
(
	input  logic clk,
	input  logic rst_n,
	input  logic wr_en,
	input  logic rd_en,                      //wire write/read enable
	input  logic [FIFO_WIDTH-1:0] buf_in,     // data input to be pushed to buffer
	output logic [FIFO_WIDTH-1:0] buf_out,    // port to output the data using pop.
	output logic buf_empty,
	output logic buf_full,                   // fifo buffer empty/full indication
	output logic [ADDR_WIDTH-1:0] fifo_cnt    // number of data pushed in to buffer,16-> FULL;0-> EMPTY
);

  logic [ADDR_WIDTH-1:0] rd_ptr,wr_ptr;      //ADDR PTR .INDEX ,CYCLE 0->15->0->15
  logic [FIFO_WIDTH-1:0] buf_mem[0:FIFO_DEPTH-1];
  
	//decide empty and full
  assign buf_empty = (fifo_cnt == 0)?1:0;
  assign buf_full  = (fifo_cnt == FIFO_DEPTH)?1:0;

  always_ff @(posedge clk or negedge rst_n)begin
     if(!rst_n)
         fifo_cnt <= 0;
     else if((!buf_full&&wr_en)&&(!buf_empty&&rd_en)) //WRTITE & READ ,HOLD
         fifo_cnt <= fifo_cnt;
     else if(!buf_full && wr_en)          //WRITE-> +1
         fifo_cnt <= fifo_cnt + 1;
     else if(!buf_empty && rd_en)         //READ -> -1
         fifo_cnt <= fifo_cnt-1;
     else
         fifo_cnt <= fifo_cnt;
  end
  //READ
  always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			buf_out <= 0;
		end else if(rd_en && !buf_empty) begin
			buf_out <= buf_mem[rd_ptr];
		end
  end
  //WRITE
  always_ff @(posedge clk) begin
		if(wr_en && !buf_full)
			buf_mem[wr_ptr] <= buf_in;
  end
//wr_ptr & rd_ptr  ,ADDR PTR
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			wr_ptr <= 0;
			rd_ptr <= 0;
		end else begin
			if(!buf_full && wr_en)
				wr_ptr <= wr_ptr + 1;
			if(!buf_empty && rd_en)
				rd_ptr <= rd_ptr + 1;
		end
	end

endmodule
`timescale 10ns/10ps

`define MACRO_DSIZE 8
`define MACRO_ASIZE 4
module AsyncFIFO
/************************
import packages*********
************************/


/************************
parameter****************
localparam****************
************************/
#(
parameter DSIZE = MACRO_DSIZE, //Data width
parameter ASIZE = MACRO_ASIZE  //Address width
)

/************************
interfaces***************
************************/
(
  input  logic [DSIZE-1: 0] wdata,    // input data
  input  logic              winc, wclk, wrst_n, //write enable、clock、rst
  input  logic              rinc, rclk, rrst_n, //read enable、clock、rst
  output logic [DSIZE-1: 0] rdata,    // output data
  output logic              wfull,    // fll signal for write
  output logic              rempty   // empty signal for read
)
; //!semicolon!



logic  [ASIZE-1 : 0]  waddr, raddr; 
logic  [ASIZE : 0]    wptr, rptr, wq2_rptr, rq2_wptr; 
 
//read to write
DualFFSynchronizer   sync_r2w (.outptr(wq2_rptr), .inptr(rptr),
                     .clk(wclk), .rst_n(wrst_n));

//write to read
DualFFSynchronizer   sync_w2r (.outptr(rq2_wptr), .inptr(wptr),
                     .clk(rclk), .rst_n(rrst_n));
 
fifomem #(DSIZE, ASIZE)  fifomem
                         (.rdata(rdata), .wdata(wdata),
                          .waddr(waddr), .raddr(raddr),
                          .wclken(winc), .wfull(wfull),
                          .wclk(wclk));


rptr_empty #(ASIZE)  rptr_empty
                     (.rempty(rempty),
                      .raddr(raddr),
                      .rptr(rptr), .rq2_wptr(rq2_wptr),
                      .rinc(rinc), .rclk(rclk),
                      .rrst_n(rrst_n));


wptr_full #(ASIZE)  wptr_full
                    (.wfull(wfull), .waddr(waddr),
                     .wptr(wptr), .wq2_rptr(wq2_rptr),
                     .winc(winc), .wclk(wclk),
                     .wrst_n(wrst_n));

endmodule: AsyncFIFO

module fifomem 
#(parameter DATASIZE = MACRO_DSIZE, //Data width
  parameter ADDRSIZE = MACRO_ASIZE  //Address width
)
/************************
interfaces***************
************************/
(output logic [DATASIZE-1: 0] rdata,
 input  logic [DATASIZE-1: 0] wdata,
 input  logic [ADDRSIZE-1: 0] waddr, raddr,
 input  logic                 wclken, wfull, wclk
);
    
`ifdef VENDORRAM 
// use vendor wrapper
/*vendor_ram  mem (.dout(rdata), .din(wdata),
                 .waddr(waddr), .raddr(raddr),
                 .wclken(wclken),
                 .wclken_n(wfull), .clk(wclk));*/
`else
// Behaviour model  
localparam DEPTH = 1<<ADDRSIZE; //calculate FIFO depth
logic  [DATASIZE-1: 0] mem [0: DEPTH-1]; // mem array
assign  rdata = mem[raddr];
always_ff @(posedge wclk)
   if (wclken && !wfull) 
      mem[waddr] <= wdata; 
`endif
endmodule

module rptr_empty 
# (parameter ADDRSIZE = MACRO_ASIZE)
(
output logic                  rempty,   
output logic  [ADDRSIZE-1: 0] raddr,    
output logic  [ADDRSIZE  : 0] rptr,     
input  logic  [ADDRSIZE  : 0] rq2_wptr, //writer address passed from the other side 
input  logic                  rinc, rclk, rrst_n
);

logic [ADDRSIZE: 0] rbin; //binary code
logic [ADDRSIZE: 0] rgraynext, rbinnext; 

always_ff@(posedge rclk or negedge rrst_n)
  if (!rrst_n) {rbin, rptr} <= 0;
  else         {rbin, rptr} <= {rbinnext, rgraynext};

assign raddr     = rbin[ADDRSIZE-1:0]; 

//pop when rinc (enabled) and the FIFO is not empty, then ++1
assign rbinnext  = rbin + (rinc & ~rempty);
assign rgraynext = (rbinnext>>1) ^ rbinnext; //convert to grey code
assign rempty_val = (rgraynext == rq2_wptr); //empty condition using grey code

always_ff@(posedge rclk or negedge rrst_n)
   if (!rrst_n) rempty <= 1'b1;
   else         rempty <= rempty_val;
endmodule

module wptr_full
#(parameter ADDRSIZE = MACRO_ASIZE)
(
output logic                 wfull, // full indicator
output logic [ADDRSIZE-1: 0] waddr, // write address
output logic [ADDRSIZE : 0]  wptr,  // potiner 
input  logic [ADDRSIZE : 0]  wq2_rptr, // read pointer passed from the other side
input  logic                 winc, wclk, wrst_n
);
   
logic [ADDRSIZE : 0]  wbin;
logic [ADDRSIZE : 0]  wgraynext, wbinnext;

always_ff @(posedge wclk or negedge wrst_n)
  if (!wrst_n) {wbin, wptr} <= 0;
  else         {wbin, wptr} <= {wbinnext, wgraynext};

assign waddr     =   wbin[ADDRSIZE-1:0]; //used for memory addressing

assign wbinnext  =   wbin + (winc & ~wfull);  //push and increment
assign wgraynext =  (wbinnext>>1) ^ wbinnext; //convert to grey code
// full condition by grey code
assign wfull_val = (wgraynext == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1],
                                   wq2_rptr[ADDRSIZE-2:0]}); 
always_ff @(posedge wclk or negedge wrst_n)
  if (!wrst_n) wfull <= 1'b0;
  else         wfull <= wfull_val;
endmodule

module DualFFSynchronizer 
#(parameter ADDRSIZE = MACRO_ASIZE)
(
output logic [ADDRSIZE: 0] outptr,  
input  logic [ADDRSIZE: 0] inptr,    
input  logic               clk, rst_n
);

logic [ADDRSIZE : 0]  firstFF; // the first FF
    
always @(posedge clk or negedge rst_n)
  if (!rst_n) {outptr,firstFF} <= 0;
  else         {outptr,firstFF} <= {firstFF,inptr}; //the second FF
endmodule

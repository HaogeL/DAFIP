module up_counter(
output reg [7:0] out     ,  // Output of the counter
input  wire      enable  ,  // enable for counter
input  wire      clk     ,  // clock Input
input  wire      reset      // reset Input

output wire      clk_out 
);
//-------------Code Starts Here-------
always_ff @(posedge clk)
if (reset) begin
  out <= 8'b0 ;
end else if (enable) begin
  out ++;
end

always_comb begin
	if(out%2==0)
		clk_out = 1b'1;
	else
		clk_out = 1b'0;
end

endmodule 
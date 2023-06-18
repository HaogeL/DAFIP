/*
grant is valid at the same CC as request and valid_request
*/
module round_robin_arb
#(parameter WIDTH=4)
(
  input  logic clk          ,
  input  logic rst_n        ,
	input  logic valid_request,
  input  logic [WIDTH-1:0] request,
  output logic [WIDTH-1:0] grant
);

    // Last arbitration result
    logic [WIDTH-1:0]   last_state;
		logic [2*WIDTH-1:0] grant_ext;
	  logic [WIDTH-1:0]   starting_onehot; 
		
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            last_state <= 4'b0001; //defualt after reset the LSB is selected
        else if(|request && valid_request==1b'1)
            last_state <= grant; // 
        else
            last_state <= last_state;  
    end

    
		//circular shift the previous grant one bit left. Otherwise there is chance the previous bit gets granted over and over again
		assign starting_onehot = {last_state[WIDTH-2,0], last_state[WIDTH-1]}; //circular shift the previous grant one bit left. Otherwise there is chance the same bit gets occupied again
    //perform RR arbiter algorithm
		assign grant_ext = {request,request} & ~({request,request} - starting_onehot);
    assign grant = grant_ext[WIDTH-1:0] | grant_ext[2*WIDTH-1:WIDTH];

endmodule


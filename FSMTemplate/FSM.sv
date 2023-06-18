module top_module (
	input clk,
	input [1:0] in,
	input areset,
	output out
);
	localparam A=2'd00, B=2'd01, C=2'd10, D=2'd11;
	logic[1:0] state;		// Ensure state and next are big enough to hold the state encoding.
	logic[1:0] next;
        
  always_comb begin
		case (state)
			A: //comb logic
			case (in)
					2'b01:     next = B ;
					2'b10:     next = C ;
					default:   next = state ;
			endcase
			B: //comb logic
			case (in)
					2'b01:     next = C ;
					2'b10:     next = D ;
					default:   next = state ;
			endcase
			C: //comb logic
			case (in)
					2'b01:     next = D ;
					2'b10:     next = A ;
					default:   next = state ;
			endcase
			D: //comb logic
			case (in)
					2'b01:     next = A ;
					2'b10:     next = B ;
					default:   next = state ;
			endcase
			default: next = A;
		endcase
  end			
	
	// Edge-triggered always block (DFFs) for state flip-flops. Asynchronous reset.
	always @(posedge clk or posedge areset) begin
		if (areset) state <= B;		// Reset to state B
		else state <= next;			// Otherwise, cause the state to transition
	end	
	// Combinational output logic. In this problem, an assign statement is the simplest.
	// In more complex circuits, a combinational always block may be more suitable.
	assign out = (state==B);
endmodule
module f3(clk, rst_n,clk2);

input clk;
input rst_n;
output clk2;

reg [2:0] negedge_count;
reg [2:0] posedge_count;
reg posedge_clk2;
reg negedge_clk2;
parameter N = 3;


always@(posedge clk or negedge rst_n)
begin
if(!rst_n || posedge_count == N-1)
posedge_count <= 3'd0;
else
posedge_count <= posedge_count +1'd1;
end


always@(negedge clk or negedge rst_n)
begin
if(!rst_n || negedge_count == N-1)
negedge_count <= 3'd0;
else
negedge_count <= negedge_count +1'd1;
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
posedge_clk2 <= 3'd0;
else if (posedge_count == 3'd1 || posedge_count == 3'd0)
posedge_clk2 <= !posedge_clk2;
else
posedge_clk2 <= posedge_clk2;
end


always@(negedge clk or negedge rst_n)
begin
if(!rst_n)
negedge_clk2 <= 3'd0;
else if (negedge_count == 3'd1 || negedge_count == 3'd0)
negedge_clk2 <= !negedge_clk2;
else
negedge_clk2 <= negedge_clk2;
end

assign clk2 = posedge_clk2 || negedge_clk2;

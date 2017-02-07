module bram #(
  parameter ABITS = 8, DBITS = 512,
  parameter INIT_ADDR = 0, INIT_DATA = 0
) (
  input clk,

  input [ABITS-1:0] WR_ADDR1,
  input [DBITS-1:0] WR_DATA1,
  input WR_EN1,

  input [ABITS-1:0] WR_ADDR2,
  input [DBITS-1:0] WR_DATA2,
  input WR_EN2,

  input [ABITS-1:0] RD_ADDR,
  output reg [DBITS-1:0] RD_DATA
);
  reg [DBITS-1:0] memory [0:2**ABITS-1];
  wire [ABITS-1:0] WR_ADDR;
  wire [DBITS-1:0] WR_DATA;
  wire WR_EN;

  assign WR_EN = (WR_EN1) ? WR_EN1 : WR_EN2;
  assign WR_ADDR = (WR_EN1) ? WR_ADDR1 : WR_ADDR2;
  assign WR_DATA = (WR_EN1) ? WR_DATA1 : WR_DATA2;

  initial begin
    memory[INIT_ADDR] <= INIT_DATA;
  end

  always @(posedge clk) begin
    if (WR_EN) memory[WR_ADDR] <= WR_DATA;
    RD_DATA <= memory[RD_ADDR];
  end
endmodule

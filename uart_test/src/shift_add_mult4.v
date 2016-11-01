`default_nettype none
module shift_add_mult4 (
  a,
  b,
  p
  );

  input [3:0] a;
  input [3:0] b;
  output [7:0] p;

  //shifts of a by (si)  or 0 if b[si] == 0
  wire [3:0] a_s0;
  wire [4:0] a_s1;
  wire [5:0] a_s2;
  wire [6:0] a_s3;

  wire [5:0] sum01;
  wire [6:0] sum12;


  assign a_s0 = b[0] ? a : 4'b0;
  assign a_s1 = b[1] ? (a << 1) : 4'b0;
  assign a_s2 = b[2] ? (a << 2) : 4'b0;
  assign a_s3 = b[3] ? (a << 3) : 4'b0;

  assign sum01 = a_s0 + a_s1;
  assign sum12 = a_s2 + sum01;
  assign p = a_s3 + sum12;

  endmodule

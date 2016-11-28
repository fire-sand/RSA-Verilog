`default_nettype none

module and_add (
    P,
    A,
    b,
    Out
);


input wire [256:0] P;
input wire [255:0] A;
input wire b;
output wire [256:0] Out;

assign Out = b ? (P+A) : P;
//assign Out = (P+A) * b + P * !b;

endmodule

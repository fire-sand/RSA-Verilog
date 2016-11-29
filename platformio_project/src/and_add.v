`default_nettype none

module and_add (
    P,
    A,
    b,
    Out
);


input wire [8:0] P;
input wire [7:0] A;
input wire b;
output wire [8:0] Out;

assign Out = b ? (P+A) : P;
//assign Out = (P+A) * b + P * !b;

endmodule

  1 //-----------------------------------------------------
  2 // Design Name : up_counter
  3 // File Name   : up_counter.v
  4 // Function    : Up counter
  5 // Coder      : Deepak
  6 //-----------------------------------------------------
  7 module up_counter    (
  8 out     ,  // Output of the counter
  9 enable  ,  // enable for counter
 10 clk     ,  // clock Input
 11 reset      // reset Input
 12 );
 13 //----------Output Ports--------------
 14     output [7:0] out;
 15 //------------Input Ports--------------
 16      input enable, clk, reset;
 17 //------------Internal Variables--------
 18     reg [7:0] out;
 19 //-------------Code Starts Here-------
 20 always @(posedge clk)
 21 if (reset) begin
 22   out <= 8'b0 ;
 23 end else if (enable) begin
 24   out <= out + 1;
 25 end
 27 

module synchronizer #(parameter width = 1) (
  input [width-1:0] async_signal,
  input clk,
  output [width-1:0] sync_signal
);
  // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.
  reg[width-1:0] q1=0;
  reg [width-1:0] q2=0;
  genvar i;
  generate for (i = 0; i < width; i = i + 1) begin:bit
       always@(posedge clk  )   begin
            q1[i]<=async_signal[i];
        end
       always@(posedge clk  ) begin
            q2[i]<=q1[i];
       end
       assign   sync_signal[i]=q2[i];
       end
   
  endgenerate

endmodule

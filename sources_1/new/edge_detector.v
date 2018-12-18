module edge_detector #(
  parameter width = 1
)(
  input clk,
  input [width-1:0] signal_in,
  output [width-1:0] edge_detect_pulse
);
  // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.
  reg [width-1:0]d=0;
  reg [19:0]k=0;
  reg [width-1:0]e=0;
  genvar i;
  generate  for (i = 0; i < width; i = i + 1) begin:bit
       always@(posedge clk)begin
             e[i]=signal_in[i]&&(~d[i]);
             d[i]=signal_in[i];
       end
       assign edge_detect_pulse[i]=e[i];
    
  end
  endgenerate
endmodule
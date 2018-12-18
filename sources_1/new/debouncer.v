`include "util.vh"

module debouncer #(
  parameter width = 1,
  parameter sample_count_max = 25000,
  parameter pulse_count_max = 150,
  parameter wrapping_counter_width = `log2(sample_count_max),
  parameter saturating_counter_width = `log2(pulse_count_max))
(
  input clk,
  input [width-1:0] glitchy_signal,
  output [width-1:0] debounced_signal
);
  // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.
 reg [wrapping_counter_width-1:0]counter1=0;
 genvar i;
 reg [width-1:0]deb=0;
 reg sig=0;
 reg [saturating_counter_width-1:0]  saturating_counter [width-1:0]; 
 integer k; 
 initial begin  
     for (k = 0; k < width; k = k + 1) begin 
         saturating_counter[k] = 0; 
     end 
 end
 generate for (i = 0; i < width; i = i + 1) begin:bit
    always@(posedge  clk)begin
        if(counter1<sample_count_max)
             begin
                 counter1 <=counter1+1'b1;
                 sig<=0;
             end
        else
            begin
                counter1 <=0;
                sig<=1;
            end
   end   
           
   always@(posedge clk)begin
        if(glitchy_signal[i]&&sig)begin
                  if(saturating_counter[i]<pulse_count_max)begin
                       saturating_counter[i]<=saturating_counter[i]+1;
                       deb[i]<=0;
                  end
                  if(saturating_counter[i]==pulse_count_max)begin
                        saturating_counter[i]<=pulse_count_max;
                        deb[i]<=1;
                  end
        end             
        if(!glitchy_signal)begin
              saturating_counter[i]<=0;
              deb[i]<=0;
  
         end
  end
  assign debounced_signal[i]=deb[i];
    
end
endgenerate
endmodule

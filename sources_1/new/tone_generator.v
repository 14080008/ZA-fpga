module tone_generator (
    input output_enable,
    input [23:0] tone_switch_period,
    input clk,
    input rst,
    output square_wave_out
);
  // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.

  reg[23:0] clock_counter=0;
 
  reg sqw =0;
  always@(posedge  clk  )
  begin
     if(rst)begin
         clock_counter <=24'b0;
     end
     else if(!rst)begin
         if(output_enable)begin
               if(clock_counter<tone_switch_period)
                   clock_counter <=clock_counter+1'b1;
               else if(clock_counter==tone_switch_period)
                      clock_counter <=24'b0;
         end
         else begin
              clock_counter <= clock_counter;
         end
     end
 end
 always@(posedge clk  ) begin
   if(rst)
       sqw <=1'b0;
   else begin
       if(output_enable)begin
          if(clock_counter==tone_switch_period/2)
                 sqw = ~sqw ;
          else  if(clock_counter==tone_switch_period)
                  sqw = ~sqw ;
        end
        else begin
              sqw = sqw ;
        end
    end
 end     
   assign square_wave_out=sqw;
endmodule

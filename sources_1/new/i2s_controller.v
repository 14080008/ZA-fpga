`include "util.vh"

module i2s_controller #(
  parameter SYS_CLOCK_FREQ = 125_000_000,
  parameter LRCK_FREQ_HZ = 88_200,
  parameter MCLK_TO_LRCK_RATIO = 192,
  parameter BIT_DEPTH = 24
) (
  input sys_reset,
  input sys_clk,            // Source clock, from which others are derived

  input [BIT_DEPTH-1:0] pcm_data,
  input [1:0] pcm_data_valid,
  output reg [1:0] pcm_data_ready,

  // I2S control signals
  output mclk,              // Master clock for the I2S chip
  output sclk,
  output lrck,              // Left-right clock, which determines which channel each audio datum is sent to.
  output sdin               // Serial audio data.
);

  // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.
//  localparam MCLK_FREQ_HZ = LRCK_FREQ_HZ * MCLK_TO_LRCK_RATIO;
//  localparam MCLK_CYCLES = `divceil(SYS_CLOCK_FREQ, MCLK_FREQ_HZ);
//  localparam MCLK_CYCLES_HALF = `divceil(MCLK_CYCLES, 2);
//  localparam MCLK_COUNTER_WIDTH = `log2(MCLK_CYCLES);
//  localparam LRCK_CYCLES=`divceil(SYS_CLOCK_FREQ, LRCK_FREQ_HZ);
//  localparam LRCK_CYCLES_HALF=`divceil(LRCK_CYCLES, 2);
//  localparam LRCK_COUNTER_WIDTH=`log2(LRCK_CYCLES);
//  localparam SCLK_FREQ_HZ=4233600;
////  localparam SCLK_CYCLES=`divceil(SYS_CLOCK_FREQ, SCLK_FREQ_HZ);
//  localparam SCLK_CYCLES=LRCK_CYCLES/48;
//  localparam SCLK_CYCLES_HALF=`divceil(SCLK_CYCLES, 2);
//  localparam SCLK_COUNTER_WIDTH=`log2(SCLK_CYCLES);

localparam MCLK_FREQ_HZ = LRCK_FREQ_HZ * MCLK_TO_LRCK_RATIO;
localparam MCLK_CYCLES = `divceil(SYS_CLOCK_FREQ, MCLK_FREQ_HZ);
localparam MCLK_CYCLES_HALF = `divceil(MCLK_CYCLES, 2);
localparam MCLK_COUNTER_WIDTH = `log2(MCLK_CYCLES);
localparam SCLK_FREQ_HZ=48*LRCK_FREQ_HZ;
localparam SCLK_CYCLES=`divceil(MCLK_FREQ_HZ, SCLK_FREQ_HZ);
//localparam SCLK_CYCLES=4;
localparam SCLK_CYCLES_HALF=`divceil(SCLK_CYCLES, 2);
//localparam SCLK_CYCLES_HALF=2;
localparam SCLK_COUNTER_WIDTH=`log2(SCLK_CYCLES);
localparam LRCK_CYCLES=`divceil(SCLK_FREQ_HZ, LRCK_FREQ_HZ);
//localparam LRCK_CYCLES=MCLK_TO_LRCK_RATIO;
localparam LRCK_CYCLES_HALF=`divceil(LRCK_CYCLES, 2);
//localparam LRCK_CYCLES_HALF=64;
localparam LRCK_COUNTER_WIDTH=`log2(LRCK_CYCLES);
      reg MCLK=0;
      reg SCLK=0;
      reg LRCK=0;
      reg SDIN=0;
      
      reg [MCLK_COUNTER_WIDTH-1:0]clkcounter=0;
      reg [LRCK_COUNTER_WIDTH-1:0]lrckcounter=0;
      reg [SCLK_COUNTER_WIDTH-1:0]sclkcounter=0;
      reg [BIT_DEPTH-1:0]bitcounter=0;
      reg [BIT_DEPTH-1:0]sdout=0;
  
      assign mclk=MCLK;
            assign sclk=SCLK;
            assign lrck=LRCK;
            assign sdin=sdout;
    always@(posedge sys_clk)begin
                 if(clkcounter==MCLK_CYCLES_HALF)begin
                       MCLK<=1;                         
                 end
                 if(clkcounter==MCLK_CYCLES)begin
                     clkcounter<=0;
                     MCLK<=0;
                 end
                 if(clkcounter!=MCLK_CYCLES)begin
                    clkcounter=clkcounter+1;
                 end    
            end
      
      
      
  // 2: Generate the LRCK, the left-right clock.
        
  always@( negedge sclk)begin
         if(lrckcounter==LRCK_CYCLES_HALF-1)begin
               LRCK<=1;
         end
         if(lrckcounter==LRCK_CYCLES-1)begin      
             lrckcounter<=0;
             LRCK<=0;                        
         end
         if(lrckcounter<LRCK_CYCLES-1)begin
            lrckcounter<=lrckcounter+1;
         end       
  end
  
  
  
  // 3. Generate the bit clock, or serial clock. It clocks transmitted bits for a 
  // whole sample on each half-cycle of the lr_clock. The frequency of this clock
  // relative to the lr_clock determines how wide our samples can be.
always@(posedge  mclk)begin
           if(sclkcounter==SCLK_CYCLES_HALF-1)begin
                 SCLK<=1;
           end
           if(sclkcounter==SCLK_CYCLES-1)begin      
               sclkcounter<=0;
               SCLK<=0;                        
           end
           if(sclkcounter<=SCLK_CYCLES-1)begin
              sclkcounter=sclkcounter+1;
           end       
    end
  
     always@(posedge sys_clk)begin
           if(sys_reset)begin
                  clkcounter<=0;
                  lrckcounter<=0;
                  sclkcounter<=0;
                  bitcounter<=0;
                  MCLK<=0;
                  SCLK<=0;
                  LRCK<=0;
                  sdout<=0;
                  pcm_data_ready<={1'b0,1'b0};
            end   
     end   
//  assign sdin = 1'b0;
//  assign sclk = 1'b0;
//  assign mclk = 1'b0;
//  assign lrck = 1'b0;

//ÊäÈëÓëÊä³ö
always@(negedge sclk )begin
//    if(lrckcounter==LRCK_CYCLES_HALF||lrckcounter==LRCK_CYCLES)
    if(pcm_data_valid>0)begin
      
            sdout<=pcm_data[23-bitcounter]; 
        
    end    
    else begin
        sdout<=sdout;
    
    end

end
always@(negedge sclk)begin
  if (pcm_data_valid>0)begin
   if(bitcounter<BIT_DEPTH-1)begin
       bitcounter<=bitcounter+1'b1;
   end
   else  begin  
       bitcounter<=0;
   end  
   end


end

always@(negedge LRCK)begin
  
      pcm_data_ready<={1'b1,1'b0};
      
end
always@(posedge LRCK)begin
   pcm_data_ready<={1'b0,1'b1};
   
end



endmodule

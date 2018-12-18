module z1top #(
    // We are using a 125 MHz clock for our design.
    // It is declared as a parameter so the testbench can override it if desired.
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200,
    // These are used for the button debouncer.
    // They are overridden in the testbench for faster runtime.
    parameter integer B_SAMPLE_COUNT_MAX = 0.0002 * CLOCK_FREQ,
    parameter integer B_PULSE_COUNT_MAX = 0.03/0.0002,
    
    parameter integer LRCK_FREQ_HZ = 44100,
    parameter integer MCLK_TO_LRCK_RATIO = 256,
    // This is the sample width, or the number of bits per sample sent in each audio frame.
    // Make sure this parameter is used everywhere it needs to be, consistently.
    parameter integer BIT_DEPTH = 8
)(
//    input RESET,
    input RESET,
    input CLK_125MHZ_FPGA,      // 125 MHz clock signal.
//    input [2:0] BUTTONS,        // Momentary push-buttons.
//    input [1:0] SWITCHES,       // Slide switches
    output [5:0] LEDS,          // Board LEDs.
    
    // You may not have plugged this in!
//    output [7:0] PMOD_LEDS,

    // I2S Signals
//    output MCLK,                // Master Clock.
//    output LRCLK,               // Left-right Clock.
//    output SCLK,                // Serial Clock.
//    output SDIN,                // Serial audio data output.
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
    // Crummy audio output
//    output AUDIO_PWM,
//    output aud_sd
);
//assign aud_sd=1;
//  wire reset;

  wire [2:0] clean_buttons;
  wire rcrd_en;
  wire[7:0] rcdout;
  wire rcempty;
  wire[7:0] rcdin;
  wire rcfull;
  wire rcwr_en;
  
  wire tswr_en;
  wire [7:0]tsdin;
  wire tsempty;
  wire tsfull;
  wire tsrd_en;
  wire [7:0]tsdout;
  
  // The button_parser is a wrapper for the synchronizer -> debouncer -> edge detector signal chain
//  button_parser #(
//      .width(4),
//      .sample_count_max(B_SAMPLE_COUNT_MAX),
//      .pulse_count_max(B_PULSE_COUNT_MAX)
//  ) b_parser (
//      .clk(CLK_125MHZ_FPGA),
//      .in({RESET, BUTTONS}),
//      .out({reset, clean_buttons})
//  );
  
  // YOUR CODE HERE.
  //    tone_generator
  //    piano_fsm,
  //    rom,
  //    piano_scale_rom,
  //    uart...
  
  //  下面是串口的实例化和串口与fifo之间信号逻辑的编写 
  
  //串口的实例化  
   reg [7:0] data_in;
   wire [7:0] data_out;
//   reg[7:0] dd;
//   always@(posedge CLK_125MHZ_FPGA)begin
//       if(RESET) dd<=1;
//       else    
//         dd<=tsdout;
//   end
   wire data_in_valid, data_in_ready, data_out_valid, data_out_ready;
   //串口与fifo之间的逻辑编写
//     assign data_in_valid=!tsempty;
////   assign tsrd_en=data_in_ready;
////   assign rcwr_en=data_out_valid;
//     assign data_out_ready=tsfull;
//     assign tswr_en=data_out_valid;
//     assign tsrd_en=data_in_ready;
//   always@(posedge CLK_125MHZ_FPGA) begin
//      if(reset)begin
//          data_out_ready<=0;
//      end
//      else if(data_out_valid)begin
//          data_out_ready<=0;
//      end
//      else begin
//        data_out_ready<=1;
//      end
   
   
//   end
      reg [7:0]tsdout1=8'b11111111;
        reg [7:0] char=0;
     
uart # (
          .CLOCK_FREQ(CLOCK_FREQ),
          .BAUD_RATE(BAUD_RATE)
      ) on_chip_uart (
          .clk(CLK_125MHZ_FPGA),
          .reset(RESET),
          .data_in(tsdout),
          .data_in_valid(data_in_valid),
          .data_in_ready(data_in_ready),
          .data_out(data_out),
          .data_out_valid(data_out_valid),
          .data_out_ready(data_out_ready),
          .serial_in(FPGA_SERIAL_RX),

          .serial_out(FPGA_SERIAL_TX)
      );
//always@(posedge CLK_125MHZ_FPGA)begin
//   if(data_in_valid)data_in<=tsdout;


//end
 reg has_char=0;
   fifo #(
                  .data_width(8),
                  .fifo_depth(32)
              )ts(
                  .clk(CLK_125MHZ_FPGA),
                  .rst(RESET),
                  .wr_en(tswr_en),
                  .din(tsdin),
                  .full(tsfull),
                  .rd_en(tsrd_en),
                  .dout(tsdout),
                  .empty(tsempty)
              );  
              
  always @(posedge CLK_125MHZ_FPGA) begin
     if (RESET) has_char <= 1'b0;
     else has_char <= has_char ? data_in_ready :data_out_valid ;
  end
//   always @(posedge CLK_125MHZ_FPGA) begin
//           if (!has_char) char <= tsdout;
//       end      
//  always @(posedge CLK_125MHZ_FPGA) begin
//      if (tsdout==0) tsdout1=8'b11111111;
//      else tsdout1=tsdout;
//      end
  assign LEDS[5:0]=tsdout[5:0];
    
//  always @(posedge CLK_125MHZ_FPGA) begin
//     if (!has_char) char <= tsdout;
//  end
//       reg fl=0;     
//  always @ (*) begin
//      if(!tsempty)begin
//         fl<=1;
         
         
//      end
//      else
//      fl=0;
//  end

//reg flag;
//always@(negedge data_in_valid )begin
//flag<=data_in_ready;
//end
//reg counter=0;
//reg flag1;
//always@(posedge CLK_125MHZ_FPGA )begin
//if(counter==2)begin
//flag1<=1;
//end
//else
//flag1<=0;
//end
//always@(posedge CLK_125MHZ_FPGA)begin
//if(has_char&&counter<1)begin
//   counter<=counter+1'b1;
////   if(counter==1)begin
////      flag1<=1;
////   end
////   else flag1<=0;
//end
//else
//  counter<=0;
   
//end
reg has=0;
reg has1=0;
always@(posedge CLK_125MHZ_FPGA)begin
  has<=has_char;

end
always@(posedge CLK_125MHZ_FPGA)begin
  has1<=has;

end
//reg em=0;
//reg emcount=2;
//reg redcount=0;
//always@(posedge CLK_125MHZ_FPGA)begin
// redcount<=data_in_ready;
//end
//always@(posedge CLK_125MHZ_FPGA)begin
//  if(!redcount&&emcount==2)begin
//     emcount<=emcount-1'b1;
//  end
//  if(emcount==1) emcount<=0;
//  if(redcount) emcount<=2;

//end
//always@(posedge CLK_125MHZ_FPGA)begin
//  if(emcount==1)begin
//     em<=1;
//  end
//  else em<=0;

//end
reg tsem=0;
always@(posedge CLK_125MHZ_FPGA)begin
     tsem<=tsempty;

end
assign data_in_valid = has;
assign data_out_ready = !has; 
assign tsrd_en=data_in_ready;
assign tswr_en=data_out_valid;
assign tsdin=data_out; 
             
//fifo的实例化


//fifo #(
//        .data_width(32),
//        .fifo_depth(8)
//    ) rc(
//        .clk(CLK_125MHZ_FPGA),
//        .rst(reset),
//        .wr_en(rcwr_en),
//        .din(data_out),
//        .full(rcfull),
//        .rd_en(rcrd_en),
//        .dout(rcdout),
//        .empty(rcempty)
//    );
      
//  fifo #(
//            .data_width(32),
//            .fifo_depth(8)
//        ) ts(
//            .clk(CLK_125MHZ_FPGA),
//            .rst(reset),
//            .wr_en(tswr_en),
//            .din(tsdin),
//            .full(tsfull),
//            .rd_en(tsrd_en),
//            .dout(data_in),
//            .empty(tsempty)
//        );  

//fifo #(
//        .data_width(8),
//        .fifo_depth(8)
//    ) rc(
//        .clk(CLK_125MHZ_FPGA),
//        .rst(reset),
//        .wr_en(rcwr_en),
//        .din(data_out),
//        .full(rcfull),
//        .rd_en(!tsfull),
//        .dout(rcdout),
//        .empty(rcempty)
         
//      always @(posedge CLK_125MHZ_FPGA) begin
//                      if (reset) has_char <= 1'b0;
//                      else has_char <= has_char ? !data_in_ready : data_out_valid;
//                  end
// always @(posedge CLK_125MHZ_FPGA) begin
//                          if (!has_char) char <= tsdout;
//                      end  
                      
//   always @ (*) begin
//          data_in = char;
//   end
                      
                          
  //piano_fsm的实例化    
      
//     piano_fsm aa(
//          .clk(CLK_125MHZ_FPGA),  
//          .rst(reset),   
//          .rotary_event(), 
//          .rotary_left(),
         
//          .ua_transmit_din(tsdin),  //回传给transmit的fifo的数据
//          .ua_transmit_wr_en(tswr_en),     //传递给transmit的fifo的wr_en写信号
//          .ua_transmit_full(tsfull),     // 输入的transmit的fifo的full信号
          
//          .ua_receive_dout(rcdout),   //从receive的fifo来的数据
//          .ua_receive_empty(rcempty),          //从receive的fifo来的empty信号
//          .ua_receive_rd_en(rcrd_en),       //输出给receive的fifo的re_en读信号
          
//          .i2s_din(),          //输出给i2s的fifo的数据
//          .i2s_wr_en(),               //输出给i2s的fifo的 wr_en写信号
//          .i2s_full(),                 //输入的i2s的fifo的full信号
          
//          .audio_pwm(AUDIO_PWM)               //输出给audio out的pwm数据
//         ); 
      
      
//  reg [BIT_DEPTH-1:0] pcm_data;
//  reg [1:0] pcm_data_valid;
//  wire [1:0] pcm_data_ready;

  // For the first part of the lab, you might want to just use this.
//  i2s_controller #(
//    .SYS_CLOCK_FREQ(CLOCK_FREQ),
//    .LRCK_FREQ_HZ(LRCK_FREQ_HZ),
//    .MCLK_TO_LRCK_RATIO(MCLK_TO_LRCK_RATIO),
//    .BIT_DEPTH(BIT_DEPTH)
//  ) i2s_control (
//    .sys_reset(reset),
//    .sys_clk(CLK_125MHZ_FPGA),

//    .pcm_data(pcm_data),
//    .pcm_data_valid(pcm_data_valid),
//    .pcm_data_ready(pcm_data_ready),

//    // I2S control signals
//    .mclk(MCLK),
//    .sclk(SCLK),
//    .lrck(LRCLK),
//    .sdin(SDIN)
//  );
endmodule

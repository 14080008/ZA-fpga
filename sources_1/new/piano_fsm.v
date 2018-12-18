module piano_fsm (
    input clk,  // 125 MHz clock as usual
    input rst,     //复位 
    input rotary_event,  //
    input rotary_left,

    output [7:0] ua_transmit_din,  //回传给transmit的fifo的数据
    output ua_transmit_wr_en,     //传递给transmit的fifo的wr_en写信号
    input ua_transmit_full,     // 输入的transmit的fifo的full信号

    input [7:0] ua_receive_dout,   //从receive的fifo来的数据
    input ua_receive_empty,          //从receive的fifo来的empty信号
    output ua_receive_rd_en,       //输出给receive的fifo的re_en读信号

    output [19:0] i2s_din,          //输出给i2s的fifo的数据
    output i2s_wr_en,               //输出给i2s的fifo的 wr_en写信号
    input i2s_full,                 //输入的i2s的fifo的full信号

    output audio_pwm               //输出给audio out的pwm数据
);
wire [23:0]tone=0;
reg [7:0]ascll=0;
reg [19:0]i2sdata=0;
reg flag1=0;
reg flag2=0;
reg flag3=0;
reg [7:0]eco=0;
reg [26:0]timeer=27'd25000000;
reg [26:0]clockcounter=0;
assign ua_transmit_din=eco;
assign ua_receive_rd_en=flag1;
assign ua_transmit_wr_en=flag2;

always@(posedge clk)begin
    if(!ua_receive_empty)begin
         flag1<=1;
         eco<=ua_receive_dout;
    end     

end

always@(posedge clk)begin
  if(!ua_transmit_full)begin
     flag2<=1;
  end
          
end
piano_scale_rom  pianodata(
      .address(eco), 
      .data(tone), 
      .last_address()
);

always@(posedge clk)begin
   if(!rst)begin
        if(clockcounter<timeer)
            clockcounter<=clockcounter+1'b1;
        else
            clockcounter<=27'b0;   
   end     
end
always@(posedge clk)begin
    if(!i2s_full)begin
        flag3<=1;
        i2sdata<=tone;
    
    
    end


end

tone_generator tg(
    .output_enable(flag1),
//    .tone_switch_period(tone),
    .tone_switch_period(tone),
    .clk(clk),
    .rst(rst),
    .square_wave_out(audio_pwm)
);



//    assign audio_pwm = 1'b0;
//    assign ua_transmit_din = 0;
//    assign ua_transmit_wr_en = 0;
//    assign ua_receive_rd_en = 0;
//    assign i2s_din = 0;
//    assign i2s_wr_en = 0;
endmodule

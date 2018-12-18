module piano_fsm (
    input clk,  // 125 MHz clock as usual
    input rst,     //��λ 
    input rotary_event,  //
    input rotary_left,

    output [7:0] ua_transmit_din,  //�ش���transmit��fifo������
    output ua_transmit_wr_en,     //���ݸ�transmit��fifo��wr_enд�ź�
    input ua_transmit_full,     // �����transmit��fifo��full�ź�

    input [7:0] ua_receive_dout,   //��receive��fifo��������
    input ua_receive_empty,          //��receive��fifo����empty�ź�
    output ua_receive_rd_en,       //�����receive��fifo��re_en���ź�

    output [19:0] i2s_din,          //�����i2s��fifo������
    output i2s_wr_en,               //�����i2s��fifo�� wr_enд�ź�
    input i2s_full,                 //�����i2s��fifo��full�ź�

    output audio_pwm               //�����audio out��pwm����
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

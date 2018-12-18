`include "util.vh"

module fifo #(
    parameter data_width = 8,    //FIFO中每个条目的位数
    parameter fifo_depth = 32,   //FIFO中条目数
    parameter addr_width = `log2(fifo_depth)//读写指针的位数
) (
    input clk, rst,

    // Write side
    input wr_en,                //该信号为高电平时，时钟的上升沿，din的数据将被写入FIFO
    input [data_width-1:0] din,       //写入FIFO的数据在这条线上
    output full,                          //此信号为高电平时表示FIFO已满

    // Read side
    input rd_en,                    //当该信号为高电平，在时钟的上升沿FIFO应该读出有dout上指针索引的数据
    output [data_width-1:0] dout,          //在rd_en被置为有效态后的上升沿后从FIFO读取的数据        
    output empty                       //此信号为高标明FIFO为空。
);
//    assign full = 1'b1;
//    assign empty = 1'b0;
//    assign dout = 0;

 reg [data_width-1:0]ram[fifo_depth-1:0];
 reg [data_width-1:0] D;
 reg [addr_width:0] c1,c2;
 
 integer k;
 initial begin
       for(k=0;k<fifo_depth;k=k+1)begin
           ram[k]<=0;
       end
       D<=0;
       c1<=0;
       c2<=0;
 end
 always@(posedge clk or negedge rst)begin
       if(rst)begin
           for(k=0;k<fifo_depth;k=k+1)begin
                  ram[k]<=0;
           end
           D<=0;
           c1<=0;
           c2<=0;
       end    
       else begin
           if(wr_en&&!full)begin
              ram[c1]<=din;
              c1<=c1+1'b1;
           end
//           if(c1==fifo_depth-1)begin
//               c1<=0;
//           end
       end
 end
 
 always@(posedge clk )begin
        if(!rst)begin
            if(rd_en&&!empty)begin
                 D<=ram[c2];
//                 ram[c2]<=0;
                 c2<=c2+1'b1;
            end
//            if(c2==fifo_depth-1)begin
//               c2<=0;
//            end
       end
 end

 assign full=(c1[addr_width]^c2[addr_width]&&c1[addr_width-1:0]==c2[addr_width-1:0]);
 assign empty=(c1==c2);
 assign dout[data_width-1:0]=D[data_width-1:0];
 always@(posedge clk)begin
     if(empty&&c1!=0&&c2!=0)begin
         c1<=0;
         c2<=0;
     end

 end
 

 
 
 
 
 
 
 
       
endmodule




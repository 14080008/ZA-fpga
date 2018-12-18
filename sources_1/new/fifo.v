`include "util.vh"

module fifo #(
    parameter data_width = 8,    //FIFO��ÿ����Ŀ��λ��
    parameter fifo_depth = 32,   //FIFO����Ŀ��
    parameter addr_width = `log2(fifo_depth)//��дָ���λ��
) (
    input clk, rst,

    // Write side
    input wr_en,                //���ź�Ϊ�ߵ�ƽʱ��ʱ�ӵ������أ�din�����ݽ���д��FIFO
    input [data_width-1:0] din,       //д��FIFO����������������
    output full,                          //���ź�Ϊ�ߵ�ƽʱ��ʾFIFO����

    // Read side
    input rd_en,                    //�����ź�Ϊ�ߵ�ƽ����ʱ�ӵ�������FIFOӦ�ö�����dout��ָ������������
    output [data_width-1:0] dout,          //��rd_en����Ϊ��Ч̬��������غ��FIFO��ȡ������        
    output empty                       //���ź�Ϊ�߱���FIFOΪ�ա�
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




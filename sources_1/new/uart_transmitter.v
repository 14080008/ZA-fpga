`include "util.vh"

module uart_transmitter #(
    parameter CLOCK_FREQ = 33_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,
 
    output serial_out
);
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   `log2(SYMBOL_EDGE_TIME);
    reg [9:0]ts_shift;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter=0;
    reg [3:0] bit_counter=0;
    wire endbitcounter;
    wire endclkcounter;
    reg buff=1;
    reg buff1=1;
    wire start;
    wire tx_running;
    assign tx_running=bit_counter!=4'd0;
    assign start = !data_in_ready && !tx_running; 
    assign endclkcounter=clock_counter==SYMBOL_EDGE_TIME-1;
    wire a=bit_counter==1;
    assign endbitcounter= a&&endclkcounter;
    always @(posedge clk ) begin
            if(reset == 1)
               clock_counter <= 0;
            else if(data_in_ready == 0) begin
               if(endclkcounter)
                   clock_counter <= 0;
               else
                   clock_counter <= clock_counter + 1'b1;
            end
        end
             reg flag=1;
        always @(posedge clk ) begin
            if(reset == 1)
               bit_counter <= 0;
            
                if(start) begin
                  
                   bit_counter <=10;
                end
            
                 if(endclkcounter&&tx_running)begin
                 
                   bit_counter <= bit_counter - 1'b1;
           end
        
        end
//   always @(posedge clk ) begin
//       if(reset == 1)bit_counter <= 0;
//       else if(endclkcounter)begin
//            if(endbitcounter)bit_counter <= 0;
//            else     bit_counter <= bit_counter +1'b1;    
//       end
   
//   end
   
   
   
   
   
   
   
   
   
   
    always @(posedge clk ) begin
                  if(reset == 1)
                      buff<= 1;
                      flag<=1;
                  if(data_in_valid)
                      buff <= 0;
                      flag<=2;
//                  if(buff==0)
//                     buff<=1;    
                  if(endbitcounter)
                      buff <= 1;
                      flag<=0;
          end
//      always@(posedge clk)begin     
//            if(reset)serial_out<=1'b1;
//            else if(buff==0&&bit_counter==0)begin
//                if(bit_counter==0)serial_out<=0;
//                else if (bit_counter==9) serial_out<=1; 
//                else  serial_out<=data_in[bit_counter-1];
            
//            end
//        end
          
        always@(posedge clk)begin
           if(data_in_valid)begin
            ts_shift<={1'b1,data_in,1'b0};
            end
            if(endclkcounter&&!endbitcounter&&data_in_ready==0)begin
               buff1=ts_shift[0];
               ts_shift = {1'b0,ts_shift[9:1]};
            end
            if(endbitcounter)begin
               buff1<=1'b1;
            end
             end


//             always @(posedge clk) begin
                 
//                 if (endclkcounter && tx_running) begin
                    
//                    ts_shift <= {1'b0,ts_shift[9:1]};
//             end 
         
       
//       reg flagin=0;
//         always@(posedge clk)begin
//         if(buff)begin
//             repeat (3) @(posedge clk);
//             flagin=buff;
//          end  
//         end 
//       reg bf=0;
//always@(negedge data_in_valid)begin
//  if(data_in_ready) bf<=1;
//  else bf<=0;
//end
       assign serial_out=buff1;
       assign data_in_ready=buff;
      

//    // USE YOUR IMPLEMENTATION FROM PREVIOUS LABS.

//    assign data_in_ready = 1'b0;
//    assign serial_out = 1'b1;
endmodule

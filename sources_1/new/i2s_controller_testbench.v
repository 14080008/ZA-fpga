`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000
`define SYSTEM_CLK_PERIOD 8
`define BIT_DEPTH 24
`define DATA_WIDTH 24
`define FIFO_DEPTH 8
`define RD_CLK_PERIOD 30
`define WR_CLK_PERIOD 80
module i2s_controller_testbench();
    // System clock domain I/O
    reg system_clock = 0;
    reg system_reset = 0;
    //reg square_wave = 0;
    //reg [3:0] volume_control = 0;

    // Connections between AC97 codec and controller
    //wire sdata_out, sync, reset_b, bit_clk;
    
    wire mclk, sclk, lrck, sdin;

    // Generate system clock
    always #(`SYSTEM_CLK_PERIOD/2) system_clock = ~system_clock;

    reg [`BIT_DEPTH-1:0] pcm_data=0;
    reg  left_valid=0;
    reg right_valid=0;
    wire left_ready, right_ready;
    reg rd_clk = 0;
        reg wr_clk = 0;
    always #(`RD_CLK_PERIOD/2) rd_clk = ~rd_clk;
             always @ (*) wr_clk = rd_clk;
                // Write side signals
              reg [`DATA_WIDTH-1:0] din = 0;
              reg wr_en = 0;
              wire full;
          
              // Read side signals
              wire [`DATA_WIDTH-1:0] dout;
              reg rd_en = 0;
              wire empty;
              reg [`DATA_WIDTH-1:0] test_values[`FIFO_DEPTH-1:0];
              reg [`DATA_WIDTH-1:0] received_values[`FIFO_DEPTH-1:0];
            fifo #(
                    .data_width(`DATA_WIDTH),
                    .fifo_depth(`FIFO_DEPTH)
                ) fifofo (
                    .clk(rd_clk),
                    .rst(system_reset),
                    .wr_en(wr_en),
                    .din(din),
                    .full(full),
                    .rd_en(rd_en),
                    .dout(dout),
                    .empty(empty)
                );    
        
        
    i2s_controller #(
      .SYS_CLOCK_FREQ(125_000_000),
      .LRCK_FREQ_HZ(88_200),
      .MCLK_TO_LRCK_RATIO(256)
    ) i2s (
      .sys_reset(system_reset),
      .sys_clk(system_clock),
      .pcm_data(pcm_data),
      .pcm_data_valid({left_valid, right_valid}),
      .pcm_data_ready({left_ready, right_ready}),
      .mclk(mclk),
      .sclk(sclk),
      .lrck(lrck),
      .sdin(sdin)
    );
    
   task write_to_fifo;
                input [`DATA_WIDTH-1:0] write_data;
                input violate_interface;
                begin
                    // If we want to not violate the interface agreement, if we are already full, don't write
                    if (!violate_interface && full) begin
                        wr_en <= 1'b0;
                    end
                    // In all other cases, we will force a write
                    else begin
                        wr_en <= 1'b1;
                    end
                    // Apply the data input
                    din <= write_data;
        
                    // Wait for the clock edge to perform the write
                    @(posedge wr_clk);
                    #1;
                    // Deassert the write enable
                    wr_en <= 1'b0;
                end
            endtask
        
            // This task will read some data from the FIFO through the read interface
            // violate_interface does the same as for the write_to_fifo task
            task read_from_fifo;
                input violate_interface;
                output [`DATA_WIDTH-1:0] read_data;
                begin
                    if (!violate_interface && empty) begin
                        rd_en <= 1'b0;
                    end
                    else begin
                        rd_en <= 1'b1;
                    end
                    // Wait for the clock edge to get the read data
                    @(posedge rd_clk);
                    #1;
        
                    read_data = dout;
                    rd_en <= 1'b0;
                end
            endtask     
        
        
        
        
        
    initial begin :TB
       // pcm_data = 0;
        integer i;
              // Generate the random data to write to the FIFO
        for (i = 0; i < `FIFO_DEPTH; i = i + 1) begin
            test_values[i] <= $urandom();
        end
        // Pulse the system reset to the i2s controller
        @(posedge system_clock);
        system_reset = 1'b1;
        repeat (10) @(posedge system_clock);
        system_reset = 1'b0;
        repeat (10) @(posedge system_clock);
        if (empty !== 1'b1) begin
                    $display("After reset, the FIFO isn't empty. empty = %b", empty);
                    $finish();
                end
        
                if (full !== 1'b0) begin
                    $display("After reset, the FIFO is full. full = %b", full);
                    $finish();
                end
        
                @(posedge wr_clk);
        
                // Begin pushing data into the FIFO with a 1 cycle delay in between each write operation
                for (i = 0; i < `FIFO_DEPTH - 1; i = i + 1) begin
                    write_to_fifo(test_values[i], 1'b0);
                if (empty === 1'b1) begin
                        $display("FIFO was empty as it's being filled"); $finish();
                end
                   if (full === 1'b1) begin
                   $display("FIFO was full before all entries have been filled"); $finish();
                   end
                                   
                 // Insert single-cycle delay between each write
                 @(posedge wr_clk);
               end
                                   
           // Perform the final write
      write_to_fifo(test_values[`FIFO_DEPTH-1], 1'b0);
                                   
          // Check that the FIFO is now full
    if (full !== 1'b1 || empty === 1'b1) begin
         $display("FIFO wasn't full or empty went high.\n");
          $display("full = %b, empty = %b", full, empty);
          $finish();
    end
                                   
    // Cycle the clock, the FIFO should still be full!
    repeat (10) @(posedge wr_clk);
      // The FIFO should still be full!
   if (full !== 1'b1 || empty == 1'b1) begin
 $display("Cycling the clock while the FIFO is full shouldn't change its stage! \n");
    $display("full = %b, empty = %b", full, empty);
      $finish();
   end
 repeat (5) @(posedge rd_clk);                                  
        
        
      while (!left_ready) @(posedge system_clock);  
      
       
        if(!empty)begin
             read_from_fifo(1'b0, received_values[0]); 
             pcm_data = received_values[0];
             left_valid =1;
             while (left_ready) @(posedge system_clock);
             left_valid = 0;
             while (!right_ready) @(posedge system_clock);
             read_from_fifo(1'b0, received_values[1]);
             pcm_data = received_values[1];
              right_valid = 1;
              while (right_ready) @(posedge system_clock);
              right_valid = 0;
        end
        
        
        
        
        
        
        
        
//        while (!left_ready) @(posedge system_clock);
//        pcm_data = 24'haaaaaa;
//        left_valid = 1;
//        while (left_ready) @(posedge system_clock);
//        left_valid = 0;

//        while (!right_ready) @(posedge system_clock);
//        pcm_data = 24'hcdcdcd;
//        right_valid = 1;
//        while (right_ready) @(posedge system_clock);
//        right_valid = 0;
        
    end


endmodule

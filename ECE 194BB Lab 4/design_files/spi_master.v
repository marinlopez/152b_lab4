`timescale 1ns / 1ps

module spi_master(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] ctrl,
    input  wire [31:0] data_tx,
    input  wire        spi_i,
    
    output reg  [31:0] data_rd,
    
    output reg         spi_clk,
    output reg         cs_n,
    output reg         spi_o
    );

//FSM parameters
parameter idle = 2'b00;
parameter setSR = 2'b01;
parameter stage1 = 2'b10;
parameter stage2 = 2'b11;

//Registers to be declared
reg [31:0] MOSI;
reg [1:0] state_current;
reg initiateSR;
reg srWriteFlag;
reg [4:0] spiclkCounter;
reg [5:0] dataOutCounter;

reg[31:0] localSlaveFIFO;

reg spi_oLatch;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        data_rd <= 32'b0;
        spi_clk <= 1'b0;
        cs_n <= 1'b1;
        spi_o <= 1'b0;
        MOSI <= 32'b0;
        initiateSR <= 1'b0;
        srWriteFlag <= 1'b0;
        spiclkCounter <= 3'b0;
        dataOutCounter <= 3'b0;
        localSlaveFIFO <= 32'b0;
        state_current <= idle;
    end else begin
        case(state_current)

            idle: begin //when the transition is done its going to go to this idle stage will it get stuck in else statment of if?
                if(ctrl == 8'h00000001 & initiateSR == 1'b0) begin
                    initiateSR <= 1'b1;
                    localSlaveFIFO <= 32'b0;
                    state_current <= setSR;
                    //after 32 bits have been transferred since srWriteFlag was never reset it comes to idle and immediately back here
                end else if(ctrl == 8'h00000002 && srWriteFlag == 1) begin
                    cs_n <= 0;
                    state_current <= stage1;
                end else begin
                    state_current <= idle;
                end

                if(dataOutCounter >= 32) begin
                    dataOutCounter <= 0;
                    data_rd <= localSlaveFIFO;
                    //this should be set to 0 so the ctrl can go back into the initiateSR stage if not stages just go 01010101
                    initiateSR <= 0;
                    state_current <= idle;
                end
            end

            setSR: begin
                MOSI <= data_tx;
                srWriteFlag <= 1'b1;
                state_current <= idle;
            end

            stage1: begin
                //this makes the frequency ratio 16, first 8 are when clock polarity is low
                spiclkCounter <= spiclkCounter + 1;
                if(spiclkCounter == 7) begin
                    spi_clk <= 1; //flip polarity go to next stage
                    state_current <= stage2;
                end else begin
                    state_current <= stage1;
                end                
            end

            stage2: begin // this will transmit untilspiclkcounter = 16 so no good
                //sample the data, will this cause problems?
                spiclkCounter <= spiclkCounter + 1;
                if(spiclkCounter ==9) begin
                    //shift into spi_o the MSB of local master register MISO, maybe change name to reduce conf
                    spi_o <= MOSI[31];
                    spi_oLatch <= MOSI[31];
                    //moves to next msb bit
                    MOSI <= {MOSI[30:0], 1'b0};
                    state_current <= stage2;
                end else begin 
                    if(spiclkCounter == 15 && dataOutCounter != 32) begin
                        //assign this MSB of MOSI to localslave reigster through spi_o
                        //when data out counter turns to 1 this does not update
                        localSlaveFIFO <= {localSlaveFIFO[30:0], spi_oLatch};
                        //this is a check to see if all data is transmitted
                        dataOutCounter <= dataOutCounter + 1;
                        spi_clk <= 0;
                        spiclkCounter <= 0;
                        state_current <= stage1;
                    end else begin
                        //spiclkCounter <= spiclkCounter + 1;
                        state_current <= stage2;
                    end
                end

                //if dataout is 32, spiclkcounter should always be 16
                if(dataOutCounter == 32 && spiclkCounter == 15) begin
                    cs_n <=1;
                    spiclkCounter <= 0;
                    srWriteFlag <= 0;
                    state_current <= idle;
                end
            end
        endcase  
    end
end
endmodule
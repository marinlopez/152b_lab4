`timescale 1ns / 1ps

/*cs_n, do i change this in the idle stage to 0 to initiate then put the case statement in a big if
statement that is if(!cs_n) do the fsm, and in the last transition stage [31:24] set cs_n to 1 to stop
*/

/*
Is it okay for the frequency ratio to be representd by a counter, if so am i thinking of the logic correctly
gets sampled at the 8th rising edge of the system clock and finishes at the 16th rising edge so thats
4 bits every 16 clock cycles or?
*/

/*
When im in my transition stage what register do i use to shift out data, i knowi ts spi_o but like thats
only 1 bit
*/

/*
should all my logic be in a synchronous always block? And fix my always@(posedge clk) block
*/

/*
Does it make sense to have the 4 stages for 8 bits each stage?
*/

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

//states are split into 4 transition stages where 4 bits and transfered each stage
parameter idle = 3'b000;
parameter setSR = 3'b001;
parameter transition07 = 3'b010;
parameter transition815 = 3'b011;
parameter transition1623 = 3'b100;
parameter transition2431 = 3'b101;

//frequency ratio logic

parameter counterBits = 4;
reg [counterBits -1: 0] frequencyCounter;

//these are set to high meaning that nothing happens so when they are set to low stuff starts
reg CPOL;
reg CPHA;
reg [2:0] state_next, state_current;

//flag for the SPI transition, COULD ALSO BE CS_N ,maybe do it in the clk logic 
reg initiateSR;

//this flag checks if the local shift register has been written to, this signal is reset when no data inside sr
reg srWriteFlag;

//this is the shift register that is set when control is 00000001 in stage setSR, other stages are
// to trasnmit the data
reg [31:0] localSR;


//frequency ratio 16 and CPOL and CPHA both low
//16 frequency ratio means that it should be sampled at 8 
//while cs_n is low data can be transmitted

always *@ begin
    if(rst_n) begin
        data_tx = 32'b0;
        spi_i = 1'b0;
        data_rd = 32'b0;
        spi_clk = 1'b0;
        cs_n = 1'b1;
        spi_o = 1'b0;
        CPOL = 1'b0;
        CPHA = 1'b0;
        initiateSR = 1'b0;
        srWriteFlag = 1'b0;
        frequencyCounter = 3'b000;
        state_next = idle;
    end else begin
        //should this be in an always @(posedge ) because that represents CPHA as low?
        case(state_current)

            idle: begin
                //set the shift register
                if(ctrl == 8'h00000001) begin
                    initiateSR = 1'b1;
                    state_next = setSR;
                //start transition if ctrl = 0x2 and local shift register has been written to
                //set cs_n to low here to initiate write
                end else if(ctrl = 8'h00000002 && srWriteFlag) begin
                    state_next = transition07;
                end else begin
                    //ex: ctrl = 0x2 but srWriteFlag is 0
                    state_next = idle;
                end
            end
            
            setSR: begin
                //set local shift register to data on data_tx, do i do localSR = data_tx or this
                localSR = {localSR, data_tx[31:0]};
                //say that the SR has been written to (condition for ctrl 0x2)
                srWriteFlag = 1'b1;
                //go back to idle to wait for control signal
                state_next = idle;
            end

            transition07: begin
                //does each bit go into spi_o then where does it go, how do i implement the freq ratio
            end
        endcase
    end

end

//cs_n changing logic this is chcecked everytime in the final stage transition, a flag should be set 
// to change cs_n and indicate a successful transcation of data and set the signal high again
always *@ begin

end

//SHOULD IT ALL JUST BE ON AN ALWAYS@(CLK)
// these might be wrong because cs_n is what means data can be had cs_n is 1 bit
always@(posedge clk) begin
    if(rst_n) begin
        spi_clk <= 1'b0;
        cs_n <= 1'b1;
        data_rd <= 32'b0;
        spi_o <= 32'b0;
        counter <= 0;
    end else begin

        //frequency counter logic
        counter <= counter + 1;
        if(counter == 15) begin
            counter <= 0;
        end

        cs_n <= data_tx;
        data_rd <= spi_i;
        state_current <= state_next;
    end
    //how is spi_o configured what do I set it to on the rising clock? Should it just be apart of the fsm?
    //spi_o
end

//this generate spi_clk

    
endmodule
    
`timescale 1ns / 1ps

module spi_slave(
    input  wire        spi_clk,
    input  wire        rst_n,
    input  wire        cs_n,
    input  wire        spi_i,
    
    output reg         spi_o
    );
    
    reg [31:0] sr;
    reg in_buffer;
    
    parameter sr_default = 'h1234abcd;
    
    always @(posedge spi_clk or negedge rst_n) begin
        if (!rst_n) begin
            in_buffer <= 1'b0;
        end
        else begin
            in_buffer <= spi_i;
        end
    end
    
    always @(negedge spi_clk or negedge rst_n) begin
        if (!rst_n) begin
            sr <= sr_default;
        end
        else sr <= {sr[30:0], in_buffer};
    end
    
    always @(*) begin
        spi_o = sr[31];
    end
    
endmodule

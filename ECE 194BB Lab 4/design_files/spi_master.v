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
    
endmodule
    
`timescale 1ns / 1ps

module spi_tb;

// Testbench uses reg for inputs to the master and wire for connections between master and slave
reg         clk_tb;
reg         rst_n_tb;
reg  [31:0] ctrl_tb;
reg  [31:0] data_tx_tb;

wire [31:0] data_rd_tb;
wire        spi_clk_tb;
wire        cs_n_tb;
wire        spi_o_master_tb;
wire        spi_o_slave_tb;

// Instantiate the spi_master module
spi_master master (
    .clk(clk_tb),
    .rst_n(rst_n_tb),
    .ctrl(ctrl_tb),
    .data_tx(data_tx_tb),
    .data_rd(data_rd_tb),
    .spi_i(spi_o_slave_tb),  // Connect spi_o from slave to spi_i of master
    .spi_clk(spi_clk_tb),
    .cs_n(cs_n_tb),
    .spi_o(spi_o_master_tb)
);

// Instantiate the spi_slave module
spi_slave slave (
    .spi_clk(spi_clk_tb),
    .rst_n(rst_n_tb),
    .cs_n(cs_n_tb),
    .spi_i(spi_o_master_tb),  // Connect spi_o from master to spi_i of slave
    .spi_o(spi_o_slave_tb)
);

// Clock generation
initial begin
    clk_tb = 0;
    forever #5 clk_tb = ~clk_tb; // Generate a clock with a period of 10 ns
end

// Test stimulus
initial begin
    // Initialize inputs
    rst_n_tb = 0;
    ctrl_tb = 0;
    data_tx_tb = 0;

    // Reset the system
    #200;
    rst_n_tb = 1;

    // Set control and data to be transmitted
    #20;
    ctrl_tb = 32'h00000001; // Example control value
    data_tx_tb = 32'h12345678; // Example data to transmit

    // Simulate SPI input data
    #100;
    ctrl_tb = 32'h00000002;
    
    #6000;
    ctrl_tb = 32'h00000001; // Example control value
    data_tx_tb = 32'h87654321; // Example data to transmit

    // Simulate SPI input data
    #100;
    ctrl_tb = 32'h00000002;
    
    // Continue with further test cases as needed

    #6000; // Run the simulation for a set time
    $finish; // End the simulation
end

endmodule
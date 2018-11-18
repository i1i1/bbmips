//`timescale 1ns / 1ps

module bbmips_test;

    reg i_clk, i_rst;

    bbmips	bbmips(.i_clk(i_clk), .i_rst(i_rst));


    parameter period = 100;

    initial begin
        i_rst = 0;
        #70 i_rst = 1;
    end

    initial begin
        i_clk = 0;
        forever #(period/2) i_clk = ~i_clk;
    end

endmodule


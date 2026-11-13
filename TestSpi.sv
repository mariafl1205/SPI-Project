`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2026 03:12:02 PM
// Design Name: 
// Module Name: TestSpi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TestSpi();

    parameter C_S_AXI_ADDR_WIDTH = 8, C_S_AXI_DATA_WIDTH = 32, CLK_PERIOD = 33.33;
    
    localparam CLK_PERIOD_2 = CLK_PERIOD/2;
    logic  S_AXI_ACLK;
    logic  S_AXI_ARESETN;
    logic  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR;
    logic  S_AXI_AWVALID;
    logic  S_AXI_AWREADY;
    logic  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA;
    logic  [3:0] S_AXI_WSTRB;
    logic  S_AXI_WVALID;
    logic  S_AXI_WREADY;
    logic  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR;
    logic  S_AXI_ARVALID;
    logic  S_AXI_ARREADY;
    logic  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA;
    logic  [1:0] S_AXI_RRESP;
    logic  S_AXI_RVALID;
    logic  S_AXI_RREADY;
    logic  [1:0] S_AXI_BRESP;
    logic  S_AXI_BVALID;
    logic  S_AXI_BREADY;
    
    logic conv;
    logic SDI;
    logic SCK;
    logic SDO;
    
    logic   [C_S_AXI_ADDR_WIDTH-1:0] wrAddr ;
    logic   [C_S_AXI_DATA_WIDTH-1:0] wrData ;
    logic   wr ;
    logic   [C_S_AXI_ADDR_WIDTH-1:0] rdAddr ;
    logic   [C_S_AXI_DATA_WIDTH-1:0] rdData ;
    logic   rd ;
    logic   wrDone;
    logic   rdDone;
    
    
    logic [C_S_AXI_DATA_WIDTH-1:0] rxData;
    
    Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteManager1
        (
            // Simple Bus
            .wrAddr(wrAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .wrData(wrData),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
            .wr(wr),                            // input    
            .wrDone(wrDone),                    // output
            .rdAddr(rdAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .rdData(rdData),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
            .rd(rd),                            // input
            .rdDone(rdDone),                    // output
            // Axi4Lite Bus
            .M_AXI_ACLK(S_AXI_ACLK),            // input
            .M_AXI_ARESETN(S_AXI_ARESETN),      // input
            .M_AXI_AWADDR(S_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
            .M_AXI_AWVALID(S_AXI_AWVALID),      // output
            .M_AXI_AWREADY(S_AXI_AWREADY),      // input
            .M_AXI_WDATA(S_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_WSTRB(S_AXI_WSTRB),          // output   [3:0]
            .M_AXI_WVALID(S_AXI_WVALID),        // output
            .M_AXI_WREADY(S_AXI_WREADY),        // input
            .M_AXI_ARADDR(S_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
            .M_AXI_ARVALID(S_AXI_ARVALID),      // output
            .M_AXI_ARREADY(S_AXI_ARREADY),      // input
            .M_AXI_RDATA(S_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_RRESP(S_AXI_RRESP),          // input    [1:0]
            .M_AXI_RVALID(S_AXI_RVALID),        // input
            .M_AXI_RREADY(S_AXI_RREADY),        // output
            .M_AXI_BRESP(S_AXI_BRESP),          // input    [1:0]
            .M_AXI_BVALID(S_AXI_BVALID),        // input
            .M_AXI_BREADY(S_AXI_BREADY)         // output
        );   
        
SPI #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) SPI1 
    (
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_WSTRB(S_AXI_WSTRB),          // input    [3:0]
        .S_AXI_WVALID(S_AXI_WVALID),        // input
        .S_AXI_WREADY(S_AXI_WREADY),        // output        
        .S_AXI_ARADDR(S_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_ARVALID(S_AXI_ARVALID),      // input
        .S_AXI_ARREADY(S_AXI_ARREADY),      // output
        .S_AXI_RDATA(S_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_RRESP(S_AXI_RRESP),          // output   [1:0]
        .S_AXI_RVALID(S_AXI_RVALID),        // output    
        .S_AXI_RREADY(S_AXI_RREADY),        // input
        .S_AXI_BRESP(S_AXI_BRESP),          // output   [1:0]
        .S_AXI_BVALID(S_AXI_BVALID),        // output
        .S_AXI_BREADY(S_AXI_BREADY),
        
        .conv(conv),
        .SDI(SDI),
        .SCK(SCK),
        .SDO(SDO)
    );
    
    AdcTester # () AdcTester1
    (
    .SCK(SCK), 
    .SDI(SDI), 
    .CS_(conv), 
    .SDO(SDO)
    );
    
    always begin
	   #(CLK_PERIOD_2) S_AXI_ACLK = ~S_AXI_ACLK;
    end
    
    initial begin
        S_AXI_ACLK = 0;
        S_AXI_ARESETN = 0;
        
        wr = 0;
        wrAddr = 0;
        wrData = 0;
        rd = 0;
        rdAddr = 0;

        #(CLK_PERIOD_2+2) S_AXI_ARESETN = 1;
        #(CLK_PERIOD*22);

        //write Width
        wr = 1;
        wrAddr = 'h04;
        wrData = 16;

        wait(wrDone === 1'b1);

        wr = 0;

        #(CLK_PERIOD_2+2);
        @(negedge S_AXI_ACLK);

        // Writew Frequency
        wr = 1;
        wrAddr = 'h08;
        wrData = 'h258; //600
        
        @(negedge S_AXI_ACLK);

        wr = 0;
        wait(wrDone === 1'b1);
        //wrAddr = 'h04;
        #(CLK_PERIOD+2);
        
        for (int i = 0; i < 1000; i++) begin
            rdAddr = 'h10;
            rxData = 0;
            

            @(negedge S_AXI_ACLK);
            wr = 1;
            wrAddr = 'h0C;
            
            if(i%2 == 0) begin
                wrData = 'hc000;
            end else begin
                wrData = 'h8000;
            end
            
            @(negedge S_AXI_ACLK);
            wr = 0;

            wait(wrDone === 1'b1);
            wait(wrDone === 1'b0);



            while (rxData[31] !== 1'b1) begin
                @(negedge S_AXI_ACLK);
                rd = 1;
                @(negedge S_AXI_ACLK);
                // Capture data immediately when read completes
                rd = 0;
                wait(rdDone === 1'b1);
                rxData = rdData;
                #(CLK_PERIOD+2);
            end 
            #(CLK_PERIOD+2);
            $display(rxData);
        end
        $finish;
        
    end
endmodule

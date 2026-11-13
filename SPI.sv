`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2026 01:20:23 PM
// Design Name: 
// Module Name: SPI
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

module SPI # (parameter C_S_AXI_ADDR_WIDTH = 8, C_S_AXI_DATA_WIDTH = 32, NUM_TAPS = 61, DATA_WIDTH = 32, ADDR_WIDTH = 6)(

        input  logic  S_AXI_ACLK,
        input  logic  S_AXI_ARESETN,
        input  logic  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input  logic  S_AXI_AWVALID,
        output logic  S_AXI_AWREADY,
        input  logic  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input  logic  [3:0] S_AXI_WSTRB,
        
        input  logic  S_AXI_WVALID,
        output logic  S_AXI_WREADY,
        input  logic  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input  logic  S_AXI_ARVALID,
        output logic  S_AXI_ARREADY,
        output logic  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output logic  [1:0] S_AXI_RRESP,
        output logic  S_AXI_RVALID,
        input  logic  S_AXI_RREADY,
        output logic  [1:0] S_AXI_BRESP,
        output logic  S_AXI_BVALID,
        input  logic  S_AXI_BREADY,

        output logic conv,
        output logic SDI,
        output logic SCK,
        input logic SDO
    );

    logic [C_S_AXI_ADDR_WIDTH-1:0] wrAddr, rdAddr;
    logic [C_S_AXI_DATA_WIDTH-1:0] wrData, rdData;
    logic wr, rd;

Axi4LiteSupporter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSupporter1 (

    // Simple Bus
    .wrAddr(wrAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .wrData(wrData),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
    .wr(wr),                            // output
    .rdAddr(rdAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .rdData(rdData),                    // input    [C_S_AXI_ADDR_WIDTH-1:0
    .rd(rd),                            // output  

    // Axi4Lite Bus
    .S_AXI_ACLK(S_AXI_ACLK),            // input
    .S_AXI_ARESETN(S_AXI_ARESETN),      // input
    .S_AXI_AWADDR(S_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_AWVALID(S_AXI_AWVALID),      // input
    .S_AXI_AWREADY(S_AXI_AWREADY),      // output
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
    .S_AXI_BREADY(S_AXI_BREADY)         // input
    );
// need sdo FLOP 

typedef enum logic [1:0] {IDLE, CONV, INITSCK, DONE} statetype ;
statetype nextState, currState ;  

    logic [8:0] sckQ, sckD;
    logic[9:0] sampleClkQ, sampleClkD;

    logic [23:0] StoreSDI_Q, StoreSDI_D;

    logic [6:0] sdi_widthQ, sdi_widthD;
    logic [17:0] conv_widthQ, conv_widthD;

    logic ADC_Q, ADC_D;
    logic SDI_D, SDI_Q;
    
    logic SCK_D, SCK_Q;
    logic conv_D, conv_Q;
    
    logic WrBuffer_Q, WrBuffer_D;

    logic [31:0] sdoData_D, sdoData_Q;

    assign SDI = SDI_Q;
    assign SCK = SCK_Q;
    assign conv = conv_Q;
    

// Sequential Logic

always_ff @(posedge S_AXI_ACLK) begin

    if (!S_AXI_ARESETN) begin
        currState <= IDLE;
        sckQ <= 0;
        sampleClkQ <= 'h258;

        sdi_widthQ <= 0;
        StoreSDI_Q <= 0;
        conv_widthQ <= 0;

        ADC_Q <= 0;
        SDI_Q <= 0;
        sdoData_Q <= 0;
        
        SCK_Q <= 0;
        conv_Q <= 0;
        
        WrBuffer_Q <= 0;
        
    end
    else begin
        currState <= nextState;
        sckQ <= sckD;
        sampleClkQ <= sampleClkD;
        
        sdi_widthQ <= sdi_widthD;
        StoreSDI_Q <= StoreSDI_D;
        conv_widthQ <= conv_widthD;
        
        ADC_Q <= ADC_D;
        SDI_Q <= SDI_D;
        
        sdoData_Q <= sdoData_D;
        
        SCK_Q <= SCK_D;
        conv_Q <= conv_D;
        
        WrBuffer_Q <= WrBuffer_D;
    end
end


always_comb begin
    nextState = currState;
    sckD = sckQ;

    sdi_widthD = sdi_widthQ;
    StoreSDI_D = StoreSDI_Q;
    conv_widthD = conv_widthQ;

    ADC_D = ADC_Q;
    SDI_D = SDI_Q;
    sampleClkD = sampleClkQ + 1;
    
    sdoData_D = sdoData_Q;
    
    SCK_D = SCK_Q;
    conv_D = conv_Q;
    rdData = sdoData_Q;
    
    WrBuffer_D = WrBuffer_Q;
    
    case (currState)

        IDLE: begin
            nextState = IDLE;
            
            if (wr && wrAddr == 'h04) begin //Width
                sdi_widthD = wrData;
            end

            if (wr && wrAddr == 'h08) begin //CONV LENGTH
                conv_widthD = wrData;
            end

            if (wr && wrAddr == 'h0C) begin //DATA
                StoreSDI_D = wrData;
                WrBuffer_D = 1'b1;
            end
            
            if (WrBuffer_Q && sampleClkQ > conv_widthQ) begin //DATA
                WrBuffer_D = 1'b0;
                nextState = CONV;
            end
            
            //if (wr && wrAddr == 'h00 && sampleClkQ > 10'd600 ) begin
//            if (wr && wrAddr == 'h00 && sampleClkQ > 'h258) begin //DAC
//                nextState = CONV;
//                DACSDI_D = wrData;
//                sdi_widthQ = wrData;
//                //
//                ADC_D = 0;
//            end
//           if (wr && wrAddr == 'h04 && sampleClkQ > 'h258) begin //ADC
//                nextState = CONV;
//                ADCSDI_D = wrData;
//                ADC_D = 1;
//            end
              SCK_D = 0;
              conv_D = 1;
        end

        CONV: begin
            conv_D = 0;
            sampleClkD = 0;
            nextState = INITSCK;
            sdoData_D = 0;
        end

        

        INITSCK: begin
            if (sckQ > (sdi_widthQ * 8)) begin
                SCK_D = 0;
                sdoData_D = sdoData_Q >> 1;
                sdoData_D[30] = 0;
                sdoData_D[31] = 1;
                nextState = DONE;
            end

           //Counter
            sckD = sckQ + 1;

            if ((sckQ&7) == 2) begin //may cause problems
                SCK_D = 1;                
            end           
            
            if ((sckQ&7) == 4) begin
               sdoData_D[0] = SDO; 
            end  
            
            if ((sckQ&7) == 5) begin
                sdoData_D = sdoData_Q << 1;
                SCK_D = 0;
                sckD = sckQ + 3;
            end
            if ((sckQ&7) == 0) begin
                SDI_D = StoreSDI_Q[sdi_widthQ - 1];
                StoreSDI_D = StoreSDI_Q << 1;

//                if (!ADC_Q) begin
//                    SDI_D = DACSDI_Q[23];
//                    DACSDI_D = DACSDI_Q << 1;
//                end
//                if (ADC_Q) begin
//                    SDI_D = ADCSDI_Q[15];
//                    ADCSDI_D = ADCSDI_Q << 1;
//                end
            end
        end

        DONE : begin
            sckD = 0;
            conv_D = 1;
            nextState = IDLE;
        end
        
        endcase
        
        if (rd && rdAddr == 'h10) begin
            if (sdoData_Q[31] == 1) begin
                rdData = sdoData_Q;
                sdoData_D[31] = 0;
            end
        end
    end
    
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2026 01:17:16 PM
// Design Name: 
// Module Name: Axi4LiteSupporter
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


module Axi4LiteSupporter # 
    (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
    (
        // Simple Bus
        output logic  [C_S_AXI_ADDR_WIDTH-1:0] wrAddr,
        output logic  [C_S_AXI_DATA_WIDTH-1:0] wrData,
        output logic  wr,
        output logic  [C_S_AXI_ADDR_WIDTH-1:0] rdAddr,
        input  logic  [C_S_AXI_DATA_WIDTH-1:0] rdData,
        output logic  rd,
        // Axi4Lite Bus
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
        input  logic  S_AXI_BREADY
    );
    
    typedef enum logic [3:0] {IDLE, WR1, WR2, WReady, R1, R2, R3, R4, RReady} statetype ;
    statetype nextState, currState ;

logic [C_S_AXI_ADDR_WIDTH-1:0] rdAddrD, rdAddrQ ;
logic [C_S_AXI_DATA_WIDTH-1:0] rdDataD, rdDataQ ;

    // Sequential logc
always_ff @ (posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        currState <= IDLE;
        rdAddrQ <= 0;
        rdDataQ <= 0;
    end else begin
        currState <= nextState;
        
        rdAddrQ <= rdAddrD;
        rdDataQ <= rdDataD;
    end
end

// COmbinational Logic

always_comb begin
    
    nextState = currState;
    
    S_AXI_AWREADY = 0; 
    S_AXI_WREADY = 0; 
    S_AXI_BVALID = 0;
    S_AXI_BRESP = 'b00;
    
    S_AXI_ARREADY = 0;
    S_AXI_RVALID = 0;
    S_AXI_RRESP = 'b00;
    S_AXI_RDATA = 0;
    
    //Supporter Bus
    wr = 0;
    wrAddr = 0;
    wrData = 0;
    rd = 0;
    rdAddr = 0;
    
    //Flops
    rdDataD = rdDataQ;
    rdAddrD = rdAddrQ;
    
    case (currState)
        IDLE: begin
        if (S_AXI_AWVALID && S_AXI_WVALID) begin
            nextState = WR1;
        end else if (S_AXI_ARVALID) begin
            rdAddrD = S_AXI_ARADDR;
            nextState = R1;
            end
        end
        
        // Write FSM
        WR1: begin
            S_AXI_AWREADY = 1;
            S_AXI_WREADY = 1;
            
            wr = 1;
            wrAddr = S_AXI_AWADDR;
            wrData = S_AXI_WDATA;
            nextState = WR2;
        end
        
        WR2: begin
            S_AXI_BRESP = 'b00;
            S_AXI_BVALID = 1;
            
            if (S_AXI_BREADY) begin; 
                nextState = IDLE; 
            end
        end
        
        // Read FSM
        
        R1: begin
            S_AXI_ARREADY = 1;
            rdAddr = rdAddrQ;
            rd = 1;
            
            rdDataD = rdData;
            nextState = RReady;
        end
                
        RReady: begin
            S_AXI_RDATA = rdDataQ;
            S_AXI_RRESP = 'b00;
            S_AXI_RVALID = 1;
            
            if (S_AXI_RREADY) begin
                nextState = IDLE;
            end
        end
        
        default: begin
            nextState = IDLE;
        end
    endcase
end
endmodule

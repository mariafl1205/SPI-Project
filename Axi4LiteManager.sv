`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/27/2026 03:18:54 PM
// Design Name: 
// Module Name: axi4LiteManager
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


module Axi4LiteManager # 
    (parameter C_M_AXI_ADDR_WIDTH = 8, C_M_AXI_DATA_WIDTH = 32)
    (
        // Simple Bus
        input  logic    [C_M_AXI_ADDR_WIDTH-1:0] wrAddr,
        input  logic    [C_M_AXI_DATA_WIDTH-1:0] wrData,
        input  logic    wr,
        output  logic   wrDone,
        input  logic    [C_M_AXI_ADDR_WIDTH-1:0] rdAddr,
        output logic    [C_M_AXI_DATA_WIDTH-1:0] rdData,
        input  logic    rd,
        output  logic   rdDone,
        // Axi4Lite Bus
        input  logic    M_AXI_ACLK,
        input  logic    M_AXI_ARESETN,
        output logic    [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR,
        output logic    M_AXI_AWVALID,
        input  logic    M_AXI_AWREADY,
        output logic    [C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA,
        output logic    [3:0] M_AXI_WSTRB,
        output logic    M_AXI_WVALID,
        input  logic    M_AXI_WREADY,
        output logic    [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR,
        output logic    M_AXI_ARVALID,
        input  logic    M_AXI_ARREADY,
        input  logic    [C_M_AXI_DATA_WIDTH-1:0] M_AXI_RDATA,
        input  logic    [1:0] M_AXI_RRESP,
        input  logic    M_AXI_RVALID,
        output logic    M_AXI_RREADY,
        input  logic    [1:0] M_AXI_BRESP,
        input  logic    M_AXI_BVALID,
        output logic    M_AXI_BREADY
    );
    
    typedef enum logic [3:0] {IDLE, WR1, WRESP ,WDONE, R1, RRESP, RDONE} statetype ;
    statetype nextState, currState ;
    
logic [C_M_AXI_ADDR_WIDTH-1:0] wrAddrD, wrAddrQ ;
logic [C_M_AXI_DATA_WIDTH-1:0] wrDataD, wrDataQ ;
logic [C_M_AXI_ADDR_WIDTH-1:0] rdAddrD, rdAddrQ ;
logic [C_M_AXI_DATA_WIDTH-1:0] rdDataD, rdDataQ ;



// Sequential logc
always_ff @ (posedge M_AXI_ACLK) begin
    if (!M_AXI_ARESETN) begin
        currState <= IDLE;
        wrAddrQ <= 0;
        wrDataQ <= 0;
        rdDataQ <= 0;
        rdAddrQ <= 0;
    end else begin
        currState <= nextState;
        wrAddrQ <= wrAddrD;
        wrDataQ <= wrDataD;
        rdDataQ <= rdDataD;
        rdAddrQ <= rdAddrD;
    end
end

// COmbinational Logic

always_comb begin
    nextState = currState;
    
    //Write
    M_AXI_AWADDR = 0;
    M_AXI_AWVALID = 0;
    M_AXI_WDATA = 0;
    M_AXI_WVALID = 0;
    
    M_AXI_BREADY = 0;
    wrDone = 0;
    
    //Read
    M_AXI_ARADDR = 0;
    M_AXI_ARVALID = 0;
    M_AXI_RREADY = 0;
    rdData = 0;
    rdDone = 0;
    
    //Flops
    wrDataD = wrDataQ;
    wrAddrD = wrAddrQ;
    rdDataD = rdDataQ;
    rdAddrD = rdAddrQ;
    
    M_AXI_WSTRB = 'b1111 ;
    
    case (currState)
        IDLE: begin
        if (wr) begin
            wrDataD = wrData;
            wrAddrD = wrAddr;
            nextState = WR1;
        end else if (rd) begin
            rdAddrD = rdAddr;
            nextState = R1;
            end
        end 
        
        // Write FSM
        WR1: begin
            M_AXI_AWADDR = wrAddrQ;
            M_AXI_AWVALID = 1;
            M_AXI_WDATA = wrDataQ;
            M_AXI_WVALID = 1;
            if(M_AXI_AWREADY && M_AXI_WREADY) begin
                nextState = WRESP;
                end
            end
            
        WRESP: begin
            M_AXI_BREADY = 1;
            if (M_AXI_BVALID && M_AXI_BRESP == 'b00) begin
                nextState = WDONE;
            end
            // May need to add for other error codes, but is fine for now 
        end
        
        WDONE: begin
            wrDone = 1;
            if (!wr) begin
                nextState = IDLE;
            end
        end
        
        // Read FSM
        R1: begin
            M_AXI_ARADDR = rdAddrQ;
            M_AXI_ARVALID = 1;
            if (M_AXI_ARREADY) begin
                nextState = RRESP;
            end
        end
        
        RRESP: begin
            M_AXI_RREADY = 1;
            if (M_AXI_RVALID && M_AXI_RRESP == 'b00) begin
                rdDataD = M_AXI_RDATA;
                nextState = RDONE;
            end
        end
        
        RDONE: begin
            rdData = rdDataQ;
            rdDone = 1;
            if (!rd) begin
                nextState = IDLE;
            end
        end
        
    endcase 
end

endmodule

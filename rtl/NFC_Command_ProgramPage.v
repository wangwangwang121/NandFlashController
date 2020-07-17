`timescale 1ns / 1ps

module NFC_Command_ProgramPage
#
(
    parameter NumberOfWays    =   4,
    parameter CommandID       =   6'b000011,
    parameter TargetID        =   5'b00101
)
(
    iSystemClock             ,  
    iReset                   ,  

    iOpcode                  ,  
    iTargetID                ,  
    // iSourceID                ,  
    // iAddress                 ,  
    iLength                  ,  
    iCMDValid                ,  
    oCMDReady                ,  
    iWaySelect               ,
    iColAddress              ,
    iRowAddress              ,

    oStart                   ,
    oLastStep                ,

    // iWriteData               ,  
    // iWriteLast               ,  
    // iWriteValid              ,  
    // oWriteReady              ,  

    // oReadData                ,  
    // oReadLast                ,  
    // oReadValid               ,  
    // iReadReady               , 

    // oReadyBusy               ,  

    oACG_Command          ,  
    oACG_CommandOption    ,  

    iACG_Ready            ,  
    iACG_LastStep         ,  
    oACG_TargetWay        ,  
    oACG_NumOfData        ,  

    oACG_CASelect         ,  
    oACG_CAData           ,  

    // oACG_WriteData        ,  
    // oACG_WriteLast        ,  
    // oACG_WriteValid       ,  
    // iACG_WriteReady       ,  

    // iACG_ReadData         ,  
    // iACG_ReadLast         ,  
    // iACG_ReadValid        ,  
    // oACG_ReadReady        ,  

    iACG_ReadyBusy        
);


    input                           iSystemClock         ;
    input                           iReset               ;
 
    input   [5:0]                   iOpcode              ;
    input   [4:0]                   iTargetID            ;
    // input   [4:0]                   iSourceID            ;
    // input   [31:0]                  iAddress             ;
    input   [15:0]                  iLength              ;
    input                           iCMDValid            ;
    output                          oCMDReady            ;

    input   [NumberOfWays - 1:0]    iWaySelect           ;
    input   [15:0]                  iColAddress          ;
    input   [23:0]                  iRowAddress          ;
    output                          oStart               ;
    output                          oLastStep            ;

    // input   [15:0]                  iWriteData           ;
    // input                           iWriteLast           ;
    // input                           iWriteValid          ;
    // output                          oWriteReady          ;

    // output  [31:0]                  oReadData            ;
    // output                          oReadLast            ;
    // output                          oReadValid           ;
    // input                           iReadReady           ;

    // output  [NumberOfWays - 1:0]    oReadyBusy           ;


    output   [7:0]                   oACG_Command             ;
    output   [2:0]                   oACG_CommandOption       ;

    input    [7:0]                   iACG_Ready               ;
    input    [7:0]                   iACG_LastStep            ;
    output   [NumberOfWays - 1:0]    oACG_TargetWay           ;
    output   [15:0]                  oACG_NumOfData           ;

    output                           oACG_CASelect            ;
    output   [39:0]                  oACG_CAData              ;

    // output   [15:0]                  oACG_WriteData           ;
    // output                           oACG_WriteLast           ;
    // output                           oACG_WriteValid          ;
    // input                            iACG_WriteReady          ;
  
    // input    [15:0]                  iACG_ReadData            ;
    // input                            iACG_ReadLast            ;
    // input                            iACG_ReadValid           ;
    // output                           oACG_ReadReady           ;

    input    [NumberOfWays - 1:0]    iACG_ReadyBusy           ;

    reg   [4:0]                   rTargetID            ; //option
    // reg                           rStart             ;
    reg                           rLastStep          ;
    // reg   [31:0]                  rAddress             ;
    reg   [15:0]                  rLength              ;
    reg                           rCMDReady          ;  
    // reg  [NumberOfWays - 1:0]     rReadyBusy     

    reg   [15:0]                  rColAddress          ;
    reg   [23:0]                  rRowAddress          ;

    reg   [7:0]                   rACG_Command       ;      
    reg   [2:0]                   rACG_CommandOption ;      
    reg   [NumberOfWays - 1:0]    rACG_TargetWay     ;      
    reg   [15:0]                  rACG_NumOfData     ;      
    reg                           rACG_CASelect      ;      
    reg   [39:0]                  rACG_CAData        ;   

    reg   [NumberOfWays - 1:0]    rACG_ReadyBusy     ;
    reg                           rWay_ReadyBusy     ;

    // reg                           rWriteReady          ;

    wire                          wLastStep          ;

    reg   [15:0]                  rACG_WriteData           ;
    reg                           rACG_WriteLast           ;
    reg                           rACG_WriteValid          ;

    reg   [31:0]                  rfeatures;
    // FSM Parameters/Wires/Regs
    localparam rST_FSM_BIT    = 9;
    localparam rST_RESET      = 9'b00000_0001;
    localparam rST_READY      = 9'b00000_0010; //
    localparam rST_CMDLatch   = 9'b00000_0100; // 
    localparam rST_CMDIssue   = 9'b00000_1000; // 
    localparam rST_ADDRIssue  = 9'b00001_0000; // 
    localparam rST_DATAIssue  = 9'b00010_0000; // 
    localparam rST_CMD2Issue  = 9'b00100_0000; // 
    localparam rST_WaitRBLow  = 9'b01000_0000; // 
    localparam rST_WaitRBHigh = 9'b10000_0000; // 

    reg     [rST_FSM_BIT-1:0]       rST_cur_state          ;
    reg     [rST_FSM_BIT-1:0]       rST_nxt_state          ;

    assign wStart    = (iOpcode[5:0] == CommandID) & iCMDValid;
    
    assign wProgCache     = (rTargetID[1:0] == 2'b01) ? 1 : 0;
    assign wProgMultplane = (rTargetID[1:0] == 2'b10) ? 1 : 0;

    assign wACGReady  = (iACG_Ready[6:0] == 7'b111_1111);
    
    // assign wACAReady = wACGReady;
    // assign wACAStart = wACAReady & rACG_Command[6];
    // assign wACADone  = iACG_LastStep[6];

    assign wACSReady = wACGReady;
    assign wACSStart = wACSReady & rACG_Command[3];
    assign wACSDone  = iACG_LastStep[3];

    // assign wDOAReady = wACGReady;
    // assign wDOAStart = wDOAReady & rACG_Command[5];
    // assign wDOADone  = iACG_LastStep[5];

    assign wDOSReady = wACGReady;
    assign wDOSStart = wDOSReady & rACG_Command[2];
    assign wDOSDone  = iACG_LastStep[2];

    // update current state to next state
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rST_cur_state <= rST_RESET;
        end else begin
            rST_cur_state <= rST_nxt_state;
        end
    end
    
    // deside next state
    always @ ( * ) begin
        case (rST_cur_state)
            rST_RESET: begin
                rST_nxt_state <= rST_READY;
            end
            rST_READY: begin
                rST_nxt_state <= (wStart)? rST_CMDLatch : rST_READY;
            end
            rST_CMDLatch: begin
                rST_nxt_state <= rST_CMDIssue;
            end
            rST_CMDIssue: begin
                rST_nxt_state <= (wACSDone) ? rST_ADDRIssue : rST_CMDIssue;
            end
            rST_ADDRIssue: begin
                rST_nxt_state <= (wACSDone) ? rST_DATAIssue : rST_ADDRIssue;
            end
            rST_DATAIssue: begin
                rST_nxt_state <= (wDOSDone) ? rST_CMD2Issue : rST_DATAIssue;
            end
            rST_CMD2Issue: begin
                rST_nxt_state <= (rLastStep == 1) ? rST_READY : rST_CMD2Issue;
            end
            // rST_WaitRBLow: begin
            //     rST_nxt_state <= (rWay_ReadyBusy == 0) ? rST_WaitRBHigh : rST_WaitRBLow; // wait for Valid
            // end
            // rST_WaitRBHigh: begin
            //     rST_nxt_state <= (rLastStep == 1) ? rST_READY : rST_WaitRBHigh; // wait for Valid
            // end
            default:
                rST_nxt_state <= rST_READY;
        endcase
    end

    // state behaviour
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rCMDReady          <= 1;
            rLastStep          <= 0;
            rLength            <= 16'd0;
            rTargetID          <= 5'd0;
            rColAddress        <= 0;
            rRowAddress        <= 0;

            rACG_Command       <= 8'b0000_0000;
            rACG_CommandOption <= 3'b000;
            rACG_TargetWay     <= 8'h00;
            rACG_NumOfData     <= 16'h0000;
            rACG_CASelect      <= 1'b1;
            rACG_CAData        <= 40'h00_00_00_00_00;
        end else begin
            case (rST_nxt_state)
                rST_RESET: begin
                    rCMDReady          <= 1;
                    rLastStep          <= 0;
					rLength            <= 16'd0;
                    rTargetID          <= 5'd0;
                    rColAddress        <= 0;
                    rRowAddress        <= 0;

                    rACG_Command       <= 8'b0000_0000;
                    rACG_CommandOption <= 3'b000;
                    rACG_TargetWay     <= 8'h00;
                    rACG_NumOfData     <= 16'h0000;
                    rACG_CASelect      <= 1'b1;
                    rACG_CAData        <= 40'h00_00_00_00_00;
                end
                rST_READY: begin
                    rCMDReady          <= 1;
                    rLastStep          <= 0;
					rLength            <= 16'd0;
                    rTargetID          <= 5'd0;
                    rColAddress        <= 0;
                    rRowAddress        <= 0;

                    rACG_Command       <= 8'b0000_0000;
                    rACG_CommandOption <= 3'b000;
                    rACG_TargetWay     <= iWaySelect;
                    rACG_NumOfData     <= 16'h0000;
                    rACG_CASelect      <= 1'b1;
                    rACG_CAData        <= 40'h00_00_00_00_00;
                end
                rST_CMDLatch: begin
                    rCMDReady          <= 0;
                    rLastStep          <= 0;
                    rLength            <= iLength  ;
                    rTargetID          <= iTargetID;
                    rColAddress        <= iColAddress;
                    rRowAddress        <= iRowAddress;

                    rACG_Command       <= 8'b0000_0000;
                    rACG_CommandOption <= 3'b000;
                    rACG_TargetWay     <= iWaySelect;
                    rACG_NumOfData     <= 16'h0000;
                    rACG_CASelect      <= 1'b1;
                    rACG_CAData        <= 40'h00_00_00_00_00;
                end
                rST_CMDIssue: begin
                    rCMDReady          <= 0;
                    rLastStep          <= 0;
					rLength            <= rLength  ;
                    rTargetID          <= rTargetID;
                    rColAddress        <= rColAddress;
                    rRowAddress        <= rRowAddress;

                    rACG_Command       <= 8'b0000_1000;
                    rACG_CommandOption <= 3'b000;
                    rACG_TargetWay     <= rACG_TargetWay;
                    rACG_NumOfData     <= 16'h0000;
                    rACG_CASelect      <= 1'b1;
                    rACG_CAData        <= 40'h80_00_00_00_00; // RESET FFh
                end
                rST_ADDRIssue: begin
                    rCMDReady          <= 0;
                    rLastStep          <= 0;
					rLength            <= rLength ;
                    rTargetID          <= rTargetID;
                    rColAddress        <= rColAddress;
                    rRowAddress        <= rRowAddress;

                    rACG_Command       <= 8'b0000_1000;
                    rACG_CommandOption <= 3'b000;
                    rACG_TargetWay     <= rACG_TargetWay;
                    rACG_NumOfData     <= 16'h0004;
                    rACG_CASelect      <= 1'b0;
                    rACG_CAData        <= {rColAddress[7:0],rColAddress[15:8], rRowAddress[7:0],rRowAddress[15:8],rRowAddress[23:16]}; 
                end

                rST_DATAIssue: begin
                    rCMDReady          <= 0;
                    rLastStep          <= 0;
					rLength            <= rLength ;
                    rTargetID          <= rTargetID;
                    rColAddress        <= rColAddress;
                    rRowAddress        <= rRowAddress;

                    rACG_Command       <= 8'b0000_0100;
                    rACG_CommandOption <= 3'b000;
                    rACG_TargetWay     <= rACG_TargetWay;
                    rACG_NumOfData     <= rLength;
                    rACG_CASelect      <= 1'b0;
                    rACG_CAData        <= 40'h00_00_00_00_00; // RESET FFh
                end
                rST_CMD2Issue: begin
                    rCMDReady          <= 0;
                    rLastStep          <= wACSDone ? 1 :0 ;
					rLength            <= rLength ;
                    rTargetID          <= rTargetID;
                    rColAddress        <= rColAddress;
                    rRowAddress        <= rRowAddress;

                    rACG_Command       <= wACSDone ? 8'b0000_0000: 8'b0000_1000;
                    rACG_CommandOption <= 3'b000;
                    rACG_TargetWay     <= rACG_TargetWay;
                    rACG_NumOfData     <= 16'h0000;
                    rACG_CASelect      <= 1'b1;
                    rACG_CAData[39:32] <= (wProgCache) ? 8'h15: ((wProgMultplane) ? 8'h11 : 8'h10); // RESET FFh
                    rACG_CAData[31:0]  <= 0;
                end
                // rST_WaitRBLow : begin
                //     rCMDReady          <= 0;
                //     rLastStep          <= 0;

                //     rACG_Command       <= 8'b0000_0000;
                //     rACG_CommandOption <= 3'b000;
                //     rACG_TargetWay     <= rACG_TargetWay;
                //     rACG_NumOfData     <= 16'h0000;
                //     rACG_CASelect      <= 1'b1;
                //     rACG_CAData        <= 40'h00_00_00_00_00;
                // end
                // rST_WaitRBHigh : begin
                //     rCMDReady          <= 0;
                //     rLastStep          <= rWay_ReadyBusy ? 1 : 0;

                //     rACG_Command       <= 8'b0000_0000;
                //     rACG_CommandOption <= 3'b000;
                //     rACG_TargetWay     <= rACG_TargetWay;
                //     rACG_NumOfData     <= 16'h0000;
                //     rACG_CASelect      <= 1'b1;
                //     rACG_CAData        <= 40'h00_00_00_00_00;
                // end
                default: begin
                    rCMDReady          <= 0;
                    rLastStep          <= 0;
                    rLength            <= 0;
                    rTargetID          <= 0;
                    rColAddress        <= 0;
                    rRowAddress        <= 0;

                    rACG_Command       <= 8'b0000_0000;
                    rACG_CommandOption <= 3'b000;
                    rACG_TargetWay     <= 8'h00;
                    rACG_NumOfData     <= 16'h0000;
                    rACG_CASelect      <= 1'b1;
                    rACG_CAData        <= 40'h00_00_00_00_00;
                end
            endcase
        end
    end

    always @ (posedge iSystemClock, posedge iReset) begin
        rACG_ReadyBusy <= rACG_TargetWay & iACG_ReadyBusy;
        rWay_ReadyBusy <= | rACG_ReadyBusy;
    end

    assign oStart             = wStart             ;
    assign oLastStep          = rLastStep          ;

    assign oCMDReady          = rCMDReady          ;
    assign oACG_Command       = rACG_Command       ;
    assign oACG_CommandOption = rACG_CommandOption ;
    assign oACG_TargetWay     = rACG_TargetWay     ;
    assign oACG_NumOfData     = rACG_NumOfData     ;
    assign oACG_CASelect      = rACG_CASelect      ;
    assign oACG_CAData        = rACG_CAData        ;

endmodule
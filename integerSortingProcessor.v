`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2025 02:25:15 PM
// Design Name: 
// Module Name: FD
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
module DRAM (
    input clk,
    input rst,
    input memwrite,
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] memory [0:255];
    integer i;

    always @( posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 256; i 
            = i + 1)
                memory[i] <= 32'b0;

            memory[0] <= 32'd42949672;  // Large positive number
            memory[1] <= 32'd98374839;  // Larger number
            memory[2] <= 32'd23784932;
            memory[3] <= 32'd74839201;
            memory[4] <= 32'd12938475;
            memory[5] <= 32'd99887766;
            memory[6] <= 32'd11223344;
            memory[7] <= 32'd55667788;
            memory[8] <= 32'd33445566;
            memory[9] <= 32'd77778888;

        end else if (memwrite) begin
            memory[address] = write_data;
        end
    end

    assign read_data = memory[address]; //  Async read
endmodule
//module DRAM (
//    input clk,
//    input rst,
//    input memwrite,
//    input [31:0] address,
//    input [31:0] write_data,
//    output [31:0] read_data
//);
//    reg [31:0] memory [0:255];
//    integer i;

//    // Initialize memory from file
//    initial begin
//        $readmemh("/home/bhuvaneshganta/Desktop/DRAM.mem", memory);
//    end

//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            // Reset does NOT overwrite memory contents
//            // (File-loaded values persist through reset)
//        end
//        else if (memwrite) begin
//            memory[address] <= write_data;
//        end
//    end
//    assign read_data = memory[address]; // Async read
//endmodule

module dpath(
    input clk,
    input rst,
    output [31:0] ins
);
    wire [31:0] pc_out;
    wire [31:0] instruction, imm_out, read_data1, read_data2, alu_result;
    wire [31:0] read_data, reg_write_data;
    wire [3:0] alucon;
    wire alusrc, regwrite, signext, memwrite, resultSRC;
    wire [1:0] immsel;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] alu_b_input;
    wire PCsel;
                      // New port from ALU: branch condition flag
    wire branch_en; 
             // Gated PCsel to only take branch when condition met

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];

    // Gate branch enable: only assert PCsel when decoder says branch and ALU flag is true
    assign branch_en = PCsel & alu_result ;
 
    // PC Module
    PC pc_inst (
        .clk(clk),
        .rst(rst),
        .PCsel(branch_en),      // use gated branch enable
        .imm_in(imm_out),
        .pc(pc_out)
    );

    // DRAM (Data Memory)
    DRAM dram_inst (
        .clk(clk),
        .rst(rst),
        .memwrite(memwrite),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(read_data)
    );

    // Instruction Memory
    IMEM imem_inst (
        .address(pc_out),
        .clk(clk),
        .win(32'b0),
        .rst(rst),
        .ins(instruction)
    );

    assign ins = instruction;

    // Register File
    registerfile rf_inst (
        .clk(clk),
        .rst(rst),
        .regwrite(regwrite),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(rd),
        .write_data(reg_write_data), 
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Sign Extend
    signextend se_inst (
        .instruction(instruction),
        .signext(signext),
        .immsel(immsel),
        .imm_out(imm_out)
    );

    // ALU Input Mux
    assign alu_b_input = alusrc ? imm_out : read_data2;

    // ALU with new flag port
    ALU alu_inst (
        .a(read_data1),
        .b(alu_b_input),
        .alucon(alucon),
        .result(alu_result)          // condition flag output
    );

    // MUX for register file write data (ALU result or DRAM read_data)
    assign reg_write_data = resultSRC ? read_data : alu_result;

    // Decoder
    decoder decoder_inst (
        .instruction(instruction),
        .PCsel(PCsel),
        .immsel(immsel),
        .regwrite(regwrite),
        .memwrite(memwrite),
        .alucon(alucon),
        .alusrc(alusrc),
        .resultSRC(resultSRC),
        .signext(signext)
    );
endmodule


module PC(
    input clk,
    input rst,
    input PCsel,
    input [31:0] imm_in,       // From signextend
    output reg [31:0] pc
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;
//        else if (PCsel)
//            pc <= pc + imm_in; // Raw word offset (no scaling)
//        else if (~PCsel)
//            pc <= pc + 32'b00000000000000000000000000000001;      // Normal word-address increment
////        else 
////            pc<= pc + imm_in;
//        else begin
//         pc = pc+ (PCsel==0?1:imm_in);
    
 
    else if (PCsel==1)
        pc <= pc + imm_in;
    else if (PCsel==0)
        pc <= pc+4;
//end
       
    end
endmodule


module IMEM(
    input [31:0] address,
    input clk,
    input [31:0] win,
    input rst,
    output wire [31:0] ins
);
    reg [31:0] mem[1000:0];
    integer i;

//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            for (i = 0; i < 64; i = i + 1)
//                mem[i] <= 32'b0;
                
initial begin


//initialize x7 as i counter var
//initialize x8 as 9; max variable
//branch to check i< x8;else jump with offset +12
//mem[0]<=32'b0;
//mem[1] <= 32'b000000000100_00000_000_01000_0010011; // addi x8, x0, N counter
//mem[2]<=32'b000000000000_00001_000_01010_0010011;  // replace this with loading 0th popsition of dram into x10
//mem[3] <= 32'b0_000001_01000_00111_100_0000_0_1100011; // blt x7, x8, body increase offsetif counte exceeded
//mem[4] <= 32'b00000000000100111000001110010011; // addi x7, x7, 1

//mem[5]<=32'b1_00000001_0_0000000000_00000_1101111;  //jal back into loop

////mem[5] <= 32'h00000013; // nop (land here after looping)



//    mem[0] <= 32'b00000000000000000000000000000000; // NOP, x7 starts at 0          //MAXLOOP WORKED

//    mem[1] <= 32'b000000001011_00000_000_01000_0010011; // addi x8, x0, 3     ; counter limit = 3

//    mem[2] <= 32'b000000000000_00000_010_01010_0000011; // lw   x10, 0(x0)      ; max = MEM[0]

//    mem[3] <= 32'b0_000000_01000_00111_100_1110_0_1100011; // blt  x8, x7, +14   ; if x8 < x7, jump ahead 14 (LOOP EXIT)

//    mem[4] <= 32'b000000000001_00111_000_00111_0010011; // addi x7, x7, 1       ; i++

//    mem[5] <= 32'b000000000000_00111_010_01011_0000011; // lw   x11, 0(x7)      ; load MEM[i]

//    mem[6] <= 32'b0_000000_01010_01011_100_0100_0_1100011; // blt  x10, x11, +8   ; if max < new, goto UPDATE

//    mem[7] <= 32'b0_00000001_0_0000000000_00000_1101111; // jal  x0, +2          ; skip UPDATE

//    mem[8] <= 32'b000000000000_01011_000_01010_0010011; // addi x10, x11, 0     ; max = new

//    mem[9] <= 32'b1_00000011_0_0000000000_00000_1101111; // jal  x0, -6          ; jump back to LOOP_HEAD (mem[3])





//// [0] i = 0
//mem[0]  <= 32'b000000000000_00000_000_00101_0010011; // addi x5, x0, 0     ; i = 0
//// [1] N = 4
//mem[1]  <= 32'b000000010101_00000_000_00111_0010011; // addi x7, x0, 4     ; N = 4

//// LOOP1:
//// [2] if (i < N) → continue_outer
//mem[2]  <= 32'b0000000_00101_00111_100_01000_1100011; // blt x5, x7, +X     ; to [4]
//// [3] Exit
//mem[3]  <= 32'b0_11111111_0_0000000000_00000_1101111; // jal x0, +Y         ; to [exit]

//// continue_outer:
//// [4] x30 = N - i
//mem[4]  <= 32'b0100000_00101_00111_000_11110_0110011; // sub x30, x7, x5    ; x30 = N - i
//// [5] x29 = 1
//mem[5]  <= 32'b000000000001_00000_000_11101_0010011; // addi x29, x0, 1     ; x29 = 1
//// [6] x30 = x30 - 1
//mem[6]  <= 32'b0100000_11101_11110_000_11110_0110011; // sub x30, x30, x29  ; x30 = x30 - 1
//// [7] j = 0
//mem[7]  <= 32'b000000000000_00000_000_00110_0010011; // addi x6, x0, 0      ; j = 0

//// LOOP2:
//// [8] if (j < N - i - 1) → continue_inner
//mem[8]  <= 32'b0000000_00110_11110_100_01000_1100011; // blt x6, x30, +X     ; to [10]
//// [9] Loop1 increment
//mem[9]  <= 32'b0_00000100_1_0000000000_00000_1101111; // jal x0, +Y          ; to [18]  

//// continue_inner:
//// [10] x8 = j + 1
//mem[10] <= 32'b000000000001_00110_000_01000_0010011; // addi x8, x6, 1      ; x8 = j+1
//// [11] x9 = MEM[x6]
//mem[11] <= 32'b000000000000_00110_010_01001_0000011; // lw x9, 0(x6)        ; x9 = x[j]
//// [12] x30 = MEM[x8]
//mem[12] <= 32'b000000000000_01000_010_11111_0000011; // lw x30, 0(x8)       ; x30 = x[j+1]
//// [13] if (x30 < x9) → skip swap
//mem[13] <= 32'b0000000_11111_01001_100_01100_1100011; // blt x30, x9, +X     ; to [16]

//// SWAP:
//// [14] MEM[x8] = x9 (x[j+1] = x[j])
//mem[14] <= 32'b0000000_01001_01000_010_00000_0100011; // sw x9, 0(x8)
//// [15] MEM[x6] = x30 (x[j] = x[j+1])
//mem[15] <= 32'b0000000_11111_00110_010_00000_0100011; // sw x30, 0(x6)

//// skip_swap:
//// [16] j++
//mem[16] <= 32'b000000000001_00110_000_00110_0010011; // addi x6, x6, 1

//// [17] back to LOOP2
//mem[17] <= 32'b1_00000100_1_0000000000_00000_1101111; // jal x0, -X          ; to [8]

//// LOOP1 increment:
//// [18] i++
//mem[18] <= 32'b000000000001_00101_000_00101_0010011; // addi x5, x5, 1
//mem[19] <= 32'b000000000000_10001_000_00110_0010011; // addi x6, x17, 0 ; j = x17 = 0
//// [19] back to LOOP1
//mem[20] <= 32'b1_00001001_0_0000000000_00000_1101111; // jal x0, -Y          ; to [2]

//// [20] EXIT (nop)
//mem[21] <= 32'b000000000000_00000_000_00000_0010011; // nop



// [0] x1 = 1 (CRITICAL FIX)
mem[0]  <= 32'b000000000001_00000_000_00001_0010011; // addi x1, x0, 1    ; x1=1
// [1] i = 1 
mem[1]  <= 32'b000000000001_00000_000_00101_0010011; // addi x5, x0, 1    ; i=1
// [2] N = 4
mem[2]  <= 32'b000000010101_00000_000_00111_0010011; // addi x7, x0, 4    ; N=4

// OUTER_LOOP:
// [3] if (i < N) → continue_outer
mem[3]  <= 32'b0_0000000_00101_00111_100_01000_1100011; // blt x5, x7, +8 (to [5])
// [4] Exit
mem[4]  <= 32'b0_1110110_1_0000000000_00000_1101111; // jal x0, +out (to [17])

//// continue_outer:
//// [5] key = MEM[i]
mem[5]  <= 32'b000000000000_00101_010_01010_0000011; // lw x10, 0(x5)    ; key=arr[i]
// [6] j = i-1 (USING x1=1)
mem[6]  <= 32'b0100000_00001_00101_000_00110_0110011; // sub x6, x5, x1   ; j=i-1

// INNER_LOOP:
// [7] if (j >= 0) → check_value

mem[7]  <= 32'b0_0000000_00110_00000_101_01000_1100011; // bge x6, x0, +8 (to [9])
// [8] Exit inner loop
mem[8]  <= 32'b0_0000010_0_0000000000_00000_1101111; // jal x0, +24 (to [14])
// [9] arr[j] load
mem[9]  <= 32'b000000000000_00110_010_01011_0000011; // lw x11, 0(x6)    ; arr[j]
// [10] if (arr[j] > key) → shift
mem[10] <= 32'b0_0000000_01010_01011_100_01000_1100011; // blt x10, x11, +8 (to [12])

// [11] Exit inner loop
mem[11] <= 32'b1_00000001_1_0000000000_00000_1101111; // jal x0, +12 (to [14])

// SHIFT_ELEMENT:
// [12] MEM[j+1] = MEM[j]
mem[12] <= 32'b0000000_01011_00110_010_00001_0100011; // sw x11, 1(x6)   ; arr[j+1]=arr[j]
// [13] j-- (USING x1=1)
mem[13] <= 32'b0100000_00001_00110_000_00110_0110011; // sub x6, x6, x1  ; j--
mem[14] <= 32'b1_00000011_1_0000000000_00000__1101111; // jal x0, -28 (to [7])

// INSERT_KEY:
// [15] MEM[j+1] = key
mem[15] <= 32'b0000000_01010_00110_010_00001_0100011; // sw x10, 1(x6)   ; arr[j+1]=key
//// [16] i++ 
mem[16] <= 32'b000000000001_00101_000_00101_0010011; // addi x5, x5, 1   ; i++
mem[17] <= 32'b1_00000111_0_0000000000_00000_1101111;// jal x0, -56; (to [3])

// EXIT:
mem[18] <= 32'b000000000000_00000_000_00000_0010011; // nop

//        end else begin
//            mem[address>>2] <= win;
//        end
   end

    assign ins=mem[address>>2];
    
endmodule


module registerfile(
    input wire clk,
    input wire rst,
    input wire regwrite,
    input wire [4:0] read_addr1,
    input wire [4:0] read_addr2,
    input wire [4:0] write_addr,
    input wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] registers[31:0];
    integer i;

    // Asynchronous read logic
    assign read_data1 = (read_addr1 != 0) ? registers[read_addr1] : 32'b0;
    assign read_data2 = (read_addr2 != 0) ? registers[read_addr2] : 32'b0;

    // Synchronous write logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
            // Initialize specific registers
            registers[5'b00001] <= 2;  // x1 = 2
            registers[5'b00010] <= 5;  // x2 = 5
            registers[5'b00011] <= 9;  // x3 = 9
            registers[5'b00100] <= 7;  // x4 = 7
        end else if (regwrite) begin
            registers[write_addr] <= write_data;
        end
    end
endmodule
module signextend(
    input [31:0] instruction,
    input signext,
    input [1:0] immsel,
    output wire signed [31:0] imm_out
);

    assign imm_out = (signext) ? 
                     (immsel == 2'b01) ? {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8],1'b0} : // B-type
                     (immsel == 2'b10) ? (instruction[31]?-{ 12'b0, instruction[19:12], instruction[20], instruction[30:21], 1'b0}:{ 12'b0, instruction[19:12],instruction[20],instruction[30:21],1'b0} ):
                     (immsel==2'b11)? {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}:
                     (immsel == 2'b00) ? {{20{instruction[31]}}, instruction[31:20]} : // I-type
                     32'b1 : 
                     32'b0;

endmodule
module ALU(
    input [31:0] a,
    input [31:0] b,
    input [3:0] alucon,
    output reg [31:0] result
);
    always @(*) begin
        // Default values
        result = 32'b0;
      
        case (alucon)
            4'b0010: result = a + b;                    // ADD
            4'b1010: result = a - b;                    // SUB
            4'b0110: result = (a == b);                 // BEQ
            4'b0001: result = a & b;                    // AND
            4'b1000: result = a * b;                    // MUL
            4'b1010: result = a >> b;                   // SRL
            4'b1110: result = (a != b);                 // BNE
            4'b0111: result = a + b;                    // For address calculation
            4'b0101: result = a + b;                    // For address calculation
            4'b1111: result = ($signed(a) > $signed(b));  // BLT (signed)
            4'b1100: result = ($signed(a) <= $signed(b)); // BGE (signed)
            4'b1001: result = 32'b1;                    // JAL
            default: begin
                result = 32'b0;
            end
        endcase
    end
endmodule

module decoder(
    input [31:0] instruction,
    output wire PCsel,
    output wire [1:0] immsel,
    output wire regwrite,
    output wire memwrite,
    output wire [3:0] alucon,
    output wire alusrc,
    output wire resultSRC,
    output wire signext
);

    // Assign control signals based on the instruction
    assign PCsel = (instruction[6:0] == 7'b1101111) || // JAL
                   (instruction[6:0] == 7'b1100011);   // BEQ, BNE, BLT, BGE

    assign immsel = (instruction[6:0] == 7'b1101111) ? 2'b10 : // JAL
                    (instruction[6:0] == 7'b1100011) ? 2'b01 : // BEQ, BNE, BLT, BGE
                    (instruction[6:0] == 7'b0000011) ? 2'b00 : // lw
                    (instruction[6:0] == 7'b0100011) ? 2'b11:  // sw
                    (instruction[6:0] == 7'b0010011) ? 2'b00 : // I
                    3'b111;
                    

    assign regwrite = (instruction[6:0] == 7'b0010011) || // I-type
                      (instruction[6:0] == 7'b0110011) || // R-type
                      (instruction[6:0] == 7'b0000011);   // LW

    assign memwrite = (instruction[6:0] == 7'b0100011); // SW

    assign alusrc = (instruction[6:0] == 7'b0010011) || // I-type
                    (instruction[6:0] == 7'b0000011) || // LW
                    (instruction[6:0] == 7'b0100011);   // SW

    assign resultSRC = (instruction[6:0] == 7'b0000011)||(instruction[6:0] == 7'b0100011);// LW (Load) and SW

    assign signext = (instruction[6:0] == 7'b1101111) || // JAL
                     (instruction[6:0] == 7'b1100011) || // BEQ, BNE, BLT, BGE
                     (instruction[6:0] == 7'b0010011) || // I-type
                     (instruction[6:0] == 7'b0000011) || // LW
                     (instruction[6:0] == 7'b0100011);   // SW

    assign alucon = (instruction[6:0] == 7'b1100011 && instruction[14:12] == 3'b100) ? 4'b1111 : // BLT
                    (instruction[6:0] == 7'b1100011 && instruction[14:12] == 3'b101) ? 4'b1100 : // BGE (new)
                    (instruction[6:0] == 7'b1100011 && instruction[14:12] == 3'b000) ? 4'b0110 : // BEQ
                    (instruction[6:0] == 7'b1100011 && instruction[14:12] == 3'b001) ? 4'b1110 : // BNE
                    (instruction[6:0] == 7'b0010011 && instruction[14:12] == 3'b000) ? 4'b0010 : // ADDI
                    (instruction[6:0] == 7'b0010011 && instruction[14:12] == 3'b100) ? 4'b0001 : // ANDI
                    (instruction[6:0] == 7'b0110011 && {instruction[30], instruction[14:12]} == 4'b0000) ? 4'b0010 : // ADD
                    (instruction[6:0] == 7'b0110011 && {instruction[30], instruction[14:12]} == 4'b1000) ? 4'b1010 : // SUB
                    (instruction[6:0] == 7'b0110011 && {instruction[30], instruction[14:12]} == 4'b0100) ? 4'b0001 : // AND
                    (instruction[6:0] == 7'b1101111 ) ? 4'b1001 : // jal
                    (instruction[6:0] == 7'b0000011 ) ? 4'b0111:   // lw
                    (instruction[6:0] == 7'b0100011)?   4'b0101 : // sw
                    4'b0000; // Default

endmodule
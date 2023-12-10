# MIPS Architecture


## MIPS Over View
3 Basic Types of Instruction
- Arithmetic/Bitwise Logic
- Data Transfer from/between/to Registers and Memory
- Control Flow

32 Registers
| Assembler Name | Reg Number | Description |
| -------------- |------------|-------------|
|$zero|$0|Constant 0|
|$at|$1|Assembler Temporary|
|$v0-$v1|$2-$3|Procedure return or exp evaluation|
|$a0-$a3|$4-$7|Arguments|
|$t0-$t7|$8-$15|Temporaries|
|$s0-$s7|$16-$23|Saved Temporaries|
|$t8-$t9|$24-$25|Temporaries|
|$k0-$k1|$26-$27|Reserved or OS|
|$gp|$28|Global Pointer|
|$sp|$29|Stack Pointer|
|$fp|$30|Frame Pointer|
|$ra|$31|Return address|

## I2C Slave FSM
```mermaid
stateDiagram-v2

    [*] --> IDLE

    IDLE --> ADDR6  : start==1
    IDLE --> IDLE   : start==0 

    ADDR6 --> ADDR5
    ADDR5 --> ADDR4
    ADDR4 --> ADDR3
    ADDR3 --> ADDR2
    ADDR2 --> ADDR1
    ADDR1 --> ADDR0
    ADDR0 --> RW
    RW --> ACK1     : (address == input_addr_reg) & (RW==0)
    RW --> WAIT     : address != input_addr_reg

    RW --> ACK4     : (address == input_addr_reg) & (RW==1)

    WAIT --> IDLE   : stop == 1
    WAIT --> WAIT   : stop == 0

    ACK1 --> REG_ADDR7
    REG_ADDR7 --> REG_ADDR6
    REG_ADDR6 --> REG_ADDR5
    REG_ADDR5 --> REG_ADDR4
    REG_ADDR4 --> REG_ADDR3
    REG_ADDR3 --> REG_ADDR2
    REG_ADDR2 --> REG_ADDR1
    REG_ADDR1 --> REG_ADDR0
    REG_ADDR0 --> ACK2


    ACK2 --> DATA7
    DATA7 --> DATA6  : start == 0 & stop == 0
    DATA6 --> DATA5
    DATA5 --> DATA4
    DATA4 --> DATA3
    DATA3 --> DATA2
    DATA2 --> DATA1
    DATA1 --> DATA0
    DATA0 --> ACK3
    ACK3 --> DATA7
    DATA7 --> IDLE    : stop == 1

    DATA7 --> ADDR6  : start == 1
    ACK4 --> DATA_OUT7
    DATA_OUT7 --> DATA_OUT6
    DATA_OUT6 --> DATA_OUT5
    DATA_OUT5 --> DATA_OUT4
    DATA_OUT4 --> DATA_OUT3
    DATA_OUT3 --> DATA_OUT2
    DATA_OUT2 --> DATA_OUT1
    DATA_OUT1 --> DATA_OUT0
    DATA_OUT0 --> NACK
    NACK --> DATA_OUT7      : SDA == 1
    NACK --> WAIT           : SDA == 0
```
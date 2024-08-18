slave_states = ['INIT','ADDR6','ADDR5','ADDR4','ADDR3','ADDR2','ADDR1','ADDR0','RW_t','ACK1','WAIT',
          'REG_ADDR7','REG_ADDR6','REG_ADDR5','REG_ADDR4','REG_ADDR3','REG_ADDR2','REG_ADDR1','REG_ADDR0','ACK2',
          'DATA7','DATA6','DATA5','DATA4','DATA3','DATA2','DATA1','DATA0','ACK3',"ACK4",
          'DATA_OUT7','DATA_OUT6','DATA_OUT5','DATA_OUT4','DATA_OUT3','DATA_OUT2','DATA_OUT1','DATA_OUT0','NACK']



# Regular Encoding
for idx, val in enumerate(slave_states):
    print("%s=8'd%d,"%(val,idx))

# One-hot Encoding
for idx, val in enumerate(slave_states):
    print("39'b%s \"%s\""%(bin((1<<idx))[2:].zfill(39),val))
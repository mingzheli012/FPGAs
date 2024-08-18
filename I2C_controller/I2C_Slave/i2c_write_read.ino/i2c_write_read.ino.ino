#include <Wire.h>

void setup()
{
  Serial.begin (115200);  
  Wire.begin (21, 22);   // sda= GPIO_21 /scl= GPIO_22
  delay(1000);

  char msg[8] = "HELLO!!";
  for(int i=0;i<8;i++){
    Write(i,atoi(&msg[i]));
  }

}

void Write(int addr, int val)
{
  //Wire.begin();
  Serial.println("Starting I2C Transmission to 0x22");
  //Wire.beginTransmission(0x22);         // Begin I2C transmission Address (i)
  //byte result;
  //result = Wire.endTransmission();
  //Serial.print("ACK Result: ");
  //Serial.println(result,HEX);
  //if (result == 0){
    
  Wire.beginTransmission(0x22);         // Begin I2C transmission Address (i)
  Wire.write(addr);
  Wire.write(val);
  Wire.endTransmission();
  delay(100);
}


char Read(int addr){
  Wire.beginTransmission(0x22);         // Begin I2C transmission Address (i)
  Wire.write(addr);
  Wire.endTransmission(0);
  Wire.requestFrom(0x22, 8); // We want one byte
  char read_back;
  read_back = Wire.read();
  delay(100);
  return read_back;
}

void loop()
{
  char msg[8] = "";
  for(int i=0;i<8;i++){
    msg[i] = Read(i);
  }
  Serial.write(msg);
}

import pandas as pd

df = pd.read_csv(r"E:\FPGAs\I2C_controller\digital.csv")
df['delta'] = df.Time.diff().fillna(0)*10**9

for idx,row in df.iterrows():
    print("#%d; SDA_r = %d; SCL = %d;"%(row.delta, row.SDA, row.SCL))
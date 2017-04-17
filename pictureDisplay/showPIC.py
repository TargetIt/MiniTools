#! /ux/Tools/python2.7.10/bin/python2.7
import PIL
from PIL import Image
import sys

f_raw_data_name = sys.argv[1]
Hsize = int(sys.argv[2])
Vsize = int(sys.argv[3])
ColorMode = sys.argv[4]

#f_raw_data_name = 'raw.txt'
#Hsize = 256
#Vsize = 256
#ColorMode = 'RGB'

with open(f_raw_data_name, 'r') as f_rd:
    raw_data=f_rd.read()

def limitRange(i):
    if i < 0 :
        return 0
    elif i > 255:
        return 255
    else:
        return int(round(i))
def YUV2RGB(Y, U, V):
    R = 1.164 * (Y - 16) + 1.596 * (V - 128)
    G = 1.164 * (Y - 16) - 0.813 * (V - 128) - 0.391 * (U - 128)
    B = 1.164 * (Y - 16) + 2.018 * (U - 128)
    R = limitRange(R)
    G = limitRange(G)
    B = limitRange(B)
    return R, G, B

raw_data = raw_data.replace('\n', '') # del enter
raw_data = raw_data.replace(' ', '') # del space
raw_data = raw_data[:-1] #del the last comma
raw_data = raw_data.split(',') # conv to a list
raw_data = map(int, raw_data)
#if ColorMode is "YUV":
if ColorMode.startswith("YUV"):
    # del the redundant Y
    for i in range(len(raw_data)):
        if (i-2)%4 == 0 :
            raw_data[i] = 'DEL'
    raw_data = [x for x in raw_data if x != 'DEL']
    # conv YUV 2 RGB
    for i in range(len(raw_data)):
        if i%3 == 0:
            Y, U, V = raw_data[i:i+3]
            R, G, B = YUV2RGB(Y, U, V)
            raw_data[i:i+3] = [R, G, B]
raw_data = map(chr, raw_data)
post_data = ''.join(raw_data)

im = Image.fromstring('RGB', (Hsize, Vsize), post_data)
im.save("test.png", "PNG")
im.show()

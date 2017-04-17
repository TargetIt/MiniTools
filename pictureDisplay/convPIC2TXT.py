#! /ux/Tools/python2.7.10/bin/python2.7

import PIL
from PIL import Image
import sys

imName = sys.argv[1]
imTextName = imName+"."+"txt"

listPixel = []

im = Image.open(imName)
rgb_im = im.convert("RGB")
Vsize, Hsize = rgb_im.size
print Vsize, Hsize

for i in range(Hsize):
    for j in range(Vsize):
        r,g,b = rgb_im.getpixel((j,i))
        listPixel.append((r,g,b))

with open(imTextName, 'w') as f:
    for r,g,b in listPixel:
        strline = str(r)+','+str(g)+','+str(b)+','+'\n'
        f.write(strline)


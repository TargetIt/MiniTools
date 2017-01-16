
import sys
import os
import re


F1 = sys.argv[1]
F2 = sys.argv[2]

# ------------------------------------------------
# Parse constants file
# ------------------------------------------------
f1 = open(F1, 'r')
parameter = {}

for line in f1.readlines():
	line = line.strip()
	if not len(line) or line.startswith('//'):
		continue
	line = line.replace('`define','').strip()
	line = line.split()
	if len(line)<2 : line.append('1')
	keyline = line[0]
	valueline = line[1]
	valueline = valueline.replace("8'h",'0x')
	if valueline.find('0x')== -1 : base_num = 10
	else:	base_num = 16
	valueline = int(valueline, base=base_num)
	parameter[keyline] = valueline

print parameter


# ------------------------------------------------
# Parse pcie_iip_device file
# ------------------------------------------------
result = []
f2 = open(F2, 'r')
flag_def = 0
count = 0    # {count>0}: the number of not defined parameters 
cntlist = [1] # the status of embeded if


for line in f2.readlines():
	line = line.strip()
	if line.startswith('`ifdef'):
		paralist = line.split()
		para = paralist[1]
		if not parameter.has_key(para): 
			cntlist.append(0)
		#elif parameter[para]: 
		#	cntlist.append(1)
		else:
			cntlist.append(1)
	elif line.startswith('`ifndef'):
		paralist = line.split()
		para = paralist[1]
		if parameter.has_key(para): 
			cntlist.append(0)
		else:
			cntlist.append(1)
	elif line.startswith('`else'):
		cntlist[-1] = (cntlist[-1]+1)%2
	elif line.startswith('`endif'):
		cntlist.pop()
	else:
		flag_def = sorted(cntlist)[0]
		if flag_def :
			result.append(line)
		
f3 = open('temp.v', 'w')
for line in result:
	f3.write(line+'\n')


f1.close()
f2.close()
f3.close()

print result



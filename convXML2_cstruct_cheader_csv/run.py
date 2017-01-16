#!/usr/bin/python

import re
import os
import sys

# ------------------------------------------------------------
## input files rx and check
# ------------------------------------------------------------
argv1 = sys.argv[1]
argv2 = sys.argv[2] #: 1:csv, 2: cheader, 3: cstruct
argv2 = int(argv2)
f1 = open(argv1, 'r')
base_name = "base_"+os.path.splitext(os.path.split(argv1)[1])[0]

# ------------------------------------------------------------
## Pattern record and compile
# ------------------------------------------------------------
PTregName   =re.compile(r'<spirit:name>(.*)<\/spirit:name>')
PTregAddr   =re.compile(r'<spirit:addressOffset>(.*)<\/spirit:addressOffset>')
PTregDim    =re.compile('<spirit:dim>(.*)<\/spirit:dim>')
PTregSize   =re.compile('<spirit:size>(.*)<\/spirit:size>')
PTregAcc    =re.compile('<spirit:access>(.*)<\/spirit:access>')
PTregRstVal =re.compile('<spirit:value>(.*)<\/spirit:value>')
PTregMsk    =re.compile('<spirit:mask>(.*)<\/spirit:mask>')
PTbitName   = re.compile(r'<spirit:name>(.*)<\/spirit:name>')
PTbitDesp   = re.compile(r'<spirit:description>(.*)<\/spirit:description>')
PTbitOffset = re.compile(r'<spirit:bitOffset>(.*)<\/spirit:bitOffset>')
PTbitWdith  = re.compile(r'<spirit:bitWidth>(.*)<\/spirit:bitWidth>')
PTbitAcc    = re.compile(r'<spirit:access>(.*)<\/spirit:access>')
#PTbitRstVal = re.compile(r'<soc:resetValue spirit:dependency="spirit:decode\(soc:bin\((.*)\)\)"spirit:resolve="dependent">(.*)<\/soc:resetValue>')
PTbitRstVal = re.compile(r'<soc:resetValue spirit:dependency=(.*)spirit:resolve="dependent">(.*)<\/soc:resetValue>')
#PTflag

PTregFlagBg = re.compile(r'<spirit:register>')
PTregFlagEd = re.compile(r'<\/spirit:register>')
PTbitFlagBg =re.compile(r'<spirit:field>')
PTbitFlagEd =re.compile(r'<\/spirit:field>')
# ------------------------------------------------------------
# var 
# ------------------------------------------------------------
regName = "-"
regDim = "-"
regAddr = "-"
regSize = "-"
regAcc = "-"
regRstVal = "-"
regMsk = "-"
bitName = "-"
bitDesp = "-"
bitOffset = "-"
bitWidth = "-"
bitAcc = "-"
bitRstVal = "-"
#flag
regBg = 0
regEd = 0
bitBg = 0
bitEd = 0
# ------------------------------------------------------------
# all methods(gen csv, cstruct, cheader) are packaged into RegBitPro
# ------------------------------------------------------------
class RegBitPro():
    def __init__(self):
        self.regName = "-"
        self.regDim = "-"
        self.regAddr = "-"
        self.regSize = "-"
        self.regAcc = "-"
        self.regRstVal = "-"
        self.regMsk = "-"
        self.bitName = "-"
        self.bitDesp = "-"
        self.bitOffset = "-"
        self.bitWidth = "-"
        self.bitAcc = "-"
        self.bitRstVal = "-"
        self.bitfield={}
    def resetReg(self):
        self.regName = "-"
        self.regDim = "-"
        self.regAddr = "-"
        self.regSize = "-"
        self.regAcc = "-"
        self.regRstVal = "-"
        self.regMsk = "-"
    def resetBit(self):
        self.bitName = "-"
        self.bitDesp = "-"
        self.bitOffset = "-"
        self.bitWidth = "-"
        self.bitAcc = "-"
        self.bitRstVal = "-"
    def RegMch(self,line):
        if(PTregName.match(line)):      self.regName=PTregName.match(line).group(1).replace(',','..')
        elif(PTregAddr.match(line)):    self.regAddr=PTregAddr.match(line).group(1).replace(',','..')
        elif(PTregDim.match(line)):     self.regDim=PTregDim.match(line).group(1).replace(',','..')
        elif(PTregSize.match(line)):    self.regSize=PTregSize.match(line).group(1).replace(',','..')
        elif(PTregAcc.match(line)):     self.regAcc=PTregAcc.match(line).group(1).replace(',','..')
        elif(PTregRstVal.match(line)):  self.regRstVal=PTregRstVal.match(line).group(1).replace(',','..')
        elif(PTregMsk.match(line)):     self.regMsk=PTregMsk.match(line).group(1).replace(',','..')
    def BitMch(self,line):
        if(PTbitName.match(line)):      self.bitName=PTbitName.match(line).group(1).replace(',','..')
        elif(PTbitDesp.match(line)):    self.bitDesp=PTbitDesp.match(line).group(1).replace(',','..')
        elif(PTbitOffset.match(line)):  self.bitOffset=PTbitOffset.match(line).group(1).replace(',','..')
        elif(PTbitWdith.match(line)):   self.bitWidth=PTbitWdith.match(line).group(1).replace(',','..')
        elif(PTbitAcc.match(line)):     self.bitAcc=PTbitAcc.match(line).group(1).replace(',','..')
        elif(PTbitRstVal.match(line)):  self.bitRstVal=PTbitRstVal.match(line).group(1).replace(',','..')
    def genCSV(self):
        print self.regName ,",",self.regDim ,",",self.regAddr ,",",self.regSize ,",",self.regAcc ,",",self.regRstVal ,",",self.regMsk ,",",self.bitName ,",",self.bitDesp ,",",self.bitOffset ,",",self.bitWidth ,",",self.bitAcc ,",",self.bitRstVal
    def genCHeaders(self):
        print "#define ", self.regName , "(" ,base_name, "+", self.regAddr , ")"
        #print "#define ", self.regName , "hdmi_base + ", "((" ,base_name, "+", self.regAddr , ")<<2)"
        print "\t //", "rAcc:",self.regAcc, " rSize:", self.regSize, " rRstVal:", self.regRstVal
    def genBitNotes(self):
        print "\t //","bOffset:", self.bitOffset ," bName:", self.bitName, " bWD:",self.bitWidth ," bAcc:",self.bitAcc ,"bRstVal:", self.bitRstVal
        print "\t   //", "bDesp:", self.bitDesp 
    def genCStruct_Head(self):
        print "typedef union {"
        print "\t unsigned long U;"
        print "\t struct ", " {"
    def genCStruct_Tail(self):
        print "\t\t } B;"
        print "\t }", self.regName ,"_t", ";"
    def addCStruct_Body(self):
        self.bitfield[int(self.bitOffset)]=(self.bitName, self.bitWidth)
    def genCStruct_Body(self):
        self.bitfield = sorted(self.bitfield.iteritems(), key=lambda d:d[0], reverse=False)
        for k,v in self.bitfield:
            print "\t\t", "unsigned long", " ", v[0], ":", v[1], ";"
        self.bitfield={}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------
RegBitProInst=RegBitPro()
regAct = 0
bitAct = 0
regBg = 0 
regEd = 0 
bitBg = 0 
bitEd = 0 
regOutEn = 1
#Only for CSV
if argv2 == 1:
    print "regName" ,",","regDim" ,",","regAddr" ,",","regSize" ,",","regAcc" ,",","regRstVal" ,",","regMsk" ,",","bitName" ,",","bitDesp" ,",","bitOffset" ,",","bitWidth" ,",","bitAcc" ,",","bitRstVal"
for line in f1.readlines():
    line =line.strip()
    # gen flags
    if(PTregFlagBg.match(line)): 
        RegBitProInst.resetReg()
        regAct = 1
        regBg = 1
        regEd = 0
    elif(PTregFlagEd.match(line)):
        regAct = 0
        regBg = 0
        regEd = 1
    elif(PTbitFlagBg.match(line)):
        RegBitProInst.resetBit()
        bitAct = 1
        bitBg = 1
        bitEd = 0
    elif(PTbitFlagEd.match(line)):
        bitAct = 0
        bitBg = 0
        bitEd = 1
    else:
        regBg = 0
        regEd = 0
        bitBg = 0
        bitEd = 0
    # reg and bit match
    if regAct and not bitAct:
        RegBitProInst.RegMch(line)
    elif regAct and bitAct:
        RegBitProInst.BitMch(line)
    # gen output
    if regAct and bitBg and regOutEn:
        if argv2==2: RegBitProInst.genCHeaders()
        if argv2==3: RegBitProInst.genCStruct_Head()
        regOutEn = 0
    elif not regAct and regEd :
        if argv2==3: RegBitProInst.genCStruct_Body()
        if argv2==3: RegBitProInst.genCStruct_Tail()
        regOutEn = 1
    elif not bitAct and bitEd :
        if argv2==1: RegBitProInst.genCSV()
        if argv2==2: RegBitProInst.genBitNotes()
        if argv2==3: RegBitProInst.addCStruct_Body()

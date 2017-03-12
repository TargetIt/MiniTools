#! /usr/bin/python
#Server
#  
import os
import sys
import re
import time


import math
def GetSimFileFoulderList(RootDir):
    AllList = []
    FileList = []
    FoulderList = []
    AllList = map(lambda x: os.path.join(RootDir, x), os.listdir(RootDir)) 
    FileList = filter(lambda x: os.path.isfile(x), AllList)
    FoulderList = filter(lambda x: os.path.isdir(x), AllList)
    #map(lambda x: GetFileList(x), FoulderList)
    return FileList, FoulderList
def GetSimFileListRec(RootDir, AllFileList):
    FileList, FoulderList = GetSimFileFoulderList(RootDir)
    AllFileList.append(FileList)
    for foulder in FoulderList:
        GetSimFileListRec(foulder, AllFileList)
    return AllFileList
def GetFileListAgent(RootDir):
    if not os.path.isdir(RootDir):
        raise IOError('Input RootDir is illegal !!')
    AllFileList = []
    AllFileListPost = []
    AllFileListPost = GetSimFileListRec(RootDir, AllFileList)
    # flatten list, cov 2-dim to 1-dim
    # filter the void element
    AllFileListPost = [j for i in AllFileListPost for j in i ]
    return AllFileListPost
# ----------------------------------------------------------------  
def SplitFileSh(InputFile):
    os.system('split -l 49152 ' + InputFile)    
def SplitFilePyAgent(InputFile):
    fin = open(InputFile, 'rb')
    try:
        lines = fin.readlines()
    finally:
        fin.close()
    return SplitListPy(InputFile, lines)
def SplitListPy(InputFile, InputList):
    SplResult = {}
    SplResultLine = []
    if(len(str(InputList)) > 49152):
        i = 0
        AllLineNum = len(InputList)
        CurLineNum = 0
        for line in InputList:
            CurLineNum = CurLineNum + 1
            SplResultLine.append(line)
            #SplResult[InputFile+'_sp_'+str(i)].append(line)
            if ((len(str(SplResultLine))) > 49152):
                i = i + 1
                RedundantLine = SplResultLine.pop()
                if(len(str(RedundantLine)) > 49152):
                    SplResultStr = SplitStrPy(InputFile, i, RedundantLine)
                    SplResult = dict(SplResult.items() + SplResultStr.items())
                else:
                    SplResult[InputFile+'_sp_'+str(i)] = SplResultLine
                    SplResultLine = []
                    SplResultLine.append(RedundantLine)
            if CurLineNum == AllLineNum:
                i = i + 1
                SplResult[InputFile+'_sp_'+str(i)] = SplResultLine
                return SplResult
                
    else :
        SplResult[InputFile] = InputList
    
    return SplResult
def SplitStrPy(InputFile, LineNum, InputStr):
    SplResult = {}
    SliceNum = int(math.ceil(len(InputStr) / 49152.0))
    for i in range(1,SliceNum):
        SplResult[InputFile+'_sp_'+str(LineNum)+'_'+str(i)] = InputStr[(i-1)*49152:i*49152]
    return  SplResult
# ---------------------------------------------------------------
def xcSetScoreBoard(text):
    outf = os.popen('xclip -selection c', 'w')
    outf.write(text)
    outf.close()
def xcGetScoreBoard():
    #outf = os.popen('xclip -selection c -o', 'r')
    outf = os.popen('xclip -selection buffer-cut -o', 'r')
    content = outf.read()
    outf.close()
    return content
def xclipClrBufferCut():
    outf = os.system('echo "1111" | xclip -selection buffer-cut -i')
def GetDataViaScoreboard():
    OpenClipboard()
    try:
        got = GetClipboardData()
    finally:
        CloseClipboard()
    return got
def TestEmptyScoreboard():
    OpenClipboard()
    try:
        EmptyClipboard()
        assert EnumClipboardFormats(0)==0, "Clipboard formats were available after emptying it!"
    finally:
        CloseClipboard()
def SetDataToScoreboard(text):
    OpenClipboard()
    try:
        SetClipboardText(text)
    finally:
        CloseClipboard()
def WaitAckFromScoreboard(ACK):
    data =  GetDataViaScoreboard()
    while data != ACK:
        time.sleep(0.8)
        data =  GetDataViaScoreboard()
        print data
    
    ##data = xcGetScoreBoard()
    ##while data != ACK:
    ##  time.sleep(0.8)
    ##  data =  xcGetScoreBoard()
    ##xclipClrBufferCut()
def TxDataToDriver(Dat_0,Ack_0):
    retry_num = 50
    xclipClrBufferCut()
    xcSetScoreBoard(Dat_0)
    print "\t\t Tx data :" + Dat_0[0:20]
    #for i in range(retry_num):
    i = 0
    while 1:
        i = i + 1
        for j in range(10):
            time.sleep(2)
            data =  xcGetScoreBoard()
            print "\t\t Received ACK = " + data[0:20]
            print "\t\t Expected ACK = " + Ack_0
            if data == Ack_0:
                break
        if data == Ack_0:
            print "... ... Successful to receive ack from client ... ..."
            break
        else:
            xclipClrBufferCut()
            xcSetScoreBoard(Dat_0)
            print "... ... Fail to receive ack from client ... ..."
            print "\t\t Received ACK = " + data[0:20]
            print "\t\t Expected ACK = " + Ack_0
            print "\t\t Retry Number: " + str(i)
            time.sleep(0.8)
    #if i==retry_num-1:
    #    raise IOError('TimeOut : Tx failed over 50 times re-try!!!')

def TxDataToDriver_win(Dat_0,Ack_0):
    retry_num = 5
    TestEmptyScoreboard()
    SetDataToScoreboard(Dat_0)
    for i in range(retry_num):
        for j in range(20):
            time.sleep(0.8)
            data =  GetDataViaScoreboard()
            print data
            if data == Ack_0:
                break
        if data == Ack_0:
            break
        else:
            TestEmptyScoreboard()
            SetDataToScoreboard(Dat_0)
            time.sleep(0.8)
    if i==retry_num-1:
        raise IOError('TimeOut : Tx failed over 5 times re-try!!!')
def TxAFileToClipboard(SynNum, FilePathName, FileContent):
    print "\n[Begin] Start to TX, SynNum = " + SynNum 
    TxDataToDriver(SynNum + "FilePathName_" + FilePathName, SynNum + "Ack" + "FilePathName")
    TxDataToDriver(SynNum + "FileContent_" + FileContent, SynNum + "Ack" + "FileContent")

def ConvListToStr(Listin):
    StrOut = ""
    for i in Listin:
        StrOut = StrOut + i;
    return StrOut
def StartSyn(SynNum):
    TxAFileToClipboard(SynNum, "XiaoAoJiangHu", "LinHuChong")
def StopSyn(SynNum):
    TxAFileToClipboard(SynNum, "HuaShanLunJian", "DuGuQiuBai")
if __name__ == '__main__':
    RootDir = sys.argv[1]
    if not os.path.isdir(RootDir):
        raise IOError('Input RootDir is illegal !!')
    os.chdir(RootDir)
    AllFileListPost = GetFileListAgent('./')
    print " ============ Below are filelists ==============="
    print AllFileListPost
    #SetDataToScoreboard(str(AllFileListPost))
    #SetDataToScoreboard(ConvListToStr(AllFileListPost))
    SynNum = 0
    StartSyn(str(SynNum))
    for AFileList in AllFileListPost:
        FilePathNameContent = SplitFilePyAgent(AFileList)
        for FilePathName, FileContent in FilePathNameContent.iteritems():
            #print "=================================================" 
            #print FilePathName
            #print ConvListToStr(FileContent)
            #print "-------------------------------------------------" 
            #print FileContent
            SynNum = SynNum + 1
            TxAFileToClipboard(str(SynNum), ConvListToStr(FilePathName), ConvListToStr(FileContent))
    StopSyn(str(SynNum+1))
    print "All files have been sent!!!"



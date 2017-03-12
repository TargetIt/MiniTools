# Client
from win32clipboard import *
import os
import sys
import re
import time
import win32con
def FlagAckViaClipboard(ack):
    OpenClipboard()
    try:
        SetClipboardText(ack)
        time.sleep(0.1)
    finally:
        CloseClipboard()
def GetDataViaClipboard():
    OpenClipboard()
    try:
        got = GetClipboardData()
        time.sleep(0.1)
    finally:
        CloseClipboard()
    return got
def TestEmptyClipboard():
    OpenClipboard()
    try:
        EmptyClipboard()
        time.sleep(0.1)
    finally:
        CloseClipboard()
def SplitFile(InputFile):
    os.system('split -l 32768 ' + InputFile)     
def GetDataFromServer(SynHeader, AckData_lst, AckData_cur):
    retry_num = 0
    Data = GetDataViaClipboard()
    while retry_num < 50:
        if Data.startswith(SynHeader):
            print "... ... Successful to match SynHeader: " + SynHeader 
            retry_num = 0
            break
        else : 
            print "... ...  Fail to match SynHeader ... ... "
            print "\t\t Expected SynHeader : " + SynHeader
            print "\t\t Received SynHeader : " + Data[0:20]
            print "\t\t Retry Number : " + str(retry_num)
            retry_num = retry_num + 1
            TestEmptyClipboard()
            time.sleep(1.5)
            FlagAckViaClipboard(AckData_lst)
            time.sleep(3.5)
            Data = GetDataViaClipboard()
    if retry_num == 50 :
        raise IOError('TimeOut : Rx failed over 20 times re-try!!!')
    TestEmptyClipboard()
    time.sleep(1.5)
    FlagAckViaClipboard(AckData_cur)
    return Data[len(SynHeader) :]
def GetAFileFromServer(SynNum):
    AckFilePathName_cur = str(SynNum) +"Ack"+"FilePathName"
    AckFileContent_cur = str(SynNum) +"Ack"+"FileContent"
    AckFilePathName_last = str(SynNum-1) +"Ack"+"FilePathName"
    AckFileContent_last = str(SynNum-1) +"Ack"+"FileContent"
    SynFilePathName_cur = str(SynNum) +"FilePathName_"
    SynFileContent_cur = str(SynNum) +"FileContent_"
    FileName = GetDataFromServer(SynFilePathName_cur, AckFileContent_last, AckFilePathName_cur)
    time.sleep(3.5)
    FileContent = GetDataFromServer(SynFileContent_cur, AckFilePathName_cur, AckFileContent_cur)
    time.sleep(3.5)
    FileName = FileName.strip()
    return FileName, FileContent
def StoreAFileToLocal(FilePathName, FileContent):
    FilePath = os.path.split(FilePathName)[0]
    #os.system('mkdir -p ' + FilePath)
    if not os.path.isdir(FilePath):
        os.makedirs(FilePath)
    fout = open(FilePathName, 'wb')
    try:
        fout.write(str(FileContent))
    finally:
        fout.close()
    return 0
if __name__=='__main__':
    #print GetDataViaClipboard()
    #FlagAckViaClipboard()
    SynNum = 0
    AllRecvPathName = ""
    print "[Begin]" + "Start to SYN ......" + str(SynNum) 
    FilePathName, FileContent = GetAFileFromServer(SynNum)
    while True:
        if SynNum == 0:
            if (FilePathName.startswith("XiaoAoJiangHu") and FileContent.startswith("LinHuChong")) :
                SynNum = SynNum + 1
                print "[End]  SYN successfully : " + FilePathName
            else :
                FilePathName, FileContent = GetAFileFromServer(SynNum)
        else:
            print "\n"+"[Begin]" + "Start to RX, SynNum = " + str(SynNum) 
            FilePathName, FileContent = GetAFileFromServer(SynNum)
            if (FilePathName.startswith("HuaShanLunJian") and FileContent.startswith("DuGuQiuBai")) :
                print AllRecvPathName
                break
            print "[End]  RX successfully : " + FilePathName
            print FileContent
            AllRecvPathName = AllRecvPathName+"\n"+FilePathName
            StoreAFileToLocal(FilePathName, FileContent)
            SynNum = SynNum + 1 
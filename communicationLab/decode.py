import base64
import os
import sys

infile_name = sys.argv[1]

infile_handle = open(infile_name, 'r')

infile_content = infile_handle.read()

outfile_content =  base64.b64decode(infile_content)

outfile_name = 'dec' + infile_name

outfile_handle = open(outfile_name, 'wb')

outfile_handle.write(outfile_content)

infile_handle.close()
outfile_handle.close()

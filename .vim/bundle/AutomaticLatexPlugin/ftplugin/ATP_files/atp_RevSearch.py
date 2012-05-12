#!/usr/bin/python
# Author: Marcin Szamotulski <mszamot[@]gmail[.]com>
# This script is a part of Automatic TeX Plugin for Vim.
# It can be destributed seprately under General Public Licence ver.3 or higher.

# SYNTAX:
# atp_RevSearch.py <file> <line_nr> [<col_nr>]

# DESRIPTION: 
# This is a python sctipt which implements reverse searching (okular->vim)
# it uses atplib#FindAndOpen() function which finds the vimserver which hosts
# the <file>, then opens it on the <line_nr> and column <col_nr>.
# Column number is an optoinal argument if not set on the command line it is 1.

# HOW TO CONFIGURE OKULAR to get Reverse Search
# Designed to put in okular: 
# 		Settings>Configure Okular>Editor
# Choose: Custom Text Edit
# In the command field type: atp_RevSearch.py '%f' '%l'
# If it is not in your $PATH put the full path of the script.

# DEBUG:
# debug file : /tmp/atp_RevSearch.debug

import subprocess, sys, re, optparse, os
from optparse import OptionParser
from os import devnull

usage   = "usage: %prog [options]"
parser  = OptionParser(usage=usage)
parser.add_option("--vim", dest="vim", action="store_false", default=True)
parser.add_option("--synctex", dest="synctex", action="store_true", default=False)
(options, args) = parser.parse_args()
if options.vim:
    progname = "gvim"
else:
    progname = "vim"

f = open('/tmp/atp_RevSearch.debug', 'w')

def vim_remote_expr(servername, expr):
# Send <expr> to vim server,

# expr must be well quoted:
#       vim_remote_expr('GVIM', "atplib#callback#TexReturnCode()")
    cmd=[progname, '--servername', servername, '--remote-expr', expr]
    devnull=open(os.devnull, "w+")
    subprocess.Popen(cmd, stdout=devnull, stderr=f).wait()
    devnull.close()

# Get list of vim servers.
output  = subprocess.Popen([progname, "--serverlist"], stdout=subprocess.PIPE)
servers = output.stdout.read().decode()
match   = re.match('(.*)(\\\\n)?', servers)
file    = args[0]
if not options.synctex:
    line=args[1]
    # Get the column (it is an optional argument)
    if (len(args) >= 3 and int(args[2]) > 0):
            column = str(args[2])
    else:
            column = str(1)
else:
    # Run synctex
    page=args[1]
    x=args[2]
    y=args[3]
    if x == "0" and y == "0":
        sys.exit("-1")
    y=float(791.333)-float(y)
    synctex_cmd=["synctex", "edit", "-o", str(page)+":"+str(x)+":"+str(y)+":"+str(file)]
    f.write('>>> synctex     '+' '.join(synctex_cmd)+"\n")
    synctex=subprocess.Popen(synctex_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    synctex.wait()
    synctex_output      = synctex.stdout.read()
    synctex_error       = synctex.stderr.read()
    synctex_error_list  = re.split('\n',synctex_error)
    error               = ""
    f.write('>>> synctex return code: '+str(synctex.returncode)+"\n")
    for error_line in synctex_error_list:
        if re.match('SyncTeX ERROR', error_line):
            error=error_line
            f.write(">>> synctex error      : "+error+"\n")
            break
    if synctex.returncode == 0:
        match_pos=re.findall("(?:Line:(-?\d+)|Column:(-?\d+))",synctex_output)
        if len(match_pos):
            line=match_pos[0][0]
            column=match_pos[1][1]
            if column == "-1":
                column = "1"
        else:
            line        = "-1"
            column      = "-1"
    else:
        print("synctex return code: "+str(synctex.returncode))
        line    = "-1"
        column  = "-1"

f.write(">>> args        "+file+":"+line+":"+column+"\n")

if match != None:
    servers=match.group(1)
    server_list=servers.split('\\n')
    server = server_list[0]
    f.write(">>> server: "+server+"\n")
    # Call atplib#FindAndOpen()     
    cmd=progname+" --servername "+server+" --remote-expr \"atplib#FindAndOpen('"+file+"','"+line+"','"+column+"')\""
    findandopen=subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    vim_server=re.split("\n",findandopen.stdout.read())[0]
    f.write('>>> vim server: '+vim_server+"\n")
    if synctex.returncode != 0 and vim_server != "":
        cmd=""
        if error != "":
            vim_remote_expr(vim_server, "atplib#callback#Echo('[ATP:] "+error+"','echomsg','WarninMsg', '1')")
        else:
            vim_remote_expr(vim_server, "atplib#callback#Echo(\"[SyncTex:] synctex return with exit code: "+str(synctex.returncode)+"\",'echo','WarninMsg', '1')")
# Debug:
if match != None:
	f.write(">>> file        "+file+"\n>>> line        "+line+"\n>>> column      "+column+"\n>>> cmd         "+cmd+"\n")
else:
	f.write(">>> file        "+file+"\n>>> line        "+line+"\n>>> column      "+column+"\n>>> server       not found\n")
f.close()

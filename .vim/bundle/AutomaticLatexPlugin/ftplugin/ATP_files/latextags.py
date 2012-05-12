#!/usr/bin/python

import re, optparse, subprocess, os
from optparse import OptionParser
from time import strftime, localtime
import locale

# ToDoList:
# I can use synstack function remotely to get tag_type.
# I can scan bib files to get bibkeys (but this might be slow)!
#       this could be written to seprate file (does vim support using multiple tag file)

# OPTIONS:
usage   = "usage: %prog [options]"
parser  = OptionParser(usage=usage)
parser.add_option("--files",    dest="files"    )
parser.add_option("--auxfile",  dest="auxfile"  )
parser.add_option("--hyperref", dest="hyperref",        default=False,  action="store_true")
parser.add_option("--servername", dest="servername",    default=""      )
parser.add_option("--progname", dest="progname",        default="gvim"  )
parser.add_option("--bibfiles", dest="bibfiles",        default=""      )
parser.add_option("--bibtags",  dest="bibtags",         default=False,  action="store_true")
parser.add_option("--bibtags_env",  dest="bibtags_env", default=False,  action="store_true")
parser.add_option("--dir",      dest="directory")
parser.add_option("--cite",     dest="cite",            default="default" )
(options, args) = parser.parse_args()
file_list=options.files.split(";")
bib_list=options.bibfiles.split(";")

# Cite Pattern:
if options.cite == "natbib":
    cite_pattern=re.compile('^(?:[^%]|\\\\%)*\\\\(?:c|C)ite(?:(?:al)?[tp]\*?|year(?:par)?|(?:full)?author\*?|num)?(?:\[.*\])?{([^}]*)}')
elif options.cite == "biblatex":
# there is no pattern for \[aA]utocites, \[tT]extcites, \[sS]martcites,
# \[pP]arencites, \[cC]ites, \footcites, \footcitetexts commands
    cite_pattern=re.compile('^(?:[^%]|\\\\%)*\\\\(?:[cC]ite\*?|[pP]arencite\*?|footcite(?:text)?|[tT]extcite|[sS]martcite|supercite|[aA]utocite\*?|[cC]iteauthor|citetitle\*?|cite(?:year|date|url)|nocite|(?:foot)?fullcite|(?:[vV]ol|fvol|ftvol|[sStTpP]vol)cite(?:\[.*\])?{(?:[^}]*)}|[nN]otecite|[pP]nocite|citename|citefield)(?:\[.*\])?{([^}]*)}')
# (?:[aA]utoc|[tT]extc|[sS]martc|[pP]arenc|[cC]|footc)ites(?:(?:\[.*\]{([^}]*)]))*
else:
    cite_pattern=re.compile('^(?:[^%]|\\\\%)*\\\\(?:no)?cite(?:\[.*\])?{([^}]*)}')

def vim_remote_expr(servername, expr):
# Send <expr> to vim server,

# expr must be well quoted:
#       vim_remote_expr('GVIM', "atplib#callback#TexReturnCode()")
    cmd=[options.progname, '--servername', servername, '--remote-expr', expr]
    subprocess.Popen(cmd)

def get_tag_type(line, match, label):
# Find tag type,

# line is a string, match is an element of a MatchingObject
    tag_type=""
    if label == 'label':
        pat='(?:\\\\hypertarget{.*})?\s*\\\\label'
    else:
        pat='(?:\\\\label{.*})?\s*\\\\hypertarget'
    if re.search('\\\\part{.*}\s*'+pat+'{'+match+'}', line):
        tag_type="part"
    elif re.search('\\\\chapter(?:\[.*\])?{.*}\s*'+pat+'{'+match+'}', line):
        tag_type="chapter"
    elif re.search('\\\\section(?:\[.*\])?{.*}\s*'+pat+'{'+match+'}', line):
        tag_type="section"
    elif re.search('\\\\subsection(?:\[.*\])?{.*}\s*'+pat+'{'+match+'}', line):
        tag_type="subsection"
    elif re.search('\\\\subsubsection(?:\[.*\])?{.*}\s*'+pat+'{'+match+'}', line):
        tag_type="subsubsection"
    elif re.search('\\\\paragraph(?:\[.*\])?{.*}\s*'+pat+'{'+match+'}', line):
        tag_type="paragraph"
    elif re.search('\\\\subparagraph(?:\[.*\])?{.*}\s*'+pat+'{'+match+'}', line):
        tag_type="subparagraph"
    elif re.search('\\\\begin{[^}]*}', line):
        # \label command must be in the same line, 
        # To do: I should add searching in next line too.
        #        Find that it is inside \begin{equation}:\end{equation}.
        type_match=re.search('\\\\begin\s*{\s*([^}]*)\s*}(?:\s*{.*})?\s*(?:\[.*\])?\s*'+pat+'{'+match+'}', line)
        try:
            # Use the last found match (though it should be just one).
            tag_type=type_match.group(len(type_match.groups()))
        except AttributeError:
            tag_type=""
    return tag_type

def find_in_filelist(match, file_dict, get_type=False, type_pattern=None):
# find match in list of files, 

# file_dict is a dictionary with { 'file_name' : file }.
    r_file = ""
    r_type = ""
    for file in file_dict.keys():
        flinenr=1
        for line in file_dict[file]:
            pat_match=re.search(match, line)
            if pat_match:
                r_file=file
                if get_type:
                    r_type=re.match(type_pattern, line).group(1)
                break
            flinenr+=1
    if get_type:
        return [ r_file, flinenr, r_type ]
    else:
        return [ r_file, flinenr ]

def comma_split(arg_list):
    ret_list = []
    for element in arg_list:
        ret_list.extend(element.split(","))
    return ret_list

# Read tex files:
file_dict={}
# { 'file_name' : list_of_lines }
for file in file_list:
    file_object=open(file, "r")
    file_dict[file]=file_object.read().split("\n")
    file_object.close()

# Read bib files:
if len(bib_list) > 1:
    bib_dict={}
    # { 'bib_name' : list_of_lines } 
    for bibfile in bib_list:
        bibobject=open(bibfile, "r")
        bib_dict[bibfile]=bibobject.read().split("\n")
        bibobject.close()

# GENERATE TAGS:
# From \label{} and \hypertarget{}{} commands:
tags=[]
tag_dict={}
for file_name in file_list:
    file_ll=file_dict[file_name]
    linenr=0
    p_line=""
    for line in file_ll:
        linenr+=1
        # Find LABELS in the current line:
        matches=re.findall('^(?:[^%]|\\\\%)*\\\\label{([^}]*)}', line)
        for match in matches:
            tag=str(match)+"\t"+file_name+"\t"+str(linenr)
            # Set the tag type:
            tag_type=get_tag_type(line, match, "label")
#             print(line)
            if tag_type == "":
                tag_type=get_tag_type(p_line+line, match, "label")
            tag+=";\"\tinfo:"+tag_type+"\tkind:label"
            # Add tag:
            tags.extend([tag])
            tag_dict[str(match)]=[str(linenr), file_name, tag_type, 'label']
        # Find HYPERTARGETS in the current line:        /this could be switched on/off depending on useage of hyperref/
        if options.hyperref:
            matches=re.findall('^(?:[^%]|\\\\%)*\\\\hypertarget{([^}]*)}', line)
            for match in matches:
                # Add only if not yet present in tag list:
                if not tag_dict.has_key(str(match)):
                    tag_dict[str(match)]=[str(linenr), file_name, tag_type, 'hyper']
                    tag_type=get_tag_type(line, match, 'hypertarget')
                    if tag_type == "":
                        tag_type=get_tag_type(p_line+line, match, "label")
                    tags.extend([str(match)+"\t"+file_name+"\t"+str(linenr)+";\"\tinfo:"+tag_type+"\tkind:hyper"])
        # Find CITATIONS in the current line:
        if options.bibtags and not options.bibtags_env:
            # There is no support for \citealias comman in natbib.
            # complex matches are slower so I should pass an option if one uses natbib.
            matches=re.findall(cite_pattern, line)
            matches=comma_split(matches)
            for match in matches:
                if not tag_dict.has_key(str(match)):
                    if len(bib_list) == 1:
                        tag=str(match)+"\t"+bib_list[0]+"\t/"+match+"/;\"\tkind:cite"
                        tag_dict[str(match)]=['', bib_list[0], '', 'cite']
                        tags.extend([tag])
                    elif len(bib_list) > 1:
                        bib_file=""
                        [ bib_file, bib_linenr, bib_type ] = find_in_filelist(re.compile(str(match)), bib_dict, True, re.compile('\s*@(.*){'))
                        if bib_file != "":
#                             tag=str(match)+"\t"+bib_file+"\t/"+match+"/;\"\tkind:cite\tinfo:"+bib_type
                            tag=str(match)+"\t"+bib_file+"\t"+str(bib_linenr)+";\"\tkind:cite\tinfo:"+bib_type
                            tag_dict[str(match)]=['', bib_file, bib_type, 'cite']
                            tags.extend([tag])
        if options.bibtags and options.bibtags_env:
            matches=re.findall(cite_pattern, line)
            matches=comma_split(matches)
            for match in matches:
                if not tag_dict.has_key(str(match)):
                    [ r_file, r_linenr ] = find_in_filelist(re.compile("\\\\bibitem(?:\s*\[.*\])?\s*{"+str(match)+"}"), file_dict)
                    tag=str(match)+"\t"+r_file+"\t"+str(r_linenr)+";\"\tkind:cite"
                    tag_dict[str(match)]=[str(r_linenr), r_file, '', 'cite']
                    tags.extend([tag])
        p_line=line

# From aux file:
ioerror=False
try:
    auxfile_list=open(options.auxfile, "r").read().split("\n")
    for line in auxfile_list:
        if re.match('\\\\newlabel{[^}]*}{{[^}]*}', line):
            [label, counter]=re.match('\\\\newlabel{([^}]*)}{{([^}]*)}', line).group(1,2)
            counter=re.sub('{', '', counter)
            counter=re.search('[0-9.]+', counter).group(0)
            try:
                [linenr, file, tag_type, kind]=tag_dict[label]
            except KeyError:
                [linenr, file, tag_type, kind]=["no_label", "no_label", "", ""]
            except ValueError:
                [linenr, file, tag_type, kind]=["no_label", "no_label", "", ""]
            if linenr != "no_label" and counter != "":
                tags.extend([str(counter)+"\t"+file+"\t"+linenr+";\"\tinfo:"+tag_type+"\tkind:"+kind])
except IOError:
    ioerror=True
    pass

# SORT (vim works faster when tag file is sorted) AND WRITE TAGS
time=strftime("%a, %d %b %Y %H:%M:%S +0000", localtime())
tags_sorted=sorted(tags, key=str.lower)
tags_sorted=['!_TAG_FILE_SORTED\t1\t/'+time]+tags_sorted
os.chdir(options.directory)
tag_file = open("tags", 'w')
tag_file.write("\n".join(tags_sorted))
tag_file.close()

# Communicate to Vim:
if options.servername != "":
    vim_remote_expr(options.servername, "atplib#callback#Echo(\"[LatexTags:] tags file written.\",'echo','')")
if ioerror:
    vim_remote_expr(options.servername, "atplib#callback#Echo(\"[LatexTags:] no aux file.\",'echomsg', 'WarningMsg')")

#!/usr/bin/python
# -*- coding: utf-8 -*-

import subprocess
import os.path
from random import randint

print '-'*10, "which_mkdir test running...", '-'*10
return_code = subprocess.call("which mkdir", shell=True)
if ( return_code == 0):
    print "PASS <which mkdir displayed the path to mkdir>"
else:
    print "FAIL <command 'which mkdir' failed to display path>"
print '-'*10, "end of which_mkdir test", '-'*10
print


print '-'*10, "mkdir_folder test running", '-'*10
random_num = randint(1,1000000)
dirname = "dirname_" + str(random_num)
mkdir_cmd = "mkdir " + dirname
rm_cmd = "rm -r " + dirname
return_code = subprocess.call(mkdir_cmd, stderr=subprocess.STDOUT, shell=True)
#print mkdir_cmd, " process run, and file exsists: ", os.path.exists(dirname)
if (return_code == 0):
    print "PASS <mkdir created a new folder, functionality tested, now the folder will be removed>"
else:
    print "FAIL <unable to create a folder>"
subprocess.call(rm_cmd, stderr=subprocess.STDOUT, shell=True) #cleaning
print '-'*10, "end of mkdir_folder test", '-'*10



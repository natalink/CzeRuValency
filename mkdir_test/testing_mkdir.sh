#!/bin/bash

echo "====Testing ***mkdir which***, displaying the path:====="
which mkdir
if [ $? -eq 0 ]
then
    echo "PASS <'which mkdir' test displayed the path correctly>"
else
    echo "FAIL <TEST 'which mkdir' failed: command did not displated the path>" > log.txt
fi
echo "======End of testing ***mkdir which***========"
echo
echo

echo "====Testing ***mkdir*** without arguments, displaying help info:====="
mkdir
if [ $? -eq 1 ]
then
        echo "PASS <'mkdir' command can not be run without arguments>"
else
    echo "FAIL <TEST 'mkdir' failed: command without arguments should actually fail>" >> log.txt
fi
echo "======End of testing ***mkdir*** without arguments========"
echo
echo

echo "====Testing ***mkdir folder***:====="
NEWDIR=folder_$RANDOM
mkdir $NEWDIR
if [ $? -eq 0 ]
then
    echo "PASS 'mkdir dir' command correctly created a directory "$NEWDIR
    echo "Cleanup: the directory *"$NEWDIR"* will be removed"
    rm -r $NEWDIR
else
    echo "FAIL <'mkdir dir' did not created a new directory as expected>" >> log.txt
fi
echo "======End of testing ***mkdir folder***========"
echo
echo

echo "====Testing ***mkdir existing_folder***====="
mkdir dir_already_exists #creating dir once
mkdir dir_already_exists #trying to create the dir once more
if [ $? -eq 1 ]
then
    echo "PASS <'mkdir existing_dir' did not created a directory which already exists>"
else
    echo "FAIL <'mkdir existing_dir' did not noticed the dir already existed>" >>log.txt
fi
echo "======End of testing ***mkdir existing_folder***========"
echo
echo


echo "====Testing ***mkdir -v dir***====="
NEWDIR=folder_$RANDOM
MKDIR_V="$(mkdir -v $NEWDIR)"
if [ $? -eq 0 ]
then
    #if [ $MKDIR_V = "Directory $NEWDIR created" ]; then echo displayed ??TODO
    echo "PASS <'mkdir -v dir' created a folder and displayed on the STDOUT that it was created>"
else
    echo "FAIL <'mkdir -v dir' >" >> log.txt
fi
echo "======End of testing ***mkdir which***========"
echo
echo

if [ -f log.txt ]; #TODO it some other way
then
    echo  "/**TEST FAILED: <number of failed checks:"
    echo $(wc -l < "log.txt")" test(s) failed"
    echo "/**Summary written in log.txt>**/"
    exit 1
else
    echo ""/**TEST PASSED: <summary TODO!!!>**/""

fi


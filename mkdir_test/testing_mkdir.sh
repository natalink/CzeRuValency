#!/bin/bash

FAILED=0

echo
echo "====Testing ***mkdir which***, displaying the path:====="
which mkdir
if [ $? -eq 0 ]
then
    echo "PASS 'which mkdir' test displayed the path correctly"  | tee log.txt #printing to STDOUT
else
    echo "FAIL 'which mkdir' failed: command did not displated the path" | tee -a log.txt
    ((FAILED+=1))
fi
echo "======End of testing ***mkdir which***========"
echo
echo

echo "====Testing ***mkdir*** without arguments====="
mkdir
if [ $? -eq 1 ]
then
    echo "PASS 'mkdir' command can not be run without arguments" | tee -a log.txt
else
    echo "FAIL TEST 'mkdir' failed: command without arguments should actually fail" | tee -a log.txt
    ((FAILED+=1))
fi
echo "======End of testing ***mkdir*** without arguments========"
echo
echo

echo "====Testing ***mkdir folder***:====="
NEWDIR=folder_$RANDOM
mkdir $NEWDIR
if [ $? -eq 0 ]
then
    echo "PASS 'mkdir dir' command correctly created a directory "$NEWDIR  | tee -a log.txt
    #echo "Cleanup: the directory *"$NEWDIR"* will be removed"
    rm -r $NEWDIR
else
    echo "FAIL 'mkdir dir' did not created a new directory as expected"  | tee -a log.txt
    ((FAILED+=1))
fi
echo "======End of testing ***mkdir folder***========"
echo
echo

echo "====Testing ***mkdir existing_folder***====="
mkdir dir_already_exists #creating dir once
mkdir dir_already_exists #trying to create the dir once more
if [ $? -eq 1 ]
then
    echo "PASS 'mkdir existing_dir' should not create a directory which already exists"  | tee -a log.txt
    
else
    echo "FAIL 'mkdir existing_dir' did not noticed the dir already existed>" | tee -a log.txt
    ((FAILED+=1))
fi
rm -r dir_already_exists #cleaning
echo "======End of testing ***mkdir existing_folder***========"
echo
echo

#Here will be some false fail (a bug in a test) just to proove the FAILED test also works
echo "====Testing ***mkdir -v dir***====="
NEWDIR=mkdirv_$RANDOM
MKDIR_V="$(mkdir -v $NEWDIR)"
if [ $? -eq 0 ]
then
    if [[ $MKDIR_V == "mkdir: created directory '$NEWDIR'" ]]
    then 
        echo "PASS 'mkdir -v dir' created a folder and displayed on the STDOUT that it was created>" | tee -a log.txt
    else
        echo "FAIL 'mkdir -v dir' created a directory, but the message was not displayed" | tee -a log.txt
        ((FAILED+=1))
    fi
else
    echo "FAIL <'mkdir -v dir' did not create a dir>" | tee -a log.txt
    ((FAILED+=1))
fi
rm -r $NEWDIR
echo "======End of testing ***mkdir -v dir***========"
echo
echo

echo "====Testing ***mkdir --help***====="
if [ $? -eq 0 ]
then
	echo "PASS 'mkdir --help' displayed help>" | tee -a log.txt
else
        echo "FAIL 'mkdir --help' help was not displayed" | tee -a log.txt
        ((FAILED+=1))
fi
echo "======End of testing ***mkdir --help***========"
echo
echo

echo "====Testing ***mkdir -p dir***====="
NEWDIR=parentdir/dir/dir
MKDIR_P="$(mkdir -p $NEWDIR)"
if [ $? -eq 0 ]
then
    echo "PASS 'mkdir -p dir/dir' created a parent directory" | tee -a log.txt
else
    echo "FAIL 'mkdir -p dir/dir'  did not create a parent directory" | tee -a log.txt
    ((FAILED+=1))
fi
rm -r $NEWDIR
echo "======End of testing ***mkdir -p dir***========"
echo
echo

echo "====Testing ***mkdir -m permissons dir***====="
NEWDIR=mkdirm
MKDIR_M="$(mkdir -m 777 $NEWDIR)"
if [ $? -eq 0 ]
then
    echo "PASS 'mkdir -m 777 dir' created a directory with any possible permissions>" | tee -a log.txt
else
    echo "FAIL 'mkdir -m 777 dir' failed to create a directory with all permissions " | tee -a log.txt
    ((FAILED+=1))
fi
rm -r $NEWDIR
echo "======End of testing ***mkdir -m permissions dir***========"
echo
echo

echo "====Testing ***mkdir --version***====="
mkdir --version
if [ $? -eq 0 ]
then
    echo "PASS 'mkdir -version' displayed version information>" | tee -a log.txt
else
    echo "FAIL 'mkdir --version' did not display version information" | tee -a log.txt
        ((FAILED+=1))
fi
echo "======End of testing ***mkdir --version***========"
echo
echo



if [ $FAILED -eq 0 ]; #TODO it some other way
then
    echo "TEST PASSED: summary written to the log.txt, you can also read it below:"
    cat log.txt
    exit 0
else
    echo  "TEST FAILED: number of failed checks:"
    echo $FAILED" test(s) failed"
    echo "Summary below is also written to log.txt:"
    cat log.txt    
    exit 1
fi


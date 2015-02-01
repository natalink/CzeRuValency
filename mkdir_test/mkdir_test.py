#!/usr/bin/python

import sys
import string
import subprocess
import os.path

class TestMkdir():

    def __init__(self):
        self.count_failed = 0
        self.count_passed = 0
        self.summary = []

    def process_0(self, arg_msg):
        arg, msg = arg_msg[0], arg_msg[1]
        cmd = 'mkdir '+ arg
        print
        print '*'*5, cmd, '*'*5
        return_code = subprocess.call(cmd, shell=True)

        if return_code == 0:
            self.passed(msg,cmd)
        else:
            self.failed(msg,cmd)

        if ( os.path.exists('directory') ):
            self.cleanup('directory')
        print '*'*10
        return self.count_passed, self.count_failed, self.summary

    def process_1(self, arg_msg):
        arg, msg = arg_msg[0], arg_msg[1]
        cmd = 'mkdir '+ arg#+ '2 > stderr.log'
        print
        print '*'*5, cmd, '*'*5
        return_code = subprocess.call(cmd, shell=True)

        if return_code == 1:
            self.passed(msg, cmd)
        else:
            self.failed(msg, cmd)
        if ( os.path.exists('directory') ):
            self.cleanup('directory')
        print '*'*10
        return self.count_passed, self.count_failed, self.summary

    def passed(self,msg,cmd):
            summ = "PASS <command ***" +cmd + "*** " + msg + ", and it worked as expected>"
            print summ
            self.summary.append(summ)
            self.count_passed += 1

    def failed(self,msg,cmd):
            summ = "FAIL <command ***" +cmd + "*** " + msg + ", and it did not work as expected>"
            print summ
            self.summary.append(summ)
            self.count_failed += 1

    def cleanup(self,arg):
        remove_dir = 'rm -r ' + arg
        subprocess.call(remove_dir, shell=True)


if __name__ == "__main__":
    test = TestMkdir()
    failed = 0
    args_0 = [
        ['--help', 'should display a short manual'],
        ['--version', 'should display version of mkdir'],
        ['directory', 'should create a directory'],
        ['-p directory/dir1/dir2', 'should create a parent directory'],
        ['-v directory', 'should create a directory and print message to STDOUT'],
        ['-m 777 directory', 'should create directory with all permissions'],
        #['-t', 'TESTING FAILURE']
    ]
    args_1 = [
        ['', 'should not run without args'],
        ['dir', 'should not create an existing directory'],
        ['~ufaladmin/newdir', 'should not create a directory in an unauthorized place']
    ]
    for arg in args_0:
        passed, failed, summary = test.process_0(arg)

    for arg in args_1:
        passed, failed, summary = test.process_1(arg)

    print
    if ( failed > 0 ):
        print "TEST FAIL: ", failed, " check(s) failed, ", passed, "checks passed. Summary: "
        for summ in summary:
            print summ
        exit(1)
    else:
        print "TEST PASSED: ", passed, "checks passed. Summary: "
        for summ in summary:
            print summ
        exit(0)


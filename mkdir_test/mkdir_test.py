#!/usr/bin/python

import sys
import string
import subprocess
import os.path

class TestMkdir():

    def __init__(self):
        self.count_failed = 0
        self.summary = []

    def process_0(self, arg_msg):
        arg, msg = arg_msg[0], arg_msg[1]
        cmd = 'mkdir '+ arg
        print '*'*5, cmd, '*'*5
        return_code = subprocess.call(cmd, shell=True)
        if return_code == 0:
            summ = "PASS <" + msg + ", and it worked>"
            print summ
            self.summary.append(summ)
        else:
            print "FAIL <", msg, ", and it did not work>"
            self.count_failed += 1
        if arg.startswith('d'):
            self.cleanup(arg)
        print '*'*10
        return self.count_failed, self.summary

    def process_1(self, arg_msg):
        arg, msg = arg_msg[0], arg_msg[1]
        cmd = 'mkdir '+ arg + '2 > stderr.log'
        print '*'*5, cmd, '*'*5
        return_code = subprocess.call(cmd, shell=True)
        if return_code == 1:
            print "PASS <", msg, ", and it worked>"
        else:
            print "FAIL <", msg, ", and it did not work>"
            self.count_failed += 1
        if arg.startswith('d'):
            self.cleanup(arg)
        print '*'*10
        return self.count_failed, self.summary

    def cleanup(self,arg):
        remove_dir = 'rm -r ' + arg
        print remove_dir
        subprocess.call(remove_dir, shell=True)


if __name__ == "__main__":
    test = TestMkdir()
    failed = 0
    args_0 = [
        ['--help', 'Expected: short manual displayed'],
        ['directory', 'Expected: directory created'],
        ['-p dir/dir1/dir2', 'Expected: embedded directories created']
    ]
    args_1 = [
        ['', 'Expected: can not run without args']
    ]
    for arg in args_0:
        failed, summary = test.process_0(arg)

    for arg in args_1:
        failed = test.process_1(arg)

    if ( failed > 0 ):
        print "TEST FAIL: ", failed, " checks failed. Summary: "
    else:
        print "TEST PASSED: "

    for summ in summary:
        print summ

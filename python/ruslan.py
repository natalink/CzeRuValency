#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import string
import re

class Processor():

    def process(self, line):
        print '-'*10
        line = line.rstrip()
        czech, rest = self.parse_line(line)
        print "Czech: ", czech

        russian = self.get_russian(rest)
        frame = self.get_frame(rest)
        print '-'*10

    def parse_line(self, line):
        czech, rest = line.split('|')
        return czech, rest

    def get_russian(self, rest):
        raw_frame, russian = re.match(r'(.*)[\d|x],\s*([\w|\d\.-]+)', rest) #proc to fungovalo i kdyz tam bylo line?
        #for ruverb in russian:
        print "Russian: ", russian
        print "REST RAW_FRAME: ", raw_frame
            #return ruverb


    def get_frame(self,rest):
        rest = rest.lstrip('(')
        print "RESTBEFORE:", rest
        rest = re.sub(',\/,i\(\,*i\)', '', rest) #print "RESTAFTER:", rest #for now ignore left-hand valency and passivization
        rest = re.sub('n\(n\),i\(i\)', '', rest)
        rest = re.sub('n\(n\)', '', rest)

        czech_simple = re.findall(r'[^\w][a|d|g|l|i]\(\w\)', rest)
        print "Czech simple: ", czech_simple
        for czech in czech_simple:
            print "CZECH: ", czech
            m0 = re.match(r",(\w)\((\w)", czech)
            if m0:
                print "czechval ", m0.group(1)
                print "ruval ", m0.group(2)

        sim_prep = re.findall(r'[^\w|^(][a|d|g|l|i]\(\w+\(\w\)', rest)
        if sim_prep:
            print "SIM_PREP", sim_prep
        #prep_prep = re.findall(r'\w+\(', rest)

if __name__ == "__main__":
    processor = Processor()
    txt = open('slovesa4', 'r')
    for line in txt:
        output = processor.process(line)
        #print output


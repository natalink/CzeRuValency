#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import string
import re
import codecs
from transliterate import translit

class Processor():

    def process(self, line):
        #print '-'*10
        line = line.rstrip()
        czech, rest = self.parse_line(line)
        #print "Czech: ", czech

        russian = self.get_russian(rest)
        #russian_tr = self.ruslan_translit(russian)
        #russian = translit(russian, "ru")
        #print "RUSSIAN: ", russian
        #transliterated_russian = ruslan.to_rus(russian)
        #print "Transliterated RUSSIAN: ", transliterated_russian
        raw_frame = self.get_rawframe(rest)
        valdict = self.get_frame(raw_frame)
        for key, value in valdict.iteritems():

         #   print "TRANSFORMED: czech: %s %s -> %s %s" % (czech, key, russian, value)
            out_line = "%s\t%s\t%s\t%s" % (czech, key, russian, value)

            return out_line
        #print '-'*10

    def parse_line(self, line):
        czech, rest = line.split('|')
        refl = re.search(r"refl\((..)", rest)
       # print "REST:", rest
        if refl:
            refl_czech = czech + " " + refl.group(1)
            return refl_czech, rest
        else:
            return czech, rest

    def get_russian(self, rest):
        russian = re.match(r'.*[\d|x],\s*([\w|\d\.-]+)', rest)
        if russian:
            #print "Russian: ", russian.group(1)
            return russian.group(1)

    def ruslan_translit(self,russian):
        table = {'c2':'ch', 's2':'sh', 's3':'shch', "6":"'", 'ja':'ja', 'ch': 'kh', 'ju': 'ju'}
        for k in table.keys():
            translit = russian.replace(k,table[k])
            return translit

    def change_case(self,case):
        table2 = {'a':' + Acc', 'i':' + Ins', 'g':' + Gen', 'd':' + Dat'}
        for k in table2.keys():
            case = case.replace(k,table2[k])
        return case

    def get_rawframe(self, rest):
        frame = re.sub(',\/,i\(\,*i\)', '', rest)
        frame = frame.lstrip('(')
        frame = re.sub(',\/,i\(\,*i\)', '', frame)
        frame = re.sub('n\(n\)\,i\(i\)', '', frame)
        frame = re.sub(' i\(i\)', '', frame)
        frame = re.sub(',i\(i\)', '', frame)
        frame = re.sub('n\(n\)', '', frame)
        frame = re.sub('před\(', 'substitutte_back_przhed(', frame)
        #print "Rest aFTER ", frame
        if frame != None:
            return frame

    def get_frame(self, frame):

        val_dict = dict()
        sim_sim = re.findall(r'[^\w|\(][a|d|g|l|i]\(\w\)', frame)
        simsimmatch = re.search(r'[^\w][a|d|g|l|i]\(\w\)', frame)
        #print "Simple simple: ", sim_sim
        if simsimmatch:
            for czech in sim_sim:
        #       print "SIM SIM FRAME: ", czech
                m0 = re.match(r"[^w](\w)\((\w)", czech)
                if m0:
                    czech_case = self.change_case(m0.group(1))
                    ru_case = self.change_case(m0.group(2))
                    val_dict[czech_case] = ru_case
                else:
                    continue


        prep_sim = re.findall(r'[^\w][s|v|k|u|o|\w+]\([a|d|g|i],[a|d|g|i]\)', frame)
        #print "Prep-simple: ", prep_sim
        prep_sim_match = re.search(r'[^\w][s|v|k|u|o|\w+]\([a|d|g|i],[a|d|g|i]\)', frame)
        if prep_sim_match:
            for czech in prep_sim:
          #      print "PREPSIMFRAME: ", czech
                m0 = re.match(r"[,| ](\w+)\(([a|d|g|i]),([a|d|g|i])\)", czech)
                if m0:
                    czech_frame = m0.group(1) + " " + self.change_case(m0.group(2))
         #           print "czech valency ", czech_frame
        #            print "russian valency  ", m0.group(3)
                    val_dict[czech_frame] = m0.group(3)
                else:
                    continue



        prep_prep = re.findall(r'[^\w]\w+\([a|d|g|i], *\w+\([a|d|g|i]\)', frame)
       # print "Prep-prep: ", prep_prep
        prep_prep_match = re.search(r'[^\w]\w+\([a|d|g|i], *(\w+)\([a|d|g|i]\)', frame)
        if prep_prep_match:
            for czech in prep_prep:
                m0 = re.match(r"[^\w](\w+)\(([a|d|g|i]), *(\w+)\(([a|d|g|i])", czech)
                if m0:
           #         print "THIS PREPPREP MATCHES"
                    czechframe = m0.group(1) + " " + self.change_case(m0.group(2))
                    russianframe = m0.group(3) + " " + self.change_case(m0.group(4))
                    czechframeutf = czechframe.encode('utf8')
          #          print "czechval", czechframe
         #           print "ruval ", russianframe
                    val_dict[czechframeutf] = russianframe
                else:
                    continue

        #print "VALDIC: ", val_dict
        return  val_dict

if __name__ == "__main__":
    processor = Processor()
    txt = open('slovesa4', 'r')
    #txt = codecs.getreader("UTF-8")(txt)
    for line in txt:
        output = processor.process(line)
        if output:
            print output


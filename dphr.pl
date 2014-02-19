#!/usr/bin/perl
#use warnings;
use strict;
use utf8;
use Data::Dumper;
#use List::MoreUtils qw(uniq);
use XML::LibXML;
use 5.010;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
open VALLEX, "/ha/home/kljueva/tectomt/treex/lib/Treex/Tool/Vallex/CS/frames-tectomt.txt" or die $!;
binmode(VALLEX, ':utf8');
open DICTIONARY, "/net/work/people/kljueva/slovniky/slovar_pc" or die $!;
binmode(DICTIONARY, ':utf8');
open (CORPUS_CS, "/net/work/people/kljueva/corpusforval/czech_factored")  or die $!;
binmode(CORPUS_CS, ':utf8');
open (FACTORED_RU, "/net/work/people/kljueva/corpusforval/rus242242")  or die $!;
binmode(FACTORED_RU, ':utf8');
#open (PHRASETABLE, "zcat  |") or die $!;
#binmode(PHRASETABLE, ':utf8');


open (OUTFILE, '>>idioms_19_02_8_01.out');

my %count_formems; my %phrasemes; my %frame1; my %dic; my %corpus; my %valency; my@frames; my @multiframes; my %example;
sub process_vallex{
  my $parser = XML::LibXML->new();
  my $doc = $parser->parse_file('testvallex');
  foreach my $lexeme ($doc->findnodes('/body/lexeme_cluster/lexeme')) {
    my @lu_cluster = $lexeme->findnodes('.//lu_cluster');
     foreach my $lucluster (@lu_cluster){

        if ($lucluster->getAttribute("idiom") =~ m/1/){
	   my $lemma = $lucluster->getAttribute("id");
	   next if ($lemma =~ m/\-s[e|i]\-/);
           my ($luc, $v, $verb, $meaning) = split /\-/, $lemma;
	   $verb =~ s/\d//g;
	   my @dphrs = $lucluster->findnodes('.//frame/slot');
	   foreach my $dphr(@dphrs){
		if ($dphr->getAttribute("functor") =~ m/DPHR/){
		    # print "$verb ".$dphr->getAttribute("functor")."\t";
		    my @phraseme_parts = $dphr->findnodes('form');
		    foreach my $phraseme_part(@phraseme_parts){
		     # print "$verb ".$phraseme_part->getAttribute("phraseme_part")."\n";
		      my $phrase = $phraseme_part->getAttribute("phraseme_part");
		      push @{$phrasemes{$verb}}, $phrase;
		    }
		}
	  }#foreach dphr
	}#if lucluster
      }#foreach my$lu_cluster
  } #foreach my $lexeme
}
process_vallex();
#print Dumper \%phrasemes;
sub dictionary {
 while (<DICTIONARY>){
        chomp;
        my ($cs_dic, $ru_dic) = split /\t/;
        push @{ $dic{$cs_dic} }, $ru_dic;
 }
return %dic;
}

my @sents_ru; my@sents_cs;
while (<FACTORED_RU>){
        chomp;
        push @sents_ru, $_;
}
while (<CORPUS_CS>){
        chomp;
        push @sents_cs, $_;
}


my $r;
my %dict = dictionary();
for ($r = 0; $r <= $#sents_ru; $r++){
       #print "==============Start a sentence ***$r***===========\n";
        my @words_cs = map { split / / } $sents_cs[$r];
	my $i; my$k; 
        for ($i = 0; $i <= $#words_cs; $i++) { #$k = $i+1;
          #my ($form_cs, $lemma_cs, $tag_cs) = split (/\|/, $words_cs[$i]);
          my $lemma_cs = &lemma_cz($words_cs[$i]);  
	  $lemma_cs =~ s/-.+//g;
          $lemma_cs =~ s/_.+//g;
	 # print "$lemma_cs ";

	  foreach my $verb (keys %phrasemes){
		next if ($verb =~ /být/);
	  	if ($verb eq $lemma_cs){
		   #print "$verb IS IN THE SENTENCE $sents_cs[$r]\t";
  		   my @phrasemes = @{$phrasemes{$verb}};
		   foreach my $phraseme(@phrasemes){
			#print "VALLEXIDIOM:$verb $phraseme:\t";
		    my $l;
		     for ($l = 1; $l <= 4; $l++) {
		     last if ($words_cs[$i+$l] =~ m/\,\|/ or &tag_cz($words_cs[$i+$l]) =~ m/^V/);

			if($phraseme ne m/ /  and &form_cz($words_cs[$i+$l]) =~ m/\Q$phraseme/){#testujeme jednoslovne NP's 
				print "L= $l; VERB+PHRASEME $verb $phraseme is in the sent $sents_cs[$r]\n";
				my @possible_translations;
			        push (@possible_translations, $_) for  @ { $dic{$lemma_cs}  };
				my @possible_phrasemes;
				push (@possible_phrasemes, $_) for @ { $dic{$phraseme} };
				foreach my $dicru_verb(@possible_translations) {
							  
			            if($sents_ru[$r] =~ m/\Q$dicru_verb/){ #my $dicrus = $dic{$form_cs};
				 	#my $test = &lemma_cz($words_cs[$i+1]);
					#print "$verb $phraseme => $dicru_verb $test\n";	
				        foreach my $dicru_phraseme(@possible_phrasemes){
						if ($sents_ru[$r] =~ m/\Q$dicru_phraseme/){
							my $russian = &phraseme_ru($sents_ru[$r],$dicru_verb,&lemma_cz($words_cs[$i+$l]));	
						   if(length $russian > 0 ){
							print OUTFILE "$verb $phraseme => $russian\n";#\t$sents_cs[$r] $sents_ru[$r]\n";
						    }#length russian
						}
					}#dicru_phrasemes
				    }
				}#dicru_verb
			}
		     }#$l
		   }

		  
		}
	  }
	}
}# 
#print "\n";

sub phraseme_ru{
my $sent = $_[0];
my $verb_ru = $_[1];
my $nextword = $_[2];
my @words_ru = map { split / / } $sent;

    $nextword =~ s/-.+//g;
    $nextword =~ s/_.+//g;

my @translations_phraseme;
push (@translations_phraseme, $_) for @{ $dic{ $nextword }  } ;
foreach my $ru_translation (@translations_phraseme){
 if ($sent =~ m/\Q$ru_translation/ ){
  my $i;
  for ($i = 1; $i <= $#words_ru; $i++ ){
        #return $i, $ru_translation;
        my ($form_ru, $lemma_ru, $form2, $tag_ru) = split (/\|/, $words_ru[$i]);
        if ($lemma_ru eq $verb_ru){my $d;
          for ($d =1; $d <= 4; $d++ ){
            my ($form_ru_d, $lemma_ru_d, $form2_d, $tag_ru_d) = split (/\|/, $words_ru[$i+$d]);
	    if ($ru_translation eq $lemma_ru_d){
		my$exampleru = $verb_ru." ".$form_ru_d;
		return $exampleru;
		last;
	    }
	  }
        }
   }
 }
}
}

sub tag_cz {
my ($line) = @_;
my ($form_cs, $lemma_cs, $tag_cs) = split /\|/, $line;
return $tag_cs;
}

#lemma_cz();
sub lemma_cz {
my ($line) = @_;
my ($form_cs, $lemma_cs, $tag_cs) = split /\|/, $line;
return $lemma_cs;
}

#form_cz();
sub form_cz {
my ($line) = @_;
my ($form_cs, $lemma_cs, $tag_cs) = split /\|/, $line;
return $form_cs;
}


sub lemma_ru {
my ($line) = @_;
my ($form_ru, $lemma_ru, $form2, $tag_ru) = split /\|/, $line;
return $lemma_ru;
}



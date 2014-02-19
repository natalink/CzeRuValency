#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use Data::Dumper;
#use List::MoreUtils qw(uniq);
use XML::LibXML;
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
open VALLEX, "/ha/home/kljueva/tectomt/treex/lib/Treex/Tool/Vallex/CS/frames-tectomt.txt" or die $!;
binmode(VALLEX, ':utf8');
open DICTIONARY, "/net/work/people/kljueva/slovniky/slovar_pc" or die $!;
binmode(DICTIONARY, ':utf8');
open (CORPUS_CS, "cz_dev")  or die $!;
binmode(CORPUS_CS, ':utf8');
open (FACTORED_RU, "ru_dev")  or die $!;
binmode(FACTORED_RU, ':utf8');

#open (CORPUS_CS, "/net/work/people/kljueva/corpusforval/czech_factored")  or die $!;
#binmode(CORPUS_CS, ':utf8');
#open (FACTORED_RU, "/net/work/people/kljueva/corpusforval/rus242242")  or die $!;
#binmode(FACTORED_RU, ':utf8');
use 5.010;
#open (OUTFILE, '>>valency_06112013.out');

my %count_formems; my %formems; my %frame1; my %dic; my %corpus; my %valency; my@frames; my @multiframes; my %example;
sub process_vallex{
  my $parser = XML::LibXML->new();
  my $doc = $parser->parse_file('testvallex');
  foreach my $lexeme ($doc->findnodes('/body/lexeme_cluster/lexeme')) {
    my @mlemmas = $lexeme->findnodes('./lexical_forms/mlemma');
     foreach my $mlemma (@mlemmas){
       my @formemtypes = $lexeme->findnodes('.//frame/slot/form');
       my $sloveso = $mlemma->to_literal;
       foreach my $nod (@formemtypes){
         if ($nod->getAttribute("type") =~ m/direct_case/ ){
                #print $nod->getAttribute("type")." DIRECTCASE:".$nod->getAttribute("case")."\n";
                my $formema = "n:".$nod->getAttribute("case");
                #print "Sloveso: $sloveso; FORMEMA: $formema\n"; 
                push @{$formems{$sloveso}}, $formema;
         }
         if ($nod->getAttribute("type") =~ m/prepos_case/){
                #print $nod->getAttribute("type")."PREPOS: ".$nod->getAttribute("prepos_lemma")." CASE: ".$nod->getAttribute("case")."\n";
                my $formema = "n:".$nod->getAttribute("prepos_lemma")."+".$nod->getAttribute("case");
                #print "Sloveso: $sloveso, Formema: $formema\n";
                push @{$formems{$sloveso}}, $formema;
         }
        }#foreach my$nod
       } #foreach my $mlemma
 }
}  
process_vallex();


while  (<VALLEX>) 
{
	   chomp;
	   $_ =~ m/^(\w+)-V: (.*?)$/ or next;
	   my $verb = $1;
	   my $frame_all = $2;
           $frame_all =~ s/, /,/g;
	   @frames = split / /, $frame_all;
	  #%frame1 = map { split /\[/ } map {   }@frames;

             foreach my $frame1 (@frames){
        	#$frame{$verb} = [] unless exists $frame{$verb};

               $frame1 =~ m/(\w+)\[(.*)\]/;
               my$functor = $1;
               my$form = $2;
	       #my @verbframes = @{$form};
		my @multiframe1 = split /,/, $form;
		my @formems = grep { /n\:/  } grep { !/v\:/ } grep { !/\?\?\?/ } uniq(@multiframe1) ;

	       push @{$formems{$verb}}, @formems; 
	     }
}

for (keys %formems) {
	$formems{$_} = [uniq (@{$formems{$_}})];
	}
my %count_verbs;
for (keys %formems) {
	$count_verbs{$_}++;  
        my @formems = @{$formems{$_}};
	foreach my $form(@formems){
	    next if ($form =~ m/n\:1/);
	   my$concatenated = $_.$form;
	    $count_formems{$concatenated}++;
	}
}

#print "POCET SLOVES:".scalar keys %count_verbs;
#print "POCET FORMEMU:".scalar keys %count_formems;
#print Dumper \%count_formems;

sub dictionary {
 while (<DICTIONARY>){
	chomp;
	my ($cs_dic, $ru_dic) = split /\t/;
	push @{ $dic{$cs_dic} }, $ru_dic;
 }
return %dic;
}

#&get_translation;

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
my (%prep_simple, %prep_prep, %simple_simple, %simple_prep);
for ($r = 0; $r <= $#sents_ru; $r++){
 #      print "==============Start a sentence ***$r***===========\n";
        my @words_cs = map { split / / } $sents_cs[$r];
        my $i; my$k; my %simple; my %prepositional;
        for ($i = 0; $i <= $#words_cs; $i++) { #$k = $i+1;
          my ($form_cs, $lemma_cs, $tag_cs) = split (/\|/, $words_cs[$i]);
	  #my $next_word = $words_cs[$k];
          #my ($next_form_cs, $next_lemma_cs, $next_tag_cs) = split (/\|/, $next_word//"");
	  #my ($form_cs2, $lemma_cs2, $tag_cs2) = split (/\|/, $words_cs[$i+2]//"");
          $lemma_cs =~ s/-.+//g;
          $lemma_cs =~ s/_.+//g;
          foreach my $verb (keys %formems){
	  next if ($verb =~ m/být/);
	  my @possible_translations;
	  push (@possible_translations, $_) for  @ { $dic{$lemma_cs}  };
#	  print "possible translations of $form_cs: @possible_translations\n";
	   foreach my $dicru_verb(@possible_translations) {    
            if($verb eq $lemma_cs and $sents_ru[$r] =~ m/\Q$dicru_verb/){ #my $dicrus = $dic{$form_cs};
		my @formems = @{$formems{$verb}}; 
		foreach my $formem(@formems){
                  $formem =~ s/n\://g; $formem =~ s/ //g; next if ($formem =~ m/^1/);
		 #print "FRK CANDIDATE:$verb + $formem\n";
		my $l;
		
                for ($l = -3; $l <= -1; $l++) {

                  #my ($form_l, $lemma_l, $tag_l) = split (/\|/, $words_cs[$i+$l]);
                        #print "ZKOUSIM_ZAPORNY L:$l; $words_cs[$i+$l]\n";
                        last if ($words_cs[$i+$l] =~ m/\,\|/ or $words_cs[$i+$l] =~ m/^V/);
                        #print "ZKOUSIM L:$l; $words_cs[$i+$l]\n";
                        my $zkus_tag =  &tag_cz($words_cs[$i+$l]);
                        my $zkus_lemma = &lemma_cz($words_cs[$i+$l]);
                        $zkus_lemma =~ s/-.+//g; $zkus_lemma =~ s/_.+//g;
                        if ($formem =~ m/\+/ ){
                         my ($formem_prep,$formem_prepcase) = split /\+/, $formem;
                         #print "$verb + $formem_prep + $formem_prepcase lemma|tag: $zkus_lemma|$zkus_tag\n";   
                         if ($zkus_tag =~ m/RR..\Q$formem_prepcase/ and $zkus_lemma eq $formem_prep){
                           #print "L: $l;slovo: $words_cs[$i+$l] ; $verb + $formem_prep + $formem_prepcase, ruverb: $dicru_verb\n";
                           my $ru_valency_prep = &preposition_ru($sents_ru[$r], $dicru_verb);
                           my $ru_valency_simple = &simple_ru($sents_ru[$r], $dicru_verb, $words_cs[$i+$l]);
#                           print "ZAPORNY PREP.cz/SIMPLE.ru: $verb+$formem => $dicru_verb + $ru_valency_simple\n" if $ru_valency_simple ne "";
 #                          print "ZAPORNY PREP.cz/PREP.ru: $verb+$formem => $dicru_verb + $ru_valency_prep\n" if $ru_valency_prep ne "" ;
  #                         push @{ $prep_simple{"$verb+$formem"} }, "$dicru_verb+$ru_valency_simple"  if $ru_valency_simple ne "" ;
   #                        push @{ $prep_prep{"$verb+$formem"} }, "$dicru_verb+$ru_valency_prep"  if $ru_valency_prep ne "" ;
			   #$example{$verb."+".$formem} = $example_ru;
                           #push @ {$prep_simple{"doufat+v+4"}}, "надеяться+a";
                           #print "***order of $dicru_verb is $order in a sentence $sents_ru[$r]******$dicru_verb + RUVALENCY: $ru_valency  ***\n";     
                         }

                        }else {
                            if ($zkus_tag =~ m/N...\Q$formem/){
                                #print "passing $dicru_verb and $words_cs[$i+$l], veta $sents_ru[$r]\n";
                            my $ru_valency_simple = &simple_ru($sents_ru[$r], $dicru_verb, $words_cs[$i+$l]);
                            my $ru_valency_prep = &preposition_ru($sents_ru[$r], $dicru_verb);
    #                       print "ZAPORNY SIMPLE.cz/SIMPLE.ru: $verb+$formem => $dicru_verb + $ru_valency_simple\n" if $ru_valency_simple ne "" ;
     #                      print "ZAPORNY SIMPLE.cz/PREP.ru: $verb+$formem => $dicru_verb + $ru_valency_prep\n" if $ru_valency_prep ne "" ;
      #                     push @{ $simple_simple{"$verb+$formem"} },"$dicru_verb+$ru_valency_simple"  if $ru_valency_simple ne "" ;
       #                    push @{ $simple_prep{"$verb+$formem"} }, "$dicru_verb+$ru_valency_prep"  if $ru_valency_prep ne "" ;
			  # push $example{$verb." ".$words_cs[$i+$l]} = $example_ru;
                           #last;
                            }
                         } #else
                   } #$l - search around a word

	        for ($l = 1; $l <= 4; $l++) {
		 
		  #my ($form_l, $lemma_l, $tag_l) = split (/\|/, $words_cs[$i+$l]);
			#print "ZKOUSIM L:$l; $words_cs[$i+$l]\n";
		        last if ($words_cs[$i+$l] =~ m/\,\|/ or $words_cs[$i+$l] =~ m/^V/);
			#print "ZKOUSIM L:$l; $words_cs[$i+$l]\n";
		   	my $zkus_tag =  &tag_cz($words_cs[$i+$l]); 
		   	my $zkus_lemma = &lemma_cz($words_cs[$i+$l]);
			my $zkus_form = &form_cz($words_cs[$i+$l]);
			$zkus_lemma =~ s/-.+//g; $zkus_lemma =~ s/_.+//g;
			if ($formem =~ m/\+/ ){
			 my ($formem_prep,$formem_prepcase) = split /\+/, $formem;
			# print "$verb + $formem_prep + $formem_prepcase lemma|tag: $zkus_lemma|$zkus_tag\n";	
			 if ($zkus_tag =~ m/RR..\Q$formem_prepcase/ and $zkus_lemma eq $formem_prep){
#		           print "L: $l;slovo: $words_cs[$i+$l] ; $verb + $formem_prep + $formem_prepcase, ruverb: $dicru_verb\n";
			   my $ru_valency_prep = &preposition_ru($sents_ru[$r], $dicru_verb);
			   my $ru_valency_simple = &simple_ru($sents_ru[$r], $dicru_verb, $words_cs[$i+$l]);
#			   print "PREP.cz/SIMPLE.ru: $verb+$formem => $dicru_verb + $ru_valency_simple\n" if $ru_valency_simple ne "";
 #                          print "PREP.cz/PREP.ru: $verb+$formem => $dicru_verb + $ru_valency_prep\n" if $ru_valency_prep ne "" ;
			   push @{ $prep_simple{"$verb+$formem"} }, "$dicru_verb+$ru_valency_simple"  if $ru_valency_simple ne "" ;
			   push @{ $prep_prep{"$verb+$formem"} }, "$dicru_verb+$ru_valency_prep"  if $ru_valency_prep ne "" ;
			   #push @ {$prep_simple{"doufat+v+4"}}, "надеяться+a";
				
			   #print "***order of $dicru_verb is $order in a sentence $sents_ru[$r]******$dicru_verb + RUVALENCY: $ru_valency  ***\n";	
			 }
			 
			}else { 
			    if ($zkus_tag =~ m/N...\Q$formem/){
				#print "passing $dicru_verb and $words_cs[$i+$l], veta $sents_ru[$r]\n";
			    my $ru_valency_simple = &simple_ru($sents_ru[$r], $dicru_verb, $words_cs[$i+$l]);
			    my $ru_valency_prep = &preposition_ru($sents_ru[$r], $dicru_verb);
#			   print "SIMPLE.cz/SIMPLE.ru: $verb+$formem => $dicru_verb + $ru_valency_simple\n" if $ru_valency_simple ne "" ;
#			   print "SIMPLE.cz/PREP.ru: $verb+$formem => $dicru_verb + $ru_valency_prep\n" if $ru_valency_prep ne "" ;
			   push @{ $simple_simple{"$verb+$formem"} },"$dicru_verb+$ru_valency_simple"  if $ru_valency_simple ne "" ;
                           push @{ $simple_prep{"$verb+$formem"} }, "$dicru_verb+$ru_valency_prep"  if $ru_valency_prep ne "" ;
			   #last;
			  # $example{"$verb+$formem"} = $verb." ".$zkus_form." | ".$example_ru;
			    }
		   	 } #else
		   } #$l - search around a word
		     }# foreach formem
            }#if $verb
	   }#foreach my $dicru_verb(possible translations)	   
	  }
	}#$i
}

#print Dumper \%prep_prep;
print Dumper \%simple_simple;

my %count; 
foreach my $valency_cz(keys %simple_simple) {
#	print "Valencecz: $valency_cz *** ";
	my @valencies_ru = @{ $simple_simple{$valency_cz} };
	foreach my $valency_ru (@valencies_ru) {
#		print "Valenceru: $valency_ru\n";
		$count{$valency_cz}{$valency_ru}++;
	}

}
foreach my $valency_cz(keys %prep_prep) {
#        print "Valencecz: $valency_cz *** ";
        my @valencies_ru = @{ $prep_prep{$valency_cz} };
        foreach my $valency_ru (@valencies_ru) {
#                print "Valenceru: $valency_ru\n";
                $count{$valency_cz}{$valency_ru}++;
        }

}

foreach my $valency_cz(keys %prep_simple) {
#        print "Valencecz: $valency_cz *** ";
        my @valencies_ru = @{ $prep_simple{$valency_cz} };
        foreach my $valency_ru (@valencies_ru) {
#                print "Valenceru: $valency_ru\n";
                $count{$valency_cz}{$valency_ru}++;
        }

}

foreach my $valency_cz(keys %simple_prep) {
#        print "Valencecz: $valency_cz *** ";
        my @valencies_ru = @{ $simple_prep{$valency_cz} };
        foreach my $valency_ru (@valencies_ru) {
#                print "Valenceru: $valency_ru\n";
                $count{$valency_cz}{$valency_ru}++;
        }

}

 
print Dumper \%count;

sub largest_value (\%) {
    my $hash = shift;
    keys %$hash;       # reset the each iterator

    my ($large_key, $large_val) = each %$hash;

    while (my ($key, $val) = each %$hash) {
        if ($val > $large_val) {
            $large_val = $val;
            $large_key = $key;
        }
    }
    $large_key
}

foreach my $freq_key (keys %count){
#	print OUTFILE "$freq_key\t".largest_value(%{$count{$freq_key}})."\n";
}

sub uniq { my %seen; grep !$seen{$_}++, @_ }

#if a word from a dic is in a Russian sentence, get order of this word and $d words after/around
sub preposition_ru{
my $sent = $_[0];
my $word = $_[1];
#my $zkus_tag = $_[2];
#my @possible_translations = $_[3];
my @words_ru = map { split / / } $sent;
my $i;
  for ($i = 1; $i <= $#words_ru; $i++ ){
	my ($form_ru, $lemma_ru, $form2, $tag_ru) = split (/\|/, $words_ru[$i]);
	if ($lemma_ru eq $word and $tag_ru =~ /^V/) { my $d;
	  for ($d = 1; $d <= 2; $d++ ){
		my ($form_ru_d, $lemma_ru_d, $form2_d, $tag_ru_d) = split (/\|/, $words_ru[$i+$d]);
		if ($tag_ru_d =~ m/Sp-(\w)/){ 
		  my $prepcase_ru = $1;
		  my $rus_prep_formem = $form_ru_d.'+'.$prepcase_ru;
		  #my $example = $form_ru.' '.$form_ru_d; 
	  	  return $rus_prep_formem;
		  last;   
		}
		else {
		  return;
		}
	  } 
	} 
   }
}

sub simple_ru {
my $sent = $_[0];
my $verb_ru = $_[1];
my $nextword = $_[2];
my @words_ru = map { split / / } $sent;
my $translations = $dict{&lemma_ru($nextword)} ;
my @translations_valency;
push (@translations_valency, $_) for @{ $dic{&lemma_ru($nextword)}  } ; 
foreach my $ru_translation (@translations_valency){
 if ($sent =~ m/\Q$ru_translation/ ){
  my $i;
  for ($i = 1; $i <= $#words_ru; $i++ ){
	#return $i, $ru_translation;
	my ($form_ru, $lemma_ru, $form2, $tag_ru) = split (/\|/, $words_ru[$i]);
	if ($lemma_ru eq $verb_ru){my $d;
	  for ($d =1; $d <= 2; $d++ ){
	    my ($form_ru_d, $lemma_ru_d, $form2_d, $tag_ru_d) = split (/\|/, $words_ru[$i+$d]);
            if (($tag_ru_d =~ m/^N/ or $tag_ru_d =~ m/[P|A]....(\w)/) and $ru_translation eq $lemma_ru_d){
			 $tag_ru_d =~ m/N...(\w)/;  
			 $tag_ru_d =~ m/[P|A]....(\w)/;
			 my $simple_case = $1;
			 my $exampleru = $verb_ru." ".$form_ru_d;
			 #return ($simple_case, $exampleru);
			 return $simple_case;
			 last;
			}
		}
	  }
	}	 	
   }
 }
}


#gets a sentence and a lemma, outputs order of an element
sub search_russian{
my $sent = $_[0];
my $word = $_[1];
my @words_ru = map { split / / } $sent;
 foreach my $words_ru (@words_ru) {
        my ($form_ru, $lemma_ru, $form2, $tag_ru) = split (/\|/, $words_ru);
        if ($word eq $lemma_ru) {
                return $form_ru, $lemma_ru, $tag_ru;
        }
 }
}



#tag_cz();
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



#lemma_ru();
sub lemma_ru {
my ($line) = @_;
my ($form_ru, $lemma_ru, $form2, $tag_ru) = split /\|/, $line;
return $lemma_ru;
}

#tag_ru();
sub tag_ru {
my ($line) = @_;
my ($form_ru, $lemma_ru, $form2, $tag_ru) = split /\|/, $line;
return $tag_ru;
}

#form_ru();
sub form_ru {
my ($line) = @_;
my ($form_ru, $lemma_ru, $form2, $tag_ru) = split /\|/, $line;
return $form_ru;
}



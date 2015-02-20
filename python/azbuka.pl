#!/usr/bin/perl
use locale;
use strict;
use utf8;

binmode(STDOUT, ':utf8');
binmode(STDIN, ':utf8');

open PYTONOUT, "output_py" or die $!;
binmode PYTONOUT, ":utf8";

while (<PYTONOUT>){
    
    chomp;
    my ($czech, $czval, $line, $ruval) = split(/\t/);
    my ($prep, $case) = split('\+', $ruval);
  
      $line = $line." ".$prep;
  
      $line =~ s/c4/щ/g;
      $line =~ s/c2/ч/g;
      $line =~ s/s2/ш/g;
      $line =~ s/ch/х/g;
      $line =~ s/z2/ж/g;
      $line =~ s/je/э/g;
      $line =~ s/E/Э/g;
      $line =~ s/ju/ю/g;
      $line =~ s/ja/я/g;
      $line =~ s/a/а/g;
      $line =~ s/A/А/g;
      $line =~ s/b/б/g;
      $line =~ s/B/Б/g;
      $line =~ s/v/в/g;
      $line =~ s/V/В/g;
      $line =~ s/g/г/g;
      $line =~ s/G/Г/g;
      $line =~ s/d/д/g;
      $line =~ s/e/е/g;
      $line =~ s/z/з/g;
      $line =~ s/Z/З/g;
      $line =~ s/i/и/g;
      $line =~ s/I/И/g;
      $line =~ s/j/й/g; #x
      $line =~ s/I/Й/g; #x
      $line =~ s/k/к/g;
      $line =~ s/K/К/g;
      $line =~ s/l/л/g;
      $line =~ s/L/Л/g;
      $line =~ s/m/м/g;
      $line =~ s/M/М/g;
      $line =~ s/n/н/g;
      $line =~ s/N/Н/g;
      $line =~ s/o/о/g;
      $line =~ s/O/О/g;
      $line =~ s/p/п/g;
      $line =~ s/P/П/g;
      $line =~ s/r/р/g;
      $line =~ s/R/Р/g;
      $line =~ s/s/с/g;
      $line =~ s/S/С/g;
      $line =~ s/t/т/g;
      $line =~ s/T/Т/g;
      $line =~ s/u/у/g;
      $line =~ s/U/У/g;
      $line =~ s/f/ф/g;
      $line =~ s/F/Ф/g;
      $line =~ s/c/ц/g;
      $line =~ s/C/Ц/g;
      $line =~ s/c2/ч/g;
      $line =~ s/Č/Ч/g;
      $line =~ s/s2/ш/g;
      $line =~ s/Š/Ш/g;
      $line =~ s/s4/щ/g;
      $line =~ s/y/ы/g;
      $line =~ s/6/ь/g;


    next if ($line =~ m/Ноне/);


    print $czech." ". $czval." -> ".$line."+".$case."\n";
}

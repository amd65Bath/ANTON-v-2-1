#!/usr/bin/perl

## Copyright (C) 2010 Martin Brain and Georg Boenn
## 
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
## 02110-1301, USA.


#
# Martin Brain
# 27/03/08
# mjb@cs.bath.ac.uk
#
# Rather than having to manage lots of obscure options,
# this program builds the input answer set program as required.

use strict;
use Getopt::Long;

sub outputFileOrDie {
    my $path = shift;
    my $line;
    my $FH;

    open $FH, "<$path" or die("Can't open \"$path\"");
    while ($line = <$FH>) {
      if ($line =~ /^#include \"([a-zA-Z0-9\/\.]+)\"/) {
	outputFileOrDie($1);
      } else {
	print $line;
      }
    }
    close $FH;
}

# Declare variables
my $help;
my $task;
my $style;
my $piece;
my $time;
my $mode;
my $rhythm;
my $measures;
my $measures2;
my $measures3;
my $workingMeasures;
my $timeSignature;
my $part;

my @validTasks = ("compose", "diagnose", "debug", "parse");
my @validStyles = ("solo", "duet", "trio", "quartet");
my @validModes = ("minor", "major", "dorian", "phrygian", "lydian", "mixolydian");
my @validTimeSignatures = ("2/2", "2-layer", "4/4", "3/4", "3-layer", "3/8", "6/8", "9/8", "12/8");
my $validStyle;
my $validMode;
my $validTimeSignature;

# AD - 08/22

# Declares form and setKey variables

my $form;

my @validForms = ("standard", "binary", "binarySec", "binaryCont");
my $validForm;

my $setKey;

my @validSetKeys = ("C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B");
my $validSetKey;

my $setKeyNumber = 0;

# AD End

my @RAW_ARGV = @ARGV;

# Default options
$help = 0;
$rhythm = -1;

# GetOpt
Getopt::Long::GetOptions("help" => \$help,
                         "style=s" => \$style,
			 "task=s" => \$task,
			 "piece=s" => \$piece,
			 "time=s" => \$time,
			 "mode=s" => \$mode,
       "form=s" => \$form,
       "setKey=s" => \$setKey,
			 "rhythm:i" => \$rhythm,
			 "measures=i" => \$measures,
			 "time-signature=s" => \$timeSignature);

sub printUsageAndExit {
  print STDERR "Usage " . __FILE__ . " [options]\n";
  print STDERR "Options:\n";
  print STDERR "\t--help\t\tPrints this message\n";
  print STDERR "\t--task\t\tOne of " . ( join ", ", @validTasks ) . "\n";
  print STDERR "\t--style\t\tOne of " . ( join ", ", @validStyles ) . "\n";
  print STDERR "\t--piece\t\tThe location of a (partial) piece in example format.\n";
  print STDERR "\t--time\t\tThe number of time steps to be modelled for each part.\n";
  print STDERR "\t--mode\t\tOne of " . ( join ", ", @validModes ) . "\n";
  print STDERR "\t--form\t\tOne of " . ( join ", ", @validForms ) . "\n";
  print STDERR "\t--setKey\t\tOne of " . ( join ", ", @validSetKeys ) . "\n";
  print STDERR "\t--rhythm\tAdd Farey tree based rhythm.\n";
  print STDERR "\t--measures\tThe number of measures to compose.\n";
  print STDERR "\t--time-signature\tThe time signature to use.\n";
  print STDERR "\n";
  exit 0;
}


# Help
if ($help) {
    printUsageAndExit();
}


## Validation of input

# Handle default mode
if (!(defined($task))) {
    $task = "compose";
    print STDERR "Task defaults to $task, use --task=... to change.\n";
}

# If we are given a (partial) piece then timing, mode, form and setKey are not needed
if (defined($piece)) {
    if (defined($style)) {
	print STDERR "--style=$style option is redundant when a piece is given.\n";
    }
    if (defined($time)) {
	print STDERR "--time=$time option is redundant when a piece is given.\n";
    }
    if (defined($mode)) {
	print STDERR "--mode=$mode option is redundant when a piece is given.\n";
    }
    if (defined($form)) {
	print STDERR "--form=$form option is redundant when a piece is given.\n";
    }
    if (defined($setKey)) {
	print STDERR "--setKey=$setKey option is redundant when a piece is given.\n";
    }
} else {
    # Check / give defaults for time and mode if needed
    if (($task eq "compose") || ($task eq "debug")) {

	if (!(defined($style))) {
	    $style = "solo";
	    print STDERR "Style defaults to $style, use --style=... to change.\n";
	} else {
	    my $found = 0;
	    for $validStyle (@validStyles) {
		if ($style eq $validStyle) {
		    $found = 1;
		    last;
		}
	    }

	    if ($found == 0) {
		die("Style given \"$style\" is not valid.");
	    }
	}

  # AD - 08/22

  if (!(defined($form))) {
	    $form = "standard";
	    # print STDERR "Form defaults to $form, use --form=... to change.\n";
	} else {
	    my $found = 0;
	    for $validForm (@validForms) {
		if ($form eq $validForm) {
		    $found = 1;
		    last;
		}
	    }

	    if ($found == 0) {
		die("Form given \"$form\" is not valid.");
	    }
	}

  #if there is no setKey, compose in a random key.
  if (!(defined($setKey))) {
      my $random_number = int(rand(12));
      $setKey = $validSetKeys[$random_number];
	} else {
	    my $found = 0;
	    for $validSetKey (@validSetKeys) {
		if ($setKey eq $validSetKey) {
		    $found = 1;
		    last;
		}
	    }

	    if ($found == 0) {
		die("setKey given \"$setKey\" is not valid.");
	    }
	}

  # AD End
	
	if (!(defined($time))) {
	    $time = "8";
	    print STDERR "Time defaults to $time, use --time=... to change.\n";
	} elsif (!($time =~ /((\d+),)*(\d+)/)) { 
	    die("Time must be a comma separated list of positive integers.");
	}

	if (!(defined($mode))) {
	    $mode = "major";
	    print STDERR "Mode defaults to $mode, use --mode=... to change.\n";
	} else {
	    my $found = 0;
	    for $validMode (@validModes) {
		if ($mode eq $validMode) {
		    $found = 1;
		    last;
		}
	    }

	    if ($found == 0) {
		die("Mode given \"$mode\" is not valid.");
	    }
	}

    } elsif ($task eq "diagnose") {
	die("Can't diagnose problems without a piece, use --piece=... .");
    } elsif ($task eq "parse") {
	die("Can't convert example piece to parsable without and example piece, use --piece=... .");
    } else {
	die("Task given \"$task\" is not valid.");
    }
}

# Validate the use of measure and time signatures
if ($rhythm >= 0) {

  if (!(defined($measures))) {
    $measures = 2;
    print STDERR "Measures defaults to $measures, use --measures=... to change.\n";
  }

  if ($measures <= 0) {
    die("Measures requested ($measures) not positive.");
  } else {

    $workingMeasures = $measures;
    
    $measures2 = 0;
    while (($workingMeasures % 2) == 0) {
      ++$measures2;
      $workingMeasures /= 2;
    }
    
    $measures3 = 0;
    while (($workingMeasures % 3) == 0) {
      ++$measures3;
      $workingMeasures /= 3;
    }
    
    if ($workingMeasures != 1) {
      die("Measures must be of the form 2^a * 3^b (a,b >= 0)");
    }
  }

  if (!(defined($timeSignature))) {
    $timeSignature = "4/4";
    print STDERR "Time signature defaults to $timeSignature, use --time-signature=... to change.\n";
  } else {

    my $found = 0;
    for $validTimeSignature (@validTimeSignatures) {
      if ($timeSignature eq $validTimeSignature) {
	$found = 1;
	last;
      }
    }

    if ($found == 0) {
      die("Time signature given \"$timeSignature\" is not valid.");
    }
  }
  

} else {
  if (defined($measures)) {
    print STDERR "Measures option only used when rhythm is enabled with --rhythm.\n";
  }
  if (defined($timeSignature)) {
    print STDERR "Time signatures only used when rhythm is enabled with --rhythm.\n";
  }
}

# Stamp options at the top of the file
print "%% File autogenerated by programBuilder.pl, part of the Anton composition system\n";
print "%% Command line arguments : " . join(' ', @RAW_ARGV) . "\n\n";



# Output piece (if given) - or time and mode
if ($piece ne "") {

    open FH, "<$piece" or die("Can't open \"$piece\"");
    while(<FH>) {
      if ($_ =~ /style\(([^\)]+)\)\./) {
	$style = $1;
      } elsif ($_ =~ /rhythm\(1\)\./) {
	$rhythm = 1;
      }
      print $_;
    }
    close FH;

} else {

  $part = 1;
  while ($time =~ s/^(\d+),(.*)/$2/) {
    print "partTimeMax($part,$1).\n";
    ++$part;
  }
  print "partTimeMax(P,$time) :- part(P), P >= $part.\n";

  print "mode($mode).\n";
  print "style($style).\n";

  #50% of the time, a binary piece will compose sectional binary.
  #The other 50%, the composition will be continous binary
  if ($form eq "binary"){
    my $r_number = int(rand(1));
    if ($r_number == 0){
      $form = "binarySec"
    }
    else{
      $form = "binaryCont"
    }
  }
  print "form($form).\n";

  my @numbList = (0..11);
  for my $i (@numbList){
      if ($setKey eq $validSetKeys[$i]){
          $setKeyNumber = $i;
      }
  }

  print "setKey($setKeyNumber).\n";

  if ($rhythm >= 0) {
    print "measureLimit($measures).\n";
    print "measureDepth(" . (1 + $measures2 + $measures3) . ").\n";

    # Check for wildcard time sigantures
    print "meterDepthConfig(F,\"" . $timeSignature . "\") :- fareyTree(F).\n";
    if ($timeSignature =~ /layer/) {
      print "wildcardTimeSignature(\"" . $timeSignature  . "\").\n"
    } else {
      print "treeTimeSignature(F,\"" . $timeSignature . "\") :- fareyTree(F).\n";
    }
  }

}

# If just converting to parsable then don't output the rules
if ($task eq "parse") {
  print "partTime(P,1..TM) :- partTimeMax(P,TM).\n";   # Parse uses time literals

  if ($rhythm >= 0) {
   print STDERR "WARNING : Parse does not support pieces with rhythm.\n";
  }

  exit(0);
} else {

  # Only include the necessary styles
  outputFileOrDie("rules/styles/$style.lp");
  
  # If we are using rhythm, include the relevant files
  if ($rhythm >= 0) {
    outputFileOrDie("rules/rhythm.lp");
  } else {
    outputFileOrDie("rules/monorhythmic.lp");
  }
  
  # Output what to compute
  outputFileOrDie("rules/tasks/$task.lp");
}

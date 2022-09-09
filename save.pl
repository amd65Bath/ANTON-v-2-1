#!/usr/bin/perl -w -I ./lib/

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
# 01/02/08
# mjb@cs.bath.ac.uk
#
# Given answer sets on STDIN, saves them in the suitable place for examples

use strict;
use Getopt::Long;
use parseAnswerSet;

# Declare variables
my $help;
my $force;
my $verdict;
my $name;
my $type;
my $line;
my $tune;
my $key;
my $answerSetCounter;

# Default options
$help = 0;
$force = 0;

# GetOpt
Getopt::Long::GetOptions("help" => \$help, "force" => \$force);

# Help
if ($help  || scalar(@ARGV) < 2) {
  print STDERR "Usage " . __FILE__ . " [options] verdict name\n";
  print STDERR "\tverdict\t\tgood, valid or bad.\n";
  print STDERR "\tname\t\tThe name used for the saved files.\n";
  print STDERR "Options:\n";
  print STDERR "\t--help\t\tPrints this message.\n";
  print STDERR "\t--force\t\tWill overwrite any files that already exist.\n";
  print STDERR "\n";

  exit 0;
}

$verdict = $ARGV[0];
$name = $ARGV[1];

# Validate args
if (! (($verdict eq "good") || ($verdict eq "valid") ||
       ($verdict eq "bad")  || ($verdict eq "rhythm")) ) {
  die("Verdict must be good, valid or bad");
}


# Create the directory (if needed) to put
system("mkdir -p examples/$verdict/");


# Work through the input

$answerSetCounter = 0;
while ((($type,$line) = parseAnswerSet(\*STDIN)) && ($type ne "End")) {

  # Find the stable models
  if ($type eq "Answer Set") {
    ++$answerSetCounter;
    print STDERR "Found answer set $answerSetCounter ... ";

    # Check to see if file already exists
    if (!($force) && (-e "examples/$verdict/$name.$answerSetCounter")) {
      die "File examples/$verdict/$name.$answerSetCounter already exists.\n";
    } else {
      # Write to file
      open FH, "| ./parse.pl --output=example >examples/$verdict/$name.$answerSetCounter";
      print FH "Answer: 1\nStable Model: $line\n";
      close FH;

      print STDERR "written to examples/$verdict/$name.$answerSetCounter\n";
    }
    
  }
}

if ($answerSetCounter == 0) {
  print STDERR "No answer sets found, check input file?\n";
}

#!/usr/bin/perl -I ./lib/

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
# countAnswerSets.pl
#
# Martin Brain
# mjb@cs.bath.ac.uk
# 12/05/09
#
# Used by test.sh, broken out into a separate script so that it can handle
# the different output formats used by different solvers.

use parseAnswerSet;

$count = 0;

while ((($type,$line) = parseAnswerSet(\*STDIN)) && ($type ne "End")) {
    if ($type eq "Answer Set") {
	++$count;
    }
}

print "$count\n";

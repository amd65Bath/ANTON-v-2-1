#!/usr/bin/perl -w

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



# Martin Brain
# mjb@cs.bath.ac.uk
# 25/03/07
#
# Shuffles a file in smodels input format.

my @list;
my $i;
my $j;
my $tmp;

# Seed the random number generator
if (scalar(@ARGV) != 1) {
    die("Must give a seed for the random number generator");
} else {
    srand(pop @ARGV);
}

# Input
while (<>) {
    if ($_ =~ /^0$/) {
        last;
    } else {
        push @list, $_;
    }
}

# Shuffle
for ($i=0; $i < $#list; ++$i) {
    $j = int(rand() * $#list);
    $tmp = $list[$i];
    $list[$i] = $list[$j];
    $list[$j] = $tmp;
}

# Output
foreach $tmp (@list) {
    print $tmp;
}

# Rest of input
print "0\n";
print <>;

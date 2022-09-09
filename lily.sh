#!/usr/bin/bash


    OLDIFS=$IFS
    IFS='|'

    
# not correct file name, $1 to be output from gtestNew
    if ! [ -f "$1" ]
	then
        echo "$0 Error: $1 file not found"
		exit -1
	fi

# read args
	lineCount=0
	while read test a b c d e f g h i j result time

	do
		lineCount=$((lineCount+1))

#remove second if
        if [ $lineCount -lt 3 ]
        then
            continue
        fi

        if [ $result = Success ]
        then
            cd /home/ash/Documents/Project/anton-2.0.0
            ./parse.pl --output=lilypond < testing/tunes_$test > testing/tunes_$test.ly
            cd /home/ash/Documents/Project/anton-2.0.0/testing
            lilypond tunes_$test.ly
            echo $test\|$a\|$b\|$c\|$d\|$e\|$f\|$g\|$h\|$i\|$j\|$result\|$time
        else
            printf "\nError: Composition $test returns no answer sets (unsatisfiable) and a piece cannot be composed with the existing input parameters \n"
        fi


    done < $1

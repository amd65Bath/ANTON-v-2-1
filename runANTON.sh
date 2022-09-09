#!/usr/bin/bash
#---------------------------------------------------------------------------------------------------
# This script runs the Perl program programbuilder.pl for a number of different ANTON configurations
#
# Each configuration is described as a set of pipe-delimited values within separate lines of
# a configuration file passed to this script
# The script reads the config file (e.g. params.cfg), assigns the pipe-delimited values to script 
# variables that are then used as parameters to programbuilder.pl
#
# The script writes a separate output program file for each configuration called program_n.lp
# where n is the number of the configuration (i.e. the line-number in the configuration file of each 
# parameter-set.
#
# Finally, the script writes a pipe-delimited output file that lists the parameters used for each ANTON run 
# together with a status value (SUCCESS or FAIL depending on whether the answerset output from gringo is
# SUCCESSFUL or UNSUCCESSFUL) and the time (in seconds) that the run took
#---------------------------------------------------------------------------------------------------

##################################################################################################
# NOTE: This script should be run from a testing folder that should be created as a subdirectory 
# of the main anton-2.0.0 folder
##################################################################################################

# Script arguments
# ----------------
# $1 is config file (input)
# $2 is output file
# $3 is output folder for all files

# keep a record of current working directory
    startDir=$PWD

# set configFile as the input file
    configFile=$(readlink -f $1)

    cd ..
    rulesDir=$PWD

# set output folder
    outFolder=$(readlink -f $3)

#------------------------------------------------------------------------------------------------
# Read configuration file to pick up parameters for programbuilder.pl for a variety of tests
# Format of config file is:
# Record format: Delimited
# Header: No
# Delimiter: | (pipe)
# Fields: task time style mode rhythm measures timeSig form setKey nComp
# Example: compose|16|duet|major|rhythm|4|4/4|standard|G|1
#------------------------------------------------------------------------------------------------

# input file separator is a pipe
	OLDIFS=$IFS
	IFS='|'
	PROGRAMBUILDER=$rulesDir/programBuilder.pl
        FAILSTRING=UNSATISFIABLE

# check output folder has been provided
    if [ -z "$outFolder" ]
	then
		echo "$0 Error: need to have output folder name as arg 3"
		exit -1
	fi

# set output file name
        outfile=$outFolder/$2

# check config file exists
	if ! [ -f "$configFile" ]
	then
		echo "$0 Error: $configFile file not found"
		exit -1
	fi

# write datetimestamp to output file
	echo $(date) > $outfile

# write header line to output file
	echo "Test|Task|Time|Style|Mode|Rhythm|Measures|Time-Signature|Form|SetKey|Num.Comps|Result|Run-Time" >> $outfile

# The following loop reads each line from the config file and assigns the delimited values to script variables
 
	lineCount=0
	while read task time style mode rhythm measures timeSig form setKey nComp
	do
		lineCount=$((lineCount+1))

# get time at start of processing for this config run
        startTime=`date +%s`

# call programbuilder, 
        $PROGRAMBUILDER --task=$task --time=$time --style=$style --mode=$mode --$rhythm --measures=$measures --time-signature=$timeSig --form=$form --setKey=$setKey > $outFolder/program_$lineCount.lp

# run the output of programbuilder (the lp program) through clasp and gringo and check the result
                cat $outFolder/program_$lineCount.lp | gringo | clasp --restart-on-model --rand-freq=0.05 --seed=$RANDOM $nComp > $outFolder/tunes_$lineCount

# get first few lines of output and look for string UNSUCCESSFUL and set result appropriately                
		if head -10 $outFolder/tunes_$lineCount | grep -i $FAILSTRING 
		then
			result=Fail	
		else
			result=Success
		fi

# get time at end of processing
        endTime=`date +%s`
        let processTime=$endTime-$startTime

		echo $lineCount\|$task\|$time\|$style\|$mode\|$rhythm\|$measures\|$timeSig\|$form\|$setKey\|$nComp\|$result\|$processTime >> $outfile
	done < $configFile


cd $startDir

# Finally run lily
./lily.sh $2 



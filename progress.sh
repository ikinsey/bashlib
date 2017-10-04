#!/bin/bash

############################################################################################################################################
############################################################################################################################################
# 											     	    	   DEPENDENCIES																   #
############################################################################################################################################
############################################################################################################################################

	. ./bashlib/output.sh

############################################################################################################################################
############################################################################################################################################
# 											     					READ 																   #
############################################################################################################################################
############################################################################################################################################

	########################################################################################################################################
	#
	# Returns a display string for a progress bar 
	#
	# Input
	#   $1 = The integer representing the progress made so far
	#   $2 = The integer representing the maximum progress towards which this bar is progressing
	#	$3 = (OPTIONAL, DEFAULT=100) The integer representing the length of the bar
	# 
	# Output
	#   $__OUTPUT = The string representing the progress bar display
	#
	########################################################################################################################################
	get_progress_bar_display() 
	{
		local current_progress=$1
		local maximum_progress=$2
		local line_length="$3"; if [ "$line_length" == "" ]; then line_length=100; fi
		line_length=$(($line_length-2)) # account for the end braces
		
		local float_progress=$(bc -l <<< "$current_progress * 100 / $maximum_progress / 1")
		local progress_bar=""

		if [ $current_progress -gt 0 ] # the math in the for loop is slow, see if we can avert
		then

			# Update progress bar which counts up until the session ends at 100$ progress $$$$$
			for (( i=1; i<=$line_length; i++ ))
			do
				if (( $(echo "$float_progress > $i" |bc -l) ))
				then
					progress_bar="$progress_bar|"
				else
					progress_bar="$progress_bar "
				fi
			done

			__OUTPUT="[$progress_bar]"
		else 
			get_repeated_character " " $line_length
			__OUTPUT="[$__OUTPUT]"
		fi
	}

	########################################################################################################################################
	#
	# Returns a display string for a bi-directional progress bar 
	#
	# Input
	#   $1 = The value which will be displayed as progress
	# 	$2 = The cap value (example if cap value is 200 this bar will show progress between -200 & 200)
	# 	$3 = (OPTIONAL, DEFAULT=0) Allow 50% overflow on either side, 1 indicates yes, 0 indicates no.
	# 
	# Output
	#   $__OUTPUT = The string representing the progress bar display
	#
	########################################################################################################################################
	get_bidirectional_progress_bar_display()
	{
		local actual_value=$1
		local cap=$2
		local allow_overflow=0; if [ "$3" == "1" ]; then allow_overflow=1; fi

		local max_percent=50; if [ $allow_overflow -eq 1 ]; then max_percent=75; fi

		local START_PERCENT=-$max_percent
		local END_PERCENT=$max_percent
		
		local percent_progress=$(bc -l <<< "$actual_value * 50 / $cap / 1")
		
		local progress_bar=""
		for (( i=$START_PERCENT; i<=$END_PERCENT; i++ ))
		do
			c=" "

			if   [ $i -eq -50 ]; then c=" [ "; 
			elif [ $i -eq 0 ]; then c="^";
			elif [ $i -eq 50 ]; then c=" ] ";
			elif [ $i -gt 0 ] && (( $(echo "$percent_progress >= $i" |bc -l) ))
			then
				c="|"
			elif [ $i -lt 0 ] && (( $(echo "$percent_progress <= $i" |bc -l) ))
			then
				c="|"
			fi

			progress_bar="$progress_bar$c"
		done

		__OUTPUT=$progress_bar
	}
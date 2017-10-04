#!/bin/bash

############################################################################################################################################
############################################################################################################################################
# 											     	    	   DEPENDENCIES																   #
############################################################################################################################################
############################################################################################################################################

	. ./display.sh
	. ./query.sh

	. ./bashlib/input.sh
	. ./bashlib/progress.sh

############################################################################################################################################
############################################################################################################################################
# 											     				  CREATE															  	   #
############################################################################################################################################
############################################################################################################################################

	########################################################################################################################################
	# 
	# Sets a start time (in utc seconds) which will be used when checking the time
	# 
	# Input
	# 	$1 = (OPTIONAL, DEFAULT=main) The name of the timer to start (used when reading or pausing)
	#
	# Sets
	#   $__TIMER_FIRST_START_TIME = an array of the UTC seconds when each timer started, indexd by name
	#	$__TIMER_LAST_START_TIME = an array of UTC seconds when each timer last started, indexd by name
	# 	$__TIMER_LAST_PAUSE_TIME = an array of the UTC seconds for a timer's last pause, indexd by name
	#   $__TIMER_TOTAL_PAUSE_TIME = an array of the seconds spent paused for a timer, indexed by name
	#
	########################################################################################################################################
	start_timer() 
	{
		local timer="main"; if [ "$1" != "" ]; then timer="$1"; fi

		# Create the timer arrays if they doesn't already exist ############################################################################
		if [ "$__TIMER_FIRST_START_TIME" == "" ]
		then
			# NOTE: dont use 0 for a timer name
			__TIMER_FIRST_START_TIME=("#")
			__TIMER_LAST_START_TIME=("#")
			__TIMER_LAST_PAUSE_TIME=("#")
			__TIMER_TOTAL_PAUSE_TIME=("#")
		fi

		# Create entries in each timer array for this new timer ############################################################################
		if [ "${__TIMER_FIRST_START_TIME[timer]}" == "" ]
		then
			__TIMER_FIRST_START_TIME[$timer]=$(date +%s)
			__TIMER_TOTAL_PAUSE_TIME[$timer]=0
			__TIMER_LAST_START_TIME[$timer]=1
		fi

		# Were we paused? ##################################################################################################################
		is_timer_running "$timer"
		local is_running=$__OUTPUT
		
		if [ $is_running -eq 0 ]
		then
			local pause_time=${__TIMER_LAST_PAUSE_TIME[timer]}
			local now=$(date +%s)
			local seconds_paused=$((now - pause_time))

			if [ -z "${__TIMER_TOTAL_PAUSE_TIME[timer]}" ]
			then
				__TIMER_TOTAL_PAUSE_TIME[$timer]=0
			fi

			__TIMER_TOTAL_PAUSE_TIME[$timer]=$((__TIMER_TOTAL_PAUSE_TIME[timer] + seconds_paused))
		fi

		# Reset timer last start time ######################################################################################################
		__TIMER_LAST_START_TIME[$timer]=$(date +%s)
	}

############################################################################################################################################
############################################################################################################################################
# 											     					READ 																   #
############################################################################################################################################
############################################################################################################################################

	########################################################################################################################################
	# 
	# Outputs the given timer's elapsed time as a string
	#
	# Input
	#   $1 = (OPTIONAL, DEFAULT=main) The name of the timer for which to get the display time
	#
	# Output
	#   $__OUTPUT = The display for the given timer
	#
	########################################################################################################################################
	get_timer_display()
	{
		get_timer_seconds "$1"; local delta="$__OUTPUT"
		__OUTPUT="$(date +%M:%S --date @$delta)"
	}

	########################################################################################################################################
	# 
	# Outputs the timer's current elapsed seconds
	# 
	# Input
	# 	$1 = (OPTIONAL., DEFAULT=main) The name of the timer to read
	#
	# Output
	# 	$__OUTPUT = the number of seconds elapsed on the timer
	#
	# Expects
	#   $__TIMER_TOTAL_PAUSE_TIME = an array of the seconds spent paused for a timer, indexed by name
	#
	########################################################################################################################################
	get_timer_seconds()
	{
		local timer="main"; if [ "$1" != "" ]; then timer="$1"; fi
		local now=$(date +%s)
		local start_time=${__TIMER_FIRST_START_TIME[timer]}

		get_total_time_paused "$timer"; local paused_seconds="$__OUTPUT"
		__OUTPUT=$((now - start_time - paused_seconds))
	}

	########################################################################################################################################
	# 
	# Gets the actual amount of time paused right now, taking into consideration the fact that 
	# __TIMER_TOTAL_PAUSE_TIME is out-of-date while a timer is still paused.
	# 
	# Input
	# 	$1 = (OPTIONAL, DEFAULT=main) The name of the timer to start (used when reading or pausing)
	# 
	# Output
	#	$__OUTPUT = The total seconds that the given timer has been paused as of right now
	#
	# Sets
	# 	$__TIMER_LAST_PAUSE_TIME = an array of the UTC seconds for a timer's last pause, indexd by name
	#   $__TIMER_TOTAL_PAUSE_TIME = an array of the seconds spent paused for a timer, indexed by name
	#
	########################################################################################################################################
	get_total_time_paused()
	{
		local timer="main"; if [ "$1" != "" ]; then timer="$1"; fi

		is_timer_running "$timer"
		local is_running=$__OUTPUT
		
		if [ $is_running -eq 0 ]
		then
				local last_pause_time=${__TIMER_LAST_PAUSE_TIME[timer]}
				local now=$(date +%s)
			local seconds_for_current_pause=$((now - last_pause_time))

			local total_pause_seconds_before_current_pause=${__TIMER_TOTAL_PAUSE_TIME[timer]}			

			__OUTPUT=$((total_pause_seconds_before_current_pause + seconds_for_current_pause))

		else 
			__OUTPUT=${__TIMER_TOTAL_PAUSE_TIME[timer]}
		fi
	}

	########################################################################################################################################
	# 
	# Outputs whether the given timer is running
	# 
	# Input
	# 	$1 = (OPTIONAL, DEFAULT=main) The name of the timer to check
	#
	# Output
	#	$__OUTPUT = 1 if the timer is running, 0 if it is not
	# Expects
	#	$__TIMER_LAST_START_TIME = an array of UTC seconds when each timer last started, indexed by name
	# 	$__TIMER_LAST_PAUSE_TIME = an array of the UTC seconds for a timer's last pause, indexd by name
	#
	#
	########################################################################################################################################
	is_timer_running()
	{
		local timer="main"; if [ "$1" != "" ]; then timer="$1"; fi

		# If we've paused and started, check which happened most recently ##################################################################
		if [ "${__TIMER_LAST_PAUSE_TIME[timer]}" != "" ] && [ "${__TIMER_LAST_START_TIME[timer]}" != "" ]
		then
			local last_pause_time=${__TIMER_LAST_PAUSE_TIME[timer]}
			local last_start_time=${__TIMER_LAST_START_TIME[timer]}

			if [ "$last_pause_time" -gt "$last_start_time" ]
			then
				__OUTPUT=0
			else
				__OUTPUT=1
			fi
		# If we've never paused, but we've started, then yes it's running
		elif [ "${__TIMER_LAST_PAUSE_TIME[timer]}" == "" ] && [ "${__TIMER_LAST_START_TIME[timer]}" != "" ]
		then
			__OUTPUT=1
		else
			__OUTPUT=0
		fi	
	}

	########################################################################################################################################
	# 
	# Begins displaying and updating a timer in real time (this is a blocking function). Any keystroke
	# pauses the timer.
	#
	# Input
	# 	$1 = The duration of the timer in MINUTE (0 indicates no maximum duration)
	#	$2 = (OPTIONAL) A callback function called when the timer is paused. 
	#	  If not provided, timer stops instead of pausing on keystroke. If provided, the function must
	#	  set $__OUTPUT to 1 if it wishes the timer to continue and must expect two inputs: $1 being
	#	  the name of the timer, $2 being the number of seconds on the timer at the moment of pause
	# 	$3 = (OPTIONAL, DEFAULT=main) The name of the timer to use
	#
	# Output
	#   $__OUTPUT = 1 if the timer exited due to reaching duration, 0 otherwise
	#
	########################################################################################################################################
	display_timer()
	{
		local duration_minutes="$1"
		local duration_seconds=$(( 60 * duration_minutes ))
		local pause_callback="$2"
		local timer="main"; if [ "$3" != "" ]; then timer="$3"; fi

		start_timer "$timer"
		local is_running=1

		start_capturing_keyboard

		# Timer Loop #######################################################################################################################
		while [ $is_running -eq 1 ]
		do
			# Display time (and progress bar if we have a duration) ########################################################################
			get_timer_seconds "$timer"; local delta_seconds="$__OUTPUT"
			get_timer_display "$timer"; local display_time="$__OUTPUT"
			local progress_bar=""

			if [ $duration_minutes -gt 0 ]
			then
				get_progress_bar_display $delta_seconds $duration_seconds
				progress_bar=$__OUTPUT
			fi

			echo -ne "$progress_bar $display_time / $duration_minutes:00\r"

			# Check for pause ##############################################################################################################
			local keypress="`cat -v`"
			if [ "$keypress" != "" ]
			then
				stop_capturing_keyboard
				pause_timer "$timer"

				# Handle the pause #########################################################################################################
				if [ "$pause_callback" != "" ]
				then
					$pause_callback "$timer" "$delta_seconds"

					if [ $__OUTPUT -eq 1 ]
					then
						start_timer "$timer"
					fi
				fi

				start_capturing_keyboard
			fi

			# Handle duration complete #####################################################################################################
			get_timer_seconds "$timer"; local elapsed=$__OUTPUT

			if [ $duration_minutes -gt 0 ] && [ $delta_seconds -gt $duration_seconds ]
			then
				pause_timer "$timer"
			fi

			is_timer_running "$timer"
			is_running=$__OUTPUT
		done

		stop_capturing_keyboard

		get_timer_seconds "$timer"; local elapsed=$__OUTPUT
		elapsed=$((elapsed++))
		if [ $duration_minutes -gt 0 ] && [ $elapsed -gt $duration_minutes ]
		then
			__OUTPUT=1
		else
			__OUTPUT=0
		fi
	}

############################################################################################################################################
############################################################################################################################################
# 											     				  UPDATE																   #
############################################################################################################################################
############################################################################################################################################

	########################################################################################################################################
	# 
	# Resets the given timer to 0 seconds elapsed and starts it
	# 
	# Input
	# 	$1 = (OPTIONAL, DEFAULT=main) The name of the timer to start (used when reading or pausing)
	#
	# Sets
	#   $__TIMER_FIRST_START_TIME = an array of the UTC seconds when each timer started, indexd by name
	#	$__TIMER_LAST_START_TIME = an array of UTC seconds when each timer last started, indexd by name
	# 	$__TIMER_LAST_PAUSE_TIME = an array of the UTC seconds for a timer's last pause, indexd by name
	#   $__TIMER_TOTAL_PAUSE_TIME = an array of the seconds spent paused for a timer, indexed by name
	#
	########################################################################################################################################
	restart_timer()
	{
		reset_timer "$1"
		start_timer "$1"
	}

	########################################################################################################################################
	# 
	# Erases the value on the timer so that is ready to be restarted from 0. Does not start the timer.
	# 
	# Input
	# 	$1 = (OPTIONAL, DEFAULT=main) The name of the timer to start (used when reading or pausing)
	#
	# Sets
	#   $__TIMER_FIRST_START_TIME = an array of the UTC seconds when each timer started, indexd by name
	#	$__TIMER_LAST_START_TIME = an array of UTC seconds when each timer last started, indexd by name
	# 	$__TIMER_LAST_PAUSE_TIME = an array of the UTC seconds for a timer's last pause, indexd by name
	#   $__TIMER_TOTAL_PAUSE_TIME = an array of the seconds spent paused for a timer, indexed by name
	#
	########################################################################################################################################
	reset_timer()
	{
		local timer="main"; if [ "$1" != "" ]; then timer="$1"; fi
		__TIMER_FIRST_START_TIME[$timer]=""
		__TIMER_LAST_PAUSE_TIME[$timer]=""
		__TIMER_TOTAL_PAUSE_TIME[$timer]=0
		__TIMER_LAST_START_TIME[$timer]=1
	}

	########################################################################################################################################
	# 
	# Pauses the given timer 
	#
	# Input
	# 	$1 = (OPTIONAL, DEFAULT=main) The name of the timer to pause  
	# 
	# Sets
	#   $__TIMER_LAST_PAUSE_TIME = an array with utc pause second times indexed by timer name
	#
	########################################################################################################################################
	pause_timer() 
	{
		local timer="main"; if [ "$1" != "" ]; then timer="$1"; fi
		__TIMER_LAST_PAUSE_TIME[$timer]=$(date +%s)
	}
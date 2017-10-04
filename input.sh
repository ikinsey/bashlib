#!/bin/bash

	########################################################################################################################################
	#
	# Begins capturing keyboard. 
	# 
	# NOTE: This will make read commands non-blocking until stopped
	# 
	# To use, create a loop which checks for keyboard input every iteration.
	# Keyboard input is checked like so (but will only work while capturing is on): 
	#
	# local keypress="`cat -v`"
	# if [ "$keypress" != "" ]
	# then
	#	# Whatever you want to do when a key is pressed, probably exit your loop.
	# fi
	#
	########################################################################################################################################
	start_capturing_keyboard() {
		stty -echo -icanon -icrnl time 0 min 0
	}

	# Stops capturing keyboard.
	stop_capturing_keyboard() {
		stty sane
	}
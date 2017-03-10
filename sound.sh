#!/bin/bash

###################################################################################################
#
# Makes the given tone for the given duration
#
# Inputs
# 	$1 = Sound Frequency (Hz) 
# 	$2 = Duration (ms)
#
###################################################################################################
sound() {
  ( \speaker-test --frequency $1 --test sine > /dev/null )& 
  pid=$!
  disown
  \sleep 0.${2}s
  \kill -9 $pid
}

positive_sound() {
	sound 800 200
	sound 1000 200
	sound 1200 500
}

negative_sound() {
	sound 1200 200
	sound 1000 200
	sound 800 500
}
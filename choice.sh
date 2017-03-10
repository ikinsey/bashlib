#!/bin/bash

###################################################################################################
#
# Displays the given choices by their index
#
# Input
#   $1 = Associateive array declaration e.g., "$(declare -p VAR_FOR_MY_ARRAY)"
#
###################################################################################################
display_numbered_choices() 
{
	local -n options_by_id=$1

	for i in "${!options_by_id[@]}"
	do
		echo "$i) ${options_by_id[i]}"
	done

	echo $'\n'
}

# Input
#  $1 = An array of options indexed by number to choose
# Output
# 	$__OUTPUT = the chosen index from the input array
display_numbered_choices_and_choose_one() 
{
	display_numbered_choices "$@"
	echo "Enter a number: "
	read __OUTPUT
	echo $'\n'
}

# Input
#  $1@ = An array of options indexed by number to choose
# Output
# 	$__OUTPUT = the chosen indicies from the input array (separated by spaces)
display_numbered_choices_and_choose_some() 
{
	display_numbered_choices "$@"
	echo "Enter one or more numbers (separated by spaces): "
	read __OUTPUT
	echo $'\n'
}
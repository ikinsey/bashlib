#!/bin/bash
	
	. ./display.sh

	########################################################################################################################################
	#
	# Displays the given choices by their index
	#
	# Input
	#   $1 = Associateive array declaration e.g., "$(declare -p VAR_FOR_MY_ARRAY)"
	#	$2 = (OPTIONAL) A space-delimited string listing the order in which to display the ids
	#	$3 = (OPTIONAL) An associative array of display ids indexed by id. Will show the entry for an id in this array over the id itself
	#
	########################################################################################################################################
	display_numbered_choices() 
	{
		local -n options_by_id=$1
		local order_string="$2"
		local -n display_ids=$3
		
		if [ "$order_string" == "" ]
		then
			for i in ${options_by_id[@]}
			do 
				_ind="$i"; if [ "${display_ids[$i]}" != "" ]; then _ind="${display_ids[$i]}"; fi 
				output "$_ind) ${options_by_id[$i]}"
			done
		else
			local order_list=($order_string)
			for i in ${order_list[@]} 
			do 
				_ind="$i"; if [ "${display_ids[$i]}" != "" ]; then _ind="${display_ids[$i]}"; fi 
				output "$_ind) ${options_by_id[$i]}"; 
			done
		fi
		

		output_new_lines 2
	}

	########################################################################################################################################
	#
	# Input
	#  $1 = An array of options indexed by number to choose
	#  $2 = (OPTIONAL) A space-delimited string listing the order in which to display the ids
	#  $3 = (OPTIONAL) An associative array of display ids indexed by id. Will show the entry for an id in this array over the id itself
	# Output
	# 	$__OUTPUT = the chosen index from the input array
	#
	########################################################################################################################################
	display_numbered_choices_and_choose_one() 
	{
		display_numbered_choices $1 "$2" $3
		output "Enter a number: "
		read __OUTPUT
		output_new_lines 2
	}

	########################################################################################################################################
	#
	# Input
	#  $1@ = An array of options indexed by number to choose
	# Output
	# 	$__OUTPUT = the chosen indicies from the input array (separated by spaces)
	#
	########################################################################################################################################
	display_numbered_choices_and_choose_some() 
	{
		display_numbered_choices "$@"
		output "Enter one or more numbers (separated by spaces): "
		read __OUTPUT
		output_new_lines 2
	}
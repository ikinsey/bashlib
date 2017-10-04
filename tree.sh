#!/bin/bash

	. ./bashlib/output.sh

	########################################################################################################################################
	#
	# Displays a tree based on the given nesting information.
	#
	# Input
	#  $1 = An array indexed by parent id which contains a space-separated string of child ids
	#  $2 = An array indexed by child id, each of which points to that child's parent
	#  $3 = An array indexed by node id, each of which points to that node's description
	#  $4 = OPTIONAL, DEFAULT=0) 1 or 0, do you want to display the id index on the left side of the tree?
	#  $5 = OPTIONAL) An array indexed by node id, each of which points to that node's text color
	#  $6 = OPTIONAL, DEFAULT=0) The node from which to begin displaying
	#
	########################################################################################################################################
	display_tree() 
	{
		local -n tree_children=$1
		local -n tree_parents=$2
		local -n tree_descriptions=$3

		local show_index=0
		if [ "$4" != "" ]
		then
			show_index=$4
		fi
		
		if [ "$5" != "" ]
		then
			local -n node_colors=$5
		else
			local node_colors=()
		fi

		local node="0"
		if [ "$6" != "" ]
		then
			node="$6"
		fi

		if [ "$node" == "0" ]
		then
			if [ $show_index -eq 1 ]
			then
				local pre="0) "
			fi
			output "Root" "$pre"
		fi

		begin_temporary_indent; local temp_indent_token="$__OUTPUT"

		# Do children exist for this node? #################################################################################################
		if [ ${tree_children[$node]+has} ]
		then
			local children="${tree_children[$node]}"
			local childrenarr=($children)

			add_output_indents 2

			# If so, give 'em a loop #######################################################################################################
			for child in "${childrenarr[@]}"
			do
				# Calculate indents ########################################################################################################
				local n="$child"
				while [ ${tree_parents[$n]+has} ]
				do
					n=${tree_parents[$n]}
					indents="$indents$indent_string";
				done

				if [ $show_index -eq 1 ]
				then
					local pre="$child) "
				fi

				local text="${tree_descriptions[$child]}"

				if [ "${node_colors[$child]}" != "" ]
				then
					local COLOR="${node_colors[$child]}"
					text="${COLOR}$text${END_COLOR}"
				fi

				# And display each child + its children ####################################################################################
				output "$text" "$pre"
				display_tree $1 $2 $3 $4 "$5" "$child"
			done

			subtract_output_indents 2
		fi

		# As an unlisted last argument, recursive calls wil provide some value here that is unprovided in the original call ################
		end_temporary_indent "$temp_indent_token"
	}

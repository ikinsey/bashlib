#!/bin/bash

###################################################################################################
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
###################################################################################################
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

	local node=0
	if [ "$6" != "" ]
	then
		node=$6
	fi

	if [ $node -eq 0 ]
	then
		if [ $show_index -eq 1 ]
		then
			local pre="0) "
		fi
		echo "${pre}Root"
	fi

	# Do children exist for this node? ############################################################
	if [ ${tree_children[node]+has} ]
	then
		local children="${tree_children[node]}"
		local childrenarr=($children)
		local indent_string="  "

		if [ $show_index -eq 1 ]
		then
			indent_string=". "
		fi

		# If so, give 'em a loop ##################################################################
		for child in "${childrenarr[@]}"
		do
			# Calculate indents ###################################################################
			local indents=""
			local n=$child
			while [ ${tree_parents[n]+has} ]
			do
				n=${tree_parents[n]}
				indents="$indents$indent_string";
			done

			if [ $show_index -eq 1 ]
			then
				local pre="$child) "
			fi

			local text="${tree_descriptions[child]}"

			if [ "${node_colors[child]}" != "" ]
			then
				local COLOR="${node_colors[child]}"
				text="${COLOR}$text${END_COLOR}"
			fi

			# And display each child + its children ###############################################
			echo -e "$pre$indents$text"
			display_tree $1 $2 $3 $4 "$5" "$child"
		done
	fi
}





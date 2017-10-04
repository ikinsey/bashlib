#!/bin/bash

	########################################################################################################################################
	# NOTE: This file makes mysql queries by generating a file in its directory, it needs permissions
	########################################################################################################################################

	########################################################################################################################################
	# 
	# Queries mysql with the given information. Setting __EXIT_LOOP to 1 during the callback function will cause the results loop to break
	#
	# Input
	#	$1 = database
	#   $2 = user
	#	$3 = password
	# 	$4 = query
	#	$5 = row callback (OPTIONAL)
	#	  Called one time for each row the query returns and is passed an array of that row's values
	#   $6 = host (OPTIONAL, DEFAULT=localhost)
	#
	########################################################################################################################################
	db() 
	{
		local database=$1
		local user=$2
		local password=$3
		local query=$4
		local callback=$5

		local host="localhost"

		if [ "$6" != "" ]
		then
			host="$6"
		fi


		local credentialsFile=mysql-credentials.cnf
		echo "[client]" > $credentialsFile
		echo "user=$user" >> $credentialsFile
		echo "password=$password" >> $credentialsFile
		echo "host=$host" >> $credentialsFile
		
		local res=$(mysql --defaults-extra-file=$credentialsFile $database -se "$query")
		
		rm $credentialsFile

		IFS=$'\n' read -rd '' -a res <<< "$res"

		NOTES=()

		# Handle the query results #########################################################################################################
		for element in "${res[@]}"
		do
			# Use '~~~~~' as a place holder for empty string values so array conversion doesn't shift columns
	 		if [ "${element:0:1}" == '	' ]; then element="~~~~~$element"; fi
			element=${element//		/	~~~~~	} 

			# Convert the string row to an array
			IFS='	' read -r -a deets <<< "$element"

			# Convert any '~~~~~' elements back to empty strings in the array
			for i in "${!deets[@]}"; do if [ "${deets[$i]}" == "~~~~~" ]; then deets[$i]=""; fi; done

			# Sned the row values to the callback function if we have one
			if [ "$callback" != "" ]; then $callback "${deets[@]}"; fi

			# If Exit looping was enabled in this query, search for the variable each row to see if the callback modified it 
			if [ "$__EXIT_LOOP" == "1" ]
			then
				__EXIT_LOOP="0"
				break
			fi
		done
	}
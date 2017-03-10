#!/bin/bash

###################################################################################################
# NOTE: This file makes mysql queries by generating a file in its directory, it needs permissions
###################################################################################################

###################################################################################################
# 
# Queries mysql with the given information
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
###################################################################################################
db() {
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

	for element in "${res[@]}"
	do
		IFS='	' read -r -a deets <<< "$element"


		if [ "$callback" != "" ]
		then
			$callback "${deets[@]}"
		fi
	done
}
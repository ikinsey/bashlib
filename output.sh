
############################################################################################################################################
############################################################################################################################################
# 											     				  SETUP																   	   #
############################################################################################################################################
############################################################################################################################################

	__INDENTS=0
	__INDENT_CHARACTER=" "

	__TEMPORARY_INDENT_TOKEN=""
	__OLD_INDENT=""
	__OLD_INDENT=""

	declare -A __REPEATED_CHAR_CACHE

############################################################################################################################################
############################################################################################################################################
# 											     	    	    FUNCTIONS															       #
############################################################################################################################################
############################################################################################################################################	

	output()
	{
		local text="$1"
		local preindent_prefix="$2"
		get_indents; local indents="$__OUTPUT"

		echo -e "$preindent_prefix$indents$text"
	}

	############################################################################################################################################
	#
	# Begins remembering indent changes so they can be removed when it is ended (for example, via end_temporary_indent())
	#
	# Produces a random, temporary indent token. These temporary indent tokens only work if they are the original first, un-ended token, so that
	# nested temporaries can simply rely on the highest parent to clean up.
	# 
	# Output
	#   $__OUTPUT = The token to pass to end_temporary_indent() to revert this indent group
	#
	############################################################################################################################################
	begin_temporary_indent()
	{
		local token="$RANDOM"
		if [ "$__TEMPORARY_INDENT_TOKEN" != "" ]
		then
			__OLD_INDENT=$__INDENTS
			__OLD_INDENT_CHARACTER=$__INDENT_CHARACTER
			__TEMPORARY_INDENT_TOKEN="$token"
		fi
		__OUTPUT="$token"
	}

	end_temporary_indent()
	{
		local token_to_end="$1"
		if [ "$__TEMPORARY_INDENT_TOKEN" != "" ] && [ "$token_to_end" == "$__TEMPORARY_INDENT_TOKEN" ]
		then
			__INDENTS=$__OLD_INDENT
			__INDENT_CHARACTER=$__OLD_INDENT_CHARACTER
			__OLD_INDENT=""
			__OLD_INDENT_CHARACTER=""
			__TEMPORARY_INDENT_TOKEN=""
		fi
	}

	get_indents()
	{
		get_repeated_character "$__INDENT_CHARACTER" $__INDENTS
	}

	set_indents()
	{
		__INDENTS=$1
	}

	get_indent_char()
	{
		__OUTPUT=__INDENT_CHARACTER
	}
	
	set_indent_character()
	{
		__INDENT_CHARACTER="$1"
	}

	add_output_indents()
	{
		set_indents $(( __INDENTS + $1 ))
	}

	subtract_output_indents()
	{
		set_indents $(( __INDENTS - $1 ))
	}

	output_header()
	{
		local text="$1"
		local line_length="$2"; line_length=$((line_length - __INDENTS)) # incorporate indents
		local header_level="$3"; if [ "$header_level" == "" ]; then header_level=0; fi
		local preindent_prefix="$4"

		local text_length=${#text}

		# Header
		if [ $header_level -eq 0 ]
		then
			output "$text" "$preindent_prefix"

		# -- Header ------------------------------------------------------------------------------------------------------------------------
		elif  [ $header_level -eq 1 ]
		then
			get_repeated_character '-' $((line_length - text_length - 4))
			output "-- $text $__OUTPUT"  "$preindent_prefix"

		# __ Header ________________________________________________________________________________________________________________________
		elif  [ $header_level -eq 2 ]
		then
			get_repeated_character '_' $((line_length - text_length - 4))
			output "__ $text $__OUTPUT"  "$preindent_prefix"

		# == Header ========================================================================================================================
		elif  [ $header_level -eq 3 ]
		then
			get_repeated_character '=' $((line_length - text_length - 4))
			output "== $text $__OUTPUT"  "$preindent_prefix"

		# ==================================================================================================================================
		#    Header
		# ==================================================================================================================================
		elif  [ $header_level -eq 4 ]
		then
			get_repeated_character '=' $line_length
			local decoration="$__OUTPUT"
			output "$decoration"
			output "   $text" "$preindent_prefix"
			output "$decoration"

		# ==================================================================================================================================
		# ==================================================================================================================================
		#    Header
		# ==================================================================================================================================
		# ==================================================================================================================================
		elif  [ $header_level -eq 5 ]
		then
			get_repeated_character '=' $line_length
			local decoration="$__OUTPUT"
			output "$decoration"
			output "$decoration"
			output "   $text" "$preindent_prefix"
			output "$decoration"
			output "$decoration"
		else
			echo 'hi'
		fi
	}

	get_repeated_character()
	{
		local character="$1"
		local repeat_times=$2

		# Optimizaion: check cache
		local cache="${__REPEATED_CHAR_CACHE[$character$repeat_times]}"

		if [ "$cache" == "" ]
		then
			local outs=""		
			local count=0; while [ $count -lt $repeat_times ]; do outs="$outs$character"; ((count++)); done
			__OUTPUT="$outs"
			__REPEATED_CHAR_CACHE["$character$repeat_times"]="$__OUTPUT" # Update cache for this char
		else
			__OUTPUT="$cache"
		fi
	}

	output_bullet()
	{
		output "-- $1"
	}

	output_new_lines()
	{
		local number_of_new_lines=$1
		local count=0
		while [ $count -lt $number_of_new_lines ]; do echo ''; ((count++)); done
	}
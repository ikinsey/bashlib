#!/bin/bash

	
	basic_escape()
	{
		printf -v __OUTPUT "%q" "$1"
	}
#!/bin/bash

counter=0

while true; do
	git pull > /dev/null
	ruby src/main/ruby/monitor.rb
	let counter=counter+1
	if [[ $counter -gt 80 ]]; then
		echo
		counter=0
	fi
	echo -n '.'
	sleep 5
done

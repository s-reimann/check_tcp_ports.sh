#!/usr/bin/env bash
#
#	+-----------------------------------------------------------------------+
#	| description:	simple CMK script to check TCP port availability	|
#	| date:		September 30th, 2020					|
#	| author:	Sascha Reimann						|
#	| git:		https://github.com/s-reimann/check_tcp_ports.sh		|
#	+-----------------------------------------------------------------------+

state_ok="0"
state_wr="1"
state_cr="2"
state_uk="3"
config="/etc/check_mk/check_tcp_ports.cfg"

# check if nc binary exists
if ! [ -x "$(command -v nc)" ]; then echo "${state_uk} $0 - nc binary does not exist!"; fi

# check if config file exists and source content
if [ -f ${config} ]; then
	source ${config}
else
	echo "${state_uk} $0 - config file missing!"
fi

while :; do
	((count++))
	eval service="\$service_${count}"
	eval host="\$host_${count}"
	eval port="\$port_${count}"
	eval timeout="\$timeout_${count}"
	# loop until there is now more tcp ports to check
	if ! [ -z ${service} ]; then
		if nc -zw ${timeout} ${host} ${port}; then
			echo "${state_ok} ${service} - ${host}:${port} open"
		else
			echo "${state_cr} ${service} - ${host}:${port} unreachable! (Timeout=${timeout} seconds)"
		fi
	else
		break
	fi
done

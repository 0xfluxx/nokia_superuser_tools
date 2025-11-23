#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear_color='\033[0m'
query_base="dGl0bGU9IkdQT04gSG9tZSBHYXRld2F5IiAmJiAialF1ZXJ5IDEuMTIiICYmIHBvcnQ9IjQ0MyIK" #title="GPON Home Gateway" && "jQuery 1.12" && port="443"
API_KEY="$(cat $HOME/.zoomeye_api_key)"
if [ ! -f $HOME/.zoomeye_api_key ]; then
	printf "${red}You need to register a free account with Zoomeye to use this script.${clear_color}\n"
	echo "https://www.zoomeye.ai/cas/en-US/ui/register"
	echo "Then copy your API key from https://www.zoomeye.ai/profile/info"
	printf "Write it in a text document named ${green}.zoomeye_api_key${clear_color}\n"
	printf "in your home directory:" 	
	echo '(ex: echo "fCc692-618abDd-This-Is-Not-A-Real-Key-722b" > ~/.zoomeye_api_key)'
	exit 1
fi
if command -v base64 >/dev/null 2>&1; then
	printf "${green}base64 installed${clear_color}\n"
else
	printf "${red}base64 utility not found!${clear_color}\n"
	exit 1
fi
set_vars() {
	variable="$2"
	value="$3"
}
fl_err() {
	printf "${red}Error: variable/value not found${clear_color}\n"
	exit 1
}
shift $((OPTIND-1))
while getopts ":hpm" opt; do
	case $opt in
		h)
			echo "This script can be run with no arguments to run a default search,"
			echo "with -p (plus) to add additional search terms,"
			echo "or with -m (minus) to exclude results matching a pattern."
			printf "nokia-zoomeye -[pm] [variable] [value]\n"
			printf "ex: to ${red}exclude${clear_color} results from Brazil, use ${green}nokia-zoomeye -m country Brazil${clear_color}\n"
			printf "to show ${red}only${clear_color} results from Morocco, use ${green}nokia-zoomeye -p country Morocco${clear_color}\n"
			exit 1
			;;
		p)
			mod='='
			if [[ -z "$2" ]] || [[ -z "$3" ]]; then
				fl_err
			else
				set_var
			fi
			;;
		m)
			mod='!='
			if [[ -z "$2" ]] || [[ -z "$3" ]]; then
				fl_err
			else
				set_var
			fi
			;;
		\?)	
			printf "${red}Unknown option${clear_color}\n"
			exit 1
			;;
	esac
done
if [ ! -d "$HOME/.tmp" ]; then
	mkdir $HOME/.tmp
fi
echo "Checking if Zoomeye is up..."
curl -m 15 -s https://www.zoomeye.ai > /dev/null 2>&1
zoomeye_status="$?"
if [ "$zoomeye_status" != 0 ]; then
	echo "It appears that Zoomeye's servers are down..."
	echo "Pinging IP address 154.93.109.29..."
	ping -w 10 154.93.109.29 > /dev/null 2>&1
	ping_status="$?"
	if [ "$ping_status" != 0 ]; then
		echo "Got no response."
		exit "$ping_status"
	else
		echo "Ping worked - check your DNS settings"
		exit "$zoomeye_status"
	fi
fi
#mod only set when adding parameters, if unset, perform standard search
if [ -z "$mod" ]; then
	echo 'Searching Zoomeye for:'
	printf "${red}Title: GPON Home Gateway${clear_color}\n"
	printf "${yellow}Port: 443${clear_color}\n"
	printf "${green}jQuery 1.12${clear_color}\n"
	query="$query_base"
else
	q64_base="$(printf $query_base | base64 -d)"
	q64="$(printf $q64_base) && $variable $mod $value"
	query="$(printf $q64 | base64)"
	echo "Searching Zoomeye with custom parameters $q64"
fi
curl_request() {
curl -X POST 'https://api.zoomeye.ai/v2/search' \
    -H "API-KEY: $API_KEY" \
    -H 'content-type: application/json' \
	-d '{
		"qbase64": '"$query"',
		"page": 1
		"pagesize": 100000
	}'
}
curl_request | grep -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -u | tee $HOME/.tmp/iplist
if ! command -v ipinfo 2>&1 >/dev/null; then
	if ! command -v geoiplookup 2>&1 >/dev/null; then
		echo "No geoip tool found"
	else
		geoip="geoiplookup"
	fi
else
	geoip="ipinfo"
fi
if [[ ! -z $(cat $HOME/.tmp/iplist) ]]; then
	printf "${green}IPs matching query terms:${clear_color}\n"
	cat $HOME/.tmp/iplist
	printf "${yellow}Finding geolocations...${clear_color}\n"
	if [ "$geoip" == "ipinfo" ]; then
		cat $HOME/.tmp/iplist | tr '\n' ' ' > $HOME/.tmp/iplist-space
		ips_to_search="$(cat $HOME/.tmp/iplist-space)"
		for i in $ips_to_search; do
			ipinfo $i | grep -v "Core" | grep -v "Anycast" | head -n 5
			printf "\n"
		done
		rm $HOME/.tmp/iplist-space
	else
		cat $HOME/.tmp/iplist | xargs -n 1 $geoip
	fi
rm $HOME/.tmp/iplist
printf "${clear_color}"
fi

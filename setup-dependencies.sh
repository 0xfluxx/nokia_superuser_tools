#!/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear_color='\033[0m'
if [ "$EUID" -ne 0 ]; then
	printf "${red}Run it as root${clear_color}\n"
	exit 1
fi
install_from_apt() {
	printf "${green}Debian-based distro detected${clear_color}\n"
	apt-get update && apt upgrade -y
	apt-get install nmap python3 python3-pycryptodome python3-cryptography python3-pip
	pip install crypto --break-system-packages --root-user-action
}
install_from_pacman() {
	printf "${green}Arch-based distro detected${clear_color}\n"
	pacman -Syu
	pacman -S nmap python python-cryptography python-pycryptodome python-pip
}
install_from_apk() {
	printf "${green}Alpine-based distro detected${clear_color}\n"
	apk update
	apk upgrade
	apk add nmap python3 py3-pycryptodomex py3-pycryptodome py3-cryptography py3-pip
}
install_from_brew() {
	printf "${green}Homebrew package manager for MacOS detected${clear_color}\n"
	brew install --formula nmap
	brew install --formula python
	pip install pycryptodome pycryptodomex crypto
}
install_from_macports() {
	printf "${green}Macports package manager for MacOS detected${clear_color}\n"
	port install nmap python314 py314-pycryptodomex py314-pycryptodome py314-cryptography
}
ipinfo_oui_install() {
	if [[ "$(uname -o)" == "Linux" ]] || [[ "$(uname -o)" == "GNU/Linux" ]]; then
		if [[ "$(uname -m)" == "aarch64" ]]; then
			ipinfourl="https://github.com/ipinfo/cli/releases/download/ipinfo-3.3.1/ipinfo_3.3.1_linux_arm64.tar.gz"
			ouiurl="https://github.com/thatmattlove/oui/releases/download/v2.0.6/oui_2.0.6_linux_arm64.tar.gz"
		elif [[ "$(uname -m)" == "x86_64" ]]; then
			ipinfourl="https://github.com/ipinfo/cli/releases/download/ipinfo-3.3.1/ipinfo_3.3.1_linux_amd64.tar.gz"
			ouiurl="https://github.com/thatmattlove/oui/releases/download/v2.0.6/oui_2.0.6_linux_amd64.tar.gz"
		elif [[ "$(uname -m)" == "arm"* ]]; then
			ipinfourl="https://github.com/ipinfo/cli/releases/download/ipinfo-3.3.1/ipinfo_3.3.1_linux_arm.tar.gz"
			ouiurl="https://github.com/thatmattlove/oui/releases/download/v2.0.6/oui_2.0.6_linux_armv6.tar.gz"
		else
			printf "${red}Linux detected, but architecture unknown or unsupported${clear_color}\n"
		fi
	elif [[ "$(uname -o)" == "Darwin" ]]; then
		if [[ "$(uname -m)" == "x86_64" ]]; then
			ipinfourl="https://github.com/ipinfo/cli/releases/download/ipinfo-3.3.1/ipinfo_3.3.1_darwin_amd64.tar.gz"
			ouiurl="https://github.com/thatmattlove/oui/releases/download/v2.0.6/oui_2.0.6_darwin_amd64.tar.gz"
		elif [[ "$(uname -m)" == "arm64" ]]; then
			ipinfourl="https://github.com/ipinfo/cli/releases/download/ipinfo-3.3.1/ipinfo_3.3.1_darwin_arm64.tar.gz"
			ouiurl="https://github.com/thatmattlove/oui/releases/download/v2.0.6/oui_2.0.6_darwin_arm64.tar.gz"
		else
			printf "${red}MacOS detected, but architecture unknown or unsupported${clear_color}\n"
		fi
	else
		printf "${red}Unsupported operating system${clear_color} -- figure it out yourself, bud\n"
	fi
	urls="$ipinfourl $ouiurl"
	for u in $urls; do
		if [ ! -z "$u" ]; then
			if command -v curl > /dev/null 2>&1; then
				curl -fsSL $u | tar xzvf - -C "/usr/bin"
			elif command -v wget > /dev/null 2>&1; then
				wget -qO- $u | tar xzvf - -C "/usr/bin"
			else
				printf "${red}Neither curl nor wget found${clear_color} -- please download and extract $u manually and put it on your PATH\n"
			fi
		fi
	done
}
check_os() {
	if [ -f "/etc/debian_version" ]; then
        	install_from_apt
	elif [ -f "/etc/alpine-release" ]; then
        	install_from_apk
	elif [ -f "/etc/arch-release" ]; then
        	install_from_pacman
	elif command -v brew > /dev/null 2>&1; then
	        install_from_brew
	elif command -v port > /dev/null 2>&1; then
	        install_from_macports
	else
	        printf "${red}Unsupported OS/distro${clear_color}; you will have to manually install dependencies\n"
	fi
}
confirm() {
    printf "${green}yes${clear_color}\n"
}
deny() {
    printf "${red}no${clear_color}\n" 
}
check_local_bin() {
if ! ( echo $PATH | grep .local/bin >/dev/null ); then
        printf "Directory $HOME/.local/bin found, ${red}but it isn't on your PATH${clear_color}\n"
        printf "To change this, run"
	printf 'export PATH=$HOME/.local/bin:$PATH'
	printf "\n"
else
        echo "Directory $HOME/.local/bin found and is along PATH"
fi
}
if [ -d $HOME/.local/bin ]; then
	check_local_bin
else
	echo "Creating directory for local executables at $HOME/.local/bin"
	mkdir -p $HOME/.local/bin
	check_local_bin
fi
dependencies="nmap python3 ipinfo oui urlencode"
for d in $dependencies; do
	printf "Checking if $d is installed... "
	if command -v $d > /dev/null 2>&1; then
		confirm
	else
		deny
		deny_ran="1"
	fi
done
if python3 -c "import Crypto" > /dev/null 2>&1; then
	printf "python ${green}Crypto${clear_color} library already installed!\n"
else
	deny_ran="1"
fi
python_crypto() {
	if python3 -c "import Crypto" > /dev/null 2>&1; then
		printf "python ${green}Crypto${clear_color} library already installed!\n"
	else
                printf "Installing python crypto library with pip"
                pip install crypto --break-system-packages --root-user-action
        fi
}
if [ "$deny_ran" -ne 0 ]; then
	check_os
	ipinfo_oui_install
	python_crypto
fi

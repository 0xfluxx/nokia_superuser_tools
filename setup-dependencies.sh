#!/usr/bin/env bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear_color='\033[0m'
echo "This will build dependencies from source, which may take a considerable amount of time depending on your system."
echo "You will need a C/C++ compiler (preferably GCC), Golang, and Cargo (rust) installed to do this, plus any libraries required for each build."
echo "You will also need python3, git, and GNU make installed."
echo "Alternatively, you can search your package manager for compiled binaries of these dependencies:"
printf "${green}ipinfo	nmap	python3 + pycryptodome	urlencode${clear_color}\n"
sleep 2
confirm() {
    printf "${green}yes${clear_color}\n"
}
deny() {
    printf "${red}no${clear_color}\n" 
}
printf "Checking for C compiler... "
if command -v cc &> /dev/null; then
	confirm
else
    	deny
	echo "Please install a C compiler"
    	exit 1
fi
printf "Checking for C++ compiler... "
if command -v c++ &> /dev/null; then
	confirm
else
	deny
	echo "Please install a C++ compiler"
	exit 1
fi
printf "Checking for Go compiler... "
if command -v go &> /dev/null; then
	confirm
else
    	deny
	echo "Please install Golang"
	exit 1
fi
printf "Checking for Cargo (Rust package manager)... "
if command -v cargo &> /dev/null; then
	confirm
else
	deny
	echo "Please install Rust"
	exit 1
fi
printf "Checking for Python3..."
if command -v python3 &> /dev/null; then
	confirm
else
	deny
	echo "Please install python3"
    	exit 1
fi
printf "Checking for make..."
if command -v make &> /dev/null; then
	confirm
else
	deny
	echo "Please install make"
	exit 1
fi
printf "Checking for git..."
if command -v git &> /dev/null; then
	confirm
else
	deny
	echo "Please install git"
	exit 1
fi
check_local_bin() {
echo $PATH | grep .local/bin >/dev/null
local_bin_on_path="$?"
if [ $local_bin_on_path -eq 1 ]; then
        echo "Directory $HOME/.local/bin found, but it isn't on your PATH"
        echo 'To change this, run `export PATH=$HOME/.local/bin:$PATH`'
else
        echo "Directory $HOME/.local/bin found and is along PATH"
fi
}
if [ -d $HOME/.local/bin ]; then
	check_local_bin
else
	echo "Creating directory for local executables at $HOME/.local/bin"
	mkdir -p $HOME/.local/bin
fi
if command -v ipinfo &> /dev/null; then
	printf "${green}ipinfo${clear_color} already installed!\n"
else
	echo "Building ipinfo"
	cd $HOME
	if [ ! -d ipinfo-cli ]; then
        	git clone --depth=1 https://github.com/ipinfo/cli ipinfo-cli
	        cd ipinfo-cli
	else
        	echo "Git repo already cloned"
        	cd ipinfo-cli 
        	git pull
	fi
	go install ./ipinfo/
	ipinfo_out="$(pwd)/ipinfo/ipinfo"
	if [ -f "$ipinfo_out" ]; then
		ln -s $(pwd)/ipinfo/ipinfo $HOME/.local/bin/ipinfo
	else
		printf "${red}Building ipinfo failed${clear_color}\n"
		exit 1
	fi
fi
if command -v nmap &> /dev/null; then
	printf "${green}nmap ${clear_color}already installed!\n"
else
	echo "Building nmap"
	cd $HOME
	curl -fsSL https://nmap.org/dist/nmap-7.98.tar.bz2 | tar xjvf -
	cd nmap-7.98
	./configure --without-zenmap --without-nping --without-ndiff --without-ncat
	make
	nmap_out="$HOME/nmap-7.98/nmap"
	if [ -f "$nmap_out" ]; then
		ln -s $HOME/nmap-7.98/nmap $HOME/.local/bin/nmap
	else
		printf "${red}Building nmap failed${clear_color}\n"
		exit 1
	fi
fi
if command -v urlencode &> /dev/null; then
	printf "${green}urlencode${clear_color} already installed!\n"
else
	echo "Building urlencode"
	cargo install urlencode
	urlencode_out="$HOME/.cargo/bin/urlencode"
	if [ -f "$urlencode_out" ]; then
		ln -s "$urlencode_out" $HOME/.local/bin/urlencode
	else
		printf "${red}Building urlencode failed${clear_color}\n"
		exit 1
	fi

fi
python3 -c "import Crypto" && printf "python ${green}Crypto${clear_color} library already installed!\n" || echo "No python3 module named Crypto found - you can use pip or your package manager but for this one you must manually install it, as we don't want to be responsible for breaking your python installation"
check_local_bin

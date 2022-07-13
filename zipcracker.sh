#!/bin/bash

#Author: h3g0c1v
#This script is a simple automator to decrypt .zip files using the john tool.
#./zipcracker zip_filename passwords_dictionary


# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Location of zip2john
$(zip2john 2>/dev/null)
state=$?

# Ctl + C
trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!] Coming out ...\n${endColour}"
	exit 1
}

#Function to help
function helpPanel(){
     echo -e "\n${redColour}[!] Usage: ./zipcracker.sh zip_filename passwords_dictionary${endColour}"
     for i in $(seq 1 80); do echo -ne "${redColour}-"; done; echo -ne "${endColour}"
     echo -e "\n\n\n\t${grayColour}[-h]${endColour}${yellowColour} Show this help panel${endColour}"
     echo -e "\n\n${blueColour}(Example: ./zipcracker.sh compressed.zip /usr/share/wordlists/rockyou.txt)${endColour}\n"

     exit 1
}

#Parameter -h
while getopts ":h" arg; do
    case $arg in
        h)
			helpPanel;
			exit;;
	esac
done

#Checks
if [ "$*" == "" ]; then
	helpPanel
fi

if [ ! -f "$1" ] && [ ! -f "$2" ]; then
	echo -e "\n${redColour}[!] File ($1) and dictionary ($2) not found${endColour}"
	helpPanel;
fi

if [ ! -f "$1" ]; then
	echo -e "\n${redColour}[!] File ($1) not found${endColour}"
    helpPanel;
fi

if [ ! -f "$2" ]; then
	echo -e "\n${redColour}[!] Dictionary ($2) not found${endColour}"
	helpPanel;
fi

# Installing zip2john to generate the hash
if [ $state -ne 0 ]; then
	echo -e "${greenColour}[*] Installing zip2john to generate the hash\n${endColour}"
	sudo apt install john
fi

#Script functionality
if [ -f "$1" ]; then

	echo -e "\n${greenColour}[*] Generating the hash for the compressed file ... \n${endColour}"
	# Generating the hash
	zip2john $1 > hash

	echo -e "\n${greenColour}[*] Hash generated \n${endColour}"

	echo -e "\n${yellowColour}[*] Cracking the compressed file \n${endColour}"
	john --wordlist=$2 hash > pass.txt
	cat pass.txt | grep $1 | awk 'NF{print$1}' > password.txt
	rm pass.txt

	echo -e "\n${redColour}[!] In case you don´t see the password in the password.txt file, it means, that it has been possible to crack it. \n${endColour}"
	echo -e "\n${blueColour}[*] The password is ${endColour}"${yellowColour}$(cat password.txt)${endColour}
	rm hash
	rm password.txt

else
	echo -e "\n${redColour} [!] Ocurrio algun problema al ejecutar el programa${endColour}\n"
fi

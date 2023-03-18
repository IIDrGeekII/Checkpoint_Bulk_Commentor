#!/bin/bash

###############################################################################################
###############################################################################################

#Color Codes:

export PS3=$'\e[38;5;172mTerminal > \e[0m'
END="\e[0m"
GREEN="\e[1;92m"
RED="\e[1;91m"
CYAN="\033[36m"
MAGENTA="\033[35m"
YELLOW="\033[33m"

###############################################################################################
###############################################################################################

cleanup() {
        rm -rf ~/junk > /dev/null
  }

###############################################################################################
###############################################################################################

Spinner for sleep:

spinner () {
    local chars=('|' / - '\')

    # hide the cursor
    tput civis
    trap 'printf "\010"; tput cvvis; return' INT TERM

    printf %s "$*"

    while :; do
        for i in {0..3}; do
            printf %s "${chars[i]}"
            sleep 0.3
            printf '\010'
        done
    done
}

###############################################################################################
###############################################################################################

copy ()
{
    local pid return

    spinner "$spin" & pid=$!

    # Slow copy command here
    sleep 7

    return=$?

   # kill spinner, and wait for the trap commands to complete
    kill "$pid"
    wait "$pid"

    if [[ "$return" -eq 0 ]]; then
        echo " "
    else
        echo ERROR
    fi
}

###############################################################################################
###############################################################################################

quit()
{

cat << !

`printf "${CYAN}            +----------------------------------------+ ${END}"`
`printf "${CYAN}            |                                        | ${END}"`
`printf "${CYAN}            |    Thank you for using CPCommentor!    | ${END}"`
`printf "${CYAN}            |     Vaibhav_Masane A.K.A. @DrGeek      | ${END}"`
`printf "${CYAN}            |                                        | ${END}"`
`printf "${CYAN}            +----------------------------------------+ ${END}"`

!
cleanup
spin=$(printf "${RED}cleaning up and quitting the program ...${END}") && copy && clear
exit 0
}

###############################################################################################
###############################################################################################

mainmenu()
{

printf "\n${GREEN}Select option: ${END}"
printf "\n"
mainmenu=("Comment Rules" "Check for different policy package" "Quit Program")
select opt in "${mainmenu[@]}"; do
        if [ "$opt" = "Quit Program" ]; then
        quit
        elif [ "$opt" = "Comment Rules" ]; then
commentrule
        elif [ "$opt" = "Check for different policy package" ]; then
rulebasesize
        else
#if no valid option is chosen, chastise the user
        echo "That's not a valid option! Hit ENTER to show menu."
        fi
done

}

###############################################################################################
###############################################################################################

change()
{

printf "\n${GREEN}Select option: ${END}"
printf "\n"
change=("Publish" "Discard" "Check for different policy package" "Quit Program")

select menu in "${change[@]}"; do

if [ "$menu" = "Check for different policy package" ]; then
        rulebasesize
        elif [ "$menu" = "Quit Program" ]; then
        quit
        elif [ "$menu" = "Publish" ]; then
        time mgmt_cli publish -s "$session"
        elif [ "$menu" = "Discard" ]; then
        time mgmt_cli discard -s "$session"
        else
#if no valid option is chosen, chastise the user
        echo "That's not a valid option! Hit ENTER to show menu."
        fi
done

}

###############################################################################################
###############################################################################################

rulebasesize()
{

printf "\n${GREEN}Provide IP address or Name of the Domain or SMS you want to check: ${END}"
read DOMAIN
sleep 2

printf "\nListing all available Policy Package Names...\n"
sleep 2
printf "\n"

access_layers=$(mgmt_cli -r true -d $DOMAIN show access-layers limit 500 --format json | jq --raw-output '."access-layers"[] | (.name)')
printf "${MAGENTA}Available policy packages: \n${END}"
printf "\n"
echo "$access_layers"

# Loop until a valid access layer is selected
while true; do
  # Ask for input
  printf "\n${GREEN}Specify Policy Package Name from the above list[mention full name]: ${END}"
  read POL_NAME

  # Check if the input is a valid access layer
  if echo "$access_layers" | grep -q "^$POL_NAME$"; then
    break
  else
    printf "\n"
    echo "Error: Invalid input. Please select from the list above."
  fi
done
printf "\nDetermining Rulesbase size...\n"
printf "\n"
total=$(mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" --format json |jq '.total')
echo "+-------------------------------------------------+"
printf "There are total \e[0;30m\e[43m$total\e[0m rules in \e[1m$POL_NAME\e[0m policy package.\n"
echo "+-------------------------------------------------+"
printf "\n"
printf "${GREEN}Enter total number of rules to scan: ${END}"
read COUNT
printf "\n"
printf "Fetching result...\n"
printf "\n"
printf "Note: This may take time depending on the number of rules to scan.\nPlease be patient..."
printf "\n"
printf "\n"
total2=$(mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" details-level "standard" limit "$total" use-object-dictionary true show-hits true --format json | jq  -r '.rulebase[] | .rulebase[]? // . | select(.comments == "")' | jq --raw-output '.uid' | wc -l)
echo "+-------------------------------------------------+"
printf "There are total \e[0;30m\e[43m$total2\e[0m rules in \e[1m$POL_NAME\e[0m policy package\nthat does not have any comments.\n"
echo "+-------------------------------------------------+"

mainmenu

}

###############################################################################################
###############################################################################################

sessioncreator()
{

printf "\nProvide credentials to create session:\n"

printf "\n${GREEN}Enter Smartconsole Username: ${END}"
read username

# Disable local echo
stty -echo
printf "${GREEN}Enter Smartconsole Password: ${END}"
read password
# Enable local echo again
stty echo
printf "\n"
spin=$(printf "${CYAN}\nCreating session...${END}")
copy
mkdir ~/junk
mgmt_cli login user "$username" password "$password" > ~/junk/session
input=$(grep -o "\S*" ~/junk/session | grep -i "sid" | sed "s/://g")
#sleep 3
if [ "$input" = "sid" ]; then

printf "${YELLOW}\nSession created successfully.\n${END}"
printf "${MAGENTA}\n`grep -i "sid\|uid" ~/junk/session | grep -v "user-uid"`\n${END}"
session=$(echo ~/junk/session)
spin=$(printf "${CYAN}\nScanning database...${END}")
copy
fi

if [ "$input" != "sid" ]; then

printf "${RED}\n`grep -i "message" ~/junk/session`\n${END}"
printf "\n${RED}Exiting with error..\n${END}"
sleep 3
printf "\n${RED}Please try again by running the script with correct credentials.\n${END}"
printf "\n"
sleep 2
exit 0

fi

}

###############################################################################################
###############################################################################################

commentrule()
{

sessioncreator

printf "\n${GREEN}Enter the comment to print: ${END}"
read comment

spin=$(printf "${CYAN}\nCommenting all the non-commented rules...${END}")
copy
sleep 2

pol2="$(mgmt_cli -r true show access-rulebase name "$POL_NAME" details-level "standard" limit "$total" use-object-dictionary true show-hits true --format json | jq  -r '.rulebase[] | .rulebase[]? // . | select(.comments == "")' | jq --raw-output '.uid')"

while read -r line; do
  mgmt_cli set access-rule uid "$line" layer "$POL_NAME" comments "$comment" -s "$session"
done <<< "$pol2"

change

}

###############################################################################################
###############################################################################################
##WELCOME################
#########################
##START WELCOME MESSAGE##
###############################################################################################
###############################################################################################
clear

banner() {
    printf "\n"
    printf "\e[1;32m%-80s\e[0m\n" "  _____ _____   _____                                     _             "
    printf "\e[1;32m%-80s\e[0m\n" " / ____|  __ \ / ____|                                   | |            "
    printf "\e[1;32m%-80s\e[0m\n" "| |    | |__) | |     ___  _ __ ___  _ __ ___   ___ _ __ | |_ ___  _ __ "
    printf "\e[1;32m%-80s\e[0m\n" "| |    |  ___/| |    / _ \| '_ \` _ \| '_ \` _ \ / _ \ '_ \| __/ _ \| '__|"
    printf "\e[1;32m%-80s\e[0m\n" "| |____| |    | |___| (_) | | | | | | | | | | |  __/ | | | || (_) | |   "
    printf "\e[1;32m%-80s\e[0m\n" " \_____|_|     \_____\___/|_| |_| |_|_| |_| |_|\___|_| |_|\__\___/|_|   "
    printf "\n"

    printf "  \e[0;30m\e[46m  Checkpoint Firewall Bulk Commentor. Author: @Vaibhav_Masane  \e[0m\n"
    printf "\n"
}

banner ""

banner()
{
  echo "              +------------------------------------------+"
  printf "              |      %s        |\n" "`date`"
  echo "              +------------------------------------------+"
}
banner ""
today="$(date +%d-%m-%Y)"
echo "+------------------------------------------------------------------+"
#today="$(date +%d-%m-%Y)"
printf  "    This script will search a specific policy package for rules\n    with no comments and then execute command to print comments\n    on all rules at once. If for any reason you make a typo and\n    need to exit then use CTRL+C.\n"
echo "+------------------------------------------------------------------+"
printf "\n"
printf "${CYAN}Press ENTER to continue...${END}"
read ANYKEY
printf "\n"

rulebasesize

quit

###############################################################################################
###############################################################################################


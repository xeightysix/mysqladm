#!/bin/bash
# Author: Noe Macias
# Version: 0.0.1
# Date 10-29-2015
# Descriptions:
#   Simple MySQL Admin Script
#

# Load config file
if [[ -f './conf/config.sh' ]]; then
  source './conf/config.sh'
fi

# load Functions
if [[ -f "./lib/func.sh" ]]; then
    source "./lib/func.sh"
fi

# Check: Root Password must be set
if [[ -z $MYSQLPASSWD ]]; then
  # Root Password Must be Set
  message "MySQL Root Password is not set. See [ conf/config.sh ]" "alert"
  exit
fi

# Check : MySQL Server is Running
case $SYSTEM in
  'osx' )
    # Get Port number on OSX
    MYSQLPORT=$(netstat -nap tcp  | grep 3306 | awk -F"." '{print $2}')
    if [[ "${MYSQLPORT:0:4}" = '3306' ]]; then
      message "MySQL Server is Running" "mesg"
    else
       message "MySQL Server is not running" "alert"
       exit
    fi
    ;;
  'linux')
    MYSQLPORT=$(netstat -tnl | grep 3306 | awk -F":" '{ print $2 }')
    if [[ "${MYSQLPORT:0:4}" = '3306' ]]; then
      message "MySQL Server is Running" "mesg"
    else
       message "MySQL Server is not running" "alert"
       exit
    fi
    ;;
  *)
    # Give User Feedback
    message "SYSTEM is not set, See [ conf/config.sh ]" "alert"
    exit
    ;;
esac

# Display Menu
echo ""
message "Type 'm' To Display Menu" "info"
echo ""

# Main logic
while [[ $myinput != "q" ]]; do

  read  -p "[mysqladm]> " myinput

  case $myinput in
    "1" )
      # Display Data bases
      prettyPrintShowDB ;;
    "2")
      # Display Users
      showUsers ;;
    "3")
      # Update User password
      updatePassword ;;
    "4")
      # Backup Database
      dumpDB ;;
    "5")
      # Create Database with out User
      dbCreate ;;
    "6")
      # Create Database with user
      dbCreateWithUser ;;
    "7")
      # Drop User
      dropUser ;;
    "8")
      # Drop Database
      dropDB ;;
    "9")
      # Add User
      addUser ;;
    "10")
      # Grant All To Database
      grantAllTo ;;
    "11")
      # Show Grants
      showGrants ;;
    "m")
      # Display Menus
      showMenu ;;
  esac

done

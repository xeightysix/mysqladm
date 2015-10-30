# Show Menu
showMenu(){
  echo ""
  message "Please Select" "info"
  message "1) Show Databases" "info"
  message "2) Show Users" "info"
  message "3) Update User Password" "info"
  message "4) Dump Database" "info"
  message "5) Create Database [ With No User ]" "info"
  message "6) Create Database [ With User ]" "info"
  message "7) Drop User" "info"
  message "8) Drop Database" "info"
  message "9) Add User" "info"
  message "10) Grant All To" "info"
  message "11) Show Grants" "info"
  message "m) Display Menu" "info"
  message "q) Quit" "info"
  echo ""
}

# Pretty print to STDOUT
message(){
	# Message
	MESG=$1
	case $2 in
		'info')
			COLOR="\e[0;33m";;
		'alert')
			COLOR="\e[0;31m";;
		'mesg')
			COLOR="\e[0;32m";;
		*)
			COLOR="\e[0;37m";;
	esac

	printf "$COLOR%b \e[0m\n" "$MESG"
}

# Show DB
showDB(){
  # Show DB SQL
  SHOWDB="SHOW DATABASES"
  echo $SHOWDB | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null
}

# Pretty Print DBS
prettyPrintShowDB(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|              Databases            |" "info"
  message "+-----------------------------------+" "info"
  # Get All database, replace libe breaks with |
  DBS=$(showDB | tr '\n' '|')
  # Explode DBS String and load into an array
  IFS="|" read -a dbs <<< "$DBS"

  # Count
  X=0
  for i in ${!dbs[@]}; do
    if [[ ! "${dbs[$i]}" =~ (_schema$|mysql|Database) ]]; then
      # Count
      COUNT=$(( X += 1 ))
      message "[$COUNT] ${dbs[$i]}" "info"
    fi

  done
  echo ""
  message "`date +%r`: Total Databases [$COUNT]" "mesg"
  echo ""

}

# Show User
showUsers(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|                All Users          |" "info"
  message "+-----------------------------------+" "info"
  # SQL: Show All User
  SQL="SELECT Password, User, Host FROM mysql.user;"
  USERS=$(echo $SQL | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null | tr '\n' "|")
  IFS="|" read -a users <<< "$USERS"

  message "Passord\t\t\t\t\t\t[ User ] [ Host ]" "info"
  for i in ${!users[@]}; do
    if [[ $i -gt 0 ]]; then
      AWK=$(echo "${users[$i]}" | awk '{print $1"|"$2"|"$3}' | tr "\n" "|")
      IFS="|" read -a user <<< "$AWK"
      message "${user[0]}\t[ ${user[1]} ] [ ${user[2]} ]" "mesg"
    fi

  done

  # Total Users
  TOTALUSERS=$(( ${#users[@]} - 1 ))
  echo ""
  message "`date +%r`: Total Users [ $TOTALUSERS ] " "info"
  echo ""
}

# Update Password
updatePassword(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|       Udpate User Password        |" "info"
  message "+-----------------------------------+" "info"
  read -p "[ Username ]: " user
  read -p "[ Host:localhost ]: " host
  read -s -p "[ New Password ] " password

  # Set Default local host
  if [[ -z $host  ]]; then
    # Add Default host
    host="localhost"
  fi

  # Update Password MYSQL
  SQL="SET PASSWORD FOR $user@$host = password('$password');"

  # update Password
  echo $SQL | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null
  echo ""
  echo ""
  message "`date +%r`: Password has been updated" "mesg"
  echo ""
}

# Dump Database
dumpDB(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|            Dump Database          |" "info"
  message "+-----------------------------------+" "info"
  # Read DB Name
  read -p "[ Database ] " db
  # Prefix
  PREFIX="dump."
  # Generate HASH
  NAMEHASH=$(date | md5)
  # Date
  DATE=$(date +%Y%m%d)
  # File name
  FILENAME=$PREFIX${NAMEHASH:0:10}.$DATE.$db.sql
  # Get All database, replace libe breaks with |
  DBS=$(showDB | tr '\n' '|')
  # Explode DBS String and load into an array
  IFS="|" read -a dbs <<< "$DBS"

  # Loop thourhg the array if db match dump it else do nothing
  for i in "${!dbs[@]}"; do
    if [[ ${dbs[$i]} = $db ]]; then
      echo ""
      message "`date +%r`: Dumping Database [ $db ]" "mesg"
      # Dump DB
      mysqldump -u $MYSQLUSER -p"$MYSQLPASSWD" $db > "./dumps/$FILENAME" 2> /dev/null
      message "`date +%r`: Dumping Complete Filename: [ $FILENAME ]" "mesg"
    fi
  done
  echo ""
}

# Create Database
dbCreate(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|       Create New Database         |" "info"
  message "+-----------------------------------+" "info"
  read -p "[ Database Name ]: " db

  # SQL
  SQL="CREATE DATABASE $db;"
  # CREATE NEW DATABASE
  echo $SQL | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null

  # Give User Feedback
  echo ""
  message "`date +%r`: Database [ $db ] Has Been Created." "mesg"
  echo ""
}

# Create Database With user
dbCreateWithUser(){
  echo ""
  message "+-----------------------------------+" "info"
  message "| Create New Database [ With User ] |" "info"
  message "+-----------------------------------+" "info"
  read -p "[ Database ]: " db
  read -p "[ Username ]: " username
  read -p "[ Host: localhost ]: " host
  read -s -p "[ Password ]: " passwd

  # Set Default local host
  if [[ -z $host  ]]; then
    # Add Default host
    host="localhost"
  fi

  # SQL Create Database
  SQL1="CREATE DATABASE $db;"
  # Create Database
  echo $SQL1 | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null
  # SQL Create User
  SQL2="CREATE USER '$username'@'$host' IDENTIFIED BY '$passwd';"
  # Create User
  echo $SQL2 | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null
  # SQL Grant All Privilidges
  SQL3="GRANT ALL ON $db.* TO '$username'@'$host';"
  # Grant All
  echo $SQL3 | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null

  # Give User Feedback
  echo ""
  message "`date +%r`: User has been created: Database [ $db ] $username@$host " "mesg"
  echo ""
}

# Drop Users
dropUser(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|             Delete User           |" "info"
  message "+-----------------------------------+" "info"
  # Username
  read -p "[ Username ]: " user
  # Host
  read -p "[ Host:localhost ]: " host

  # Set Default host
  if [[ -z $host ]]; then
    # Default host
    host='localhost'
  fi

  # SQL Drop user
  SQL="DROP USER '$user'@'$host';"
  # Drop User
  echo $SQL | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null

  # Give user Feed back
  echo ""
  message "`date +%r`: User [ $user ] has been Deleted." "mesg"
  echo ""

}

# Drop Database
dropDB(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|         Delete Database           |" "info"
  message "+-----------------------------------+" "info"
  # Database name
  read -p '[ Database ]: ' db

  # No Drop DB
  if [[ $db = 'information_schema' || $db = 'mysql' ]]; then
    message "\t`date +%r`: Sorry Can't Drop Database [ $db ]" "alert"
  else
    # SQL: Drop Database
    SQL="DROP DATABASE $db;"
    # Drop Database
    echo $SQL | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null

    # Give User Feedback
    echo ""
    message "`date +%r`: Database has been deleted: [ $db ] " "mesg" "info"
  fi
  echo ""
}

# Add Users
addUser(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|             Add User              |" "info"
  message "+-----------------------------------+" "info"
  # Username
  read -p "[ Username ]: " user
  # Password
  read -s -p "[ Password ]: " password
  # Must add echo here for newline, pretty format :)
  echo ""
  # Host
  read -p "[ Host:localhost ]: " host


  # Set Default Host
  if [[ -z $host ]]; then
    # Default Host
    host="localhost"
  fi

  # SQL Add User
  SQL="CREATE USER '$user'@'$host' IDENTIFIED BY '$password';"
  # Create User
  echo $SQL | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null

  # Give user feedback
  echo ""
  message "`date +%r`: User [ $user ] has been created." "mesg"
  echo ""
}

# Grant All To
grantAllTo(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|             Grant All To          |" "info"
  message "+-----------------------------------+" "info"
  # Username
  read -p "[ Username ]: " user
  # Database
  read -p "[ Database ]: " db
  # Host
  read -p "[ Host:localhost ]: " host

  # Set Default Host
  if [[ -z $host ]]; then
    # Default Host
    host="localhost"
  fi

  # SQL
  SQL="GRANT ALL ON $db.* TO '$user'@'$host';"
  # Grant All To
  echo $SQL | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null

  # Give user feedback
  echo ""
  message "`date +%r`: Granted All Privileges TO [ '$user'@'$host' ] ON [ $db ]" "mesg"
  echo ""

}

# Show Grants
showGrants(){
  echo ""
  message "+-----------------------------------+" "info"
  message "|             Show Grants           |" "info"
  message "+-----------------------------------+" "info"

  # Get Username
  read -p "[ Username ]: " user
  # Hostname
  read -p "[ Host:localhost ]: " host

  # Set Default Host
  if [[ -z $host ]]; then
    # Default Host
    host="localhost"
  fi

  # SQL
  SQL="SHOW GRANTS FOR '$user'@'$host'"
  # Get Grants
  GRANTS=$(echo $SQL | mysql -u $MYSQLUSER -p"$MYSQLPASSWD" 2> /dev/null | tr "\n" "|")
  # Load Grants into array
  IFS="|" read -a grants <<< "$GRANTS"
  echo ""
  for i in "${!grants[@]}"; do
      case $i in
        "0" )
          message "${grants[$i]}"
          ;;
        "1")
          message "${grants[$i]}" "info"
        ;;
        *)
          message "${grants[$i]}" "mesg"
        ;;
      esac
  done

  echo ""

}

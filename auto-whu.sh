#!/bin/bash
# Online check
check_online() {
    ping -w1 -W1 -c 1 baidu.com 1>/dev/null 2>&1 
    [[ $? = 0 ]] && echo "Network is already up" && return 0
    return 1
}
# Check online and immediately exit if is running by systemd
check_online && [[ $? = 0 ]] && [[ ! -z "$INVOCATION_ID" ]] && exit
echo "Warning: running auto-whu when already online is dangerous, you may get your account banned for too many login requests. Use systemd and the bundled service and timer file to manage auto-whu instead. Check the repo for more info: https://github.com/7Ji/auto-whu-standard"
# Help message
help () {
    echo "Usage: $0 -u [username] -p [password] -n [network] -m [manual network] -u [url] -c [config file] -f -s -h"
    echo "      -u username, should be a number of 13 digits"
    echo "      -p password, any value not empty"
    echo "      -n network, single-digit number from 0 to 3, 0 for CERNET, 1 for China Telcom, 2 for China Unicom, 3 for China Mobile"
    echo "      -m a manually specified network name, replace the -n option"
    echo "      -c config file, path to the configuration file"
    echo "      -a eportal authorization URL, DO NOT SET IT unless you totally understand it"
    echo "      -f foreground mode, ignore the systemd check"
    echo "      -s skip check for sanity for username, password and network"
    echo "      -h print this message"
    echo "      *notice that all other arguments will overwrite the value provided by the config file"
}
# Check arguments
[[ $# = 0 ]] && help && exit
while [[ $# -ge 1 ]]; do
    if [[ "$1" = '-u' ]]; then
        ARG_USERNAME="$2"
        shift
    elif [[ "$1" = '-p' ]]; then
        ARG_PASSWORD="$2"
        shift
    elif [[ "$1" = '-n' ]]; then 
        ARG_NETWORK="$2"
        shift
    elif [[ "$1" = '-m' ]]; then
        ARG_NETWORK_MANUAL="$2"
        shift
    elif [[ "$1" = '-a' ]]; then
        ARG_URL="$2"
        shift
    elif [[ "$1" = '-c' ]]; then
        ARG_CONFIG="$2"
        shift
    elif [[ "$1" = '-f' ]]; then
        ARG_IGNORE_SYSTEMD='1'
    elif [[ "$1" = '-s' ]]; then
        ARG_IGNORE_SANITY='1'
    elif [[ "$1" = '-h' ]]; then
        help && exit
    fi
    shift
done    
# Check and read configuration file if neccessary
if [[ ! -z "$ARG_CONFIG" ]]; then
    [[ ! -f "$ARG_CONFIG" ]] && echo "ERROR: The configuration file '$ARG_CONFIG' you've provided does not exist."
    [[ ! -r "$ARG_CONFIG" ]] && echo "ERROR: Not allowed to read the configuration file '$ARG_CONFIG', check your permission"
    source "$ARG_CONFIG"
fi
[[ ! -z "$ARG_USERNAME" ]] && USERNAME=$ARG_USERNAME
[[ ! -z "$ARG_PASSWORD" ]] && PASSWORD=$ARG_PASSWORD
[[ ! -z "$ARG_NETWORK" ]] && NETWORK=$ARG_NETWORK
[[ ! -z "$ARG_NETWORK_MANUAL" ]] && NETWORK_MANUAL=$ARG_NETWORK_MANUAL
[[ ! -z "$ARG_URL" ]] && URL=$ARG_URL
[[ ! -z "$ARG_IGNORE_SYSTEMD" ]] && IGNORE_SYSTEMD='1'
[[ ! -z "$ARG_IGNORE_SANITY" ]] && IGNORE_SANITY='1'
# Default value downgrading
[[ -z "$NETWORK" && -z "$NETWORK_MANUAL" ]] && NETWORK='0' && echo "Neither network number nor manual network name was set, defaulting network to 0(CERNET)"
[[ -z "$URL" ]] && URL='http://172.19.1.9:8080/eportal/InterFace.do?method=login' && echo "Using default eportial authorization URL 'http://172.19.1.9:8080/eportal/InterFace.do?method=login'"
# Check systemd
if [[ -z "$INVOCATION_ID" && "$IGNORE_SYSTEMD" != 1 ]]; then
    echo "You are running this script manually or in a non-systemd environment, it's better to manage this script with systemd."
    echo "Check the github repo to learn how to use this script properly: https://github.com/7Ji/auto-whu-standard"
    echo "You can set IGNORE_SYSTEMD='1' in the config file or use the argument -f to ignore this check"
fi
# Check intergrity or sanity. return code 1 for insanity.
if [[ "$IGNORE_SANITY" != 1 ]]; then
    echo "Starting sanity check for username, password and network, you can set IGNORE_SANITY='1' in config file, or use argument -n to ignore this check."
    [[ ! "$USERNAME" =~ ^[0-9]{13}$ ]] && echo "ERROR:The username '$USERNAME' you provided is not a number of 13 digits" && exit 1
    [[ -z "$PASSWORD" ]] && echo "ERROR:You've specified an empty password" && exit 1
    [[ ! "$NETWORK" =~ ^[0-3]$ && -z "$NETWORK_MANUAL" ]] && echo "ERROR:You've specified a network number not supported, only 0-3 is supported, 0 for CERNET(default), 1 for China Telcom, 2 for China Unicom, 3 for China Mobile" && exit 1
    echo "Sanity check pass."
fi
# Network number conversion
if [[ -z "$NETWORK_MANUAL" ]]; then
    if [[ "$NETWORK" = 0 ]]; then
        NETWORK_STRING=Internet
    elif [[ "$NETWORK" = 1 ]]; then
        NETWORK_STRING=dianxin
    elif [[ "$NETWORK" = 2 ]]; then
        NETWORK_STRING=liantong
    else   
        NETWORK_STRING=yidong
    fi
else
    NETWORK_STRING=$NETWORK_MANUAL
fi
# Authorization
echo "Trying to authorize..."
curl -d "userId=$USERNAME&password=$PASSWORD&service=$NETWORK_STRING&queryString=`curl baidu.com | grep -oP "(?<=\?).*(?=\')" | sed 's/&/%2526/g' | sed 's/=/%253D/g'`&operatorPwd=&operatorUserId=&validcode=&passwordEncrypt=false" $URL 1>/dev/null 2>&1 
check_online && [[ $? = 0 ]] && exit
echo "Failed to authorize, you may need to check your account info and credit and network connection"

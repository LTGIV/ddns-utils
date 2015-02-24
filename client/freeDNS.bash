#!/usr/bin/env bash

# argv1 = ip address to update to

host='HOST.ddns.com'
hash='FREEDNS-HASH-HERE'

echo -n "WAN: ";
ADDYWANIP=${1-`curl -s --connect-timeout 30 https://www.gotgetllc.com/ip/`};

# Timeout?
if [ "${ADDYWANIP}" = '' ]; then
	echo 'Not Available due to a timeout.  Exiting.';
	exit;
else
	echo -n $ADDYWANIP;
fi

# Override
if [ -z "$1" ]; then
	echo;
else
	echo " (override)"
fi

ADDYDNSIP=`host ${host} | awk '{print $4}'`

echo "DNS: ${ADDYDNSIP}";

echo;

if [ "${ADDYWANIP}" = "${ADDYDNSIP}" ]; then
	echo "Everything appears to be in order, exiting.";
	exit;
else
	echo "Things aren't in order, updating...";
	DDNSUPD=`curl -s "https://freedns.afraid.org/dynamic/update.php?${hash}\&address=${ADDYWANIP}"`
#	if [ "${DDNSUPD}" = '' ]; then
#		echo "A timeout error occurred, please try again.";
#		exit;
	echo $DDNSUPD
fi
echo;

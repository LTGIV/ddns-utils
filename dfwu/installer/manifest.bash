#!/usr/bin/env bash
#
# DFWU (DDNS Firewall Update) Installer-Manifest v201503070705
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/dfwu
#
# Example usage:
# sudo bash ddns-utils/dfwu/installer/manifest.bash

################################################################################
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )
SCRIPTNAME=`basename $0`
UPPATH="$( cd "$(dirname "${SCRIPTPATH}/../")" ; pwd -P )"
OWNER=`ls -ld "$UPPATH" | awk 'NR==1 {print $3}'`
WHOAMI="$(whoami)"
################################################################################

# Try to locate GGCOM Bash Library
echo -n "Checking for GGCOM Bash Library... "
LIBPATH=''
TMPGGCOMCHECK=(
	"$UPPATH/ggcom-bash-library"
	
	"`eval echo ~${OWNER}`/ggcom/ggcom-bash-library"
	"`eval echo ~${OWNER}`/ggcom/lib/bash"
	
	"`eval echo ~${WHOAMI}`/ggcom/ggcom-bash-library"
	"`eval echo ~${WHOAMI}`/ggcom/lib/bash"
	
	"/usr/lib/ggcom/bash"
)
for i in "${TMPGGCOMCHECK[@]}"
do
	if [ -f "$i/version.bash" ]; then
		echo "located in '$i'"
		LIBPATH=$i
		break
	fi
done
unset TMPGGCOMCHECK i
if [ -z "$LIBPATH" ]; then
	echo "not located."

	LIBPATH=`mktemp -d 2>/dev/null || mktemp -d -t 'dfwu'`

	echo "Downloading latest GGCOM Bash Library to a temporary directory for use with DFWU install:"
	if [ -z "$(ls -A $LIBPATH)" ]; then git clone https://github.com/LTGIV/ggcom-bash-library.git $LIBPATH; fi

	chown -R $OWNER: $LIBPATH
	chmod -R 750 $LIBPATH
	echo;
fi

################################################################################
source "${LIBPATH}/varsBash.bash"
source "${LIBPATH}/string.bash"
source "${LIBPATH}/version.bash"
################################################################################
#
################################################################################

#----- NOTICE: INFO
echo `str_repeat - 80`
echo "`getVersion $0 header`"
echo `str_repeat - 80`
echo;
#-----/NOTICE: INFO

#----- REQUIRE ROOT
if [ "$WHOAMI" != "root" ]; then
	echo 'Sorry, you are not root.  Please try again with sudo.' >&2
	exit 1
fi
#-----/REQUIRE ROOT

#----- REQUIRE PYTHON MODULES
TMPPYTHONMODS=(
	"from distutils.spawn import find_executable as which"
	"from configobj import ConfigObj"
	"import inspect, socket, hashlib"
)
for i in "${TMPPYTHONMODS[@]}"
do
	TMPPYOUTPUT=`python -c '"$i"' 2>&1`
	if [ ! -z "$TMPPYOUTPUT" ]; then
		echo "DFWU is a Python application which requires Python modules and failed at:" >&2
		echo "'$i'" >&2
		echo "Typically, you can fix this problem by installing the module with 'sudo pip install <ModuleName>'" >&2
		echo;
		exit 1;
	fi
done
unset TMPPYTHONMODS i TMPPYOUTPUT
#-----/REQUIRE CONFIGOBJ

#----- ENVIRONMENT VARIABLES
MYEDITOR=${FCEDIT:-${VISUAL:-${EDITOR:-nano}}}
ROOTDIR=~root
MYDIR=$( cd "$(dirname "$BASH_SOURCE")" ; pwd -P )
#-----/ENVIRONMENT VARIABLES

#----- DEFAULT SETTINGS I
TMPALLOWFILE='/etc/csf/csf.allow'
TMPINCLUDESTR='Include /etc/csf/csf-ddns.allow'

ACTION='installed'

TMPDFWUPROGPATH='/usr/bin'
TMPDFWUINI='/etc/dfwu.ini'
TMPCRONFILE=`mktemp /tmp/crontab.XXXXXXXXX`
#-----/DEFAULT SETTINGS I

#----- INSTALL SETTINGS

# ADD WHILE LOOP HERE FOR ITERATING UNTIL FILE IS FOUND, TO TRY AND AVOID PITFALLS
read -p "Which firewall file? [$TMPALLOWFILE] " INPALLOWFILE
if [ -z "$INPALLOWFILE" ]; then
	INPALLOWFILE=$TMPALLOWFILE
fi

read -p "What firewall line? ['$TMPINCLUDESTR'] " INPINCLUDESTR
if [ -z "$INPINCLUDESTR" ]; then
	INPINCLUDESTR=$TMPINCLUDESTR
fi

# ADD OVERRIDE ERROR
read -p "DFWU Program Path? ['$TMPDFWUPROGPATH'] " INPDFWUPROGPATH
if [ -z "$INPDFWUPROGPATH" ]; then
	INPDFWUPROGPATH=$TMPDFWUPROGPATH
fi

# ADD OVERRIDE ERROR (or is it an upgrade?)
read -p "DFWU ini path *AND* name? ['$TMPDFWUINI'] " INPDFWUINI
if [ -z "$INPDFWUINI" ]; then
	INPDFWUINI=$TMPDFWUINI
fi
#-----/INSTALL SETTINGS

#----- DEFAULT SETTINGS II
TMPCRONSTR="* * * * * $INPDFWUPROGPATH/dfwu.py $INPDFWUINI"
TMPDFWUINIPATH=$(dirname "$INPDFWUINI")
#-----/DEFAULT SETTINGS II

#----- COPY MAIN APPLICATION
if [ ! -d $INPDFWUPROGPATH ]; then
	mkdir -p $INPDFWUPROGPATH
fi

cp -a $MYDIR/../dfwu.py $INPDFWUPROGPATH/dfwu.py
chown root: $INPDFWUPROGPATH/dfwu.py
chmod 755 $INPDFWUPROGPATH/dfwu.py
#-----/COPY MAIN APPLICATION

#----- COPY DFWU INI TO DESTINATION
if [ -f $INPDFWUINI ]; then

	ACTION='upgraded'
	echo "Note: $INPDFWUINI exists, not replacing."

else

	if [ ! -d $TMPDFWUINIPATH ]; then
		mkdir -p $TMPDFWUINIPATH
		chmod -R o-rwx $TMPDFWUINIPATH
	fi

	cp -a $MYDIR/../dfwu.ini $INPDFWUINI
	chown root: $INPDFWUINI
	chmod 600 $INPDFWUINI

fi
#-----/COPY DFWU INI TO DESTINATION

#----- INSERT (or skip if exists) FIREWALL INCLUDE LINE
if [ -f $INPALLOWFILE ]; then
	grep -q -F "$INPINCLUDESTR" $INPALLOWFILE || echo "$INPINCLUDESTR" >>$INPALLOWFILE
else
	echo "ERROR: '$INPALLOWFILE' cannot be located."
	read -n1 -r -p "Press q to abort, or any other key to continue." quitCatch;

	if [ "$quitCatch" == 'q' ]; then
		echo;
		echo "Exiting at your request, and cleaning up."
		echo "DFWU program path: $INPDFWUPROGPATH"
		echo "DFWU config. path: $TMPDFWUINIPATH"
		echo "Please note: if directories were specifically created for DFWU or it's config file, you will need to delete those manually."
		echo;
		rm -rfv $INPDFWUPROGPATH/dfwu.py
		if [ -f $INPDFWUINI ]; then
			rm -rfv $INPDFWUINI
		fi
		echo;
		exit
	fi

fi
#-----/INSERT (or skip if exists) FIREWALL INCLUDE LINE

#----- INSERT ENTRY (or skip if exists) INTO CRONTAB
CRONTAB_NOHEADER='N'
crontab -l >$TMPCRONFILE 2>/dev/null
grep -q -F "$TMPCRONSTR" $TMPCRONFILE || echo "$TMPCRONSTR" >>$TMPCRONFILE
( cat $TMPCRONFILE ) | crontab -
#-----/INSERT ENTRY (or skip if exists) INTO CRONTAB

#----- DELETE TEMPORARY FILES
rm -rf $TMPCRONFILE
#-----/DELETE TEMPORARY FILES

#----- NOTICE: FINISH
echo;
echo "`getVersion $INPDFWUPROGPATH/dfwu.py header`"
echo "Steps taken: $ACTION.";
echo;
#-----/NOTICE: FINISH

#----- MANIFEST CONFIG DATA
GGCOMDATADIR=$ROOTDIR/.ggcom/ddns-utils
echo "Updating GotGet common data in '$GGCOMDATADIR'"
mkdir -pv $GGCOMDATADIR

cat <<!DFWUMANIFEST > $GGCOMDATADIR/dfwu.json
{
	"program": {
		"version": `getVersion $INPDFWUPROGPATH/dfwu.py number`,
		"path": "$INPDFWUPROGPATH",
		"name": "dfwu.py",
		"action": "$ACTION"
	},
	"config": {
		"path": "$TMPDFWUINIPATH",
		"name": "${INPDFWUINI##*/}",
		"action": "$ACTION"
	},
	"cron": {
		"entry": "$TMPCRONSTR"
	},
	"firewall": {
		"path": "`dirname "$INPALLOWFILE"`",
		"name": "${INPALLOWFILE##*/}",
		"line": "$INPINCLUDESTR",
		"action": "modified"
	}
}
!DFWUMANIFEST

echo "GotGet Common manifest data written to '$GGCOMDATADIR/dfwu.json'"
#-----/MANIFEST CONFIG DATA

#----- NOTICE: EDIT
echo;
echo "Opening $INPDFWUINI with your editor ($MYEDITOR) for you to make appropriate changes.";
read -n1 -r -p "Press q to quit, or any other key to continue." quitCatch;
#-----/NOTICE: EDIT

#----- EDITOR
if [ "$quitCatch" == 'q' ]; then
	echo;
	echo "Exiting at your request.  Please don't forget to edit '$INPDFWUINI'."
	echo;
	exit
else
	eval $MYEDITOR $INPDFWUINI
fi
#-----/EDITOR

#----- REFRESH
echo;
read -n1 -r -p "Press any key to now run DFWU the same as it will run every minute from Cron.";
echo;

eval $INPDFWUPROGPATH/dfwu.py $INPDFWUINI
#-----/REFRESH

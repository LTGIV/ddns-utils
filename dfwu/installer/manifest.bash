#----- REQUIRE ROOT
if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root.  Try again with sudo."
	exit 1
fi
#-----/REQUIRE ROOT

#----- ENVIRONMENT VARIABLES
MYEDITOR=${FCEDIT:-${VISUAL:-${EDITOR:-nano}}}
ROOTDIR=~root
MYDIR=$( cd "$(dirname "$BASH_SOURCE")" ; pwd -P )
#-----/ENVIRONMENT VARIABLES

#----- DEFAULT SETTINGS I
TMPINCLUDESTR='Include /etc/csf/csf-ddns.allow'
ACTION='installed'

TMPDFWUPROGPATH='/usr/local/bin'
TMPALLOWFILE='/etc/csf/csf.allow'
TMPDFWUINI="$ROOTDIR/etc/dfwu.ini"
TMPLOC=`mktemp /tmp/csf-allow.XXXXXXXXX`
TMPCRON=`mktemp /tmp/crontab.XXXXXXXXX`
#-----/DEFAULT SETTINGS I

#----- INSTALL SETTINGS
echo;
read -p "Which firewall file? [$TMPALLOWFILE] " INPALLOWFILE
if [ -z "$INPALLOWFILE" ]; then
	INPALLOWFILE=$TMPALLOWFILE
fi

read -p "What firewall line? ['$TMPINCLUDESTR'] " INPINCLUDESTR
if [ -z "$INPINCLUDESTR" ]; then
	INPINCLUDESTR=$TMPINCLUDESTR
fi

read -p "DFWU Program Path? ['$TMPDFWUPROGPATH'] " INPDFWUPROGPATH
if [ -z "$INPDFWUPROGPATH" ]; then
	INPDFWUPROGPATH=$TMPDFWUPROGPATH
fi

read -p "DFWU INI Path? ['$TMPDFWUINI'] " INPDFWUINI
if [ -z "$INPDFWUINI" ]; then
	INPDFWUINI=$TMPDFWUINI
fi
#-----/INSTALL SETTINGS

#----- DEFAULT SETTINGS II
TMPCRONSTR="* * * * * $INPDFWUPROGPATH/dfwu.py $INPDFWUINI"
TMPDFWUINIPATH=$(dirname "$INPDFWUINI")
#-----/DEFAULT SETTINGS II

#----- COPY MAIN APPLICATION
cp -a $MYDIR/../dfwu.py $INPDFWUPROGPATH/dfwu.py
chmod 755 $INPDFWUPROGPATH/dfwu.py
#-----/COPY MAIN APPLICATION

#----- COPY DFWU INI TO DESTINATION
if [ -f $INPDFWUINI ]; then
	ACTION='upgraded'
	echo "Note: $INPDFWUINI exists, not replacing."
else
	mkdir -p $TMPDFWUINIPATH
	chmod -R o-rwx $TMPDFWUINIPATH
	cp -a $MYDIR/../dfwu.ini $INPDFWUINI
	chmod 700 $INPDFWUINI
fi
#-----/COPY DFWU INI TO DESTINATION

#----- INSERT (or skip if exists) FIREWALL INCLUDE LINE
grep -q -F "$INPINCLUDESTR" "$INPALLOWFILE" || echo "$INPINCLUDESTR" >>$INPALLOWFILE
#-----/INSERT (or skip if exists) FIREWALL INCLUDE LINE

#----- INSERT ENTRY (or skip if exists) INTO CRONTAB
CRONTAB_NOHEADER='N'
crontab -l >$TMPCRON 2>/dev/null
grep -q -F "$TMPCRONSTR" $TMPCRON || echo "$TMPCRONSTR" >>$TMPCRON
( cat $TMPCRON ) | crontab -
#-----/INSERT ENTRY (or skip if exists) INTO CRONTAB

#----- DELETE TEMPORARY FILES
rm -rf $TMPLOC
rm -rf $TMPCRON
#-----/DELETE TEMPORARY FILES

#----- NOTICE: FINISH
echo;
echo "DFWU (DDNS Firewall Update) has been $ACTION.";
echo "www.GotGetLLC.com | www.opensour.cc/dfwu";
echo;
#-----/NOTICE: FINISH

#----- NOTICE: EDIT
echo "Opening $TMPDFWUINI with your editor ($MYEDITOR) for you to make appropriate changes.";
read -n1 -r -p "Press q to quit, or any other key to continue." quitCatch;
#-----/NOTICE: EDIT

#----- EDITOR
if [ "$quitCatch" == 'q' ]; then
	echo;
	echo "Exiting at your request.  Please don't forget to edit '$TMPDFWUINI'."
	echo;
	exit
else
	eval $MYEDITOR $TMPDFWUINI
fi
#-----/EDITOR

#----- REFRESH
echo;
read -n1 -r -p "Press any key to now run DFWU the same as it will run every minute from Cron.";
echo;

eval $INPDFWUPROGPATH/dfwu.py $TMPDFWUINI
#-----/REFRESH

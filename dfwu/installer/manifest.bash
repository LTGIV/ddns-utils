#----- REQUIRE ROOT
if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root.  Try again with sudo."
	exit 1
fi
#-----/REQUIRE ROOT

#----- ENVIRONMENT VARIABLES
myeditor=${FCEDIT:-${VISUAL:-${EDITOR:-nano}}}
rootdir=~root
mydir=$( cd "$(dirname "$BASH_SOURCE")" ; pwd -P )
#-----/ENVIRONMENT VARIABLES

#----- DEFAULT SETTINGS I
TMPALLOWFILE='/etc/csf/csf.allow'
TMPINCLUDESTR='Include /etc/csf/csf-ddns.allow'
TMPLOC=`mktemp $mydir/csf-allow.XXXXXXXXX`
TMPCRONSTR="* * * * * /usr/local/bin/ddns-fwu.py $rootdir/etc/dfwu.ini"
TMPCRON=`mktemp $mydir/crontab.XXXXXXXXX`
ACTION='installed'
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
#-----/INSTALL SETTINGS

#----- MOVE MAIN APPLICATION
cp -a $mydir/../ddns-fwu.py /usr/local/bin/
chmod 755 /usr/local/bin/ddns-fwu.py
#-----/MOVE MAIN APPLICATION

#----- MOVE DFWU INI TO root's ~/etc (usually /root/etc) IF DOESN'T EXIST (otherwise, assume an upgrade)
if [ -f $rootdir/etc/dfwu.ini ]; then
	ACTION='upgraded'
	echo "Note: $rootdir/etc/dfwu.ini exists, not replacing."
else
	mkdir -p $rootdir/etc
	chmod -R o-rwx $rootdir/etc
	cp -a $mydir/../dfwu.ini $rootdir/etc/dfwu.ini
	chmod 700 $rootdir/etc/dfwu.ini
fi
#-----/MOVE DFWU INI

#----- INSERT (or skip if exists) FIREWALL INCLUDE LINE
grep -q -F "$INPINCLUDESTR" $INPALLOWFILE || echo "$INPINCLUDESTR" >> $INPALLOWFILE
#-----/INSERT (or skip if exists) FIREWALL INCLUDE LINE

#----- INSERT ENTRY (or skip if exists) INTO CRONTAB
CRONTAB_NOHEADER='N'
crontab -l > $TMPCRON 2>/dev/null
grep -q -F "$TMPCRONSTR" $TMPCRON || echo "$TMPCRONSTR" >> $TMPCRON
( cat $TMPCRON ) | crontab -
#-----/INSERT ENTRY (or skip if exists) INTO CRONTAB

#----- DELETE TEMPORARY FILES
rm -rf $TMPLOC
rm -rf $TMPCRON
#-----/DELETE TEMPORARY FILES

#----- GARBAGE COLLECTION
unset TMPALLOWFILE INPALLOWFILE
unset TMPINCLUDESTR INPINCLUDESTR
unset TMPLOC TMPCRONSTR
#-----/GARBAGE COLLECTION

#----- NOTICE: FINISH
echo;
echo "DFWU (DDNS Firewall Update) has been $ACTION.";
echo "www.GotGetLLC.com | www.opensour.cc/dfwu";
echo;
#-----/NOTICE: FINISH

#----- NOTICE: EDIT
echo "Opening $rootdir/etc/dfwu.ini with your editor ($myeditor) for you to make appropriate changes.";
read -n1 -r -p "Press q to quit, or any other key to continue." quitCatch;
#-----/NOTICE: EDIT

#----- EDITOR
if [ "$quitCatch" == 'q' ]; then
	echo;
	echo "Exiting at your request.  Please don't forget to edit '$rootdir/etc/dfwu.ini'."
	echo;
	exit
else
	eval $myeditor $rootdir/etc/dfwu.ini
fi
#-----/EDITOR

echo;
read -n1 -r -p "Press any key to now run DFWU the same as it will run every minute from Cron.";
echo;

#----- REFRESH
/usr/local/bin/ddns-fwu.py $rootdir/etc/dfwu.ini
#-----/REFRESH

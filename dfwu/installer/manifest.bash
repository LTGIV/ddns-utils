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
TMPCRON1=`mktemp $mydir/crontab.XXXXXXXXX`
TMPCRON2=`mktemp $mydir/crontab.XXXXXXXXX`
#-----/DEFAULT SETTINGS I

#----- INSTALL SETTINGS
read -p "Which firewall file? [$TMPALLOWFILE] " INPALLOWFILE
if [ -z "$INPALLOWFILE" ]; then
	INPALLOWFILE=$TMPALLOWFILE
fi

read -p "What firewall line? [$TMPINCLUDESTR] " INPINCLUDESTR
if [ -z "$INPINCLUDESTR" ]; then
	INPINCLUDESTR=$TMPINCLUDESTR
fi
#-----/INSTALL SETTINGS

#----- MOVE MAIN APPLICATION
mv -v $mydir/../ddns-fwu.py /usr/local/bin/
chmod 755 /usr/local/bin/ddns-fwu.py
#-----/MOVE MAIN APPLICATION

#----- MOVE DFWU INI TO root's ~/etc (usually /root/etc) IF DOESN'T EXIST (otherwise, assume an upgrade)
if [ -f $rootdir/etc/dfwu.ini ]; then
	echo "$rootdir/etc/dfwu.ini exists, not replacing."
else
	mkdir -pv $rootdir/etc
	mv -v $mydir/../dfwu.ini $rootdir/etc/dfwu.ini
fi
#-----/MOVE DFWU INI

#----- INSERT (or skip if exists) FIREWALL INCLUDE LINE
sed -e "\|$INPINCLUDESTR|h; \${x;s|$INPINCLUDESTR||;{g;t};a\\" -e "$INPINCLUDESTR" -e "}" $INPALLOWFILE > $TMPLOC
cat $TMPLOC | tee $INPALLOWFILE > /dev/null
#-----/INSERT (or skip if exists) FIREWALL INCLUDE LINE

#----- INSERT ENTRY (or skip if exists) INTO CRONTAB
CRONTAB_NOHEADER='N'
crontab -l > $TMPCRON1

sed -e "\|$TMPCRONSTR|h; \${x;s|$TMPCRONSTR||;{g;t};a\\" -e "$TMPCRONSTR" -e "}" $TMPCRON1 > $TMPCRON2
cat $TMPCRON2 | tee $TMPCRON1 > /dev/null

( cat $TMPCRON1 ) | crontab -
#-----/INSERT ENTRY (or skip if exists) INTO CRONTAB

#----- DELETE TEMPORARY FILES
rm -rfv $TMPLOC
rm -rfv $mydir/../../../ddns-utils/
#-----/DELETE TEMPORARY FILES

#----- GARBAGE COLLECTION
unset TMPALLOWFILE INPALLOWFILE
unset TMPINCLUDESTR INPINCLUDESTR
unset TMPLOC
#-----/GARBAGE COLLECTION

#----- NOTICE: FINISH
echo "DFWU (DDNS Firewall Update) has been installed.";
echo "www.GotGetLLC.com | www.opensour.cc/dfwu";
echo;
#-----/NOTICE: FINISH

#----- NOTICE: EDIT
echo "Opening $rootdir/etc/dfwu.ini with your editor ($myeditor) for you to make appropriate changes.";
read -n1 -r -p "Press q to quit or any other key to continue..." quitCatch;
#-----/NOTICE: EDIT

#----- EDITOR
if [ "$quitCatch" == 'q' ]; then
	exit
else
	eval $myeditor $rootdir/etc/dfwu.ini
fi
#-----/EDITOR

#----- REFRESH
/usr/local/bin/ddns-fwu.py $rootdir/etc/dfwu.ini
#-----/REFRESH

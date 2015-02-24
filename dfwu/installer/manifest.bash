if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root.  Try again with sudo."
	exit 1
fi

mv -v ~/src/ddns-utils/dfwu/ddns-fwu.py /usr/local/bin/
chmod 755 /usr/local/bin/ddns-fwu.py

mkdir -pv ~/etc
mv -v ~/src/ddns-utils/dfwu/dfwu.ini ~/etc/

TMP83527184a914fda6b533f0a76cefd5cd26c1331f=`mktemp /tmp/ggcom.XXXXXXXXX`
TMP2c568f7aef2e18176d468d1c5e594af94e05084c='Include /etc/csf/csf-ddns.allow'
sed -e "\|$TMP2c568f7aef2e18176d468d1c5e594af94e05084c|h; \${x;s|$TMP2c568f7aef2e18176d468d1c5e594af94e05084c||;{g;t};a\\" -e "$TMP2c568f7aef2e18176d468d1c5e594af94e05084c" -e "}" /etc/csf/csf.allow > $TMP83527184a914fda6b533f0a76cefd5cd26c1331f
cat $TMP83527184a914fda6b533f0a76cefd5cd26c1331f | tee /etc/csf/csf.allow
rm -rfv $TMP83527184a914fda6b533f0a76cefd5cd26c1331f
unset TMP83527184a914fda6b533f0a76cefd5cd26c1331f TMP2c568f7aef2e18176d468d1c5e594af94e05084c

CRONTAB_NOHEADER='N'
( crontab -l ; echo "* * * * * /usr/local/bin/ddns-fwu.py $HOME/etc/dfwu.ini" ) | crontab -

rm -rfv ~/src/ddns-utils/

/usr/local/bin/ddns-fwu.py $HOME/etc/dfwu.ini

echo "DFWU (DDNS Firewall Update) has been installed.";
echo "www.GotGetLLC.com | www.opensour.cc/dfwu";
echo;
echo "Please update $HOME/etc/dfwu.ini with your preferred settings.";

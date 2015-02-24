if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root.  Try again with sudo."
	exit 1
fi

mkdir -pv ~/src
rm -rfv ~/src/ddns-utils/
git clone https://github.com/LTGIV/ddns-utils.git ~/src/ddns-utils

source ~/src/ddns-utils/dfwu/installer/manifest.bash

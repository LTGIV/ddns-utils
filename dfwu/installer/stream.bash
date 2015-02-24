mytmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'dfwu'`

git clone https://github.com/LTGIV/ddns-utils.git $mytmpdir

sudo bash $mytmpdir/dfwu/installer/manifest.bash

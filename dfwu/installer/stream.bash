#!/usr/bin/env bash
#
# DFWU (DDNS Firewall Update) Installer-Stream v201502260810
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/dfwu
#
# Example usage:
# bash <(curl -s https://raw.githubusercontent.com/LTGIV/ddns-utils/master/dfwu/installer/stream.bash||wget -q -O - https://raw.githubusercontent.com/LTGIV/ddns-utils/master/dfwu/installer/stream.bash||echo 'DFWU Install Failure.'>&2)

hash python 2>/dev/null || { echo >&2 "DFWU requires Python.  Please install, and try again."; exit 1; }
hash git 2>/dev/null || { echo >&2 "DFWU Installer requires git.  Please install, and try again."; exit 1; }

# Temporary directory to clone into
mytmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'dfwu'`

# Download entire package
git clone https://github.com/LTGIV/ddns-utils.git $mytmpdir

# Run main installer
sudo bash $mytmpdir/dfwu/installer/manifest.bash

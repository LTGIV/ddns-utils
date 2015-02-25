#!/usr/bin/env bash
#
# DFWU (DDNS Firewall Update) Installer-Manifest v201502250259
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/dfwu
#
# bash <(curl -s https://raw.githubusercontent.com/LTGIV/ddns-utils/master/dfwu/installer/stream.bash)

# Temporary directory to clone into
mytmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'dfwu'`

# Download entire package
git clone https://github.com/LTGIV/ddns-utils.git $mytmpdir

# Run main installer
sudo bash $mytmpdir/dfwu/installer/manifest.bash

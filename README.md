# ddns-utils
DDNS Client Updater and DFWU (DDNS Firewall Update)

https://www.opensour.cc/gotget/ddns-utils/ (coming soon)
https://www.GotGetLLC.com/

DFWU Turnkey install:
  curl -s https://raw.githubusercontent.com/LTGIV/ddns-utils/master/dfwu/installer/stream.bash | sudo ${0#-} /dev/stdin

DFWU Manual install:
```
sudo mkdir -pv ~/src
sudo rm -rfv ~/src/ddns-utils/
sudo git clone https://github.com/LTGIV/ddns-utils.git ~/src/ddns-utils
sudo source ~/src/ddns-utils/dfwu/installer/manifest.bash
```
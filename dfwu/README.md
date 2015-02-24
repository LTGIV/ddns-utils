# ddns-utils package:
## DFWU (DDNS Firewall Update)
https://www.opensour.cc/dfwu *(coming soon)*  
https://www.GotGetLLC.com/

[Louis T. Getterman IV](https://github.com/LTGIV) ([@LTGIV](https://twitter.com/LTGIV))
  
DFWU is geared towards hosts that need to remain closed to the world, but open to select nodes which have ephemeral IP addresses.  
  
Examples include:  
1. SIP Server with users working remotely.  
2. MQTT Server with weather station nodes deployed out in the field.

## DFWU Turnkey install:
`bash <(curl -s https://raw.githubusercontent.com/LTGIV/ddns-utils/master/dfwu/installer/stream.bash)`

## DFWU Manual install:
```
git clone https://github.com/LTGIV/ddns-utils.git
sudo bash ddns-utils/dfwu/installer/manifest.bash
```

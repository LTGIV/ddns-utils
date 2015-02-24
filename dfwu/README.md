# DFWU
> Add 'Include /etc/csf/csf-ddns.allow' to csf.allow

> Save this Python 2 script to /usr/local/bin/ddns-fwu.py

> Create /root/etc/dfwu.ini with the following contents:

# ------------------------------------------------------------------------------
[core]
fwFile		=	'/etc/csf/csf-ddns.allow'
fwFileBytes	=	1000
fwName		=	'/usr/sbin/csf'
fwArgs		=	'--restart'

[sshIn]
rule	=	tcp|in|d=22|s=%host%
hosts	=	server1.freedns.afraid.org, server2.freedns.afraid.org, server3.freedns.afraid.org

[webminIn]
rule	=	tcp|in|d=10000|s=%host%
hosts	=	server1.freedns.afraid.org
# ------------------------------------------------------------------------------

> Run 'sudo crontab -e' and add the following entry for a per-minute check
> (and assuming you have a FreeDNS pro account and using 60 TTL - if you get one because of this, tell Joshua Anderson et al. that I sent you)

* * * * * /usr/local/bin/ddns-fwu.py /root/etc/dfwu.ini

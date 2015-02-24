#!/usr/bin/env python
'''

FreeDNS Client v201502222153
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com / www.opensour.cc

##### FIX THIS ######Example usage with CSF (ConfigServer Security & Firewall):
##### FIX THIS ######/usr/local/bin/ddns-fwu.py /root/etc/dfwu.ini

Please see README for automation instructions.

'''

# Prerequisite modules
from configobj import ConfigObj
import inspect, os, sys, socket, hashlib

# Main method
def main():

	# Program Variables
	prog			=	{ 'stack' : inspect.stack()[-1][1] }
	prog['path']	=	os.path.dirname( os.path.abspath( prog[ 'stack' ] ) )
	prog['name']	=	os.path.basename( prog[ 'stack' ] )

	# Configuration
	try:
		fileIni			=	sys.argv[1]
		config			=	ConfigObj( fileIni )
		if ( os.path.isfile( fileIni ) == False ):
			raise Exception( "'%s' does not exist!" % ( fileIni ) )
	except Exception, e:
		print 'DFWU: failed with configuration file (%s)' % e
		sys.exit()

# Program called directly
if __name__ == "__main__":
	main()

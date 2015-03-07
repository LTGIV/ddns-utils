#!/usr/bin/env python
'''

DFWU (DDNS Firewall Update) Uninstaller v201503071433
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/dfwu

Example usage:
sudo ddns-utils/dfwu/installer/uninstaller.py

'''

################################################################################################################
#obj=json.load()
#python -c 'import json,sys;obj=json.load(sys.stdin);print obj["hostname"]'
################################################################################################################

# Prerequisite modules
import sys
import os
import time
try:
	from configobj import ConfigObj
	import getpass
	import json
	import argparse
except Exception, e:
	print 'DFWU: failed to import prerequisite modules (%s)' % e
	sys.exit()

# Me, myself, and I
ME			=	sys.argv[0]
versLine	=	os.popen( "head -n5 '%s' | grep -n 'v[0-9]' | cut -f1 -d:" % ( ME ) ).read().strip()
versHead	=	os.popen( "tail -n+'%s' '%s' | head -n3 | sed 's/# *//g'" % ( versLine, ME ) ).read().strip()
versProg	=	os.popen( "echo '%s' | head -n1" % ( versHead ) ).read().strip()
versNum		=	os.popen( "echo '%s' | grep -Eo 'v[0-9]{1,}' | grep -Eo '[0-9]{1,}'" % ( versHead ) ).read().strip()

#----- NOTICE: INFO
print ( '-'*79 ) + '\n' + versHead + '\n' + ( '-'*79 )
#-----/NOTICE: INFO

# User Check
if ( getpass.getuser() != 'root'.lower() ):
	print '\nSorry, you are not root.  Please try again with sudo.\n'
	sys.exit()

# Additional options
parser = argparse.ArgumentParser( description='DFWU Uninstaller' )
parser.add_argument( '--scorchedearth', action='store_true', help='verbose flag' )
args = parser.parse_args()
if ( args.scorchedearth == False ):
	print 'NOTE: This program could be capable of causing life-changing events, including stroke or heart-attack.'
	print 'If you want it to do the dirty work for you (and risk aforementioned health ailments if something goes wrong),',"You must give it the argument of '--scorchedearth', for which you assume all responsibility."
	print '-'*79
	pass

# Environment Variables
ROOTDIR=os.path.expanduser("~root")
GGCOMDATADIR=ROOTDIR+'/.ggcom/ddns-utils'
MANIFESTFILE=GGCOMDATADIR+'/dfwu.json'

# Configuration
try:
	if ( os.path.isfile( MANIFESTFILE ) == False ):
		raise Exception( "'%s' does not exist!" % ( MANIFESTFILE ) )
	else:
		manifestconfig			=	json.loads( open( MANIFESTFILE ).read( 1000 ) )
except Exception, e:
	print 'DFWU Uninstaller: failed with manifest file (%s)' % e
	sys.exit()

# Remove crontab entry
cronJson	=	manifestconfig.get( 'cron', {} )
cronEntry	=	cronJson.get( 'entry', ( '%s/%s %s/%s' % ( manifestconfig['program']['path'], manifestconfig['program']['name'], manifestconfig['config']['path'], manifestconfig['config']['name'] ) ) )
print "* Removing matching entry from crontab: '%s'" % ( cronEntry )
if (args.scorchedearth):
	if ( os.popen( '(CRONTAB_NOHEADER="N"; crontab -l | grep -F "'+cronEntry+'";) 2>/dev/null' ).read() != "" ):
		print "** crontab entry found, attempting to remove."
		os.popen( '(CRONTAB_NOHEADER="N"; crontab -l | grep -v -F "'+cronEntry+'" | crontab -;)' ).read()
		if ( os.popen( '(CRONTAB_NOHEADER="N"; crontab -l | grep -F "'+cronEntry+'";) 2>/dev/null' ).read() == "" ):
			print "*** crontab entry removed."
	else:
		print "** crontab entry not found."

# Remove DFWU include rule from firewall file (e.g. /etc/csf/csf.allow)
delDFWUfile=True
print "* Attempting to remove DFWU entry from firewall configuration:"
try:
	target	=	'%s/%s' % ( manifestconfig['firewall']['path'], manifestconfig['firewall']['name'] ) # e.g. /etc/csf/csf.allow
	print "** Looking in firewall configuration '%s'" % ( target )
except Exception, e:
	print '** ERROR: Firewall information not found in DFWU manifest.  You will need to manually remove the entry from the firewall configuration (default configuration with CSF is /etc/csf/csf.allow).'
	delDFWUFile=False
if ( args.scorchedearth and delDFWUfile ):
	print "*** Removing entry from '%s'" % ( target )
	os.popen( 'grep -v -F "%s" "%s" > "%s"' % (
		manifestconfig['firewall']['line'], # e.g. 'Include /etc/csf/csf-ddns.allow'
		target,
		( target+'-uninstalldfwu' )
	) ).read()
	os.popen( 'cat %s > %s' % ( ( target+'-uninstalldfwu' ), target ) ).read()
	os.unlink( (target+'-uninstalldfwu') )

# Parse DFWU ini to remove DFWU's firewall file
try:
	dfwuIni				=	manifestconfig['config']['path']+'/'+manifestconfig['config']['name']
except Exception, e:
	print "Cannot locate DFWU Configuration file.  Exiting."
	sys.exit()
if ( delDFWUfile ): # e.g. /etc/csf/csf.allow was found in DFWU manifest
	print "* Parsing DFWU configuration file '%s' to remove firewall-related files." % ( dfwuIni )
	dfwuConfig			=	ConfigObj( dfwuIni )
	fwFile				=	dfwuConfig['core']['fwFile'] # e.g. /etc/csf/csf-ddns.allow
	fwName				=	dfwuConfig['core']['fwName'] # e.g. /usr/sbin/csf
	fwArgs				=	dfwuConfig['core']['fwArgs'] # e.g. --restart
	print "* Adding DFWU firewall file to removal list: '%s'" % (fwFile)
	manifestconfig.update( { "dfwuFile":{ "path":os.path.dirname(fwFile), "name":os.path.basename(fwFile), "action":"installed" } } )
	del dfwuConfig
else:
	print "SKIPPING: DFWU configuration file '%s' to remove firewall-related files." % ( dfwuIni )

# Remove installed files
for k, v in manifestconfig.iteritems():
	target	=	v.get( 'path', '' ) + '/' + v.get( 'name', '' )

	if ((
		( v.get( 'action', '' ).lower() == 'installed' )
		or
		( v.get( 'action', '' ).lower() == 'upgraded' )
		)
		and ( os.path.isfile( target ) == True )
	):
		print "* Removed '%s'" % ( target )
		if ( args.scorchedearth ):
			os.unlink( target )
	pass # END FOR
print '-'*79
print "Please note: if directories were specifically created for DFWU or it's config file, you will need to delete those manually."
print '-'*79

# Restart firewall
print "Restarting firewall using commands parsed from DFWU's configuration file:"
print '-'*79
if ( args.scorchedearth ):
	print os.popen( fwName+' '+fwArgs ).read()
print '-'*79

# Removing DFWU Manifest
print "Removing DFWU Manifest (%s)" % ( MANIFESTFILE )
if ( args.scorchedearth ):
	os.unlink( MANIFESTFILE )
	pass # END IF

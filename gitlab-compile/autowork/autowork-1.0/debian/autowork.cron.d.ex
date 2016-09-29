#
# Regular cron jobs for the autowork package
#
0 4	* * *	root	[ -x /usr/bin/autowork_maintenance ] && /usr/bin/autowork_maintenance

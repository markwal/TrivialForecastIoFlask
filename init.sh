#!/bin/sh

### BEGIN INIT INFO
# Provides:          tforecast
# Required-Start:    $local_fs networking
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: TrivialForecastIoFlask daemon
# Description:       Starts a python flask server to summarize forecast.io API results
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="TrivialForecastIoFlask daemon"
NAME="tforecast"
DAEMON=/home/pi/TrivialForecastIoFlask/tforecast
DAEMON_USER=pi
PIDFILE=/var/run/$NAME.pid
PKGNAME=tforecast
SCRIPTNAME=/etc/init.d/$PKGNAME

# Read configuration variable file if it is present
[ -r /etc/default/$PKGNAME ] && . /etc/default/$PKGNAME

# Exit if the octoprint is not installed
[ -x "$DAEMON" ] || exit 0

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

#
# Function to verify if a pid is alive
#
is_alive()
{
   pid=`cat $1` > /dev/null 2>&1
   kill -0 $pid > /dev/null 2>&1
   return $?
}

#
# Function that starts the daemon/service
#
do_start()
{
   # Return
   #   0 if daemon has been started
   #   1 if daemon was already running
   #   2 if daemon could not be started

   is_alive $PIDFILE
   RETVAL="$?"

   if [ $RETVAL != 0 ]; then
       start-stop-daemon --start --background --quiet --pidfile $PIDFILE --make-pidfile \
       --exec $DAEMON --chuid $DAEMON_USER --user $DAEMON_USER --umask $UMASK -- $DAEMON_ARGS
       RETVAL="$?"
   fi
}

#
# Function that stops the daemon/service
#
do_stop()
{
   # Return
   #   0 if daemon has been stopped
   #   1 if daemon was already stopped
   #   2 if daemon could not be stopped
   #   other if a failure occurred

   start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --user $DAEMON_USER --pidfile $PIDFILE
   RETVAL="$?"
   [ "$RETVAL" = "2" ] && return 2

   rm -f $PIDFILE

   [ "$RETVAL" = "0"  ] && return 0 || return 1
}

case "$1" in
  start)
   [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
   do_start
   case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
   esac
   ;;
  stop)
   [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
   do_stop
   case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
   esac
   ;;
  restart)
   log_daemon_msg "Restarting $DESC" "$NAME"
   do_stop
   case "$?" in
     0|1)
      do_start
      case "$?" in
         0) log_end_msg 0 ;;
         1) log_end_msg 1 ;; # Old process is still running
         *) log_end_msg 1 ;; # Failed to start
      esac
      ;;
     *)
        # Failed to stop
      log_end_msg 1
      ;;
   esac
   ;;
  *)
   echo "Usage: $SCRIPTNAME {start|stop|restart}" >&2
   exit 3
   ;;
esac


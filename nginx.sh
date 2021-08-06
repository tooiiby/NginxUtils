#!/bin/bash

echo '...begin...'
if [ $# -lt 1 ]; then
  echo $0 need a host parameter
  exit 0
fi

host=$1
ipfile=/root/ddns/"$host.ini"
runlogfile=/root/ddns/"current.log"
reloadlogfile=/root/ddns/"crontab.log"
echo `date`'...read ip...'>>"$runlogfile" >&1

if [ ! -f "$ipfile" ]; then
  #touch "$ipfile"
  sh /root/ddns/ipip.sh "$host" > "$ipfile"
fi

oldIpAddress=`cat /root/ddns/$host.ini |head -n 1`
curIpAddress=`sh /root/ddns/ipip.sh "$host"`
echo `date`'...oldIpAddress='${oldIpAddress} >>"$runlogfile"
echo `date`'...curIpAddress='${curIpAddress} >>"$runlogfile"

if [ "$oldIpAddress" != "$curIpAddress" ];then
  echo '..oldIpAddress:'${oldIpAddress}'!=curIpAddress:'${curIpAddress}'.......' >>"$runlogfile"
  /etc/nginx/sbin/nginx -s reload
  echo '...nginx -s reload....' >>"$runlogfile"
  sh /root/ddns/ipip.sh "$host" > "$ipfile"
  echo `date`'...ipchanged..oldIpAddress:'${oldIpAddress}'!=curIpAddress:'${curIpAddress}'...nginx -s reload!' >>"$reloadlogfile"
fi

echo '...end ...'

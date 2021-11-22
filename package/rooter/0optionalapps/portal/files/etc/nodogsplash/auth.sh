#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Portal Auth" "$@"
}

handle_pass() {
	local pass=$1
	if [ $cnt -eq $counter ]; then
		newpass=$pass
	fi
	cnt=$((${cnt}+1))
}

do_pass() {
	local config=$1
	config_list_foreach "$config" password handle_pass
}

METHOD="$1"
MAC="$2"
USERNAME="$3"
PASSWORD="$4"

counter=$(uci -q get nodogsplash.password.counter)
max=$(uci -q get nodogsplash.password.max)
if [ -z $counter ]; then
	newpass="admin"
else
	cnt=1
	config_load nodogsplash
	config_foreach do_pass password
fi

case "$METHOD" in
  auth_client)
    if [ "$USERNAME" = "admin" -a "$PASSWORD" = $newpass ]; then
      # Allow client to access the Internet for one hour (3600 seconds)
      # Further values are upload and download limits in bytes. 0 for no limit.
      echo 3600 0 0
	  if [ ! -z $counter ]; then
		RANDOM=$(date +%s%N | cut -b10-19)
		counter=$(( $RANDOM % $max ))
		if [ $counter -gt $max ]; then
			counter=1
		fi
		if [ $counter -eq 0 ]; then
			counter=$max
		fi
		uci set nodogsplash.password.counter=$counter
		uci commit nodogsplash
	  fi
      exit 0
    else
      # Deny client to access the Internet.
      exit 1
    fi
    ;;
  client_auth|client_deauth|idle_deauth|timeout_deauth|ndsctl_auth|ndsctl_deauth|shutdown_deauth)
    INGOING_BYTES="$3"
    OUTGOING_BYTES="$4"
    SESSION_START="$5"
    SESSION_END="$6"
    # client_auth: Client authenticated via this script.
    # client_deauth: Client deauthenticated by the client via splash page.
    # idle_deauth: Client was deauthenticated because of inactivity.
    # timeout_deauth: Client was deauthenticated because the session timed out.
    # ndsctl_auth: Client was authenticated by the ndsctl tool.
    # ndsctl_deauth: Client was deauthenticated by the ndsctl tool.
    # shutdown_deauth: Client was deauthenticated by Nodogsplash terminating.
    ;;
esac
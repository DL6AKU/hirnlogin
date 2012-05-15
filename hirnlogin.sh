#!/bin/bash

#######################################################################
# Modify this:                                                        #
#######################################################################
_USER='foo' # Login-ID, e.g. meiera9d
_PASS='bar' # Password

#######################################################################
# Don't change anything past this                                     #
#######################################################################
_USERAGENT='Mozilla/5.0 (X11; Linux x86_64; rv:12.0) Gecko/20100101 Firefox/12.0'
_STARTURL='https://login.rz.ruhr-uni-bochum.de/cgi-bin/start'
_POSTURL='https://login.rz.ruhr-uni-bochum.de/cgi-bin/laklogin' 
_CACERT='/etc/ssl/certs/Deutsche_Telekom_Root_CA_2.pem' 
_POST="loginid=$_USER&password=$_PASS&action=Login"

curl -s -1 -4 -A "$_USERAGENT" --cacert "$_CACERT" "$_STARTURL" | grep -q "des Zugangs Ihre Identifikation und das zugeh&ouml;rige Passwort ein."
_EXIT=$?
if [ $_EXIT -ne 0 ]; then
  echo $_EXIT
  exit $_EXIT
fi
curl -s -1 -4 -A "$_USERAGENT" -d "$_POST" -e "$_STARTURL" -cacert "$_CACERT" "$_POSTURL" | grep -q "gelungen"
_EXIT=$?
if [ $_EXIT -ne 0 ]; then
  echo $_EXIT
  exit $_EXIT
fi

unset _USER
unset _PASS

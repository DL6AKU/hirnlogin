#!/bin/sh
# Copyright (c) 2014, Michael Düll <michael.duell@rub.de>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#######################################################################
# Modify this:                                                        #
# Deine Daten eintragen:                                              #
#######################################################################
_USER='userna7o' # Username (Login-ID) / Benutzer (Login-ID)
_PASS='myp4ssw0rd' # Password / Passwort

#######################################################################
# Don't change anything past this line!                               #
# Nach dieser Zeile nichts mehr ändern!                               #
#######################################################################
_USERAGENT='HIRN Login Script v0.5'
_STARTURL='https://login.rz.ruhr-uni-bochum.de/cgi-bin/start'
_POSTURL='https://login.rz.ruhr-uni-bochum.de/cgi-bin/laklogin' 
_CACERT='/etc/ssl/certs/Deutsche_Telekom_Root_CA_2.pem' 
_ISINTERNETUP='google.com'
_CHECKSTRING='des Zugangs Ihre Identifikation und das zugeh&ouml;rige Passwort ein.'
_SUCCESSSTRING='gelungen'

# Check if we can reach "the internet". If we're already online, we exit.
ping -W 1 -c 1 $_ISINTERNETUP >/dev/null 2>&1
_EXIT=$?
if [ $_EXIT -eq 0 ]; then
    echo "Already logged in: Exiting..."
    exit 0
fi

# Check if we're really at a HIRN Port.
curl -s -1 -4 -A "$_USERAGENT" --cacert "$_CACERT" "$_STARTURL" 2>/dev/null | grep -q "$_CHECKSTRING"
_EXIT=$?
if [ $_EXIT -ne 0 ]; then
  echo "Cannot reach HIRN-Port."
  exit 2
fi

# Get the IP address and complete the POST data
_IPADDR=`curl -s -1 -4 -A "$_USERAGENT" --cacert "$_CACERT" "$_STARTURL" | grep ipaddr| cut -d '"' -f 8`
_POST="code=1&loginid=$_USER&password=$_PASS&ipaddr=$_IPADDR&action=Login"

# Do the Login
curl -s -1 -4 -A "$_USERAGENT" -d "$_POST" -e "$_STARTURL" --cacert "$_CACERT" "$_POSTURL" | grep -q "$_SUCCESSSTRING"
_EXIT=$?
if [ $_EXIT -ne 0 ]; then
  echo "Login failed!"
  exit 1
fi

unset _USER
unset _PASS

exit 0

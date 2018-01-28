#!/bin/sh
# Copyright (c) 2014, Michael Düll <michael.duell@rub.de>
# All rights reserved.
#
# Modifications: (c) 2014, Jan Holthuis <jan.holthuis@rub.de>
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
_USER='' # Username (Login-ID) / Benutzer (Login-ID)
_PASS='' # Password / Passwort

#######################################################################
# Don't change anything past this line!                               #
# Nach dieser Zeile nichts mehr ändern!                               #
#######################################################################
_USERAGENT='HIRN Login Script v0.6'
_STARTURL='https://login.rz.ruhr-uni-bochum.de/cgi-bin/start'
_POSTURL='https://login.rz.ruhr-uni-bochum.de/cgi-bin/laklogin'
_CACERT='/etc/ssl/certs/Deutsche_Telekom_Root_CA_2.pem'
_CACERTURL='https://www.pki.dfn.de/fileadmin/PKI/zertifikate/deutsche-telekom-root-ca-2.pem'
_ISINTERNETUP='google.com'
_CHECKSTRING='des Zugangs Ihre Identifikation und das zugeh&ouml;rige Passwort ein.'
_SUCCESS_LOGIN_STRING='gelungen'
_SUCCESS_LOGOUT_STRING='erfolgreich'

# Check for login or logout action
if [ "$1" == "login" ]; then
    _ACTION="Login"
    _SUCCESSSTRING=$_SUCCESS_LOGIN_STRING
elif [ "$1" == "logout" ]; then
    _ACTION="Logout"
    _SUCCESSSTRING=$_SUCCESS_LOGOUT_STRING
else
    echo "Usage: $0 <action>"
    echo "Action: login, logout"
    exit 7
fi

# Check if we can reach "the internet". If we're already online, we exit.
ping -W 1 -c 1 $_ISINTERNETUP >/dev/null 2>&1
_EXIT=$?
if [ $_ACTION == "Login" -a $_EXIT -eq 0 ]; then
    echo "Already logged in: Exiting..."
    exit 0
elif [ $_ACTION == "Logout" -a $_EXIT -ne 0 ]; then
    echo "Already logged out: Exiting..."
    exit 0
fi

# Check if CA certificate is in place
if ! [ -e $_CACERT ] ; then
    echo "CA certificate not found. The certificate is available at:"
    echo "$_CACERTURL"
    echo "If you already downloaded the certificate, please make sure that you put it in the right location ($_CACERT)."
    exit 4
fi

# Check if CA certificate is readable
if ! [ -r $_CACERT ] ; then
    echo "CA certificate file $_CACERT is not readable by current user $USER."
    exit 5
fi

# Check if curl is installed and in $PATH
if ! curl_installed=$(type -p "curl") || [ -z "$curl_installed" ]; then
    echo "Cannot find \"curl\" executable. Are you sure it's installed?"
    exit 6
fi

# Check if we're really at a HIRN Port.
curl -s -1 -4 -A "$_USERAGENT" --cacert "$_CACERT" "$_STARTURL" 2>/dev/null | grep -q "$_CHECKSTRING"
_EXIT=$?
if [ $_EXIT -ne 0 ]; then
    echo "Cannot reach HIRN-Port."
    exit 2
fi

# Check if user entered login credentials (i.e. check if $_USER and $_PAth are zero-length strings)
if [ -z $_USER ] || [ -z $_PASS ]; then
    echo "Login credentials not set. Please edit this file and fill in values for \$_USER and \$_PASS."
    exit 3
fi

# Get the IP address and complete the POST data
_IPADDR=`curl -s -1 -4 -A "$_USERAGENT" --cacert "$_CACERT" "$_STARTURL" | grep ipaddr| cut -d '"' -f 8`
_POST="code=1&loginid=$_USER&password=$_PASS&ipaddr=$_IPADDR&action=$_ACTION"

# Do the Login
curl -s -1 -4 -A "$_USERAGENT" -d "$_POST" -e "$_STARTURL" --cacert "$_CACERT" "$_POSTURL" | grep -q "$_SUCCESSSTRING"
_EXIT=$?
if [ $_EXIT -ne 0 ]; then
    echo "Something went wrong!"
    echo "If you tried to login you may check if the login credentials are correct."
    exit 1
else
    echo "$_ACTION successfull!"
fi

unset _USER
unset _PASS

exit 0

hirnlogin - Login-Script for [lock-and-key workstations](http://www.rz.ruhr-uni-bochum.de/dienste/netze/hirnport.html#LockAndKey)
==================================================

How to Install
----------------------------

###Prerequisites

The script needs ```curl``` to be installed.

You also need to download the CA certificate (*Deutsche Telekom Root CA 2*) in PEM format. You can download the certificate (here)[https://www.pki.dfn.de/root/globalroot/]

After download, you may want to check if the SHA-256 on the website matches your downloaded file:
```bash
sha256sum deutsche-telekom-root-ca-2.pem
```

You need to move the PEM file to ```/etc/ssl/certs/Deutsche_Telekom_Root_CA_2.pem```:
```bash
mv deutsche-telekom-root-ca-2.pem /etc/ssl/certs/Deutsche_Telekom_Root_CA_2.pem
```

### Installation and Configuration

Simply download the script or clone the git repository:

```bash
git clone https://github.com/Holzhaus/hirnlogin.git
```

You can then open the file ```hirnlogin.sh``` with your favourite text editor (e.g. ```nano```):
```bash
cd hirnlogin
nano hirnlogin.sh
```

Now , you need to look for these lines:
```bash
_USER='' # Username (Login-ID) / Benutzer (Login-ID)
_PASS='' # Password / Passwort
```

Enter your login credentials, save and close the file.
```bash
_USER='loginid' # Username (Login-ID) / Benutzer (Login-ID)
_PASS='password' # Password / Passwort
```

At last, the file has to be made executable:
```bash
chmod +x hirnlogin.sh
```


Frequently asked questions (FAQ)
--------------------------------------

### Why should I use this?

You may ask yourself: "Why should i use this, when i can simply use this wget command I found somewhere on the net?"

```bash
wget --no-proxy --auth-no-challenge --referer=http://login.rz.ruhr-uni-bochum.de/cgi-bin/start --secure-protocol=auto --no-check-certificate https://login.rz.ruhr-uni-bochum.de/cgi-bin/laklogin --post-data="loginid=LOGIN-ID&password=PASSWORT&action=Login" --delete-after
```

The answer is simple: As you can see, this command comes with the ```--no-check-certificate``` option, which obviously disables certificate checks. Thus, ```wget``` doesn't check the server certificate against the corresponding certificate authority and also skips checking if the hostname matches the common name presented by the certificate.

The [manual](http://www.gnu.org/software/wget/manual/html_node/HTTPS-_0028SSL_002fTLS_0029-Options.html) of GNU Wget states:
> Only use this option if you are otherwise convinced of the site’s authenticity, or if you really don’t care about the validity of its certificate. It is almost always a bad idea not to check the certificates when transmitting confidential or important data. 

Disables certificate checks makes you susceptible to man-in-the-middle (MITM) attacks, where an attacker presents you a faked certificate, so that he can eavesdrop on your (otherwise encrypted) network communication. In this case, he could read your Login-ID and your password in plain text.

On the other hand, this script does check if the server certificate was issues by the certificate authority and therefore prevents MITM attacks. If an attacker tries to eavesdrop on your connection, SSL certificate verification will fail and he will not be able to read your login credentials.

*TLDR; Never use the ```wget``` command with the ```--no-check-certificate``` option unless you really know what you're doing. It makes you susceptible to attacks. Use this script instead.*

### Are you crazy? Putting your password in a plain text file sucks.

Unfortunately, it's not possible to login with a password hash instead of the plain text password (at least to my knowledge).

But you're right, this sucks.

### How can I stay logged in?

You could put this script in your crontab-file.

Edit your crontab-file with
```bash
crontab -e
```
and enter this:

```cron
#MIN HOUR DOM MON DOW CMD
*/5  *    *   *   *   /path/to/hirnlogin.sh >/dev/null
```

*(The snippet above will tell the ```cron``` daemon to automatically execute this script every five minutes.)*

Then restart the ```cron``` daemon.

### Is this [free software](http://fsfe.org/about/basics/freesoftware.html) (free as in freedom, not free beer)?

Yes. It's licensed under the [3-clause BSD license](http://opensource.org/licenses/BSD-3-Clause) (also known as modified BSD license).

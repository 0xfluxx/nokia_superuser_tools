This collection of tools makes use of various common command-line tools that 
should be present (or available) in nearly every distribition of GNU/Linux, namely:

`awk bash curl cut grep nmap sed ssh xargs unix2dos python3` (with crypto module)

If you are using this on macOS, it may be necessary to install the GNU versions 
of these tools to avoid syntax errors. Our recommendation is to install [Macports](https://www.macports.org) 
as this will give you an easy way to install and update GNU tools on macOS.

Some of the tools make use of some less common packages:

[urlencode](https://github.com/dead10ck/urlencode) - only necessary for Zoomeye script
[ipinfo](https://github.com/ipinfo/cli) - also only necessary for Zoomeye script
[sshpass](https://github.com/kevinburke/sshpass) - nokia-connect uses this, but can run without it

The transfer_files.sh script will allow you to simply use the 
SSH connection opened to send and receive files.

Android users can run this in Termux (with minor tweaks).
Windows is not supported (nor will it ever be). Same for iOS.
*BSD users should not encounter issues, although this is untested.

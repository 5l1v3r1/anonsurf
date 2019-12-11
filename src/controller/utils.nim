import httpclient
import os
#[
  # Destinations you don't want routed through Tor
TOR_EXCLUDE="192.168.0.0/16 172.16.0.0/12 10.0.0.0/8"

# The UID Tor runs as
# change it if, starting tor, the command 'ps -e | grep tor' returns a different UID
TOR_UID="debian-tor"

# Tor's TransPort
TOR_PORT="9040"

]#

proc safeClean*() =
  # TODO add yes no box
  # Kill processes
  discard execShellCmd("killall -q chrome dropbox iceweasel skype icedove thunderbird firefox firefox-esr chromium xchat hexchat transmission steam firejail")
  # Clear cache
  discard execShellCmd("bleachbit -c adobe_reader.cache chromium.cache chromium.current_session chromium.history elinks.history emesene.cache epiphany.cache firefox.url_history flash.cache flash.cookies google_chrome.cache google_chrome.history  links2.history opera.cache opera.search_history opera.url_history &> /dev/null")

proc getCurrentIP*(): string =
  # flag -d:ssl
  let getIP = newHttpClient()
  return getIP.getContent("https://start.parrotsec.org/ip/")


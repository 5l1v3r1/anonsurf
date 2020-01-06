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

proc getCurrentIP*(): string =
  # flag -d:ssl
  let getIP = newHttpClient()
  return getIP.getContent("https://start.parrotsec.org/ip/")


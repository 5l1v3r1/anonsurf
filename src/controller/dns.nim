import os
import gintro / gtk

proc setDNS*(b: Button) =
  discard execShellCmd("gksu anonsurf dns")

# proc dnsStop*(b: Button) =
#   # Remove old DNS settings
#   removeFile("/etc/resolv.conf")
#   # Remove lock file and DNS in tail
#   removeFile("/etc/anonsurf/opennic.lock")
#   writeFile("/etc/resolvconf/resolv.conf.d/tail", "")
#   # Create a symlink from /etc/resolvconf/run/resolv.conf to resolv.conf
#   createSymlink("/etc/resolvconf/run/resolv.conf", "/etc/resolv.conf")

#   # Restart resolvconf
#   discard execShellCmd("/usr/sbin/service resolvconf restart")

#   # Update GUI
#   b.label = "Enable OpenNIC DNS"
#   b.setTooltipText("You are not using OpenNIC DNS service")



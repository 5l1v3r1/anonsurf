import os
import gintro / gtk

proc dnsStart*(b: Button) =
  # Remove current dns in /etc/resolv.conf
  removeFile("/etc/resolv.conf")
  
  # Generate new DNS settings
  let dnsData = readFile("/etc/anonsurf/resolv.conf.opennic")
  writeFile("/etc/resolvconf/resolv.conf.d/tail", dnsData)
  writeFile("/etc/resolv.conf", dnsData)
  
  # Restart DNS service
  discard execShellCmd("/usr/sbin/service resolvconf restart")

  # Create lock
  writeFile("/etc/anonsurf/opennic.lock", "")

  # Update GUI
  b.label = "Disable OpenNIC DNS"
  b.setTooltipText("You are using OpenNIC DNS service")


proc dnsStop*(b: Button) =
  # Remove old DNS settings
  removeFile("/etc/resolv.conf")
  # Remove lock file and DNS in tail
  removeFile("/etc/anonsurf/opennic.lock")
  writeFile("/etc/resolvconf/resolv.conf.d/tail", "")
  # Create a symlink from /etc/resolvconf/run/resolv.conf to resolv.conf
  createSymlink("/etc/resolvconf/run/resolv.conf", "/etc/resolv.conf")

  # Restart resolvconf
  discard execShellCmd("/usr/sbin/service resolvconf restart")

  # Update GUI
  b.label = "Enable OpenNIC DNS"
  b.setTooltipText("You are not using OpenNIC DNS service")



import os

proc start() =
  # STOP SERVICES: nscd, resolvconf, dnsmasq
  discard execShellCmd("/usr/sbin/service nscd stop 2>/dev/null")
  discard execShellCmd("/usr/sbin/service resolvconf stop 2>/dev/null")
  discard execShellCmd("/usr/sbin/service dnsmasq stop 2>/dev/null")
  # Start tor service
  discard execShellCmd("systemctl start tor")
  # Backup iptables rules # TODO
  # Remove iptables rules # TODO

  # Add 127.0.0.1 to DNS
  var dnsData = readFile("/etc/resolv.conf")
  dnsData = "127.0.0.1\n" & dnsData
  
  # Disable ipv6 TODO
  # generate iptables routing rules and apply it TODO

proc stop() =
  # TODO use anondaemon instead
  # remove current iptable rules
  # restore ip table old rules

  #[ Restore DNS settings ]#
  # Remove old DNS settings
  removeFile("/etc/resolv.conf")
  # Create a symlink from /etc/resolvconf/run/resolv.conf to resolv.conf
  createSymlink("/etc/resolvconf/run/resolv.conf", "/etc/resolv.conf")
  
  # re enable ipv6
  # Stop tor service
  

  # Restore resolvconf, dnsmasq, nscd services
  
  discard execShellCmd("/usr/sbin/service resolvconf start || service resolvconf restart")
  discard execShellCmd("/usr/sbin/service dnsmasq start")
  discard execShellCmd("/usr/sbin/service nscd start")

proc *change() =
  # select node (must check)
  discard

proc *status() =
  # Check current tor service
  # TODO real time monitoring in gui
  # TODO use this as a "lock" for anonsurf
  discard
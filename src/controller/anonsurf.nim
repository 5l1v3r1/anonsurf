import os

proc start() =
  discard execShellCmd("gksu service anondaemon start")

proc stop() =
  discard execShellCmd("gksu service anondaemon stop")

proc restart() =
  discard execShellCmd("gksu service anondaemon restart")

proc change*() =
  # select node (must check)
  discard

proc status*() =
  # Check current tor service
  # TODO real time monitoring in gui
  # TODO use this as a "lock" for anonsurf
  discard
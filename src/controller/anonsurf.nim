import os
import gintro / gtk

proc anonsurfStart*(b: Button) =
  discard execShellCmd("gksu service anondaemon start")

proc anonsurfStop*(b: Button) =
  discard execShellCmd("gksu service anondaemon stop")

proc anonsurfRestart*(b: Button) =
  discard execShellCmd("gksu service anondaemon restart")

proc change*(b: Button) =
  # select node (must check)
  discard

proc status*(b: Button) =
  # Check current tor service
  # TODO real time monitoring in gui
  # TODO use this as a "lock" for anonsurf
  discard
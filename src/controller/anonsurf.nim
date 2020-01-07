import os
import gintro / gtk


proc anonsurfControl*(b: Button) =
  if b.label == "Enable":
    discard execShellCmd("gksu service anondaemon start")
  else:
    discard execShellCmd("gksu service anondaemon stop")


proc change*(b: Button) =
  # select node (must check)
  discard


proc status*(b: Button) =
  # Check current tor service
  # TODO real time monitoring in gui
  # TODO use this as a "lock" for anonsurf
  discard execShellCmd("x-terminal-emulator nyx")
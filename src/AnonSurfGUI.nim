import gintro / [gtk, glib, gobject]
import os
import osproc
import strutils

type
  Obj = ref object
    btnRun: Button
    btnStatus: Button
    btnChange: Button

var serviceThread: system.Thread[tuple[command: string]]


proc runThread(argv: tuple[command: string]) {.thread.} =
  discard execShellCmd(argv.command)


proc anonsurfControl(b: Button) =
  if b.label == "Enable":
    createThread(serviceThread, runThread, ("gksu service anondaemon start",))
    # discard execShellCmd("gksu service anondaemon start")
  else:
    # b.label = "Enabling"
    createThread(serviceThread, runThread, ("gksu service anondaemon stop",))
    # discard execShellCmd("gksu service anondaemon stop")


proc change(b: Button) =
  # select node (must check)
  discard


proc status(b: Button) =
  discard execShellCmd("x-terminal-emulator nyx")

proc setDNS(b: Button) =
  discard execShellCmd("gksu anonsurf dns")


proc refreshStatus(args: Obj): bool =
  # TODO work with update ip label
  # TODO check DNS buttons
  # TODO check if thread is running
  let output = execProcess("systemctl is-active anondaemon").replace("\n", "")
  if serviceThread.running():
    args.btnRun.label = "Switching"
    args.btnRun.setSensitive(false)
    args.btnStatus.setSensitive(false)
    args.btnChange.setSensitive(false)
    
  else:
    if output == "active":
      # Settings for button anonsurf
      args.btnRun.label = "Disable"
      args.btnRun.setSensitive(true)

      args.btnStatus.label = "Check Status"
      args.btnStatus.setSensitive(true)

      args.btnChange.label = "Change Tor Node"
      args.btnChange.setSensitive(true)

    else:
      args.btnRun.label = "Enable"
      args.btnRun.setSensitive(true)

      args.btnStatus.label = "AnonSurf Off"
      args.btnStatus.setSensitive(false)

      args.btnChange.label = "Not connected"
      args.btnChange.setSensitive(false)
  return SOURCE_CONTINUE

proc areaDNS(boxMain: Box) =
  let
    dnsLock = "/etc/anonsurf/opennic.lock"
    boxDNS = newBox(Orientation.horizontal, 3)
    labelDNS = newLabel("OpenNIC Service")
    btnDNS = newButton()
  
  # TODO when anonsurf is enabled, the lock file will be there but only 127.0.0.1
  if existsFile(dnsLock):
    # OpenNic is already set. Disable it
    btnDNS.label = "Disable OpenNIC DNS" # Todo change to shorter name
    btnDNS.setTooltipText("You are using OpenNIC DNS service")
    btnDNS.connect("clicked", setDNS)
  else:
    # OpenNic is not set. Enable it
    btnDNS.label = "Enable OpenNIC DNS"
    btnDNS.setTooltipText("You are not using OpenNIC DNS service")
    btnDNS.connect("clicked", setDNS)

  labelDNS.setXalign(0.0)
  
  boxDNS.packStart(btnDNS, false, true, 4)
  boxMain.packStart(labelDNS, false, true, 3)
  boxMain.packStart(boxDNS, false, true, 3)


proc areaAnonsurf(boxMain: Box) =
  #[
    Generate area to control anonsurf with:
      Enable  / disable anonsurf service button
      Check current status and monitor status
      Change exists Node
      # TODO restart button or forget about it
  ]#
  let
    boxAnonsurf = newBox(Orientation.horizontal, 3) # The whole box
    boxRun = newBox(Orientation.vertical, 3) # The box to generate Run button and its label
    boxStatus = newBox(Orientation.vertical, 3) # The box to generate Check status button and its label
    boxChange = newBox(Orientation.vertical, 3) # The box to generate Change current node button and its label
    labelRun = newLabel("Service") # TODO shorter name
    labelStatus = newLabel("Status")
    labelChange = newLabel("Change Node")
    labelAnonsurf = newLabel("AnonSurf")
    btnRunAnon = newButton("Start AnonSurf")
    btnCheckStatus = newButton("Check Status")
    btnChangeID = newButton("Change ID")
  
  var args = Obj(btnRun: btnRunAnon, btnStatus: btnCheckStatus, btnChange: btnChangeID)
  discard timeoutAdd(20, refreshStatus, args)

  labelAnonsurf.setXalign(0.0)
  labelRun.setXalign(0.0)
  labelStatus.setXalign(0.0)
  labelChange.setXalign(0.0)

  btnRunAnon.connect("clicked", anonsurfControl)
  btnCheckStatus.connect("clicked", status)
  btnChangeID.connect("clicked", change)

  
  boxRun.packStart(labelRun, false, true, 3)
  boxRun.packStart(btnRunAnon, false, true, 3)

  boxStatus.packStart(labelStatus, false,  true, 3)
  boxStatus.packStart(btnCheckStatus, false, true,3)

  boxChange.packStart(labelChange, false, true, 3)
  boxChange.packStart(btnChangeID, false, true ,3)

  boxAnonsurf.packstart(boxRun, false, true, 3)
  boxAnonsurf.packstart(boxStatus, false, true, 3)
  boxAnonsurf.packstart(boxChange, false, true, 3)
  boxMain.packStart(labelAnonsurf, false, true, 1)
  boxMain.packStart(boxAnonsurf, false, true, 3)


proc stop(w: Window) =
  mainQuit()

proc main =
  gtk.init()
  let
    mainBoard = newWindow()
    boxMain = newBox(Orientation.vertical, 5)
  
  mainBoard.title = "AnonSurf"

  areaAnonsurf(boxMain)
  areaDNS(boxMain)

  mainBoard.add(boxMain)
  mainBoard.setBorderWidth(3)

  mainBoard.showAll
  mainBoard.connect("destroy", stop)
  gtk.main()

main()
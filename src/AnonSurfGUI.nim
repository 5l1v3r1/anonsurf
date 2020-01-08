import gintro / [gtk, glib, gobject]
import os
import osproc
import strutils

type
  Obj = ref object
    btnRun: Button
    btnStatus: Button
    btnChange: Button
    btnOpenNICDNS: Button

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
  let
    output = execProcess("systemctl is-active anondaemon").replace("\n", "")
    dnsLock = "/etc/anonsurf/opennic.lock"
  
  if serviceThread.running():
    args.btnRun.label = "Switching"
    args.btnOpenNICDNS.label = "Generating"
    args.btnRun.setSensitive(false)
    args.btnStatus.setSensitive(false)
    args.btnChange.setSensitive(false)
    args.btnOpenNICDNS.setSensitive(false)
    
  else:
    if output == "active":
      # Settings for button anonsurf
      args.btnRun.label = "Disable"
      args.btnRun.setTooltipText("Stop identify protection")
      args.btnRun.setSensitive(true)

      args.btnStatus.label = "Check Status"
      args.btnStatus.setTooltipText("Check your current Tor connection")
      args.btnStatus.setSensitive(true)

      args.btnChange.label = "Change Tor Node"
      args.btnChange.setTooltipText("Change current Tor node")
      args.btnChange.setSensitive(true)

      args.btnOpenNICDNS.label = "Tor DNS"
      args.btnOpenNICDNS.setTooltipText("Using Tor DNS")
      args.btnOpenNICDNS.setSensitive(false)

    else:
      args.btnRun.label = "Enable"
      args.btnRun.setTooltipText("Enable Anonsurf to hide your identify")
      args.btnRun.setSensitive(true)

      args.btnStatus.label = "AnonSurf Off"
      args.btnStatus.setTooltipText("You are not connecting to Tor network")
      args.btnStatus.setSensitive(false)

      args.btnChange.label = "Not connected"
      args.btnChange.setTooltipText("You are not connecting to Tor network")
      args.btnChange.setSensitive(false)

      args.btnOpenNICDNS.setSensitive(true)
      if existsFile(dnsLock):
        # OpenNic is already set. Disable it
        args.btnOpenNICDNS.label = "Disable" # Todo change to shorter name
        args.btnOpenNICDNS.setTooltipText("Start using OpenNIC DNS")
      else:
        # OpenNic is not set. Enable it
        args.btnOpenNICDNS.label = "Enable"
        args.btnOpenNICDNS.setTooltipText("Stop using OpenNIC DNS")

  return SOURCE_CONTINUE


proc createArea(boxMain: Box) =
  #[
    Generate area to control anonsurf with:
      Enable / disable anonsurf service button
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
    boxDNS = newBox(Orientation.horizontal, 3)
    labelDNS = newLabel("OpenNIC DNS")
    btnDNS = newButton()
  
  var args = Obj(btnRun: btnRunAnon, btnStatus: btnCheckStatus, btnChange: btnChangeID, btnOpenNICDNS: btnDNS)
  discard timeoutAdd(20, refreshStatus, args)

  labelDNS.setXalign(0.0)
  labelAnonsurf.setXalign(0.0)
  labelRun.setXalign(0.0)
  labelStatus.setXalign(0.0)
  labelChange.setXalign(0.0)

  btnRunAnon.connect("clicked", anonsurfControl)
  btnCheckStatus.connect("clicked", status)
  btnChangeID.connect("clicked", change)
  btnDNS.connect("clicked", setDNS)

  
  boxRun.packStart(labelRun, false, true, 3)
  boxRun.packStart(btnRunAnon, false, true, 3)

  boxStatus.packStart(labelStatus, false, true, 3)
  boxStatus.packStart(btnCheckStatus, false, true,3)

  boxChange.packStart(labelChange, false, true, 3)
  boxChange.packStart(btnChangeID, false, true ,3)

  boxAnonsurf.packstart(boxRun, false, true, 3)
  boxAnonsurf.packstart(boxStatus, false, true, 3)
  boxAnonsurf.packstart(boxChange, false, true, 3)

  boxDNS.packStart(btnDNS, false, true, 3)
  
  boxMain.packStart(labelAnonsurf, false, true, 3)
  boxMain.packStart(boxAnonsurf, false, true, 3)

  boxMain.packStart(labelDNS, false, true, 3)
  boxMain.packStart(boxDNS, false, true, 3)


proc stop(w: Window) =
  mainQuit()

proc main =
  gtk.init()
  let
    mainBoard = newWindow()
    boxMain = newBox(Orientation.vertical, 3)
  
  mainBoard.title = "AnonSurf"

  createArea(boxMain)

  mainBoard.add(boxMain)
  mainBoard.setBorderWidth(3)

  mainBoard.showAll
  mainBoard.connect("destroy", stop)
  gtk.main()

main()
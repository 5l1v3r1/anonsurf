import gintro / [gtk, glib, gobject]
import os
import controller / [dns, utils, anonsurf]
import osproc
import strutils

type
  Obj = ref object
    btnRun: Button
    btnStatus: Button
    btnChange: Button

proc refreshStatus(args: Obj): bool =
  # TODO work with changeid button
  # TODO work with update ip label
  # TODO check DNS buttons
  let output = execProcess("systemctl is-active anondaemon").replace("\n", "")
  if output == "active":
    # Settings for button anonsurf
    args.btnRun.label = "Disable"
    args.btnRun.connect("clicked", anonsurf.anonsurfStop)

    args.btnStatus.label = "Check Status"
    args.btnStatus.setFocusOnClick(true)
    args.btnStatus.connect("clicked", anonsurf.status)

    args.btnChange.label = "Change Tor Node"
    args.btnChange.connect("clicked", anonsurf.change)

  else:
    args.btnRun.label = "Enable"
    args.btnRun.connect("clicked", anonsurf.anonsurfStart)

    args.btnStatus.label = "Anonsurf Off"
    args.btnStatus.setFocusOnClick(false)

    args.btnChange.label = "Not connected"
    args.btnChange.setFocusOnClick(false)
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
    btnDNS.connect("clicked", dns.setDNS)
  else:
    # TODO auto update status and check with tor
    # OpenNic is not set. Enable it
    btnDNS.label = "Enable OpenNIC DNS"
    btnDNS.setTooltipText("You are not using OpenNIC DNS service")
    btnDNS.connect("clicked", dns.setDNS)

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
    labelAnonsurf = newLabel("Anonsurf")
    btnRunAnon = newButton("Start Anonurf")
    btnCheckStatus = newButton("Check Status")
    btnChangeID = newButton("Change ID")
  

  labelAnonsurf.setXalign(0.0)
  labelRun.setXalign(0.0)
  labelStatus.setXalign(0.0)
  labelChange.setXalign(0.0)

  
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

  var args = Obj(btnRun: btnRunAnon, btnStatus: btnCheckStatus, btnChange: btnChangeID)
  discard timeoutAdd(5, refreshStatus, args)


proc stop(w: Window) =
  mainQuit()

proc main =
  gtk.init()
  let
    mainBoard = newWindow()
    boxMain = newBox(Orientation.vertical, 5)
  
  mainBoard.title = "AnonSurf GUI"

  # areaStatus(boxMain)
  areaAnonsurf(boxMain)
  areaDNS(boxMain)

  mainBoard.add(boxMain)
  mainBoard.setBorderWidth(3)

  mainBoard.showAll
  mainBoard.connect("destroy", stop)
  gtk.main()

main()
import gintro / [gtk, glib, gobject]
import os
import controller / [dns, utils, anonsurf]
import osproc
import strutils

proc refreshStatus(b: Button): bool =
  # TODO work with status button
  # TODO work with changeid button
  # TODO work with update ip label
  # TODO check DNS buttons
  let output = execProcess("systemctl is-active anondaemon").replace("\n", "")
  if output == "active":
    b.label = "Disable Anonsurf"
    b.connect("clicked", anonsurf.anonsurfStop)
  else:
    b.label = "Enable Anonsurf"
    b.connect("clicked", anonsurf.anonsurfStart)
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
    btnDNS.label = "Disable OpenNIC DNS"
    btnDNS.setTooltipText("You are using OpenNIC DNS service")
    btnDNS.connect("clicked", dnsStart)
  else:
    # OpenNic is not set. Enable it
    btnDNS.label = "Enable OpenNIC DNS"
    btnDNS.setTooltipText("You are not using OpenNIC DNS service")
    btnDNS.connect("clicked", dnsStop)

  labelDNS.setXalign(0.0)
  
  boxDNS.packStart(btnDNS, false, true, 4)
  boxMain.packStart(labelDNS, false, true, 3)
  boxMain.packStart(boxDNS, false, true, 3)


proc areaAnonsurf(boxMain: Box) =
  let
    boxAnonsurf = newBox(Orientation.horizontal, 3)
    labelAnonsurf = newLabel("Anonsurf")
    btnRunAnon = newButton("Start Anonurf")
    btnStatus = newButton("Check Status")
    btnChangeID = newButton("Change ID")
  
  # TODO useable / unusable btn changeid based on anonsurf status

  labelAnonsurf.setXalign(0.0)
  discard timeoutAdd(5, refreshStatus, btnRunAnon)

  boxAnonsurf.packstart(btnRunAnon, false, true, 3)
  boxAnonsurf.packstart(btnStatus, false, true, 3)
  boxAnonsurf.packstart(btnChangeID, false, true, 3)
  boxMain.packStart(labelAnonsurf, false, true, 3)
  boxMain.packStart(boxAnonsurf, false, true, 3)


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
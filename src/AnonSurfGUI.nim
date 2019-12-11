import gintro / [gtk, gobject]
import os
import controller / [dns, utils]

proc areaStatus(boxMain: Box) =
  let
    boxStatus = newBox(Orientation.vertical, 3)
    labelStatus = newLabel("Public IP: ")
    btnStatus = newButton()

  
  labelStatus.setXalign(0.0)
  labelStatus.setLabel("Public IP: " & getCurrentIP())

  btnStatus.setLabel("Check IP Address")
  # TODO check ip address 

  boxStatus.packStart(labelStatus, false, true, 3)
  boxStatus.packStart(btnStatus, false, true, 3)
  boxMain.packStart(boxStatus, false, true, 3)

proc areaDNS(boxMain: Box) =
  let
    dnsLock = "/etc/anonsurf/opennic.lock"
    boxDNS = newBox(Orientation.vertical, 3)
    labelDNS = newLabel("OpenNIC Service")
    btnDNS = newButton()
  
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
  boxDNS.packStart(labelDNS, false, true, 3)
  boxDNS.packStart(btnDNS, false, true, 4)
  boxMain.packStart(boxDNS, false, true, 3)


proc stop(w: Window) =
  mainQuit()

proc main =
  gtk.init()
  let
    mainBoard = newWindow()
    boxMain = newBox(Orientation.vertical, 5)
  
  mainBoard.title = "AnonSurf"

  areaStatus(boxMain)
  areaDNS(boxMain)

  mainBoard.add(boxMain)
  mainBoard.setBorderWidth(3)

  mainBoard.showAll
  mainBoard.connect("destroy", stop)
  gtk.main()

main()
import gintro / [gtk, glib, gobject, notify]
import os
import osproc
import strutils
import net

type
  Obj = ref object
    btnRun: Button
    btnStatus: Button
    btnChange: Button
    btnSetDNS: Button

var serviceThread: system.Thread[tuple[command: string]]


proc runThread(argv: tuple[command: string]) {.thread.} =
  discard execShellCmd(argv.command)


proc anonsurfControl(b: Button) =
  if b.label == "Enable":
    createThread(serviceThread, runThread, ("gksu anonsurf start",))
  else:
    createThread(serviceThread, runThread, ("gksu anonsurf stop",))


proc change(b: Button) =
  #[
    Send change node command to Control port then restart tor service
    Host: 127.0.0.1 | localhost
    Port: 9051
    Data:
    """
      authenticate "kuhNygbtfu76fFUbgv"
      signal newnym
      quit
    """
    URL: https://stackoverflow.com/a/33726166
  ]#
  let
    sock_data = "authenticate \"kuhNygbtfu76fFUbgv\"\nsignal newnym\nquit"
  var socket = newSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
  socket.connect("127.0.0.1", Port(9051))

  discard notify.init("Change Tor Node")

  let noti = newNotification("Changed node succesfully")

  if socket.trySend(sock_data):
    discard execShellCmd("gksu service tor restart")
  else:
    discard noti.update("Change node failed")
  socket.close()

  discard noti.show()


proc status(b: Button) =
  discard execShellCmd("x-terminal-emulator nyx")


proc setDNS(b: Button) =
  discard execShellCmd("gksu anonsurf dns")


proc refreshStatus(args: Obj): bool =
  # TODO work with update ip label
  let
    output = execProcess("systemctl is-active anondaemon").replace("\n", "")
    dnsLock = "/etc/anonsurf/opennic.lock"
  
  if serviceThread.running():
    args.btnRun.label = "Switching"
    args.btnSetDNS.label = "Generating"
    args.btnChange.label = "Changing"
    args.btnRun.setSensitive(false)
    args.btnStatus.setSensitive(false)
    args.btnChange.setSensitive(false)
    args.btnSetDNS.setSensitive(false)
    
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

      args.btnSetDNS.label = "Tor DNS"
      args.btnSetDNS.setTooltipText("Using Tor DNS")
      args.btnSetDNS.setSensitive(false)

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

      args.btnSetDNS.setSensitive(true)
      if existsFile(dnsLock):
        # OpenNic is already set. Disable it
        args.btnSetDNS.label = "Disable" # Todo change to shorter name
        args.btnSetDNS.setTooltipText("Start using OpenNIC DNS")
      else:
        # OpenNic is not set. Enable it
        args.btnSetDNS.label = "Enable"
        args.btnSetDNS.setTooltipText("Stop using OpenNIC DNS")

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
    labelRun = newLabel("Service")
    labelStatus = newLabel("Status")
    labelChange = newLabel("Change Node")
    labelAnonsurf = newLabel("AnonSurf")
    btnRunAnon = newButton("Start AnonSurf")
    btnCheckStatus = newButton("Check Status")
    btnChangeID = newButton("Change ID")
    boxDNS = newBox(Orientation.horizontal, 3) # Create a box for DNS area
    labelDNS = newLabel("OpenNIC DNS")
    btnDNS = newButton()
  

  labelDNS.setXalign(0.0)
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

  var args = Obj(btnRun: btnRunAnon, btnStatus: btnCheckStatus, btnChange: btnChangeID, btnSetDNS: btnDNS)
  discard timeoutAdd(20, refreshStatus, args)


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
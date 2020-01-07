import os
import gintro / gtk

proc setDNS*(b: Button) =
  discard execShellCmd("gksu anonsurf dns")

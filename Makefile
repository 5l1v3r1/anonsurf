install:
	# TODO get gintro by nimble before install
	# TODO copy desktop file
	nim c src/AnonSurfGUI.nim
	cp src/AnonsurfGUI /usr/bin/anonsurf-gtk
	cp anonsurf/anondaemon /etc/anonsurf/
	cp anonsurf/anondaemon.service /lib/systemd/system/
	cp anonsurf/anonsurf /usr/bin/
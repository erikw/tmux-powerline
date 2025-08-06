#!/usr/bin/env python
import dbus

pithos_bus = dbus.SessionBus()

pithos = pithos_bus.get_object("net.kevinmehall.Pithos", "/net/kevinmehall/Pithos")
props = pithos.get_dbus_method("GetCurrentSong", "net.kevinmehall.Pithos")

print(props()["artist"] + " - " + props()["title"])

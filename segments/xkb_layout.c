/* xkb_layout
 * Description:
 * This program will connect to the X Server and print the id of the currently
 * active keyboard layout.
 */

#include <stdio.h>
#include <X11/XKBlib.h>

int main() {
	// Get X display
	char* displayName = "";
	int eventCode;
	int errorReturn;
	int major = XkbMajorVersion;
	int minor = XkbMinorVersion;;
	int reasonReturn;
	Display *_display = XkbOpenDisplay(displayName, &eventCode, &errorReturn,
			&major, &minor, &reasonReturn);
	switch (reasonReturn) {
	case XkbOD_BadLibraryVersion:
		fprintf(stderr, "Bad XKB library version.");
		break;
	case XkbOD_ConnectionRefused:
		fprintf(stderr, "Connection to X server refused.");
		break;
	case XkbOD_BadServerVersion:
		fprintf(stderr, "Bad X11 server version.");
		break;
	case XkbOD_NonXkbServer:
		fprintf(stderr, "XKB not present.");
		break;
	case XkbOD_Success:
		break;
	}

	// Get current state of kaboard
	int _deviceId = XkbUseCoreKbd;
    XkbStateRec xkbState;
    XkbGetState(_display, _deviceId, &xkbState);
	// print the groupnumber, may be used with setxkbmap -query to get name
	// of current layout
	printf("%d\n", xkbState.group);
	return 0;
}

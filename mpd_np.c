#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <mpd/client.h>

#ifdef DEBUG
	#define DO_DEBUG DEBUG
#else
	#define DO_DEBUG 0
#endif
#define DEBUG_PRINTF(...) do{ if (DO_DEBUG) { printf(__VA_ARGS__);} } while(0)

/* Output the current song if MPD is in a playing state. */
int main(int argc, const char *argv[])
{
	struct mpd_connection *mpd_connection = mpd_connection_new("localhost", 6600, 1000);
	if (mpd_connection == NULL) {
		DEBUG_PRINTF("%s\n", "Could Not connect");
		return EXIT_FAILURE;
	}

	bool authenticated = mpd_run_password(mpd_connection, "Vmb8s2snakmJJ6aBNk7N5GXd5XWXHrFv");
	if (!authenticated) {
		DEBUG_PRINTF("Failed to authenticate.\n");
		return EXIT_FAILURE;
	}

	bool sent_status = mpd_send_status(mpd_connection);
	if (!sent_status) {
		DEBUG_PRINTF("Could not send status request.");
		return EXIT_FAILURE;
	}
	struct mpd_status *mpd_status = mpd_recv_status(mpd_connection);
	if (mpd_status == NULL) {
		DEBUG_PRINTF("Could not get mpd status.\n");
		return EXIT_FAILURE;
	}

	enum mpd_state mpd_state = mpd_status_get_state(mpd_status);
	DEBUG_PRINTF("State: ");
	if (mpd_state == MPD_STATE_PLAY) {
		DEBUG_PRINTF("Playing.");
	} else if (mpd_state == MPD_STATE_PAUSE) {
		DEBUG_PRINTF("Paused.");
	} else if (mpd_state == MPD_STATE_UNKNOWN) {
		DEBUG_PRINTF("Unknown state.");
	} else if (mpd_state == MPD_STATE_STOP) {
		DEBUG_PRINTF("Stopped.");
	}
	DEBUG_PRINTF("\n");

	if (mpd_state != MPD_STATE_PLAY) {
		// Nothing to do.
		mpd_status_free(mpd_status);
		mpd_connection_free(mpd_connection);
		return EXIT_SUCCESS;
	}

	int song_id = mpd_status_get_song_id(mpd_status);
	DEBUG_PRINTF("songid = %i\n", song_id);

	mpd_status_free(mpd_status);

	struct mpd_song *song = mpd_run_get_queue_song_id(mpd_connection, song_id);
	if (song == NULL) {
		DEBUG_PRINTF("Could not get song.\n");
		return EXIT_FAILURE;
	}

	const char *song_artist = mpd_song_get_tag(song, MPD_TAG_ARTIST, 0);
	if (song_artist == NULL) {
		DEBUG_PRINTF("Could not get song artist.");
		return EXIT_FAILURE;
	}

	const char *song_title = mpd_song_get_tag(song, MPD_TAG_TITLE, 0);
	if (song_title == NULL) {
		DEBUG_PRINTF("Could not get song title.");
		return EXIT_FAILURE;
	}
	printf("%s - %s", song_artist, song_title);

	mpd_song_free(song);
	mpd_connection_free(mpd_connection);
	return EXIT_SUCCESS;
}

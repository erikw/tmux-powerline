#The minimum version might be much lower than this.
cmake_minimum_required(VERSION 2.8)

project("tmux-powerline" NONE)

#{{{ File Locations
	set(SOURCE_DIR src)
	set(MAIN_SOURCES
		${SOURCE_DIR}/config.sh
		${SOURCE_DIR}/lib.sh
		${SOURCE_DIR}/mute_statusbar.sh
		${SOURCE_DIR}/status-left.sh
		${SOURCE_DIR}/status-right.sh
		)
	set(SEGMENTS
		${SOURCE_DIR}/segments/battery_mac.sh
		${SOURCE_DIR}/segments/battery.sh
		${SOURCE_DIR}/segments/cpu.sh
		${SOURCE_DIR}/segments/date_day.sh
		${SOURCE_DIR}/segments/date_full.sh
		${SOURCE_DIR}/segments/hostname.sh
		${SOURCE_DIR}/segments/ifstat.sh
		${SOURCE_DIR}/segments/ifstat_sys.sh
		${SOURCE_DIR}/segments/lan_ip.sh
		${SOURCE_DIR}/segments/load.sh
		${SOURCE_DIR}/segments/mail_count_apple_mail.sh
		${SOURCE_DIR}/segments/mail_count_gmail.sh
		${SOURCE_DIR}/segments/mail_count_maildir.sh
		${SOURCE_DIR}/segments/mail_count_mbox.sh
		${SOURCE_DIR}/segments/np_audacious.sh
		${SOURCE_DIR}/segments/np_banshee.sh
		${SOURCE_DIR}/segments/np_cmus.sh
		${SOURCE_DIR}/segments/np_itunes_mac.sh
		${SOURCE_DIR}/segments/np_lastfm.sh
		${SOURCE_DIR}/segments/np_mocp.sh
		${SOURCE_DIR}/segments/np_mpd.sh
		${SOURCE_DIR}/segments/np_mpd_simple.sh
		${SOURCE_DIR}/segments/np_rdio_mac.script
		${SOURCE_DIR}/segments/np_rdio_mac.sh
		${SOURCE_DIR}/segments/np_rhythmbox.sh
		${SOURCE_DIR}/segments/np_spotify_linux_native.sh
		${SOURCE_DIR}/segments/np_spotify_linux_wine.sh
		${SOURCE_DIR}/segments/np_spotify_mac.sh
		${SOURCE_DIR}/segments/pwd.sh
		${SOURCE_DIR}/segments/time.sh
		${SOURCE_DIR}/segments/tmux_mem_cpu_load.sh
		${SOURCE_DIR}/segments/tmux_session_info.sh
		${SOURCE_DIR}/segments/uptime.sh
		${SOURCE_DIR}/segments/vcs_branch.sh
		${SOURCE_DIR}/segments/vcs_compare.sh
		${SOURCE_DIR}/segments/vcs_modified.sh
		${SOURCE_DIR}/segments/vcs_others.sh
		${SOURCE_DIR}/segments/vcs_staged.sh
		${SOURCE_DIR}/segments/wan_ip.sh
		${SOURCE_DIR}/segments/weather_google.sh
		${SOURCE_DIR}/segments/weather_yahoo.sh
		${SOURCE_DIR}/segments/xkb_layout.sh
		)

	if(EXISTS "${SOURCE_DIR}/segments/np_mpd")
		list(APPEND SEGMENTS ${SOURCE_DIR}/segments/np_mpd)
	endif()

	if(EXISTS "${SOURCE_DIR}/segments/xkb_layout")
		list(APPEND SEGMENTS ${SOURCE_DIR}/segments/xkb_layout)
	endif()
#}}}

#{{{ Install Files
	if(UNIX)
		#The files go to lib, because they normally wouldn't be used as standalone executables.
		#(They probably aren't a good fit for $PATH.)
		set(INSTALL_DESTINATION lib/)
	endif()

	install(PROGRAMS ${MAIN_SOURCES}
		#CMake has a default installation prefix (/usr/local for Unix-like systems).
		DESTINATION ${INSTALL_DESTINATION}${CMAKE_PROJECT_NAME}
		)
	install(PROGRAMS ${SEGMENTS}
		DESTINATION ${INSTALL_DESTINATION}${CMAKE_PROJECT_NAME}/segments
		)
#}}}

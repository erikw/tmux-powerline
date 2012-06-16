# tmux-powerline
This is a set of scripts (segments) for making a nice and dynamic tmux status-bar where elements can come and disappears depending on events. I really like the look of [Lokaltog/vim-powerline](https://github.com/Lokaltog/vim-powerline) and I decided I wanted the same for tmux.

The following segments exists for now:
* LAN & WAN IP addresses.
* MPD now playing.
* Maildir check.
* GNU Linux and Macintosh OS X battery status (uses [richo/dotfiles/bin/battery](https://github.com/richoH/dotfiles/blob/master/bin/battery)).
* Weather in Celsius, Fahrenheit and Kelvin!
* System load and uptime.
* Date and time.
* Hostname.
* tmux info.

# Screenshots
**Full screenshot**

![Full screenshot](https://github.com/erikw/tmux-powerline/raw/master/img/full.png)

**left-status**

Current tmux session, window and pane, hostname and LAN&WAN IP address.

![left-status](https://github.com/erikw/tmux-powerline/raw/master/img/left-status.png)

**right-status**

New mails, now playing in MPD, average load, date and time.

![right-status](https://github.com/erikw/tmux-powerline/raw/master/img/right-status.png)

Now I've read my inbox so the maildir segment disappears!

![right-status, no mail](https://github.com/erikw/tmux-powerline/raw/master/img/right-status_no_mail.png)

`mpc pause` and there's no need for showing NP anymore.

![right-status, no mpd](https://github.com/erikw/tmux-powerline/raw/master/img/right-status_no_mpd.png)

Weather segment using Google's weather API and remaining battery.

![right-status, weather and battery](https://github.com/erikw/tmux-powerline/raw/master/img/right-status_weather_battery.png)

# Requirements

* Recent tmux version
* `bash --version` >= 4.0
* [libmpdclient](http://sourceforge.net/projects/musicpd/files/libmpdclient/) for MPD now playing.

# Installation
Just check out the repo with:

	$ cd ~/some/path/
	$ git clone git://github.com/erikw/tmux-powerline.git

Now edit your `~/.tmux.conf` to use the scripts:

	set-option -g status on
	set-option -g status-interval 2
	set-option -g status-utf8 on
	set-option -g status-justify "centre"
	set-option -g status-left-length 60
	set-option -g status-right-length 120
	set-option -g status-left "#(~/path/to/tmux-powerline/status-left.sh)"
	set-option -g status-right "#(~/path/to/tmux-powerline/status-right.sh)"

Also I recommend you to use the [tmux-colors-solarized](https://github.com/seebi/tmux-colors-solarized) theme (as well as solarized for [everything else](http://ethanschoonover.com/solarized) :)):

	source ~/path/to/tmux-colors-solarized/tmuxcolors.conf

# Configuration

Edit the two status scripts to suit you needs. A number of common segments are included that covers some general functions like time, date battery etc. The segments can be moved around and does not needs to be in the order (or same file) as they are now. It should be quite easy to add you own segments.

	$ $EDITOR ~/path/to/tmux-powerline/status-left.sh
	$ $EDITOR ~/path/to/tmux-powerline/status-right.sh

Here is one segment configuration explained so you'll know how to make you own.

```bash
declare -A time 								# The name of the array.
time+=(["script"]="${segments_path}/time.sh")	# mandatory, the shell script producing the output text to be shown.
time+=(["foreground"]="colour136")				# mandatory, the text foreground color.
time+=(["background"]="colour235")				# mandatory, the text background color.
time+=(["separator"]="${separator_left_thin}")	# mandatory, the separator to use. Can be (as described in `lib.sh`) any of separator_(left(_(bold|thin))|right(_(bold|thin)))
time+=(["separator_fg"]="default")				# optional, overrides the default blending coloring of the separator with a custom colored foreground.
register_segment "time"							# Registers the name of the array declared above.
```

# Notes
It's written over a night and in Bash so be prepared for the ugliness. I had some interesting design ideas but after hours of struggling with associative arrays that could not be declare where and how I wanted etc. I just went with the ugly way(s) :-P

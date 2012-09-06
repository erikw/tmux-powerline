# tmux-powerline
This is a set of scripts (segments) for making a nice and dynamic tmux statusbar where elements can come and disappears depending on events. I really like the look of [Lokaltog/vim-powerline](https://github.com/Lokaltog/vim-powerline) and I decided I wanted the same for tmux.

The following segments exists for now:
* LAN & WAN IP addresses.
* Now Playing for MPD, Spotify (GNU/Linux native or wine, OS X), iTunes (OS X), Rhythmbox, Banshee and Audacious.
* New mail count for Maildir and Apple Mail.
* GNU/Linux and Macintosh OS X battery status (uses [richo/dotfiles/bin/battery](https://github.com/richoH/dotfiles/blob/master/bin/battery)).
* Weather in Celsius, Fahrenheit and Kelvin using Google's weather API.
* System load, cpu usage and uptime.
* Git, SVN and Mercurial branch in CWD.
* Date and time.
* Hostname.
* tmux info.
* CWD in pane.
* Current X keyboard layout.

Check [segments/](https://github.com/erikw/tmux-powerline/tree/master/segments) for more undocumented segments and details.

# Screenshots
**Full screenshot**

![Full screenshot](https://github.com/erikw/tmux-powerline/raw/master/img/full.png)

**left-status**

Current tmux session, window and pane, hostname and LAN & WAN IP address.

![left-status](https://github.com/erikw/tmux-powerline/raw/master/img/left-status.png)

**right-status**

New mails, now playing, average load, weather, date and time.

![right-status](https://github.com/erikw/tmux-powerline/raw/master/img/right-status.png)

Now I've read my inbox so the mail segment disappears!

![right-status, no mail](https://github.com/erikw/tmux-powerline/raw/master/img/right-status_no_mail.png)

After pausing the music there's no need for showing NP anymore. Also the weather has become much nicer!

![right-status, no mpd](https://github.com/erikw/tmux-powerline/raw/master/img/right-status_no_mpd.png)

Remaining battery.

![right-status, weather and battery](https://github.com/erikw/tmux-powerline/raw/master/img/right-status_weather_battery.png)

# Requirements
Requirements for the lib to work are:

* Recent tmux version
* `bash --version` >= 4.0
* A patched font. Follow instructions at [Lokaltog/vim-powerline/fontpatcher](https://github.com/Lokaltog/vim-powerline/tree/develop/fontpatcher).

## Segment Requirements
Requirements for some segments. You only need to fullfill the requirements for those segments you want to use.

* WAN IP: curl
* MPD now playing: [libmpdclient](http://sourceforge.net/projects/musicpd/files/libmpdclient/)
* xkb_layout: X11, XKB

## OS X specific requirements

**You still need to follow the first part of these instructions even if you are running zsh or something else as your default shell!**

tmux-powerline uses associative arrays in bash, which were added in bash version 4.0. OS X Lion ships with an antiquated version of bash ( run
`bash --version` to see your version). In order to use tmux-powerline, you need to install a newer version of bash, fortunately,
[brew](http://mxcl.github.com/homebrew/) makes this very easy. If you don't have brew, [install it](https://github.com/mxcl/homebrew/wiki/installation).
Then follow these steps:

```bash
$ brew install bash
```

**If you're using something other than bash (or if you don't want this newer version of bash as your default shell) you should be done now**. If something
seems broken, try following the last two steps and see if it helps:

```bash
$ sudo bash -c "echo /usr/local/Cellar/bash/%INSTALLED_VERSION%/bin/bash >> /private/etc/shells"
$ chsh -s /usr/local/Cellar/bash/%INSTALLED_VERSION%/bin/bash
```

The first command installs bash through brew, the second registers the new shell with the system and the third changes to the new shell for your user.
If you later upgrade bash through brew, don't forget to do the last two steps again with the new version number. After doing the above and restarting your
terminal, running `echo $SHELL` should result in the following:

```bash
$ echo $SHELL
/usr/local/Cellar/bash/%INSTALLED_VERSION%/bin/bash
```

# Installation
Just check out the repository with:

```console
$ cd ~/some/path/
$ git clone git://github.com/erikw/tmux-powerline.git
```

Now edit your `~/.tmux.conf` to use the scripts:

<!-- Close syntax enoguth. -->
```vim
set-option -g status on
set-option -g status-interval 2
set-option -g status-utf8 on
set-option -g status-justify "centre"
set-option -g status-left-length 60
set-option -g status-right-length 90
set-option -g status-left "#(~/path/to/tmux-powerline/status-left.sh)"
set-option -g status-right "#(~/path/to/tmux-powerline/status-right.sh)"
```

Set the maximum lengths to something that suits your configuration of segments and size of terminal (the maximum segments length will be handled better in the future). Don't forget to change the PLATFORM variable in `config.sh` or your `~/.bashrc` to reflect your operating system of choice.

Also I recommend you to use the [tmux-colors-solarized](https://github.com/seebi/tmux-colors-solarized) theme (as well as solarized for [everything else](http://ethanschoonover.com/solarized) :)):

```bash
source ~/path/to/tmux-colors-solarized/tmuxcolors.conf
```
Some segments e.g. cwd and cvs_branch needs to find the current working directory of the active pane. To achive this we let tmux save the path each time the bash prompt is displayed. Put this in your `~/.bashrc` or where you define you PS1 variable (I use and source `~/.bash_ps1`):

```bash
PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#I_#P") "$PWD")'
```

# Configuration

Edit the two status scripts to suit you needs. A number of common segments are included that covers some general functions like time, date, battery etc. The segments can be moved around and does not needs to be in the order (or same file) as they are now. It should be quite easy to add you own segments.

```console
$ $EDITOR ~/path/to/tmux-powerline/status-left.sh
$ $EDITOR ~/path/to/tmux-powerline/status-right.sh
```


Here is one segment configuration explained so you'll know how to make you own.

```bash
declare -A time 								# The name of the array.
time+=(["script"]="${segments_path}/time.sh")	# mandatory, the shell script producing the output text to be shown.
time+=(["foreground"]="colour136")				# mandatory, the text foreground color.
time+=(["background"]="colour235")				# mandatory, the text background color.
time+=(["separator"]="${separator_left_thin}")	# mandatory, the separator to use. Can be (as described in `lib.sh`) any of separator_(left|right)_(bold|thin)
time+=(["separator_fg"]="default")				# optional, overrides the default blending coloring of the separator with a custom colored foreground.
register_segment "time"							# Registers the name of the array declared above.
```
# Hacking

This project can only gain positively from contributions. Fork today and make your own enhancments and segments to share back!

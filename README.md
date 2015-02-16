# DEPRECATION WARNING
This project is in a maintenance mode and no future functionality is likely to be added. tmux-powerline, with all other powerline projects, is replaced by the new unifying [powerline](https://github.com/Lokaltog/powerline). However this project is still functional and can serve as a lightweight alternative for non-python users.

# tmux-powerline
This is a set of scripts for making a nice and dynamic tmux statusbar consisting of segments. This is much like [Lokaltog/vim-powerline](https://github.com/Lokaltog/vim-powerline) but for tmux.

The following segments exists for now:
* LAN & WAN IP addresses.
* Now Playing for MPD, Spotify (GNU/Linux native or wine, OS X), iTunes (OS X), Rhythmbox, Banshee, MOC, Audacious, Rdio (OS X), cmus, Pithos and Last.fm (last scrobbled track).
* New mail count for GMail, Maildir, mbox, mailcheck, and Apple Mail.
* GNU/Linux and Macintosh OS X battery status (uses [richo/dotfiles/bin/battery](https://github.com/richoH/dotfiles/blob/master/bin/battery)).
* Weather in Celsius, Fahrenheit and Kelvin using Yahoo Weather.
* System load, cpu usage and uptime.
* Git, SVN and Mercurial branch in CWD.
* Date and time.
* Hostname.
* tmux info.
* CWD in pane.
* Current X keyboard layout.
* Network download/upload speed.
* Earthquake warnings.

# Screenshots
**Full screenshot**

![Full screenshot](img/full.png)

**left-status**

Current tmux session, window and pane, hostname and LAN & WAN IP address.

![left-status](img/left-status.png)

**right-status**

New mails, now playing, average load, weather, date and time.

![right-status](img/right-status.png)

Now I've read my inbox so the mail segment disappears!

![right-status, no mail](img/right-status_no_mail.png)

After pausing the music there's no need for showing NP anymore. Also the weather has become much nicer!

![right-status, no mpd](img/right-status_no_mpd.png)

Remaining battery.

![right-status, weather and battery](img/right-status_weather_battery.png)

# Requirements
Requirements for the lib to work are:

* Recent tmux version
* `bash --version` >= 3.2 (Does not have to be your default shell.)
* A patched font. Follow instructions at [Powerline Installation](http://powerline.readthedocs.org/en/latest/installation/linux.html) or [download](https://github.com/powerline/fonts) a new one. However you can use other substitute symbols as well; see `config.sh`.

## Segment Requirements
Requirements for some segments. You only need to fulfill the requirements for those segments you want to use.

* `wan_ip.sh`, `now_playing.sh` (last.fm), `weather_yahoo.sh`: curl, bc
* `now_playing.sh` (mpd) : [libmpdclient](http://sourceforge.net/projects/musicpd/files/libmpdclient/)
* `xkb_layout.sh`: X11, XKB
* `mailcount.sh` (gmail): wget, (mailcheck): [mailcheck](http://packages.debian.org/sid/mailcheck).
* `ifstat.sh`: ifstat (there is a simpler segment not using ifstat but samples /sys/class/net)
* `tmux_mem_cpu_load.sh`: [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load)
* `rainbarf.sh`: [rainbarf](https://github.com/creaktive/rainbarf)
* `weather.sh`: GNU `grep` with Perl regexp enabled (FreeBSD specific)

## OS X specific requirements

The `grep` tool is outdated on OS X 10.8 Mountain Lion so you might have to upgrade it. Unfortunately the main homebrew repo
[does not contain grep](https://github.com/mxcl/homebrew/pull/3473) so use the following command to get the lastest version.

```bash
brew install https://raw.github.com/Homebrew/homebrew-dupes/master/grep.rb
```

or if you have heightened security set up, just tap the homebrew dupes and install grep

```bash
brew tap homebrew/dupes
brew install homebrew/dupes/grep
```

## FreeBSD specific requirements

Preinstalled `grep` in FreeBSD doesn't support Perl regexp. Solution is rather simple -- you need to use `textproc/gnugrep` port instead. You also need to make sure, that it has support for PCRE and is compiled with `--enable-perl-regexp` flag.


# Installation
Start with checking out the repository with:

```console
$ cd ~/some/path/
$ git clone https://github.com/erikw/tmux-powerline.git
```

Now edit your `~/.tmux.conf` to use the scripts:

<!-- Close syntax enough. -->
```vim
set-option -g status on
set-option -g status-interval 2
set-option -g status-utf8 on
set-option -g status-justify "centre"
set-option -g status-left-length 60
set-option -g status-right-length 90
set-option -g status-left "#(~/path/to/tmux-powerline/powerline.sh left)"
set-option -g status-right "#(~/path/to/tmux-powerline/powerline.sh right)"
```

Set the maximum lengths to something that suits your configuration of segments and size of terminal (the maximum segments length will be handled better in the future).

The window list can be powerlineified if you'd like by adding the following line to the same file:

```vim
set-window-option -g window-status-current-format "#[fg=colour235, bg=colour27]⮀#[fg=colour255, bg=colour27] #I ⮁ #W #[fg=colour27, bg=colour235]⮀"
```

You can toggle the visibility of the statusbars by adding the following lines:

```vim
bind C-[ run '~/path/to/tmux-powerline/mute_powerline.sh left'		# Mute left statusbar.
bind C-] run '~/path/to/tmux-powerline/mute_powerline.sh right'		# Mute right statusbar.
```

Some segments e.g. cwd and cvs_branch needs to find the current working directory of the active pane. To achieve this we let tmux save the path each time the shell prompt is displayed. Put the line below in your `~/.bashrc` or where you define you PS1 variable. zsh users can put it in e.g. `~/.zshrc` and may change `PS1` to `PROMPT` (but that's not necessary).

```bash
PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'
```

# Configuration

The default segments that are shown are defined in `themes/default.sh`. You will probably want to change those to fit your needs. To do so you can edit that file directly but preferable, for easier updating of the repo, you can make a copy and edit that one (or see how to use custom themes directory below). A palette of colors that can be used can be obtained by running the script `color_palette.sh`.

```console
$ cp themes/default.sh themes/mytheme.sh
$ $EDITOR themes/mytheme.sh
```
Now  generate a default configuration file by doing

```console
$ ./generate_rc.sh
$ mv ~/.tmux-powerlinerc.default ~/.tmux-powerlinerc
$ $EDITOR ~/.tmux-powerlinerc
```
and change theme to use and values for segments you want to use. If you want to keep the repo checkout clean you can set custom segment and theme paths in the general section and then store your files outside the repo.

# Debugging

Some segments might not work on your system for various reasons such as missing programs or different versions not having the same options. To find out which segment is not working it may help to enable the debug setting in `~/.tmux-powerlinerc`. However this may not be enough to determine the error so you can inspect all executed bash commands (will be a long output) by doing

```console
$ bash -x powerline.sh (left|right)
```

To debug smaller portions of code, say if you think the problem lies in a specific segment, insert these lines at the top and bottom of the relevant code portions e.g. inside a function:

```bash
set -x
exec 2>/tmp/tmux-powerline.log
<code to debug>
set +x
```

and then inspect the outputs like

```console
less /tmp/tmux-powerline.log
tail -f /tmp/tmux-powerline.log # or follow output like this.
```

If you can not solve the problems you can post an [issue](https://github.com/erikw/tmux-powerline/issues?state=open) and be sure to include relevant information about your system and script output (from bash -x) and/or screenshots if needed.  Be sure to search in the [resolved issues](https://github.com/erikw/tmux-powerline/issues?page=1&state=closed) section for similar problems you're experiencing before posting.

## Common problems


### VCS_branch / PWD is not updating
The issue is probably that the update of the current directory in the active pane is not updated correctly. Make sure that your PS1 or PROMPT variable actually contains the line from the installation step above by simply inspecting the output of `echo $PS1`. You might have placed the PS1 line in you shell configuration such that it is overwritten later. The simplest solution is to put it at the very end to make sure that nothing overwrites it. See [issue #52](https://github.com/erikw/tmux-powerline/issues/52).

### Nothing is displayed
You have edited `~/.tmux.conf` but no powerline is displayed. This might be because tmux is not aware of the changes so you have to restart your tmux session or reloaded that file by typing this on the command line (or in tmux command mode with `prefix :`)

```console
$ tmux source-file ~/.tmux.conf
```
### Multiple lines in bash or no powerline in zsh using iTerm (OS X)
If your tmux looks like [this](https://github.com/erikw/tmux-powerline/issues/125) then you may have to in iTerm uncheck [Unicode East Asian Ambiguous characters are wide] in Preferences -> Settings -> Advanced.

# Hacking

This project can only gain positively from contributions. Fork today and make your own enhancements and segments to share back! If you'd like, add your name and E-mail to AUTHORS before making a pull request so you can get some credit for your work :-)

## How to make a segment
If you want to (of course you do!) send a pull request for a cool segment you written make sure that it follows the style of existing segments, unless you have good reason for it. Each segment resides in the `segments/` directory with a descriptive and simple name. A segment must have at least one function and that is `run_segment` which is like the main function that is called from the tmux-powerline lib. What ever text is echoed out from this function to stdout is the text displayed in the tmux statusbar. If the segment at a certain point does not have anything to show, simply don't echo anything out and the segment will be hidden. A successful execution of the `run_segment` function should return an exit code of 0. If the segment failed to execute in a fatal way return a non-zero exit code so the user can pick up the error and fix it when debug mode is on (e.g. missing program that is needed for the segment).

Usage of helper function to organize the work of a segment is encourage and should be named in the format `__helper_func`. If a segment has settings it should have a function `generate_rc` which outputs default values of all settings and a short explanation of the setting and its values. Study e.g. `segments/now_playing.sh` to see how it is done. A segment having settings should typically call a helper function `__process_settings` as the first statement in `run_segment` that sets default values to the settings that has not been set by the user.

Also, don't use bash4 features as requiring bash4 complicates installation for OS X user quite a bit. Use tabs for indentation ([discussion](https://github.com/erikw/tmux-powerline/pull/92)),

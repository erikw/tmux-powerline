# tmux-powerline
This is a set of scripts for making a nice and dynamic tmux statusbar consisting of segments. This is much like [Lokaltog/vim-powerline](https://github.com/Lokaltog/vim-powerline) but for tmux.

The following segments exists for now:
* LAN & WAN IP addresses.
* Now Playing for MPD, Spotify (GNU/Linux native or wine, OS X), iTunes (OS X), Rhythmbox, Banshee, MOC, Audacious, Rdio (OS X), cmus and Last.fm (last scrobbled track).
* New mail count for GMail, Maildir, mbox and Apple Mail.
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
* A patched font. Follow instructions at [Lokaltog/vim-powerline/fontpatcher](https://github.com/Lokaltog/vim-powerline/tree/develop/fontpatcher) or [download](https://github.com/Lokaltog/vim-powerline/wiki/Patched-fonts) a new one. However you can use other substitute symbols as well; see `config.sh`.

## Segment Requirements
Requirements for some segments. You only need to fulfill the requirements for those segments you want to use.

* wan_ip.sh, np_lastfm.sh, weather_yahoo.sh: curl, bc
* np_mpd.sh: [libmpdclient](http://sourceforge.net/projects/musicpd/files/libmpdclient/)
* xkb_layout.sh: X11, XKB
* mail_count_gmail.sh: wget.
* ifstat.sh: ifstat (there is a simpler segment not using ifstat but samples /sys/class/net)
* tmux_mem_cpu_load.sh: [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load)

## OS X specific requirements

**You still need to follow the first part of these instructions even if you are running zsh or something else as your default shell!**

tmux-powerline uses associative arrays in bash, which were added in bash version 4.0. OS X Lion ships with an antiquated version of bash ( run
`bash --version` to see your version). In order to use tmux-powerline, you need to install a newer version of bash, fortunately,
[brew](http://mxcl.github.com/homebrew/) makes this very easy. If you don't have brew, [install it](https://github.com/mxcl/homebrew/wiki/installation). Alternatively the older [MacPorts](http://www.macports.org/) can be used.
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

The `grep` tool is outdated on OS X 10.8 Mountain Lion so you might have to upgrade it. Unfortunately the main homebrew repo 
[does not contain grep](https://github.com/mxcl/homebrew/pull/3473) so use the following command to get the lastest version.

```bash
brew install https://raw.github.com/Homebrew/homebrew-dupes/master/grep.rb
```

# Installation
Just check out the repository with:

```console
$ cd ~/some/path/
$ git clone git://github.com/erikw/tmux-powerline.git
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

Set the maximum lengths to something that suits your configuration of segments and size of terminal (the maximum segments length will be handled better in the future). Segments needs to use different tools or options depending on platform. Currently there is only a distinction between Linux systems and OS X systems. `config.sh` tries to detect what machine you're on with `uname`. If needed you can override this setting with the PLATFORM variable there (or wherever you want to define it).


Some segments e.g. cwd and cvs_branch needs to find the current working directory of the active pane. To achieve this we let tmux save the path each time the shell prompt is displayed. Put the line below in your `~/.bashrc` or where you define you PS1 variable. zsh users can put it in e.g. `~/.zshrc` and may change `PS1` to `PROMPT` (but that's not necessary).

```bash
PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'
```

You can toggle the visibility of the statusbars by adding the following to your `~/.tmux.conf`:

```vim
bind C-[ run '~/path/to/tmux-powerline/mute_statusbar.sh left'		# Mute left statusbar.
bind C-] run '~/path/to/tmux-powerline/mute_statusbar.sh right'		# Mute right statusbar.
```

# Configuration

The default segments that are shown are defined in `themes/default.sh`. You will probably want to change those to fit your needs. To do so you can edit that file directly but preferable, for easier updating of the repo, you can make a copy and edit that one (or see how to use custom themes directory below).

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
and editing theme to use and values for segments you want to use.

## Custom themes and segments
<!-- TODO: Add better explanation -->
If you would like to add custom segments or themes but keep the cloned tmux-powerline repository clean in order to update it easily, you can define custom paths to directories containing the themes and segments. Add the following to your ~/.tmux-powerlinerc (e.g. under General):

```bash
export TMUX_POWERLINE_DIR_USER_THEMES="/path/to/your/custom/themes"
export TMUX_POWERLINE_DIR_USER_SEGMENTS="/path/to/your/custom/segments"
```

Once these are defined, tmux-powerline will search these first before looking in the default paths for the themes or segments specified in the rc-file and theme respectively.

# Debugging

Some segments might not work on your system for various reasons such as missing programs or different versions not having the same options. To find out which segment is not working it may help to enable the debug setting in `~/.tmux-powerlinerc`. However this may not be enough to determine the error so you can inspect all executed bash command (will be a long output) by doing

```console
$ bash -x powerline.sh (left|right)
```

If you can not solve the problems you can post an [issue](https://github.com/erikw/tmux-powerline/issues?state=open) and be sure to include relevant information about your system and script output (from bash -x) and/or screenshots if needed.

## Common problems

### VCS_branch is not updating
The issue is probably that the update of the current directory in the active pane is not updated correctly. Make sure that your PS1 or PROMPT variable actually contains the line from the installation step above by simply inspecting the output of `echo $PS1`. You might have placed the PS1 line in you shell configuration such that it is overwritten later. The simplest solution is to put it at the very end to make sure that nothing overwrites it. See [issue #52](https://github.com/erikw/tmux-powerline/issues/52).

### Nothing is displayed
You have edited `~/.tmux.conf` but no powerline is displayed. This might be because tmux is not aware of the changes so you have to restart your tmux session or reloaded that file by typing this on the command line (or in tmux command mode with prefix-:)

```console
$ tmux source-file ~/.tmux.conf
```

# Hacking

This project can only gain positively from contributions. Fork today and make your own enhancements and segments to share back! If you'd like, add your name and E-mail to AUTHORS before making a pull request so you can get some credit for your work :)

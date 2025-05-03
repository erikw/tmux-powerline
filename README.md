<!-- markdownlint-disable first-line-heading -->
<p align="center">
<img alt="log" width="80%" src="img/logo.png" />
</p>
<p align="center">
    <i>Empowering your tmux (status bar) experience!</i>
    <a href="https://x.com/intent/post?text=%E2%9A%A1%EF%B8%8Ftmux-powerline%E2%9A%A1%EF%B8%8F:%20A%20tmux%20plugin%20for%20a%20hackable%20status%20bar%20consisting%20of%20segments&url=https%3A%2F%2Fgithub.com%2Ferikw%2Ftmux-powerline&via=erik_westrup&hashtags=tmux%2Ctmux_powerline%2Cstatusbar" title="Post on X"><img src="https://img.shields.io/twitter/url/http/shields.io.svg?style=social" alt="Post on X" /></a>
</p>
<hr>

<p align="center">
   <img src="https://img.shields.io/github/stars/erikw/tmux-powerline?style=social" alt="GitHub Stars"  />
   <img src="https://img.shields.io/github/forks/erikw/tmux-powerline?style=social" alt="GitHub Forks"  />
</p>
<p align="center">
    <!-- Ref: https://dev.to/azure/adding-a-github-codespace-button-to-your-readme-5f6l -->
    <a href="https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=4647320" title="Open in GitHub Codespaces" ><img alt="Open in GitHub Codespaces" src="https://github.com/codespaces/badge.svg"></a>
</p>

<!-- markdownlint-disable no-empty-links -->
[![Lint Full](https://github.com/erikw/tmux-powerline/actions/workflows/linter-full.yml/badge.svg)](https://github.com/erikw/tmux-powerline/actions/workflows/linter-full.yml)
[![SLOC](https://sloc.xyz/github/erikw/tmux-powerline?lower=true)](#)
[![Number of programming languages used](https://img.shields.io/github/languages/count/erikw/tmux-powerline)](#)
[![Top programming languages used](https://img.shields.io/github/languages/top/erikw/tmux-powerline)](#)
[![Open issues](https://img.shields.io/github/issues/erikw/tmux-powerline)](https://github.com/erikw/tmux-powerline/issues)
[![Closed issues](https://img.shields.io/github/issues-closed/erikw/tmux-powerline?color=success)](https://github.com/erikw/tmux-powerline/issues?q=is%3Aissue+is%3Aclosed)
[![Closed PRs](https://img.shields.io/github/issues-pr-closed/erikw/tmux-powerline?color=success)](https://github.com/erikw/tmux-powerline/pulls?q=is%3Apr+is%3Aclosed)
[![License](https://img.shields.io/badge/license-BSD--3-blue)](LICENSE.txt)
[![OSS Lifecycle](https://img.shields.io/osslifecycle/erikw/tmux-powerline)](https://github.com/Netflix/osstracker)
[![Latest tag](https://img.shields.io/github/v/tag/erikw/tmux-powerline)](https://github.com/erikw/tmux-powerline/tags)
<br>
<!-- markdownlint-enable no-empty-links -->

[![Contributors](https://img.shields.io/github/contributors/erikw/tmux-powerline)](https://github.com/erikw/tmux-powerline/graphs/contributors) including these top contributors:
<a href="https://github.com/erikw/tmux-powerline/graphs/contributors">
<img alt="Top Contributors" src="https://contrib.rocks/image?repo=erikw/tmux-powerline&max=36"/>
</a>


# Intro
tmux-powerline is a tmux <a title="Tmux Plugin Manager" href="https://github.com/tmux-plugins/tpm">tpm</a> plugin that gives you a slick and hackable powerline status bar consisting of segments. It's easily extensible with custom segments and themes.
The plugin itself is implemented purely in bash thus minimizing system requirements. However you can make segments in any language you want (with a shell wrapper).

Some examples of segments available that you can add to your tmux status bar are (full list [here](https://github.com/erikw/tmux-powerline/tree/main/segments)):
* LAN & WAN IP addresses
* Now Playing for MPD, Spotify (GNU/Linux native or wine, macOS), iTunes (macOS), Rhythmbox, Banshee, MOC, Audacious, Rdio (macOS), cmus, Pithos and Last.fm (last scrobbled track).
* New mail count for GMail, Maildir, mbox, mailcheck, and Apple Mail
* GNU/Linux and macOS battery status (uses [richo/dotfiles/bin/battery](https://github.com/richoH/dotfiles/blob/master/bin/battery))
* Weather in Celsius, Fahrenheit and Kelvin using Yahoo Weather
* System load, cpu usage and uptime
* Git, SVN and Mercurial branch in CWD
* Date and time
* Hostname
* tmux info
* tmux mode indicator (normal/prefix, mouse, copy modes)
* CWD in pane
* Current X keyboard layout
* Network download/upload speed
* Earthquake warnings

# Screenshots
**Full screenshot**

<a href="img/full.png" title="Full screenshot"><img src="img/full.png" width="850" alt="Full screenshot"></a>

**left-status**

Current tmux session, window and pane, hostname and LAN & WAN IP address.

![left-status](img/left-status.png)

**right-status**

New mails, now playing, average load, weather, date and time.

![right-status](img/right-status.png)

Now I've read my inbox so the mail segment disappears!

![right-status, no mail](img/right-status_no_mail.png)

After pausing the music there's no need for showing the Now Playing segment anymore. Also the weather has become much nicer!

![right-status, no mpd](img/right-status_no_mpd.png)

Laptop mode: a battery segment.

![right-status, weather and battery](img/right-status_weather_battery.png)

**dual-line status**

![dual-line status bar](img/dual-line-status-bar.png)

# Co-Maintainer
[@xx4h](https://github.com/xx4h) is helping out developing, maintaining and managing this project!

# Requirements
Requirements for the lib to work are:
* `tmux -V` >= 2.9
* `bash --version` >= 3.2 (Does not have to be your default shell.)
* Nerd Font. Follow instructions at [Font Installation](https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#font-installation). However you can use other substitute symbols as well; see `config.sh`.

## Segment Requirements
Some segments have their own requirements. If you enable them in your theme, make sure all requirements are met for those.

* **dropbox_status.sh**: `dropbox-cli`
* **github_notifications.sh**: `jq`
* **ifstat.sh**: `ifstat` (there is a simpler segment `ifstat_sys.sh` not using ifstat)
* **mailcount.sh**
   * gmail: `wget`
   * mailcheck: [mailcheck](http://packages.debian.org/sid/mailcheck)
* **now_playing.sh**
   * mpd: [libmpdclient](http://sourceforge.net/projects/musicpd/files/libmpdclient/)
   * last.fm: `jq`, `curl`
* **rainbarf.sh**: [rainbarf](https://github.com/creaktive/rainbarf)
* **tmux_mem_cpu_load.sh**: [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load)
* **wan_ip.sh**: `curl`
* **weather.sh**:
   * Provider *yrno*: `jq`, `curl`
* **xkb_layout.sh**: X11, XKB

# Installation
1. Install [tpm](https://github.com/tmux-plugins/tpm) and make sure it's working.
2. Install tmux-powerline as a plugin by adding a line to `tmux.conf`:
     ```conf
      set -g @plugin 'erikw/tmux-powerline'
     ```
3. Install the plugin with `<prefix>I`, unless you changed [tpm's keybindings](https://github.com/tmux-plugins/tpm#key-bindings).
   * The default powerline should already be visible now!
4. Continue to the [Configuration](#configuration) section below.

> [!NOTE]
> Note that tpm plugins should be at the bottom of you `tmux.conf`. This plugin will then override some tmux settings like `status-left`, `status-right` etc. If you had already set those in your tmux config, it is a good opportunity to remove or comment those out.
> Take a look at [main.tmux](https://github.com/erikw/tmux-powerline/blob/main/main.tmux) for exactly which settings are overridden.


# Configuration
tmux-powerline stores the custom config, themes and segments at `$XDG_CONFIG_HOME/tmux-powerline/`.

To make the following example easier, let's assume the following:
* `$XDG_CONFIG_HOME` has the default value of `~/.config`
* tmux-powerline was installed to the XDG path `~/.config/tmux/plugins/tmux-powerline`

Adapt the commands below if your paths differs from this.

## Configuration File
Start by generating your own configuration file:
```shell
~/.config/tmux/plugins/tmux-powerline/generate_config.sh
mv ~/.config/tmux-powerline/config.sh.default ~/.config/tmux-powerline/config.sh
$EDITOR ~/.config/tmux-powerline/config.sh
```

Go through the default config and adjust to your needs!

## Custom Theme
The theme is specified by setting the environment variable `$TMUX_POWERLINE_THEME` in the config file above. It will use a default theme and you probably want to use your own. The default config have set the custom theme path to be `~/.config/tmux-powerline/themes/`.

Make a copy of the default theme and make your own, say `my-theme`:
```shell
mkdir -p ~/.config/tmux-powerline/themes
cp ~/.config/tmux/plugins/tmux-powerline/themes/default.sh ~/.config/tmux-powerline/themes/my-theme.sh
$EDITOR ~/.config/tmux-powerline/themes/my-theme.sh
```

> [!IMPORTANT]
> Remember to update the configuration file to use the new theme by setting `TMUX_POWERLINE_THEME=my-theme`

## Custom Segments
In the same was as themes, you can create your own segments at `TMUX_POWERLINE_DIR_USER_SEGMENTS` which defaults to `~/.config/tmux-powerline/segments`.

To get started, copy an existing segment that is similar to the segment that you want to create.
```shell
mkdir -p ~/.config/tmux-powerline/segments
cp ~/.config/tmux/plugins/tmux-powerline/segments/date.sh ~/.config/tmux-powerline/segments/my-segment.sh
$EDITOR ~/.config/tmux-powerline/segments/my-segment.sh
```

Now you can add `my-segment` to your own theme!

Also see [How to make a segment](#how-to-make-a-segment) below for more details.


# Debugging
Some segments might not work on your system for various reasons such as missing programs or different versions not having the same options. To find out which segment is not working it may help to enable the debug setting in `~/.config/tmux-powerline/config.sh`.
However this may not be enough to determine the error so you can inspect all executed bash commands (will be a long output) by doing

```shell
bash -x powerline.sh (left|right)
```

To debug smaller portions of code, say if you think the problem lies in a specific segment, insert these lines at the top and bottom of the relevant code portions e.g. inside a function:

```bash
set -x
exec 2>/tmp/tmux-powerline.log
<code to debug>
set +x
```

and then inspect the outputs like

```shell
less /tmp/tmux-powerline.log
tail -f /tmp/tmux-powerline.log # or follow output like this.
```


You can also enable the debug mode in your config file. Look for the `TMUX_POWERLINE_DEBUG_MODE_ENABLED` environment variable and set it to `true`.

If you can not solve the problems you can post an [issue](https://github.com/erikw/tmux-powerline/issues?state=open) and be sure to include relevant information about your system and script output (from bash -x) and/or screenshots if needed.
Be sure to search in the [resolved issues](https://github.com/erikw/tmux-powerline/issues?page=1&state=closed) section for similar problems you're experiencing before posting.



## Common Problems
### Nothing is Displayed
You have edited `~/.tmux.conf` but no powerline is displayed. This might be because tmux is not aware of the changes so you have to restart your tmux session or reloaded that file by typing this on the command-line (or in tmux command mode with `prefix :`)

```shell
tmux source-file ~/.tmux.conf
```

### Multiple lines in bash or no powerline in Zsh using iTerm (macOS)
If your tmux looks like [this](https://github.com/erikw/tmux-powerline/issues/125) then you may have to in iTerm uncheck [Unicode East Asian Ambiguous characters are wide] in Preferences -> Settings -> Advanced.


# Hacking (Development)
> [!IMPORTANT]
> Please read and follow the [CONTRIBUTING.md](CONTRIBUTING.md) guidelines!

This project can only gain positively from contributions. Fork today and make your own enhancements and segments to share back!

## Codespaces Devcontainer
You can fork this project and then start coding right away with GitHub Codespaces as this project is set up to install all development dependencies and install tmux-powerline on the devcontainer. See [devcontainer.json](.devcontainer/devcontainer.json) and [devcontainer_postCreateCommand.sh](scripts/devcontainer_postCreateCommand.sh). After starting the devcontainer, just type `tmux` in the terminal and you should see a working tmux-powerline already to start playing with.

> [!IMPORTANT]
> If you have set up your own dotfiles to be installed with GitHub Codespaces, and there was some tmux config files installed from your dotfiles to the devcontainer, then you might have to run this script to wipe your config in favour of the setup provided by this repo's initialization:
> 
> ```shell
> ./scripts/devcontainer_postCreateCommand.sh
> ```

## How To Make a Segment
Please section *How To Make a Segment* at [CONTRIBUTING.md](CONTRIBUTING.md#how-to-make-a-segment).



# Releasing
Create a new version of this project by using [semver-cli](https://github.com/maykonlsf/semver-cli).

```shell
vi CHANGELOG.md
semver up minor
ver=$(semver get release)
git commit -am "Bump version to $ver" && git tag $ver && git push --atomic origin main $ver
```

# More tmux Plugins
I have another tmux plugin that might interest you:
* [tmux-dark-notify](https://github.com/erikw/tmux-dark-notify) - A plugin that make tmux's theme follow macOS dark/light mode.

# Welcome to tmux-powerline Contributing Guide
🚀 Thank you for wanting to contribute to the powerline of tmux!


# Pull Requests
If you make changes to existing segments/libs or create a new segment, please follow these requirements. These are set up to make sure that this projects works on different Linux, *BSDs, and macOS by using as few dependencies as needed.

* `\t`: Use (hard) tabs for indentation [discussion](https://github.com/erikw/tmux-powerline/pull/92).
* `grep`: only use standard grep features. GNU Grep is awesome like the `-P` switch, but macOS/BSD system's does not have this version and needs to install this extra (`ggrep`) and fix their PATHs. Please use only feature that works with both GNU and BSD version of grep.
* `bash`: don't use bash4 features as requiring bash4 complicates installation for macOS user quite a bit.
* 🛑 **Avoid bringing in more dependencies**. If there is really no way around it, please document which tool needs to be installed and how that can be done in the [README.md](README.md#segment-requirements) *Segment Requirements* section.
* 🐧🍎 If possible **test your changes on both a Linux and a macOS system**, as the base tools might behave differently or support different commandline options. If you're on macOS, you can easily spin up a Virtualbox with a Linux image.
* 📰 New segment/feature or a larger change: please include an update to [CHANGELOG.md](CHANGELOG.md) in your PR.

# How To Make a Segment
If you want to (of course you do!) send a pull request for a cool segment you written make sure that it follows the style of existing segments, unless you have good reason for it. Each segment resides in the `segments/` directory with a descriptive and simple name.

A segment must have at least one function and that is `run_segment()` which is like the main function that is called from the tmux-powerline lib. What ever text is echoed out from this function to stdout is the text displayed in the tmux status bar.

If the segment at a certain point does not have anything to show, simply don't echo anything out and the segment will be hidden. A successful execution of the `run_segment()` function should return an exit code of 0.
If the segment failed to execute in a fatal way return a non-zero exit code so the user can pick up the error and fix it when debug mode is on (e.g. missing program that is needed for the segment).

Usage of helper function to organize the work of a segment is encourage and should be named in the format `__helper_func`.

If a segment has settings it should have a function `generate_segmentrc()` which outputs default values of all settings and a short explanation of the setting and its values. Study e.g. [`segments/now_playing.sh`](segments/now_playing.sh) to see how it is done. A segment having settings should typically call a helper function `__process_settings()` as the first statement in `run_segment()` that sets default values
to the settings that has not been set by the user.
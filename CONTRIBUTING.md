# Welcome to tmux-powerline contributing guide
🚀 Thank you for wanting to contibute to the powerline of tmux!


# Pull Requests
If you make changes to existing segments/libs or create a new segment, please follow these requirements. These are set up to make sure that this projects works on different Linux, *BSDs, and macOS by using as few dependencies as needed.

* `\t`: Use (hard) tabs for indentation [discussion](https://github.com/erikw/tmux-powerline/pull/92).
* `grep`: only use standard grep features. GNU Grep is awesome like the `-P` switch, but macOS/BSD system's does not have this version and needs to install this extra (`ggrep`) and fix their PATHs. Please use only feature that works with both GNU and BSD version of grep.
* `bash`: don't use bash4 features as requiring bash4 complicates installation for macOS user quite a bit.
* 🛑 **Avoid bringing in more dependencies**. If there is really no way around it, please document which tool needs to be installed and how that can be done in the [README.md](../README.md#segment-requirements) *Segment Requirements* section.
* 🐧🍎 If possible **test your changes on both a Linux and a macOS system**, as the base tools might behave differently or support different commandline options. If you're on macOS, you can easily spin up a Virtualbox with a Linux image.
* 📰 New segment/feature or a larger change: please include an update to [../CHANGELOG.md](CHANGELOG.md) in your PR.

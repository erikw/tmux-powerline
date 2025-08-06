# shellcheck shell=bash

# https://www.nerdfonts.com/cheat-sheet?q=nf-fa-dropbox
TMUX_POWERLINE_SEG_DROPBOX_GLYPH_DEFAULT=$'\uf16b'
# https://www.nerdfonts.com/cheat-sheet?q=nf-fa-upload
TMUX_POWERLINE_SEG_DROPBOX_UPLOAD_GLYPH_DEFAULT=$'\uf093'
# https://www.nerdfonts.com/cheat-sheet?q=nf-fa-download
TMUX_POWERLINE_SEG_DROPBOX_DOWNLOAD_GLYPH_DEFAULT=$'\uf019'
# https://www.nerdfonts.com/cheat-sheet?q=nf-fa-bookmark
TMUX_POWERLINE_SEG_DROPBOX_INDEX_GLYPH_DEFAULT=$'\uf02e'
# https://www.nerdfonts.com/cheat-sheet?q=nf-oct-sync
TMUX_POWERLINE_SEG_DROPBOX_SYNC_GLYPH_DEFAULT=$'\uf46a'

IFS= read -r -d '' TMUX_POWERLINE_SEG_DROPBOX_SED_SCRIPT <<EOSED
s/\(^.*\)\.\.\./\1/g
s/Syncing \([0-9]\+\) \(.*\)$/\${TMUX_POWERLINE_SEG_DROPBOX_SYNC_GLYPH} \1/g
s/Indexing \([0-9]\+\) \(.*\)$/\${TMUX_POWERLINE_SEG_DROPBOX_INDEX_GLYPH} \1/g
s/Uploading \([0-9]\+\) \(.*\)$/\${TMUX_POWERLINE_SEG_DROPBOX_UPLOAD_GLYPH} \1/g
s/Downloading \([0-9]\+\) \(.*\)$/\${TMUX_POWERLINE_SEG_DROPBOX_DOWNLOAD_GLYPH} \1/g
s/Syncing \(.*\)$/\${TMUX_POWERLINE_SEG_DROPBOX_SYNC_GLYPH} 1/g
s/Indexing \(.*\)$/\${TMUX_POWERLINE_SEG_DROPBOX_INDEX_GLYPH} 1/g
s/Uploading \(.*\)$/\${TMUX_POWERLINE_SEG_DROPBOX_UPLOAD_GLYPH} 1/g
s/Downloading \(.*\)$/\${TMUX_POWERLINE_SEG_DROPBOX_DOWNLOAD_GLYPH} 1/g
EOSED

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# The Dropbox glyph to use
export TMUX_POWERLINE_SEG_DROPBOX_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_GLYPH_DEFAULT}"
# Replace 'Uploading' in the status
export TMUX_POWERLINE_SEG_DROPBOX_UPLOAD_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_UPLOAD_GLYPH_DEFAULT}"
# Replace 'Downloading' in the status
export TMUX_POWERLINE_SEG_DROPBOX_DOWNLOAD_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_DOWNLOAD_GLYPH_DEFAULT}"
# Replace 'Indexing' in the status
export TMUX_POWERLINE_SEG_DROPBOX_INDEX_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_INDEX_GLYPH_DEFAULT}"
# Replace 'Syncing' in the status
export TMUX_POWERLINE_SEG_DROPBOX_SYNC_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_SYNC_GLYPH_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	if ! command -v dropbox-cli &>/dev/null; then
		printf "#[bg=colour124] %s ${TMUX_POWERLINE_SEG_DROPBOX_GLYPH} " "dropbox-cli not found"
		return 1
	fi
	status_text=$(dropbox-cli status \
			| sed "$TMUX_POWERLINE_SEG_DROPBOX_SED_SCRIPT" \
			| sed -z 's/\n/ /g;s/\(.*\) /\1/g' \
			| envsubst
	)
	if [ "${status_text}" = "Up to date" ]; then return 0; fi
	if [ "${status_text}" = "Dropbox isn't running!" ]; then
		printf "#[bg=colour124] %s ${TMUX_POWERLINE_SEG_DROPBOX_GLYPH} " "${status_text}"
	else
		printf "%s ${TMUX_POWERLINE_SEG_DROPBOX_GLYPH} " "${status_text}"
	fi
	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_DROPBOX_GLYPH" ]; then
		export TMUX_POWERLINE_SEG_DROPBOX_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_GLYPH_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_DROPBOX_UPLOAD_GLYPH" ]; then
		export TMUX_POWERLINE_SEG_DROPBOX_UPLOAD_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_UPLOAD_GLYPH_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_DROPBOX_DOWNLOAD_GLYPH" ]; then
		export TMUX_POWERLINE_SEG_DROPBOX_DOWNLOAD_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_DOWNLOAD_GLYPH_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_DROPBOX_INDEX_GLYPH" ]; then
		export TMUX_POWERLINE_SEG_DROPBOX_INDEX_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_INDEX_GLYPH_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_DROPBOX_SYNC_GLYPH" ]; then
		export TMUX_POWERLINE_SEG_DROPBOX_SYNC_GLYPH="${TMUX_POWERLINE_SEG_DROPBOX_SYNC_GLYPH_DEFAULT}"
	fi
}

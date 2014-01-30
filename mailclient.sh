#!/bin/sh

command -v tmux >/dev/null 2>&1 || return 1

if tmux has-session -t "mutt" 2>/dev/null; then
  #[[ $- != *i* ]] && return

  #urxvt -e bash -c "tmux attach -d -t ${name}"
  tmux attach -d -t "mutt"
else
  #urxvt -e bash -c "tmux new-session -s \"${name}\" \"${file_path}\" \; set-option status \; set set-titles-string \"${name} (tmux@${HOST})\""
  tmux new-session -s "mutt" "command mutt" \; set-option status \; set set-titles-string "mutt (tmux@x230)"
fi

#!/usr/bin/env sh

ps1='➤' # head of the to-be-executed prompt line
pslines=2 # num of lines in prompt (relevant for multiline prompts)

tmpfile=$(mktemp /tmp/st-output.XXXXXX)
trap 'rm "$tmpfile"' 0 1 15

# write to file
sed -n "w $tmpfile"

# setup data structure for all lines matching ps1. Format is
#   <first line of output>:<lines in output>:<command which produced output>
# Omit empty prompt lines.
data=$(awk -v ps1="^$ps1" -v pslines="$pslines" '{
if($0 ~ ps1) {
  if(_prev) { print _prev+1":"NR-_prev-pslines":"_cmd };
  _cmd=$0;
  _prev=NR
};}
END {
  if(_prev) { print _prev+1":"NR-_prev":"_cmd };
  }' "$tmpfile" | sed -E '/[[:digit:]]+:[[:digit:]]+:'"$ps1"'\s+$/d')
numchoices=$(printf '%s\n' "$data" | wc -l)

# prompt user to choose. Decorate lines a little bit and show them in inverse order. Prepend with line number which we
# use to match the chosen line in $data (reverse index due to `tac').
choice=$(printf '%s\n' "$data" | tac | sed -E 's/^[[:digit:]]+:([[:digit:]]+):(.*)$/[\1 lines] \2/g' | nl -n ln -s ': ' -w 1 | dmenu -l 10 -p "Which command?")  || exit

# reverse index to match order in $data
ii=$(printf '%s\n' "$choice" | cut -d ':' -f 1 | xargs expr $numchoices + 1 -)

# extract line range and copy
range=$(printf '%s\n' "$data" | sed -n "$ii{p;q}" | cut -d ':' -f1-2)
first=$(echo $range | cut -d ':' -f 1)
last=$(echo $range | cut -d ':' -f 2 | xargs expr $first - 1 +)
sed -n "$first,${last}p;${last}q" "$tmpfile" | xclip -selection clipboard

# TODO:
# [ ] multiline commands - requires proper multiline prompt (preceed every line with >)

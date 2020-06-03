#!/usr/bin/env sh

ps1='^➤ ' # re matching the command line
pslines=2 # num of lines in prompt (relevant for multiline prompts)

tmpfile=$(mktemp /tmp/st-output.XXXXXX)
trap 'rm "$tmpfile"' 0 1 15
# write to file
sed -n "w $tmpfile"
# remove nulls
# sed -i 's/\x0//g' "$tmpfile"
#
data=$(awk -v ps1="$ps1" -v pslines="$pslines" '{
if($0 ~ ps1) {
  if(_prev) { print _prev+1":"NR-_prev-pslines":"_cmd };
  _cmd=$0;
  _prev=NR
};}
END {
  if(_prev) { print _prev+1":"NR-_prev":"_cmd };
  }' "$tmpfile")
numchoices=$(printf '%s\n' "$data" | wc -l)

printf '%s\n' "$data"

choice=$(printf '%s\n' "$data" | tac | sed -E 's/^[[:digit:]]+:([[:digit:]]+):(.*)$/[\1 lines] \2/g' | nl -n ln -s ': ' -w 1 | dmenu -l 10 -p "Which command?")  || exit
printf '%s\n' "$choice"

# reverse index to match order in $data
ii=$(printf '%s\n' "$choice" | cut -d ':' -f 1 | xargs expr $numchoices + 1 -)
printf "ii = $ii\n"

range=$(printf '%s\n' "$data" | sed -n "$ii{p;q}" | cut -d ':' -f1-2)
first=$(echo $range | cut -d ':' -f 1)
last=$(echo $range | cut -d ':' -f 2 | xargs expr $first - 1 +)

printf '%s\n' "$range"
printf '%s\n' "$first"
printf '%s\n' "$last"

sed -n "$first,${last}p;${last}q" "$tmpfile"

# exit
# 
# # compute range
# echo LINESTART
# firstline=$(printf '%s\n' "$choices" | sed -n "$ii{p;q}" | cut -d ':' -f 1 | xargs expr 1 +)
# if [ $ii -eq $numchoices ]; then
#   lastline=$(wc -l "$tmpfile" | cut -d ' ' -f 1)
# else
#   lastline=$(printf '%s\n' "$choices" | sed -n "$(expr $ii + 1){p;q}" | cut -d ':' -f 1 | xargs expr -$pslines +)
# fi
# echo "first line = $firstline"
# echo "last line = $lastline"
# 
# 
# sed -n "$firstline,${lastline}p;${lastline}q" "$tmpfile"

# choices="$(grep -n "$ps1" "$tmpfile")"
# lines=$(printf '%s\n' "$choices" | cut -d ':' -f 1 | awk '{ if(NR>1){print $1-_n ;_n=$1};_n=$1 }') 
# numchoices=$(printf '%s\n' "$choices" | wc -l)
# echo "CHOICES (num = $numchoices)"
# printf '%s\n' "$choices"
# echo LINES
# echo $lines
# 
# exit
# # present choice in reverse order (last command on top)
# # TODO: Quit if selection empty
# chosen=$(printf '%s\n' "$choices" | sed -E 's/^[[:digit:]]+://g' | tac | nl -n ln -s ':' -w 1 | dmenu -l 10) || exit
# echo "CHOSEN"
# printf '%s\n' "$chosen"


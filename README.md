# st - the simple terminal

Applied the following patches on top of st v0.83:
 - alpha
 - clipboard
 - scrollback + scrollback-mouse-altscreen
 - externalpipe + externalpipe-eternal
 - font2

Features:
 - Copy output of last commands
 - Parse output of last commands for urls

### Todos

- [ ] Make pgup/pgdown respect MODE_ALTSCREEN as the mkeys do
- [ ] Use fallback font for colored emojis (lukesmith)
- [ ] Redraw on resize (seems difficult)
- [ ] Mark last shell command to being able to quickly jump to the beginnin of the output

for DOTFILE in $(find $HOME/dotprophet/aliases -maxdepth 1 -perm +111 -type f -or -type l)
do
  [ -f "$DOTFILE" ] && source "$DOTFILE"
done

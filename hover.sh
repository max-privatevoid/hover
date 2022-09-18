export HOVER_ORIGINAL_HOME="$HOME"
export HOVER_OVERLAY_DIR="$(mktemp -d)"
mkdir $HOVER_OVERLAY_DIR/{home,.upper,.work}
export HOVER_HOME=$HOVER_OVERLAY_DIR/home

hover_cleanup() {
  echo hover: cleaning up
  if ! umount $HOVER_HOME; then
    echo "hover: failed to unmount $HOVER_HOME"
    exit 1
  fi

  # be careful not to rm -rf the original home directory
  rmdir $HOVER_OVERLAY_DIR/home
  echo "hover: space consumed by temporary home directory:"
  dua -Ax $HOVER_OVERLAY_DIR/.upper
  rm -rf $HOVER_OVERLAY_DIR/.upper
  rm -rf $HOVER_OVERLAY_DIR/.work
  rmdir $HOVER_OVERLAY_DIR
}

hover_execute() {
  if ! fuse-overlayfs -o allow_root,lowerdir=$HOVER_ORIGINAL_HOME,workdir=$HOVER_OVERLAY_DIR/.work,upperdir=$HOVER_OVERLAY_DIR/.upper $HOVER_HOME; then
    echo "hover: failed to mount overlay"
    exit 1
  fi
  trap hover_cleanup EXIT
  HOVER_SAVED_APP_PATH="$PATH"
  export HOME=$HOVER_HOME
  export PATH="$HOVER_ORIGINAL_PATH"
  # change directory to temp home if already in $HOME outside
  HOVER_SAVED_PWD="$PWD"
  if [[ "$PWD" == "$HOVER_ORIGINAL_HOME" || "$PWD" == "$HOVER_ORIGINAL_HOME/"* ]]; then
    HOVER_PWD="${HOVER_HOME}${PWD#${HOVER_ORIGINAL_HOME}}"
    cd "$HOVER_PWD"
  fi
  "$@"
  cd "$HOVER_SAVED_PWD"
  export PATH="$HOVER_SAVED_APP_PATH"
  export HOME=$HOVER_ORIGINAL_HOME
}

cmd="$1"
shift
case "$cmd" in
  nix) hover_execute nix "$@";;
  ""|shell) hover_execute "$SHELL" "$@";;
  run) hover_execute "$@";;
  *)
    echo "hover: unknown operation: \"$1\""
    exit 1;;
esac

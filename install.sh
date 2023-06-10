#!/bin/bash
case "$(uname -s)" in
    Linux*) CURA_CONFIG_ROOT="$HOME/.local/share/cura";;
    Darwin*) CURA_CONFIG_ROOT="$HOME/Library/Application Support/cura";;
esac

echo "Looking for Cura configuration at $CURA_DIR ..."
[ -d "$CURA_CONFIG_ROOT" ] && CURA_DIR=$(find "$CURA_CONFIG_ROOT" -maxdepth 1 -type d | grep -E "/[0-9]+\.[0-9]+$" | sort | tail -n 1)

if [ -z "$CURA_DIR" ]
then
    echo "Can't find Cura configuration, aborting"
    exit 1
else
    echo "Found Cura configuration directory at $CURA_DIR"
fi

echo "Copying resources into $CURA_DIR ..."
cp -vR -- ./build/resources/* "$CURA_DIR/"

echo "All done! Please launch Cura to complete configuration."

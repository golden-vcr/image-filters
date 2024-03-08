#!/usr/bin/env bash
set -e
echo "CREATE $1"
for OBJFILE in $(find ./obj -name '*.o'); do
    if [ "$OBJFILE" != "./obj/main.o" ]; then
        echo "ADDMOD $OBJFILE"
    fi
done
for OBJFILE in $(find ./opencv-linux/lib -name '*.a'); do
    echo "ADDLIB $OBJFILE"
done
echo 'SAVE'
echo 'END'

#!/bin/sh -ex

if [ "$GROUP" != "" ]; then
    find "$HOME" ! -group "$GROUP" -exec chgrp "$GROUP_ID" {} \;
fi
if [ "$USER" != "" ]; then
    find "$HOME" ! -user "$USER" -exec chown "$USER_ID" {} \;
fi

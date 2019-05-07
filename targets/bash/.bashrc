#!/usr/bin/env bash

# This file is to be sourced

# Disable ^S and ^Q
stty -ixon

# source chunks
for bashrc_chunk  in $(/bin/ls -A ~/.bashrc.d/*.*.bashrc); do
  . "$bashrc_chunk"
done

# source local configs
if [[ ! -z $DF_LOCAL_CONFIGS ]]; then
  . $DF_LOCAL_CONFIGS/local.bashrc
fi

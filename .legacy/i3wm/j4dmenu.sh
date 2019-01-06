#!/usr/bin/env bash

j4-dmenu-desktop --dmenu="(cat ; (stest -flx $(echo $PATH | tr : ' ') | sort -u)) | dmenu" --display-binary

#!/usr/bin/env bash

DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
TASK=${1:-"default"}

homemaker -verbose -task=$TASK $DIR/config.toml $DIR


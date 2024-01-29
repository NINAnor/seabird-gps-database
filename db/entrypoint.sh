#!/bin/sh

set -ex

dbmate wait

exec "$@"

#!/bin/bash

set -ex

export PYTHONPATH=.
pdm run procrastinate --app=tasks.app schema --apply || true

exec "$@"

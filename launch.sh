#!/bin/sh
# Command Line args (that are passed)
args=$@
source sdg/bin/activate
# Add any env vars or extra args below
HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py $args

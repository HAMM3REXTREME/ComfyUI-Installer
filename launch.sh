#!/bin/sh
args=$@
source sdg/bin/activate
HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py "$args"

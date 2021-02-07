#!/bin/bash

eval $(opam env)
export LD_LIBRARY_PATH="$HOME/workspace/c/libfive/build/libfive/src/"
export LD_PRELOAD="$HOME/workspace/c/libfive/build/libfive/src/libfive.so"
# export DYLD_PRELOAD="$HOME/workspace/c/libfive/build/libfive/src/libfive.dylib"
#export DYLD_LIBRARY_PATH="$HOME/workspace/c/libfive/build/libfive/src"
#export DYLD_FALLBACK_FRAMEWORK_PATH="$HOME/workspace/c/libfive/build/libfive/src"

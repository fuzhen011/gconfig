#!/bin/bash

psret=$(ps -e | grep "FoxitReader" | awk '{print $1}')
kill -9 $psret
nohup FoxitReader >/dev/null 2>&1 &

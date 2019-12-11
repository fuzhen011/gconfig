#!/usr/bin/env python
#-*- coding: utf-8 -*-

# File Name: cp_app_ch.py
# Author: Kevin
# Created Time: 2020-03-17
# Description: this script is used for copying the app.c and app.h file from
# the appbuilder to the current working directory

import os
import shutil

BLE_SDK_DIR = os.environ.get('PATH_BLE_SDK')
BTMESH_SDK_DIR = os.environ.get('PATH_BTMESH_SDK')

BLE_PROJECTS = ["soc-empty"]
BTMESH_PROJECTS = ["light", "switch"]


def cp_app_ch(proj="soc-empty"):
    if proj in BLE_PROJECTS:
        shutil.copyfile(BLE_SDK_DIR + "/appbuilder/sample-apps/soc-empty/app.c",
                        os.getcwd() + "/app.c")
        shutil.copyfile(BLE_SDK_DIR + "/appbuilder/sample-apps/soc-empty/app.h",
                        os.getcwd() + "/app.h")
    else:
        print "NOT Implemented yet"
        exit(1)


if __name__ == '__main__':
    cp_app_ch()

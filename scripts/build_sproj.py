#!/usr/bin/env python
# -*- coding: utf-8 -*-

# File Name: build_sproj.py
# Author: Kevin
# Created Time: 2020-03-09
# Description:
import os

PROJ_NAME = os.getcwd()[(os.getcwd().find('/')+1):]


if __name__ == '__main__':
    path_studio = os.environ.get('PATH_STUDIO')
    path_studio = path_studio.replace(' ', '\\ ')
    os.popen(path_studio + "/developer/scripting/runScript.sh "
             + os.environ.get('PATH_MY_SCRIPT')
             + "/an1121_headless_builds/PythonScripts/BuildExistingProject_v2.py "
             + PROJ_NAME
             ).read()

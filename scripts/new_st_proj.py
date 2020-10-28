#!/usr/bin/env python
#-*- coding: utf-8 -*-

# File Name: new_proj.py
# Author: Kevin
# Created Time: 2020-03-06
# Description: This script is used when the Studio project is created, it
# copies the necessary files and generate the cflags for vim plugins

import os
import shutil

PROJ_NAME = os.getcwd()[(os.getcwd().find('/')+1):]
FILES_DIR = os.environ.get('PATH_MY_SCRIPT') + "/proj_scripts/"
BUILD_DIR = os.getcwd() + "/Debug"
GIT_CMD = "git init && git add . && git commit -m \"Initial Commit\""

files = [".gitignore", "Makefile.st", "symb.sh"]

vimrc_content = [
    "let g:ale_c_cc_executable = 'arm-none-eabi-gcc'\n",
    "let g:ale_cpp_cc_executable = 'arm-none-eabi-gcc'\n",
    "let g:ale_c_cc_options = "
]


def wrap_files():
    for i, file in enumerate(files):
        file = FILES_DIR + file
        files[i] = file


def parse_cflags():
    clean = os.popen("make clean")
    clean.read()
    make_ret = os.popen("make flags")
    make_out = make_ret.read()
    lines = make_out.split('\n')
    for line in lines:
        if line.find("arm-none-eabi-gcc") != -1:
            cflags_line = line
            break
    cflags_line = cflags_line.replace('\'', '')
    cflags_line = cflags_line.replace('\"', '')
    cflags_line = cflags_line.replace('/home/zhfu', '$HOME')
    cflags_line = cflags_line.replace('/Users/zhfu', '$HOME')
    cflags_line = cflags_line.replace('arm-none-eabi-gcc ', '')
    cflags_line = cflags_line.replace('-c ', '')
    turncate = cflags_line.find('-MMD ')
    cflags_line = cflags_line[:turncate]
    cflags_line = cflags_line.strip()
    cflags_line = "\'" + cflags_line + "\'"
    #  print cflags_line
    return cflags_line


def initiate_build():
    if os.path.isdir(BUILD_DIR):
        return
    os.popen(
        os.environ.get(
            'PATH_STUDIO') + "/developer/scripting/runScript.sh "
        + os.environ.get('PATH_MY_SCRIPT')
        + "/an1121_headless_builds/PythonScripts/BuildExistingProject_v2.py "
        + PROJ_NAME
    ).read()


def cflags_to_vimrclocal(cflags):
    with open(os.getcwd() + "/__vimrc_local.vim", 'w') as vimrc:
        vimrc_content[2] = vimrc_content[2] + cflags + "\n"
        vimrc.writelines(vimrc_content)
    pass


def copy_files():
    for file in files:
        if file == "Makefile.st":
            shutil.copyfile(FILES_DIR + file, os.getcwd() + "/" + "Makefile")
        else:
            shutil.copyfile(FILES_DIR + file, os.getcwd() + "/" + file)


def config_new_project():
    copy_files()
    initiate_build()
    cflags = parse_cflags()
    cflags_to_vimrclocal(cflags)
    r = os.system("git status")
    if r != 0:
        r = os.system(GIT_CMD)
    r = os.system("make")
    if r != 0:
        print "Build Failed"
    else:
        print "Build Succeeded"
    pass


if __name__ == '__main__':
    config_new_project()

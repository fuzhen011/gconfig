#!/usr/bin/env python
#-*- coding: utf-8 -*-

# File Name: new_proj.py
# Author: Kevin
# Created Time: 2020-03-06
# Description: 

import sys
import os
import shutil

BUILD_DIR = os.getcwd() + "/GNU ARM v7.2.1 - Default"
vimrc_content = [
    "let g:ale_c_gcc_executable = 'arm-none-eabi-gcc'\n",
    "let g:ale_cpp_gcc_executable = 'arm-none-eabi-gcc'\n",
    "let g:ale_c_gcc_options = "
]

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

def cflags_to_vimrclocal(cflags):
    with open(os.getcwd() + "/__vimrc_local.vim", 'w') as vimrc:
        vimrc_content[2] = vimrc_content[2] + cflags + "\n"
        vimrc.writelines(vimrc_content)
    pass

def update_local_vimrc():
    if not os.path.isdir(BUILD_DIR):
        print("Need to build the project from Studio")
        exit(1)

    cflags = parse_cflags()
    cflags_to_vimrclocal(cflags)

if __name__ == '__main__':
    update_local_vimrc()

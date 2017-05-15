#!/bin/bash

function remote_cmds {
    CURTIME=`date +%s`
    function prepend_meta { sed 's/^/\n'$1'\x0 '$2'\x0/' | sed 's/ //' ; }

    function pid_cmdline { cat /proc/$1/cmdline | prepend_meta "cmdline" $1 ; } 
    function pid_environ { cat /proc/$1/environ | prepend_meta "environ" $1 ; }
    function pid_lsof { lsof -Pn -p$1 | prepend_meta "lsof" $1 ; }
    function pid_fdmodage { 
        find -H /proc/$1/fd -xtype f -printf "%l\0%C@\n" \
          | awk -F'\0' -v curtime=$CURTIME '{ print $1"\0"curtime-$2}' \
          | prepend_meta fdmodage $1
    }

    function inet_pids { lsof -a -i -t ; }

    function gather_pid { 
        pid_cmdline $1
        pid_lsof $1
        pid_environ $1
        pid_fdmodage $1
    }

    for pid in `inet_pids` ; do 
        gather_pid $pid
    done | grep -a .
}

remote_host=$1
remote_cmd="`typeset -f` ; remote_cmds"

ssh $remote_host "$remote_cmd"
:

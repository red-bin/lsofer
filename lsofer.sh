#!/bin/bash

function remote_cmds {
    function prepend_meta { sed 's/^/\n'$1'\x0 '$2'\x0/' | sed 's/ //' ; }

    function pid_cmdline { cat /proc/$1/cmdline ; } 
    function pid_environ { cat /proc/$1/environ ; }
    function pid_mapfiles { awk '$NF ~ "^/" {print $NF}' /proc/$1/maps | sort | uniq ; }
    function pid_cwd { readlink -f /proc/$1/cwd ; }

    function inum_findstr { sed 's/\([0-9]\{1,\}\)/-inum \1 -o/g' \
                              | tr '\n' ' ' | sed 's/-o $//' ; }

    function pid_fdinfo { find -H /proc/$1/fd -printf "%s\0%m\0%g\0%u\0%l\0%C@\n" ; }

    function find_inodes { find -L /proc/[1-9][0-9]*/fd/ -maxdepth 2 \( `inum_findstr` \) ; }
    function extr_inodes { awk '$10 ~ "^[1-9][0-9]*$" {print $10}' ; }
    function net_inodes { cat /proc/net/{tcp,tcp6,udp} | extr_inodes ; }
    function inet_pids { net_inodes | find_inodes | awk -F'/' '{print $3}' | sort | uniq ; }

    function proto_files { grep -H . /proc/net/{tcp,tcp6,udp} ; }

    function gather_pid { 
        pid_cmdline $1 | prepend_meta "cmdline" $1
        pid_mapfiles $1 | prepend_meta "mapfiles" $1
        pid_cwd $1 | prepend_meta "cwd" $1
        pid_environ $1 | prepend_meta "environ" $1
        pid_fdinfo $1 | prepend_meta "fdinfo" $1
    }

    date +%s | prepend_meta "date"
    proto_files | prepend_meta "proto_files"
    inet_pids | for x in `cat` ; do gather_pid $x ; done
}

remote_cmds
remote_host=$1
remote_cmd="`typeset -f` ; remote_cmds"

ssh $remote_host "$remote_cmd"

#!/bin/bash
#清理各类缓存，包括应用软件缓存和日志，服务器应用缓存和日志等。

if [[ -z "$1" ]];then
    echo '用法：./cacheclean.sh [ all | svn | git | maven | gradle | tomcat | jetty | others 
]'
    echo '清理缓存'
    exit 1
fi



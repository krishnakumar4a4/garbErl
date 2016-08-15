#!/bin/bash

if [ $# == 1 ]
then
        if [[ "$1" =~ [a-zA-Z].erl$ ]]
        then
                #Still have to catch uppercase started function names in quotes
                #like 'Hellofun', these does exist too,also have to take in
                #account of occurence of % in list,string,binary,atom

                #Multiple spaces before function names needs to be worked up and also guards of the functions
                grep  -n "^[a-z].*(.*).*\->\|[[:space:]][a-z].*(.*).*\->" $1|grep -v "%%"|grep -v "[[:space:]][A-Z].*(.*).*\->\|^[A-Z].*(.*).*\->">function_names
                while read line
                do
                        NextPart=$(echo "$line"|cut -d':' -f2|cut -d'(' -f1)
                        echo $NextPart
                done<function_names>only_functions

                cat only_functions|uniq>uniq_funcs
                while read line
                do
                        Line=$(echo "$line"|cut -d':' -f1)
                        #echo "$Line"
                done<function_names

                ##Generate random function names from uniq_funcs
                INIT_FUNC="func_"
                INIT_NUM=1
                while read line
                do
                        NEW_NUM=`expr 1 + $INIT_NUM`
                        NEW_FUNC="$INIT_FUNC""$NEW_NUM"
                        INIT_NUM=$NEW_NUM
                        #matching word boundaries with \b to replace only complete
                        #words but not any substrings,although it misses replacing exports
                        echo "s/\b$line\b(/$NEW_FUNC(/g"
                done<uniq_funcs>uniq_tags.sed
                ##now apply the uniq_tags to erl file
                NEW_GARB_HEAD=`echo $1|cut -d'.' -f1`
                echo $NEW_GARB_HEAD
                NEW_GARB="$NEW_GARB_HEAD""_garb.erl"
                sed -f uniq_tags.sed $1>$NEW_GARB
                #cleaning up
                rm function_names
                rm only_functions
                rm uniq_funcs
        fi
fi

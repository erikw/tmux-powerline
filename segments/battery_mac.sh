#!/usr/bin/env bash

HEART_CONNECTED=♥
HEART_DISCONNECTED=♡

case $(uname -s) in
    "Darwin")
        ioreg -c AppleSmartBattery -w0 | \
        grep -o '"[^"]*" = [^ ]*' | \
        sed -e 's/= //g' -e 's/"//g' | \
        sort | \
        while read key value; do
            case $key in
                "MaxCapacity")
                    export maxcap=$value;;
                "CurrentCapacity")
                    export curcap=$value;;
                "ExternalConnected")
                    export extconnect=$value;;
            esac
            if [[ -n $maxcap && -n $curcap && -n $extconnect ]]; then
                if [[ "$curcap" == "$maxcap" ]]; then
                    exit
                fi
                if [[ "$extconnect" == "Yes" ]]; then
                    echo $HEART_CONNECTED $(( 100 * $curcap / $maxcap ))"%"
                else
                    echo $HEART_DISCONNECTED $(( 100 * $curcap / $maxcap ))"%"
                fi
                break
            fi
        done
esac

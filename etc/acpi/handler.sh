#!/bin/sh
# Default acpi script that takes an entry for all actions

set $*

case "$1" in
    button/power)
        case "$2" in
#           PBTN|PWRF)  logger "PowerButton pressed: $2" ;;
        esac
        ;;
    button/sleep)
        case "$2" in
#           SLPB|SBTN)   echo -n mem >/sys/power/state ;;
        esac
        ;;
    ac_adapter)
        case "$2" in
            AC|ACAD|ADP0|ACPI0003:00)
                (sleep 1 && su trygve -c "echo 'vicious.force({batterywidget})' | DISPLAY=:0 awesome-client") &
                case "$4" in
                    00000000)
                        /home/trygve/bin/coregov co
                    ;;
                    00000001)
                        /home/trygve/bin/coregov od
                    ;;
                esac
                ;;
        esac
        ;;
    button/lid)
        case "$3" in
            close)
                su trygve -c "DISPLAY=:0 /home/trygve/bin/lock 0" &
            ;;
        esac
        ;;
esac

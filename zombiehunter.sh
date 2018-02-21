#!/bin/bash
# Purpose: Matches zombie processes with the parent docker containers if possible.
# Usage: /usr/local/bin/zombiehunter.sh
# v2.0 with pod and project details
# Author: Fekete Zoltán (Z-Fekete@t-systems.com)
# Updated: Heidrich Attila (attila.heidrich@t-systems.com)

echo -e "\nZombies:"
ZOMBIEPPIDS=$(ps -e -o ppid,stat|awk '/Z/ {print $1}'|sort -u)
echo $ZOMBIEPPIDS

CONTAINERS=$(docker inspect -f '{{.Id}} ### {{.State.Pid}}' $(docker ps -q))

[[ -n "$ZOMBIEPPIDS" ]] && [[ -n "$CONTAINERS" ]] &&
BADCONTAINERS=$(for pp in $ZOMBIEPPIDS;do awk -v ppid=$pp '{if ($3 == ppid) print $1}' <<<"$CONTAINERS"; done|sort -u)

[[ -z "$BADCONTAINERS" ]] && echo -e "\n(found no container to restart)\n" && exit 1

echo -e "\nRestart Commands ### Details:"

case "$1"
in
    "-KILL"|"--KILL")
        for bc in "$BADCONTAINERS"; do echo Restarting ${bc}; docker restart ${bc}; done
        ;;
    *)
        for bc in "$BADCONTAINERS"; do echo "docker restart ${bc} &&"; done
        echo -e "\nPlease copy and run the restart commands manually or re-run with -KILL to kill the related zombies.\n" && exit 0
        ;;
esac

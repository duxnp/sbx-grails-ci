#!/bin/bash
### docker-entrypoint.sh
### to be run as the ENTRYPOINT within a container

exec java -Duser.country=US -Duser.language=en -jar /app/ROOT.war

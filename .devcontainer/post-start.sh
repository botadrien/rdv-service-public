#!/usr/bin/env bash
# S'exécute à chaque (re)démarrage du conteneur (création, ainsi que reprise d'un Codespace
# arrêté). Postgres et Redis tournent localement dans le conteneur (pas de service à part),
# donc il faut les redémarrer explicitement à chaque fois.
set -euo pipefail

sudo service postgresql start
sudo service redis-server start

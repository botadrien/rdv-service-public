FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Paquets système nécessaires pour compiler les gems natives (pg, etc.) et faire tourner
# Postgres/Redis localement dans le devcontainer (comme sur la VM devbox Lima, cf
# scripts/devtools/lima-vm/vm-install-dependencies.sh).
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        libyaml-dev \
        pkg-config \
        postgresql \
        redis-server \
    && rm -rf /var/lib/apt/lists/* \
    && service postgresql start \
    && su postgres -c "createuser --superuser vscode" \
    && service postgresql stop

# mise (gestionnaire de versions) installe Ruby/Node/Yarn aux versions exactes du repo
# (.ruby-version, .node-version, package.json#packageManager) dans postCreateCommand.
# On active mise dans .bashrc pour les shells interactifs (terminal du Codespace) ; les
# scripts postCreateCommand/postStartCommand mettent le PATH à jour eux-mêmes (cf
# scripts/devtools/lima-vm/vm-install-dependencies.sh, même approche sur la VM devbox).
USER vscode
RUN curl https://mise.run | sh \
    && echo 'eval "$($HOME/.local/bin/mise activate bash)"' >> "$HOME/.bashrc"
USER root

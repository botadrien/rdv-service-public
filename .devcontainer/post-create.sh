#!/usr/bin/env bash
# S'exécute une seule fois, à la création du Codespace : installe Ruby/Node/Yarn aux bonnes
# versions, les dépendances du projet, le navigateur Playwright, et prépare la base de test,
# pour que `bundle exec rspec spec` fonctionne immédiatement.
set -euo pipefail

cd "$(dirname "$0")/.."

# postCreateCommand ne charge pas .bashrc : on met le PATH à jour explicitement
# (mise, puis ses shims une fois `mise install` exécuté plus bas).
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

# cf CI (.github/workflows/ci.yml) : évite https://github.com/rails/rails/issues/53661
touch tmp/local_secret.txt
openssl rand -hex 64 > tmp/local_secret.txt

.devcontainer/post-start.sh # démarre Postgres et Redis

echo "==> Installation de Ruby/Node/Yarn (mise)…"
mise trust
mise install
mise reshim

echo "==> Setup du projet (bin/setup)…"
bin/setup

echo "==> Préparation de la base de test (mode non-parallèle, utilisé par 'bundle exec rspec')…"
RAILS_ENV=test bin/rails db:prepare

echo ""
echo "Setup terminé : lance 'bundle exec rspec spec' pour lancer les tests."

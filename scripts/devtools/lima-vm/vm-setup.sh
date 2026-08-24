#!/usr/bin/env bash
# S'exécute dans la VM Lima. Appelé par host-create-vm.sh.
# Variables d'environnement requises : PROJECT_DIR, HOST_HOME, VM_NAME

set -euo pipefail

# Le dossier parent du repo (p.ex. ~/dev) n'est pas monté depuis l'hôte, ce
# n'est qu'un dossier local à la VM créé par Lima et appartenant à root. On
# le passe à l'utilisateur courant pour que les dossiers frères du repo
# (worktrees créés par Orca) soient accessibles en écriture ; ils resteront
# locaux à la VM, jamais propagés vers l'hôte.
sudo chown "$(id -u):$(id -g)" "$(dirname "$PROJECT_DIR")"

sudo apt-get update -y
sudo apt-get install -y build-essential curl git vim tmux postgresql redis-server dnsutils
sudo systemctl enable postgresql redis-server
sudo systemctl start postgresql redis-server

sudo systemctl disable --now motd-news.timer # système d'annonces ubuntu

# config Postgres
sudo sed -i 's/^local\s\+all\s\+all\s\+peer/local   all             all                                     trust/' /etc/postgresql/16/main/pg_hba.conf
sudo systemctl reload postgresql
sudo -u postgres createuser --superuser rdvsp 2>/dev/null || echo 'role rdvsp already exists'

# Installe mise puis ruby, node et yarn
rm -rf ~/.local && ln -s "$PROJECT_DIR/tmp/lima-vm-cache/local" ~/.local
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
cd "$PROJECT_DIR" && mise trust && mise install && mise reshim

# Variables d'environnement (PATH ruby/node/yarn, POSTGRES_USER, identification de la VM),
# factorisées dans un seul fichier sourcé à la fois par les shells interactifs (~/.bashrc)
# et par les shells non interactifs (via BASH_ENV) — utile pour les agents IA qui lancent
# des commandes avec `bash -c` sans passer par un shell de login.
cat > ~/.rdvsp-env.sh <<EOF
export PATH="\$HOME/.local/bin:\$PATH"
eval "\$(\$HOME/.local/bin/mise activate bash)"
export POSTGRES_USER=rdvsp
export RDVSP_DEVBOX=${VM_NAME}
EOF
echo 'source ~/.rdvsp-env.sh' >> ~/.bashrc
echo "BASH_ENV=$HOME/.rdvsp-env.sh" | sudo tee -a /etc/environment > /dev/null
source ~/.rdvsp-env.sh

# tweaks
# Ne force le cd que hors contexte Orca : Orca ouvre déjà le terminal dans le
# bon worktree (ORCA_WORKTREE_ID), et ce cd écraserait ce choix.
echo "[ -z \"\${ORCA_WORKTREE_ID-}\" ] && cd $PROJECT_DIR" >> ~/.bashrc # toujours ouvrir le terminal dans le repo (sauf sous Orca)

# Installe Claude
curl -fsSL https://claude.ai/install.sh | bash
echo 'alias claude="claude --dangerously-skip-permissions"' >> ~/.bashrc
rm -rf ~/.claude && ln -s "$HOST_HOME/.claude" ~/.claude

make install


#!/usr/bin/env bash
# Prépare une VM Lima devbox. À lancer depuis la racine du projet RDVSP.
#
# Usage : host-create-vm.sh [--gh-user <compte_gh>]
#   --gh-user <compte_gh>  Optionnel. Partage dans la VM le token du compte
#                           gh indiqué (déjà connecté sur l'hôte via
#                           `gh auth login`), ex. un compte bot dédié aux
#                           agents. Sans cet argument, aucune authentification
#                           GitHub n'est partagée avec la VM.

set -euo pipefail

GH_USER=""
while [ $# -gt 0 ]; do
  case "$1" in
    --gh-user)
      GH_USER="${2:?--gh-user nécessite un nom de compte}"
      shift 2
      ;;
    *)
      echo "Argument inconnu : $1" >&2
      exit 1
      ;;
  esac
done

PROJECT_DIR="$(pwd)"
VM_NAME="rdvsp-devbox"
SCRIPTS_DIR="$PROJECT_DIR/scripts/devtools/lima-vm"
SSH_LOCAL_PORT=60102 # port fixe (au lieu de l'auto-assignation par défaut de Lima), pour pouvoir s'y référer sans revérifier à chaque recréation de VM

if limactl list --format='{{.Name}}' | grep -qx "$VM_NAME"; then
  echo "==> Suppression de la VM Lima existante '$VM_NAME'…"
  limactl delete --force "$VM_NAME"
fi

mkdir -p "$PROJECT_DIR/tmp/lima-vm-cache/local"

limactl start template:ubuntu-24.04 --name="$VM_NAME" --cpus=4 --memory=4 --disk=20 -y \
  --set ".mounts[0] = {\"location\": \"$PROJECT_DIR\", \"writable\": true}" \
  --set ".mounts[1] = {\"location\": \"$HOME/.claude\", \"writable\": true}" \
  --set ".ssh.localPort = $SSH_LOCAL_PORT"

echo "==> Installation des dépendances dans la VM…"
limactl shell "$VM_NAME" -- env PROJECT_DIR="$PROJECT_DIR" HOST_HOME="$HOME" VM_NAME="$VM_NAME" bash "$SCRIPTS_DIR/vm-setup.sh"

limactl copy "$HOME/.claude.json" "$VM_NAME:.claude.json"

# Partage optionnel de l'authentification GitHub : seul le token du compte
# demandé via --gh-user est transmis, jamais le fichier de config complet ni
# les autres comptes connectés sur l'hôte. Rien n'est partagé par défaut.
# Le compte actif sur l'hôte est restauré ensuite : gh auth switch modifie
# l'état global de gh, on ne doit pas laisser ce script changer le compte
# gh par défaut du développeur sur sa machine.
if [ -n "$GH_USER" ]; then
  echo "==> Partage de l'authentification GitHub (compte $GH_USER)…"
  PREVIOUS_GH_USER="$(gh api user --jq .login 2>/dev/null || true)"
  gh auth switch --hostname github.com --user "$GH_USER"
  gh auth token | limactl shell "$VM_NAME" -- gh auth login --hostname github.com --with-token
  limactl shell "$VM_NAME" -- gh auth setup-git
  if [ -n "$PREVIOUS_GH_USER" ] && [ "$PREVIOUS_GH_USER" != "$GH_USER" ]; then
    gh auth switch --hostname github.com --user "$PREVIOUS_GH_USER"
  fi
fi

echo ""
echo "La VM '$VM_NAME' est prête. Run: limactl shell $VM_NAME"
echo "SSH direct (port fixe) : ssh -p $SSH_LOCAL_PORT -i ~/.lima/_config/user -o NoHostAuthenticationForLocalhost=yes 127.0.0.1"

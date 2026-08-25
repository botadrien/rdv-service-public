# Récupérer les scripts Lima enrichis en local

Sur une branche qui n'a que la version de base (ex. `production`) :

```sh
git show botadrientronics/restore-agents-md-claude-md:scripts/devtools/lima-vm/vm-setup.sh > scripts/devtools/lima-vm/vm-setup.sh
git show botadrientronics/restore-agents-md-claude-md:scripts/devtools/lima-vm/host-create-vm.sh > scripts/devtools/lima-vm/host-create-vm.sh
git update-index --skip-worktree scripts/devtools/lima-vm/vm-setup.sh scripts/devtools/lima-vm/host-create-vm.sh
```

`git show branche:fichier > fichier` n'écrit que dans le working tree, sans toucher l'index : rien à "staged" par erreur.

## Annuler

Avant de pousser/partager la branche, ou pour récupérer une évolution amont de ces fichiers :

```sh
git update-index --no-skip-worktree scripts/devtools/lima-vm/vm-setup.sh scripts/devtools/lima-vm/host-create-vm.sh
git checkout -- scripts/devtools/lima-vm/vm-setup.sh scripts/devtools/lima-vm/host-create-vm.sh
```

## Vérifier ce qui est actuellement caché

```sh
git ls-files -v scripts/devtools/lima-vm | grep '^S'
```

# AGENTS.md

Conventions pour les agents IA travaillant sur ce dépôt.

## Langue

Rédige tout en français : commentaires du code, messages de commit, documentation (README, `.md`) et tes réponses à l'utilisateur.
Les identifiants techniques existants (noms de variables, méthodes, fichiers) restent en anglais.

## Linting

Avant d'écrire du Ruby ou du Slim, lis la config du linter concerné (`.rubocop.yml` pour les conventions Ruby ; les règles slim-lint) afin que tes changements respectent les conventions existantes.

- **Ruby (RuboCop) :** `bundle exec rubocop` — ou `bin/rubocop` (via Spring, préfixe automatiquement `.rubocop.yml`). Utilise les plugins `rubocop-rspec` et `rubocop-rails` ; la version Ruby cible est définie par `TargetRubyVersion` dans `.rubocop.yml`. Sur des chemins précis : `bundle exec rubocop <chemins>`.
- **Templates Slim :** `bundle exec slim-lint <fichiers>`. Uniquement sur les templates modifiés, ex. `bundle exec slim-lint app/views/path/to/_partial.html.slim`.
- **Scan de sécurité :** `bundle exec brakeman` (ou `bin/brakeman`).

### Style Slim

Dans les templates Slim, le contenu textuel d'une balise va sur une ligne à part, bien identifiable, pas sur la même ligne que la balise :

```slim
h1.card-title
  | Changer d’adresse email
```

plutôt que `h1.card-title Changer d’adresse email`. Une phrase par ligne.

Attention : deux lignes `|` consécutives dans le même paragraphe ne sont **pas** séparées par un espace au rendu (`|` ne rajoute aucun espace). Utilise `'` (au lieu de `|`) sur toutes les lignes sauf la dernière du paragraphe pour obtenir l'espace attendu entre les phrases :

```slim
p
  ' Renseignez votre nouvelle adresse email.
  | Un code de confirmation à 6 chiffres vous sera envoyé à cette adresse.
```

### DSFR uniquement, jamais Bootstrap

Dans les vues, n'utilise jamais de classes Bootstrap (`.card`, `.card-body`, `.card-title`, `.row`, `.col-*`, etc.). Ce dépôt utilise exclusivement le [DSFR](https://www.systeme-de-design.gouv.fr/) : classes `fr-*` (ex. `fr-container`, `fr-mt-1w`) et les form builders dédiés (`Dsfr::FormBuilder`). Si une vue existante contient encore des classes Bootstrap, ne les reproduis pas dans du code nouveau — utilise l'équivalent DSFR.

## Specs

- **RSpec :** `bundle exec rspec <chemins>` — ou `bin/rspec` (via Spring). Cible des fichiers/dossiers précis : `bundle exec rspec spec/features/users/online_booking/`.
- Les specs de feature utilisent Capybara avec le driver Playwright pour les exemples `js: true` ; les factories viennent de `factory_bot`.
- Pour les flux online-booking/ANTS nécessitant l'API ANTS externe, stubbe-la avec `stub_ants_status_ok(...)` (voir les specs existantes).

Lance toujours les linters et specs pertinents après un changement non trivial avant de considérer la tâche terminée.

## Sécurité

Le plus important lorsque tu proposes des fonctionnalités est de réfléchir aux enjeux de sécurité.
Les changements de permissions ou l'exposition involontaire de données qui ne l'étaient pas jusqu'ici sont à éviter ou alors à indiquer clairement dans les descriptions de PR.

# Qualité

Propose des changements minimaux. Évite autant que possible les PR de plusieurs centaines de lignes.

Avant d'introduire une nouvelle table/modèle pour une fonctionnalité, vérifie si un mécanisme existant du dépôt ne peut pas être réutilisé tel quel (ex. un système de code de vérification par email déjà en place). La réutilisation directe, quand elle est possible sans migration, est presque toujours préférable à une table dédiée même plus « propre » sur le papier — compare concrètement les deux (diff, tests) plutôt que trancher sur la seule théorie.

Quand un parcours a plusieurs étapes qui ne correspondent pas à un vrai CRUD sur une seule ressource (ex. « demander un code » puis « saisir le code »), préfère plusieurs controllers avec des actions `new`/`create` par étape plutôt que de forcer `edit`/`update` sur une étape qui ne modifie rien. Regarde s'il existe déjà un patron similaire dans le dépôt (ex. `LoginCodesController` / `SessionsByCodeController`) et aligne-toi dessus.

Lorsque tu rédiges des PR sois succinct et utilise ce pattern : `# Contexte ... # Solution ... # Captures d'écran`

Indique bien clairement comment reproduire le problème manuellement si c'est un bug que tu corriges.

Pour les captures d'écran d'un changement d'état (avant/après une mise à jour), fais en sorte que l'état pertinent (ex. l'ancienne et la nouvelle valeur) soit visible directement dans l'écran capturé, pas seulement dans la légende de la capture.

### Messages de commit et de PR

Ne mentionne jamais ton nom (Claude ou autre) ni le fait qu'un agent IA est à l'origine du commit ou de la PR : pas de trailer `Co-Authored-By`, pas de lien de session, aucune référence à un assistant IA. Les messages de commit et les PR doivent être rédigés comme s'ils venaient de l'utilisateur.

### Environnement de travail

## GitHub CodeSpace

Il est fort possible que tu tournes dans une VM GitHub CodeSpace, avec un `GITHUB_TOKEN` dans l'environnement authentifié pour un compte personnel qui possède un fork de ce dépôt.
Dans ce cas, tu ne dois JAMAIS ouvrir de PR, mettre de commentaire, ou quelconque écriture sur le repo original de l'orga betagouv.
Tu peux tout faire sur ce fork personnel — vérifie son nom exact avec `git remote -v` plutôt que de te fier à un nom en dur : le compte/fork peut avoir été renommé depuis la dernière fois (ex. `botadrien` → `botadrientronics`).
Le CLI `gh` n'est pas forcément installé : dans ce cas utilise `curl` avec `$GITHUB_TOKEN` directement contre `https://api.github.com`.
Sur un fork tout juste créé, les GitHub Actions (donc la CI) peuvent être désactivées par défaut tant qu'un humain n'a pas cliqué la bannière d'activation sur la page Actions du fork.

## VM devbox Lima

Si la variable d'environnement `RDVSP_DEVBOX_VM` est définie, tu tournes dans la VM devbox Lima créée par `scripts/devtools/lima-vm/host-create-vm.sh`. Implications :

- Postgres et Redis tournent localement dans la VM
- Le dossier du projet est un mount RW

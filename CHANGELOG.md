[Cf docs/0-docs.md#Dernières Nouveautés](docs/0-docs.md#Dernières Nouveautés)

- Réduction de la flakiness des specs (voir https://github.com/betagouv/rdv-service-public/pull/6529 et le fix de `spec/models/concerns/text_search_spec.rb`).
- Fixe l'ordre non déterministe des agents dans la vue multi-agent du planning (`set_agents` utilise désormais `in_order_of`).
- CI : double le parallélisme des jobs de tests (unit/feature_agents/feature_rest) via `parallel_tests --only-group`, pour réduire le temps d'attente de la CI.
- CI : active `parallel_tests --group-by runtime` (corrige un cache de log de runtime jamais utilisé jusqu'ici) pour équilibrer les shards par temps d'exécution réel plutôt que par taille de fichier.
- CI : chaque shard fusionne aussi le log de runtime de son binôme pour un partage cohérent (relance pour vérifier la stabilité).
- CI : relance après retour au sharding à 4 process/shard (revert de "2 instead of 8") pour confirmer le résultat final combiné.

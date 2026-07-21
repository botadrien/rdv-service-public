[Cf docs/0-docs.md#Dernières Nouveautés](docs/0-docs.md#Dernières Nouveautés)

- Réduction de la flakiness des specs (voir https://github.com/betagouv/rdv-service-public/pull/6529 et le fix de `spec/models/concerns/text_search_spec.rb`).
- Fixe l'ordre non déterministe des agents dans la vue multi-agent du planning (`set_agents` utilise désormais `in_order_of`).
- CI : double le parallélisme des jobs de tests (unit/feature_agents/feature_rest) via `parallel_tests --only-group`, pour réduire le temps d'attente de la CI.
- CI : active `parallel_tests --group-by runtime` (corrige un cache de log de runtime jamais utilisé jusqu'ici) pour équilibrer les shards par temps d'exécution réel plutôt que par taille de fichier.
- CI : chaque shard fusionne aussi le log de runtime de son binôme pour un partage cohérent (relance pour vérifier la stabilité).
- CI : relance après retour au sharding à 4 process/shard (revert de "2 instead of 8") pour confirmer le résultat final combiné.
- CI : relance une 3e fois pour confirmer la stabilité (0 flaky) du design actuel avant de trancher sur le nombre de shards.
- CI : revert de la fusion unit/feature_agents/feature_rest en 2 shards, qui divisait par 3 le parallélisme réel (24 → 8 workers) et faisait régresser le temps total (146s → ~270-300s mesuré sur 3 runs). Retour au design à 6 shards (146s confirmé, 164s sur une nouvelle run).
- CI : passe de 2 à 3 shards par catégorie (6 → 9 jobs de tests, 24 → 36 workers), le compte de jobs simultanés du dépôt restant sous la limite du plan gratuit GitHub Actions (20). Le mécanisme de fusion des logs de runtime entre binômes est étendu à 2 siblings par shard (au lieu d'1) pour garder un `--group-by runtime` cohérent sur les 3 tiers. Résultat mesuré sur CI : 143s (vs 146-164s à 2 shards/catégorie), goulot d'étranglement réduit de 159s à 138s.
- CI : run supplémentaire pour mesurer la variance à 3 shards/catégorie (voir mémoire).
<!-- measuring 3-shard variance, run 3 -->

[Cf docs/0-docs.md#Dernières Nouveautés](docs/0-docs.md#Dernières Nouveautés)

- Réduction de la flakiness des specs (voir https://github.com/betagouv/rdv-service-public/pull/6529 et le fix de `spec/models/concerns/text_search_spec.rb`).
- Fixe l'ordre non déterministe des agents dans la vue multi-agent du planning (`set_agents` utilise désormais `in_order_of`).
- CI : double le parallélisme des jobs de tests (unit/feature_agents/feature_rest) via `parallel_tests --only-group`, pour réduire le temps d'attente de la CI.
- CI : désactive fsync/full_page_writes/synchronous_commit sur le Postgres de test (conteneur éphémère, sans impact sur la production) pour accélérer les écritures pendant les specs.
  (run supplémentaire pour vérifier la reproductibilité de la mesure)

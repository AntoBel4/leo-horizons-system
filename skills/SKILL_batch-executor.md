# SKILL batch-executor
*File nocturne via Notion — exécution automatique de tâches lourdes*

---

## Description
Ce skill gère la file de tâches batch que Léo ou Antoine peuvent soumettre pour exécution nocturne automatique (2h du matin via WF4). Les tâches sont stockées dans la base Notion "Tâches" avec le tag "batch".

## Fonctionnement

### Flux complet
```
1. Antoine ou Léo crée une tâche batch dans Notion
2. WF4 (Night Scheduler) se déclenche à 2h00
3. WF4 récupère les tâches batch "À faire" triées par priorité
4. Chaque tâche est exécutée séquentiellement
5. Les résultats sont compilés
6. Un résumé est envoyé via Telegram au réveil d'Antoine
```

### Types de tâches batch

| Batch_Type | Description | Exemple |
|------------|-------------|---------|
| content | Génération de contenu | Article blog, landing page SEO |
| audit | Audit technique | Vérification logs, backup status |
| cleanup | Nettoyage | Archiver tâches terminées, purger logs |
| news | Agrégation d'actualités | NewsAPI, veille tech, veille concurrentielle |
| seo | Analyse SEO | Vérifier positions, analyser backlinks |

### Création d'une tâche batch

**Via commande Telegram :**
Antoine : "/batch Générer 3 landing pages SEO pour expert-local.fr"

Léo crée dans Notion :
```json
{
  "parent": { "database_id": "${NOTION_DATABASE_ID_TASKS}" },
  "properties": {
    "Nom": { "title": [{ "text": { "content": "Générer 3 landing pages SEO expert-local.fr" } }] },
    "Statut": { "status": { "name": "À faire" } },
    "Priorité": { "select": { "name": "Haute" } },
    "Tags": { "multi_select": [{ "name": "batch" }] },
    "Batch_Type": { "select": { "name": "content" } },
    "Projet": { "select": { "name": "Expert Local" } },
    "Horizon": { "select": { "name": "H2-Croissance" } }
  }
}
```

### Lecture des tâches batch en attente

Léo peut vérifier la file à tout moment :
```
Commande : /file ou /queue
Réponse : Liste des tâches batch en attente, triées par priorité
```

### Priorité d'exécution
1. **Haute** — Exécutée en premier, résultats prioritaires
2. **Moyenne** — Exécutée ensuite
3. **Basse** — Exécutée si budget temps restant

### Budget d'exécution
- Temps max par nuit : configurable dans WF4 (défaut : 30 minutes)
- Tokens max par nuit : ~50K tokens (via OpenRouter)
- Si budget épuisé, les tâches restantes sont reportées à la nuit suivante

---

## Résumé matinal

Le lendemain matin (intégré dans le briefing WF2), Antoine reçoit :
```
Batch nocturne (2h00) - 3/4 tâches exécutées

[Terminé] Landing page boulangerie Nogent - article généré (1200 mots)
[Terminé] Audit logs Docker - RAS, 2.1 Go espace disque libre
[Terminé] Veille SEO expert-local.fr - 3 nouveaux mots-clés identifiés
[Reporté] Cleanup Notion - budget temps épuisé, reporté à demain

Détails disponibles sur demande.
```

---

## Sécurité
- Les tâches batch ne peuvent PAS modifier la config serveur
- Les tâches batch ne peuvent PAS envoyer d'emails ou messages sans validation préalable
- Les résultats sont stockés dans Notion, pas envoyés directement à des tiers

---

*Ce SKILL est le moteur d'exécution nocturne de Léo. Il permet de décharger les tâches lourdes hors des heures de travail d'Antoine.*

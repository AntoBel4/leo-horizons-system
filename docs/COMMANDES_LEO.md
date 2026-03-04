# Commandes Léo — Référence complète
*Toutes les commandes disponibles via Telegram (@leo_horizons_bot)*
*Version : 1.0 | Mars 2026*

---

## Commandes principales

### /aide ou /help
Affiche la liste des commandes disponibles.
```
Exemple : /aide
Réponse : Liste des commandes avec descriptions
```

### /start
Initialise la conversation avec Léo.
```
Exemple : /start
Réponse : Message de bienvenue + résumé des commandes
```

---

## Calendrier et Horizons

### /jour
Affiche l'agenda du jour groupé par horizon.
```
Exemple : /jour
Réponse :
  H1-Pro (rouge)
    09:00-12:00 — Réunion D'clic
    14:00-17:00 — Ateliers numériques
  H2-Croissance (bleu)
    06:30-08:30 — Expert Local - Landing page SEO
  H1-Santé (vert)
    18:00-19:00 — Zwift 45min
```

### /event
Créer un nouvel événement dans Google Calendar (conversationnel).
```
Exemple : /event Expert Local vendredi 9h-11h
Réponse : Léo propose l'événement formaté, attend validation
  "[CROISSANCE] - Expert Local - Landing page SEO
  Vendredi 7 mars, 09:00-11:00
  DDF : [à compléter]
  Confirmer ? (oui/non)"
```

### /bilan
Bilan hebdomadaire — récapitulatif des blocs réalisés par horizon.
```
Exemple : /bilan
Réponse :
  Semaine S5 (24 fév - 2 mars)
  H1-Pro : 35h (objectif 35h) -- OK
  H2-Croissance : 6h (objectif 10h) -- 60%
  H1-Santé : 3 sessions (objectif 4) -- 75%
  Victoires : 2 enregistrées
  Recommandation : Augmenter les blocs H2 la semaine prochaine
```

### /audit
Auditer une activité et la classer dans le bon horizon.
```
Exemple : /audit Appel avec prospect expert-local
Réponse :
  Activité : Appel avec prospect expert-local
  Classification : H2-Croissance (bleu, colorId 9)
  Justification : Lié au projet Expert Local (revenus)
  Suggestion : Créer un bloc [CROISSANCE] pour tracker ?
```

---

## Tracking Santé (H1-Santé)

### /sport
Logger une activité sportive.
```
Exemple : /sport Zwift 45min zone 3
Réponse : "Sport enregistré : Zwift 45min (zone 3). Continue comme ça !"
```

### /poids
Logger le poids du jour.
```
Exemple : /poids 82.5
Réponse : "Poids enregistré : 82.5 kg. Tendance : stable depuis 1 semaine."
```

### /eau
Logger l'hydratation du jour.
```
Exemple : /eau 2.5
Réponse : "Hydratation : 2.5L enregistrés. Objectif quotidien : 2.5L atteint !"
```

---

## Productivité

### /victoire
Enregistrer une victoire dans Notion.
```
Exemple : /victoire Première landing page Expert Local publiée
Réponse : "Victoire enregistrée ! Expert Local avance. Horizon : H2-Croissance."
```

### /reflexion
Enregistrer une réflexion dans Notion.
```
Exemple : /reflexion Je pense qu'il faut prioriser le SEO local avant le blog
Réponse : "Réflexion enregistrée. Catégorie : Stratégie. Ça nourrit la prochaine planification."
```

### /batch
Soumettre une tâche pour le traitement nocturne (2h du matin).
```
Exemple : /batch Générer 5 idées d'articles pour expert-local.fr
Réponse : "Tâche batch ajoutée. Sera traitée cette nuit. Résultat demain matin dans le briefing."
```

### /file ou /queue
Voir la file des tâches batch en attente.
```
Exemple : /file
Réponse :
  File batch (3 tâches en attente)
  1. [Haute] Générer landing pages SEO (Expert Local)
  2. [Moyenne] Audit logs Docker
  3. [Basse] Cleanup tâches Notion terminées
  Prochaine exécution : 2h00
```

---

## Système et modèles

### /model
Afficher le modèle LLM actuellement actif.
```
Exemple : /model
Réponse : "Modèle actif : claude-haiku-4-5 (via OpenRouter). Fallback : gemini-2.5-flash."
```

### /think
Activer le mode raisonnement approfondi pour la prochaine réponse.
```
Exemple : /think Analyse complète de la stratégie Expert Local
Réponse : Analyse détaillée avec raisonnement étendu
```

### /usage
Voir la consommation tokens et le coût estimé.
```
Exemple : /usage
Réponse :
  Consommation du mois (mars 2026)
  Tokens utilisés : 125K
  Coût estimé : 2.30 EUR
  Budget mensuel : 5 EUR
  Restant : 2.70 EUR (54%)
```

---

## Conversations naturelles

Léo comprend aussi les messages en langage naturel :

| Message | Action de Léo |
|---------|--------------|
| "C'est quoi mon agenda ?" | Équivalent de /jour |
| "Crée un bloc Expert Local demain 9h" | Équivalent de /event |
| "J'ai fait 45min de vélo" | Équivalent de /sport |
| "Victoire : premier client signé" | Équivalent de /victoire |
| "Combien j'ai dépensé en tokens ?" | Équivalent de /usage |
| "Quel modèle tu utilises ?" | Équivalent de /model |
| "Prépare un batch pour ce soir" | Équivalent de /batch |

---

## Notes d'utilisation

- Toutes les commandes fonctionnent avec ou sans le `/` initial en conversation naturelle
- Les réponses sont adaptées au contexte (courtes en journée, détaillées pour les bilans)
- Léo ne crée JAMAIS un événement calendrier sans validation explicite
- Les commandes santé (/sport, /poids, /eau) sont loggées dans Notion automatiquement
- Le /bilan est optimisé pour le dimanche (bilan de semaine) mais fonctionne tout le temps

---

*Ce fichier liste toutes les commandes disponibles. Pour la documentation technique complète, voir README_LEO.md.*

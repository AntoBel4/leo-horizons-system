# SKILL notion — Accès direct Notion API
*Skill d'intégration Notion — lecture/écriture directe depuis Léo*

---

## Description
Ce skill permet à Léo d'interagir directement avec l'API Notion sans passer par n8n.
Utilisé pour les opérations rapides : logging victoires, réflexions, lecture de tâches batch.

## Configuration requise
- Variable d'environnement : `NOTION_API_KEY`
- Variables pour les database IDs : `NOTION_DATABASE_ID_*`
- Accès HTTP sortant vers `https://api.notion.com/v1`

## Bases de données Notion

| Base | Variable d'environnement | Usage |
|------|--------------------------|-------|
| Tâches | `NOTION_DATABASE_ID_TASKS` | Tâches batch, planification |
| Santé Log | `NOTION_DATABASE_ID_HEALTH` | Tracking santé (poids, eau, sport) |
| Projets | `NOTION_DATABASE_ID_PROJECTS` | Suivi projets (Expert Local, etc.) |
| Objectifs | `NOTION_DATABASE_ID_OBJECTIVES` | OKRs par horizon |
| Victoires | `NOTION_DATABASE_ID_VICTORIES` | Log des succès |
| Items Famille | `NOTION_DATABASE_ID_FAMILY` | Centre de commande familial |
| CRM | `NOTION_DATABASE_ID_CRM` | Contacts expert-local.fr |
| Réflexions | `NOTION_DATABASE_ID_REFLECTIONS` | Journal de réflexions |

---

## Opérations disponibles

### 1. Créer une victoire

**Commande utilisateur :** `/victoire [description]`

**Requête API :**
```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer ${NOTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "parent": { "database_id": "${NOTION_DATABASE_ID_VICTORIES}" },
    "properties": {
      "Nom": { "title": [{ "text": { "content": "Landing page Expert Local en ligne" } }] },
      "Date": { "date": { "start": "2026-03-03" } },
      "Horizon": { "select": { "name": "H2-Croissance" } },
      "Projet": { "select": { "name": "Expert Local" } },
      "Impact": { "rich_text": [{ "text": { "content": "Première page SEO locale publiée" } }] }
    }
  }'
```

### 2. Créer une réflexion

**Commande utilisateur :** `/reflexion [texte]`

**Requête API :**
```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer ${NOTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "parent": { "database_id": "${NOTION_DATABASE_ID_REFLECTIONS}" },
    "properties": {
      "Nom": { "title": [{ "text": { "content": "Réflexion sur la stratégie Expert Local" } }] },
      "Date": { "date": { "start": "2026-03-03" } },
      "Catégorie": { "select": { "name": "Stratégie" } }
    },
    "children": [
      {
        "object": "block",
        "type": "paragraph",
        "paragraph": {
          "rich_text": [{ "text": { "content": "[contenu de la réflexion]" } }]
        }
      }
    ]
  }'
```

### 3. Lire les tâches batch en attente

**Usage :** Léo vérifie les tâches marquées "batch" et "À faire"

**Requête API :**
```bash
curl -s -X POST "https://api.notion.com/v1/databases/${NOTION_DATABASE_ID_TASKS}/query" \
  -H "Authorization: Bearer ${NOTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "filter": {
      "and": [
        { "property": "Tags", "multi_select": { "contains": "batch" } },
        { "property": "Statut", "status": { "equals": "À faire" } }
      ]
    },
    "sorts": [
      { "property": "Priorité", "direction": "ascending" }
    ]
  }'
```

### 4. Logger une entrée santé

**Commande utilisateur :** `/sport [type] [durée]` ou `/poids [kg]` ou `/eau [litres]`

**Requête API :**
```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer ${NOTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "parent": { "database_id": "${NOTION_DATABASE_ID_HEALTH}" },
    "properties": {
      "Date": { "date": { "start": "2026-03-03" } },
      "Type": { "select": { "name": "Sport" } },
      "Valeur": { "number": 45 },
      "Unité": { "select": { "name": "minutes" } },
      "Notes": { "rich_text": [{ "text": { "content": "Zwift 45min - zone 3" } }] }
    }
  }'
```

### 5. Lire les objectifs de la saison

**Usage :** Briefing matinal, bilan hebdomadaire

**Requête API :**
```bash
curl -s -X POST "https://api.notion.com/v1/databases/${NOTION_DATABASE_ID_OBJECTIVES}/query" \
  -H "Authorization: Bearer ${NOTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "filter": {
      "property": "Saison",
      "select": { "equals": "S1-2026" }
    }
  }'
```

---

## Protocole de Léo pour Notion

### Écriture
1. Léo construit la requête avec les bonnes propriétés
2. Léo envoie à l'API Notion
3. Léo confirme à Antoine : "Victoire enregistrée dans Notion"

### Lecture
1. Léo query la base appropriée
2. Léo parse et formate les résultats
3. Léo présente un résumé structuré (groupé par horizon si pertinent)

### Erreurs
- Si l'API retourne 401 : "Clé API Notion invalide ou expirée"
- Si l'API retourne 404 : "Base de données introuvable — vérifier l'ID"
- Si l'API retourne 429 : "Rate limit Notion atteint — réessayer dans 1 minute"

---

## Rate limits Notion
- 3 requêtes/seconde maximum
- Léo espace ses appels si batch de requêtes
- En cas de 429, attendre 1 seconde et réessayer (max 3 tentatives)

---

## Propriétés Notion par base

### Base Tâches
| Propriété | Type | Valeurs |
|-----------|------|---------|
| Nom | title | Texte libre |
| Statut | status | À faire, En cours, Terminé |
| Priorité | select | Haute, Moyenne, Basse |
| Horizon | select | H1-Pro, H1-Admin, H1-Santé, H1-Famille, H2-Croissance, H3-Passion |
| Projet | select | Expert Local, Blog, Prospection, etc. |
| Tags | multi_select | batch, urgent, récurrent |
| Date | date | ISO 8601 |
| Batch_Type | select | content, audit, cleanup, news |

### Base Victoires
| Propriété | Type | Valeurs |
|-----------|------|---------|
| Nom | title | Description de la victoire |
| Date | date | ISO 8601 |
| Horizon | select | H1-*, H2-*, H3-* |
| Projet | select | Projet associé |
| Impact | rich_text | Description de l'impact |

### Base Santé Log
| Propriété | Type | Valeurs |
|-----------|------|---------|
| Date | date | ISO 8601 |
| Type | select | Sport, Poids, Eau, Sommeil, Énergie, Humeur |
| Valeur | number | Valeur numérique |
| Unité | select | minutes, kg, litres, heures, /10 |
| Notes | rich_text | Commentaire libre |

---

## Intégration avec les autres skills

- **SKILL_horizons** : Les victoires sont taguées avec l'horizon correspondant
- **SKILL_coach** : Le bilan hebdo utilise les données Notion pour le scoring
- **SKILL_n8n-executor** : Certaines opérations Notion passent par n8n (WF4 batch nocturne)

---

## Sécurité
- La clé API Notion est stockée en variable d'environnement uniquement
- Jamais exposée dans les logs ou messages Telegram
- Les database IDs sont dans le .env, pas dans le code

---

*Ce SKILL donne à Léo un accès direct aux données structurées d'Antoine. C'est la mémoire persistante du système.*

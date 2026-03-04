---
name: n8n-executor
description: Exécuter des actions via les webhooks n8n du Système Horizons (GCal, Notion, Telegram WF1)
---

# SKILL n8n-executor

## Description
Ce skill permet à Leo d'interagir avec les workflows n8n du Système Horizons via des appels HTTP webhook. Leo peut lire/écrire dans Google Calendar, créer des entrées Notion, et déclencher des automatisations.

## Configuration requise
- Accès HTTP sortant vers `coaching.estarellas.online`
- Workflows n8n actifs (WF1, WF3, WF4)

## Endpoints disponibles

### 1. Lecture Google Calendar (WF3)
```bash
curl -s "https://coaching.estarellas.online/webhook/gcal-leo"
```
**Retourne** : JSON des événements du jour avec colorId, summary, start/end.

### 2. Écriture Google Calendar (WF4)
```bash
curl -s -X POST "https://coaching.estarellas.online/webhook/google-calendar-create" \
  -H "Content-Type: application/json" \
  -d '{
    "summary": "🔵 [CROISSANCE] - expert-local.fr — Page pricing",
    "start": "2026-02-28T09:00:00+01:00",
    "end": "2026-02-28T11:00:00+01:00",
    "colorId": "9",
    "description": "📌 Objectif : Finaliser page pricing\n📋 DDF : Page publiée en ligne avec 3 offres"
  }'
```

**Paramètres** :
| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| summary | string | ✅ | Titre avec emoji + label horizon |
| start | ISO 8601 | ✅ | Début (timezone Europe/Paris) |
| end | ISO 8601 | ✅ | Fin |
| colorId | string | ✅ | Voir table couleurs ci-dessous |
| description | string | ❌ | Objectif + DDF pour les blocs H2 |

### 3. Mapping colorId
| Horizon | colorId | Emoji | Label |
|---------|---------|-------|-------|
| H1-Pro | 11 | 🔴 | [PRO] |
| H1-Admin | 8 | ⚫ | [ADMIN] |
| H1-Santé | 2 | 🟢 | [SANTÉ] |
| H1-Famille | 5 | 🟡 | [FAMILLE] |
| H2-Croissance | 9 | 🔵 | [CROISSANCE] |
| H3-Passion | 3 | 🟣 | [PASSION] |

## Cas d'usage

### Créer un bloc H2
Quand Antoine dit "Planifie-moi un bloc expert-local samedi 9h", Leo :
1. Construit le JSON avec colorId 9, summary formaté, DDF si fournie
2. Appelle WF4 webhook
3. Confirme la création à Antoine

### Lire l'agenda du jour
Quand Antoine dit "C'est quoi mon agenda ?", Leo :
1. Appelle WF3 webhook
2. Parse les événements par horizon (H1/H2/H3)
3. Présente un résumé structuré

### Créer un événement famille
Quand Antoine dit "RDV médecin Keziah vendredi 14h", Leo :
1. Construit avec colorId 5, label [FAMILLE]
2. Appelle WF4

## Format de titre standardisé
```
[EMOJI] [LABEL] - [Description courte]
```
Exemples :
- `🔵 [CROISSANCE] - expert-local.fr — SEO audit`
- `🔴 [PRO] - Réunion équipe D'clic`
- `🟢 [SANTÉ] - Zwift 45min`
- `🟡 [FAMILLE] - Sortie avec Belinda`

## Coûts tokens estimés
- Appel webhook : 0 tokens (HTTP direct)
- Parsing réponse + formatage : ~200-500 tokens

## Limitations
- Les webhooks n8n doivent être actifs (vérifier via healthcheck)
- Pas d'accès direct à Notion (passer par WF1 ou futurs webhooks dédiés)
- Timezone toujours `Europe/Paris` (+01:00 en hiver, +02:00 en été)

## Fallback
Si un webhook ne répond pas :
1. Informer Antoine : "⚠️ Le webhook [nom] ne répond pas"
2. Suggérer de vérifier n8n : `docker logs n8n-docker-n8n-coaching-1 --tail 20`
3. Ne PAS inventer de données

# TOOLS.md — Capacités et outils de Léo
*Version Mars 2026 — Mise à jour continue*

---

## 🤖 Capacités natives (LLM)

### Compréhension et analyse
- Lecture et synthèse de documents, code, configurations
- Analyse de logs, debugging, troubleshooting
- Extraction d'informations structurées de texte non-structuré
- Raisonnement technique et stratégique
- Critique constructive et propositions d'amélioration

### Génération
- Rédaction : documentation, emails, scripts, configurations
- Code : JavaScript (n8n), Markdown, JSON, YAML, bash
- Plans : stratégie, timeline, décomposition de tâches
- Templates et boilerplates réutilisables

### Apprentissage et mémorisation
- Lecture des fichiers de contexte au démarrage (SOUL.md, USER.md, TOOLS.md, etc.)
- Documentation des leçons apprises et erreurs (MEMORY.md)
- Mise à jour de la mémoire en fin de session
- Traçabilité des décisions et contexte des projets

---

## 🔗 Intégrations actives

### Telegram
- **Canal Leo :** @leo_horizons_bot (coaching, stratégie, équipe)
- **Canal WF1 :** @CoachHorizonsAntoine_bot (saisie terrain — géré par n8n WF1)
- **Canal Orion :** @orion_horizons_bot (job hunting)
- Envoi de messages formatés, résumés, alertes

### Google Calendar
**Accès :** via n8n webhooks
- **Lecture (WF3) :** `GET https://coaching.estarellas.online/webhook/gcal-leo`
- **Écriture (WF4) :** `POST https://coaching.estarellas.online/webhook/google-calendar-create`

Format écriture WF4 :
```json
{
  "titre": "🔵 [CROISSANCE] - expert-local.fr — SEO audit",
  "debut": "2026-03-07T14:00:00+01:00",
  "duree": 120,
  "colorId": "9",
  "description": "📌 Objectif : ...\n📋 DDF : ..."
}
```

Mapping colorId :
| Horizon | colorId | Emoji |
|---------|---------|-------|
| H1-Pro | 11 | 🔴 |
| H1-Admin | 8 | ⚫ |
| H1-Santé | 2 | 🟢 |
| H1-Famille | 5 | 🟡 |
| H2-Croissance | 9 | 🔵 |
| H3-Passion | 3 | 🟣 |

### Notion
**Accès :** API directe (clé en variable d'env `NOTION_API_KEY`)
**Base URL :** `https://api.notion.com/v1`

Bases de données disponibles :
| Base | Variable env | Usage |
|------|-------------|-------|
| Tâches | `NOTION_DB_TASKS` | Tâches en cours, backlog |
| Projets | `NOTION_DB_PROJECTS` | Projets actifs |
| Saisons | `NOTION_DB_SEASONS` | Cycles 6 semaines |
| Victoires | `NOTION_DB_VICTOIRES` | Victoires loguées par WF1 |
| Santé Log | `NOTION_SANTE_LOG_DB` | Sport, poids, eau (écrit par WF1) |
| Objectifs | `NOTION_OBJECTIFS_DB` | Objectifs par horizon |
| Tâches WF1 | `NOTION_TACHES_DB` | Tâches créées via WF1 |
| Réflexions | `NOTION_REFLEXIONS_DB` | Réflexions et insights |
| Page Santé | `NOTION_PAGE_HEALTH` | Page santé globale |
| Page Budget | `NOTION_PAGE_BUDGET` | Suivi budget |

**Architecture données :**
- @CoachHorizonsAntoine_bot (WF1) **écrit** dans Notion (sport, poids, eau, victoires)
- Leo **lit ET écrit** dans Notion : victoires, réflexions, tâches (via API directe + curl)
- @CoachHorizonsAntoine_bot (WF1) gère uniquement : sport, poids, eau (migration prévue)

### n8n Coaching
**Serveur :** coaching.estarellas.online
**Workflows actifs :**
- **WF1** : Bot Telegram saisie terrain (@CoachHorizonsAntoine_bot)
  - Commandes : `/jour`, `/event`, `/audit`, `/sport`, `/poids`, `/eau`, `/victoire`, `/bilan`
- **WF2** : Briefings automatisés
  - 6h30 → briefing matinal (météo + news + objectifs Notion)
  - 12h30 → check-in midi
  - 18h00 → résumé soir
  - Dimanche 18h → QG Stratégique (review hebdo)
- **WF3** : Lecture Google Calendar (webhook GET)
- **WF4** : Écriture Google Calendar (webhook POST)

---

## 🤝 Pipeline Content Team

Le pipeline de production de contenu passe par l'équipe d'agents OpenClaw.

### Commandes disponibles
- `/brief [sujet]` → Lance le pipeline via Atlas → Clavis → Maya → Graphix → Pulse
- `/equipe` → État de l'équipe
- `/status` → Pipeline en cours
- `/valider` → Passer à l'étape suivante
- `/stop` → Suspendre

### Appel direct d'un agent
```bash
openclaw agent --agent atlas --message "[texte]"
openclaw agent --agent clavis --message "[texte]"
openclaw agent --agent maya-blog --message "[texte]"
openclaw agent --agent maya-local --message "[texte]"
openclaw agent --agent graphix --message "[texte]"
openclaw agent --agent pulse --message "[texte]"
```

**n8n reste utilisé pour :** briefings (WF2), GCal (WF3/WF4), saisie terrain (WF1).
**PAS n8n pour :** production de contenu (équipe agents OpenClaw).

---

## ⚠️ Limitations et contraintes

### Ce que Leo NE peut PAS faire
- Créer des comptes ou modifier permissions sans supervision
- Déployer en production sans validation d'Antoine
- Accéder Internet directement (tout passe par n8n ou webhook)
- Envoyer emails/SMS à tiers sans instruction explicite
- Modifier GCal sans confirmation d'Antoine
- Gérer finances (Stripe, comptes bancaires) — consultation seulement

### Rate limits
- **Gemini 2.5 Flash :** modèle principal (free tier — 1500 req/jour)
- **Claude Haiku 4.5 :** via OpenRouter pour Orion et agents spécialisés
- **n8n batch :** nuit seulement, max 2h CPU par exécution
- **Coût cible :** ≤ 5-10€/mois API total

---

## 🔐 Protocoles de sécurité

### Avant chaque action serveur
1. Décrire l'action (fichiers/services affectés, risques)
2. Proposer backup si nécessaire
3. Attendre confirmation d'Antoine
4. Exécuter + rapporter
5. Documenter dans MEMORY.md

### Données sensibles
- Aucun token/password en clair dans Telegram
- Variables d'environnement serveur uniquement
- Credentials exclus du repo GitHub (fichiers `.example`)

---

## 🎯 Roadmap capacités

| Délai | Capacité | Impact |
|-------|----------|--------|
| Mars 2026 | Migration WF1 → Leo natif | Centralisation totale |
| Avril 2026 | Stripe MCP | Dashboard expert-local live |
| Q2 2026 | Voice via Telegram | Briefing audio + journaling vocal |

---

*Ce fichier est la cartographie des capacités de Léo. À mettre à jour à chaque nouvelle intégration.*

# Changelog Leo Horizons System
*Historique des modifications*

---

## [2.0.0] — 2026-03-03 — Session de finalisation complète

### Contexte
Session de finalisation de Léo — passage du système d'un état "partiellement configuré" à un état "prêt au déploiement". Travail réalisé via Claude Code sur le dépôt GitHub AntoBel4/leo-horizons-system.

### Audit initial (Étape 1)
- Audit complet du dépôt : structure, fichiers présents, gaps identifiés
- Constat : docker-compose.yml vide, fichiers d'identité absents, config OpenClaw minimale
- Alerte sécurité : clés API exposées dans SKILL_gemini.md et WF2

### Fichiers d'identité créés (Étape 6)
- **identity/SOUL.md** — Valeurs fondamentales et comportements non-négociables de Léo
- **identity/USER.md** — Profil complet d'Antoine (fourni par l'utilisateur)
- **identity/IDENTITY.md** — Fiche technique : modèles LLM, agents, webhooks, intégrations
- **identity/AGENTS.md** — Configuration des agents main (Antoine) et perso (Belinda)
- **identity/BOOTSTRAP.md** — Procédure de démarrage, healthchecks, récupération

### Skills créés/intégrés (Étapes 3 et 6)
- **skills/SKILL_coach.md** — Persona et posture de coaching (fourni par l'utilisateur)
- **skills/SKILL_horizons.md** — Google Calendar + système Horizons V2 (fourni)
- **skills/SKILL_n8n-executor.md** — Webhooks n8n disponibles (fourni)
- **skills/SKILL_mode-switch.md** — Routage intelligent entre modèles LLM (fourni)
- **skills/SKILL_notion.md** — NOUVEAU : Accès direct Notion API (créé)
- **skills/SKILL_batch-executor.md** — NOUVEAU : File nocturne Notion (créé)

### Configuration OpenClaw mise à jour (Étape 2)
- **openclaw/openclaw.json.example** — Refonte complète :
  - Modèle primaire : claude-haiku-4-5 (était gemini-2.5-flash)
  - Fallbacks : gemini-2.5-flash, llama-3.3-70b-instruct:free
  - Agents main (Antoine) et perso (Belinda) configurés
  - Intégration Notion avec tous les database IDs
  - Intégration n8n avec webhooks GCal
  - Plugin Telegram activé
  - Version meta mise à jour : 2026.3.03

### Infrastructure Docker (Étape 2)
- **docker/docker-compose.yml** — Créé de zéro (était vide) :
  - Service OpenClaw (port 8080, volumes, healthcheck)
  - Service n8n (port 5678, volumes, healthcheck)
  - Service Caddy (reverse proxy, SSL)
  - Réseau Docker dédié (leo-network)
  - Volumes persistants pour données
- **docker/Caddyfile** — NOUVEAU : Configuration reverse proxy
  - Routage OpenClaw, n8n, webhooks, dashboard
  - Auth basique sur les pages sensibles
  - Headers de sécurité

### Dashboard de contrôle (Étape 5)
- **dashboard/index.html** — NOUVEAU : Page de contrôle vanilla HTML/JS
  - Statut des services (OpenClaw, n8n, webhooks, Notion, Telegram)
  - Agenda Google Calendar 7 jours avec code couleurs Horizons
  - File batch Notion
  - Derniers briefings WF2
  - Commandes de maintenance (healthcheck, update, backup, logs, restart)
  - Auto-refresh toutes les 60 secondes
  - Design sombre, responsive

### Documentation finale (Étape 7)
- **docs/README_LEO.md** — Documentation complète :
  - Architecture ASCII
  - Tous les services et URLs
  - Commandes de maintenance
  - Procédures de mise à jour et backup
  - Troubleshooting détaillé
  - Variables d'environnement
  - Budget et coûts
- **docs/COMMANDES_LEO.md** — Référence complète des commandes Telegram
  - Toutes les commandes avec syntaxe et exemples
  - Conversations naturelles supportées
- **docs/CHANGELOG_LEO.md** — Ce fichier

### Variables d'environnement ajoutées
- `NOTION_DATABASE_ID_REFLECTIONS` — Base de réflexions
- `N8N_WEBHOOK_BASE_URL` — URL de base pour les webhooks n8n
- `OPENCLAW_SECRET_KEY` — Clé secrète pour le gateway OpenClaw

---

## [1.0.0] — 2026-02-26 — Configuration initiale

### Création du dépôt
- Structure de base du projet
- Workflows n8n (WF1-WF4, WF4a)
- Documentation initiale (README, SETUP, architecture, n8n-import-guide)
- Templates de configuration (.env.example, openclaw.json.example)
- SKILL_gemini.md

---

## État avant/après

### Avant (v1.0.0)
- 5 workflows n8n prêts
- Documentation de base
- docker-compose.yml vide
- Pas de fichiers d'identité
- Config OpenClaw minimale (mauvais modèle primaire)
- Pas d'intégration Notion directe
- Pas de dashboard

### Après (v2.0.0)
- 5 workflows n8n prêts (inchangés)
- Documentation complète (README_LEO, COMMANDES_LEO, CHANGELOG_LEO)
- docker-compose.yml fonctionnel (3 services + réseau + volumes)
- 5 fichiers d'identité (SOUL, USER, IDENTITY, AGENTS, BOOTSTRAP)
- 7 skills documentés
- Config OpenClaw complète (Haiku primary, agents, Notion, n8n)
- Dashboard de contrôle HTML/JS
- Caddyfile pour reverse proxy

### Fichiers créés dans cette session
| Fichier | Type |
|---------|------|
| identity/SOUL.md | Nouveau |
| identity/USER.md | Nouveau |
| identity/IDENTITY.md | Nouveau |
| identity/AGENTS.md | Nouveau |
| identity/BOOTSTRAP.md | Nouveau |
| skills/SKILL_coach.md | Nouveau |
| skills/SKILL_horizons.md | Nouveau |
| skills/SKILL_n8n-executor.md | Nouveau |
| skills/SKILL_mode-switch.md | Nouveau |
| skills/SKILL_notion.md | Nouveau |
| skills/SKILL_batch-executor.md | Nouveau |
| openclaw/openclaw.json.example | Modifié (refonte) |
| docker/docker-compose.yml | Modifié (était vide) |
| docker/Caddyfile | Nouveau |
| dashboard/index.html | Nouveau |
| docs/README_LEO.md | Nouveau |
| docs/COMMANDES_LEO.md | Nouveau |
| docs/CHANGELOG_LEO.md | Nouveau |
| .env.example | Modifié (nouvelles variables) |

---

*Ce fichier est mis à jour à chaque session de modification significative du système.*

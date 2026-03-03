# Architecture - Leo Horizons System

Vue d'ensemble technique et flux de données du système complet.

## 🏗️ Architecture Globale
```
┌─────────────────────────────────────────────────────────────────┐
│                     UTILISATEUR (AntoBel)                       │
│            Telegram (@leo_horizons_bot) + WebChat              │
└──────────────────────┬──────────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
    ┌────────┐   ┌──────────┐   ┌──────────┐
    │  n8n   │   │ OpenClaw │   │  Google  │
    │Workflows   │  (Leo)   │   │ Calendar │
    └────┬───┘   └────┬─────┘   └────┬─────┘
         │            │              │
         └────────────┼──────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
    ┌────────┐  ┌────────┐  ┌──────────┐
    │ Notion │  │Telegram│  │ Brevo    │
    │  CRM   │  │  API   │  │  Email   │
    └────────┘  └────────┘  └──────────┘
```

## 📊 Composants Principaux

### 1. **n8n** (Orchestration)
- **Rôle**: Orchestrateur central des workflows
- **Déploiement**: Docker (self-hosted) ou n8n.cloud
- **Workflows**:
  - WF1: Bot Telegram (commandes, routing)
  - WF2: Briefings automatisés (6:30 AM, midi, 6 PM, dimanche)
  - WF3: Google Calendar ↔ Notion (sync bidirectionnelle)
  - WF4: Batch nocturne (2 AM) - génération contenu, audits

### 2. **OpenClaw / Leo** (Assistant IA)
- **Rôle**: Assistant IA autonome
- **Modèles**: 
  - Haiku 4.5 (primaire, rapide)
  - Gemini 2.5 Flash (fallback, économique)
  - Cascade via OpenRouter
- **Interfaces**: Telegram + WebChat
- **Déploiement**: Docker sur Hetzner VPS
- **Intégrations**: Notion, Google Calendar, n8n

### 3. **Notion** (Databases + CRM)
- **Rôle**: Base de données centralisée
- **Bases**:
  - **Projets**: expert-local.fr, estarellas.online, etc.
  - **Objectifs**: OKRs par horizon (H1, H2, H3)
  - **Tâches**: Calendrier + priorités
  - **Victoires**: Log des succès
  - **Santé Log**: Health tracking (via Leo)
  - **Items Famille**: Centre de Commande Familial
  - **CRM**: Contacts + follow-ups (expert-local.fr)
- **Intégrations**: n8n (WF2, WF3, WF4)

### 4. **Google Calendar** (Planification)
- **Rôle**: Source de vérité pour la planification
- **Couleurs Horizons**:
  - 🔴 **H1-Pro** (rouge): Travail critique D'clic
  - 🟢 **H1-Santé** (vert): Exercice, sommeil, nutrition
  - ⚫️ **H1-Admin** (noir): Admin, docs, finances
  - 🟡 **H1-Famille** (jaune): Temps en famille
  - 🔵 **H2-Croissance** (bleu): Projets (expert-local.fr, blog)
  - 🟣 **H3-Passion** (violet): Loisirs, repos
- **Intégrations**: n8n WF3 (sync vers Notion), Leo (disponibilité)

### 5. **Telegram** (Communication)
- **Rôle**: Interface utilisateur principale
- **Bots**:
  - `@leo_horizons_bot`: Assistant Leo (conversations, questions)
  - `@CoachHorizonsAntoine_bot`: Coaching (optional)
- **Channels**: Notifications, briefings quotidiens
- **Intégrations**: n8n WF1, WF2, WF4

## 🔄 Flux de Données

### Flux 1: Commande Telegram → Exécution n8n → Notion
```
User (Telegram)
    ↓ "/log_health 80"
    ↓
n8n WF1 (Telegram Trigger)
    ↓ Parse message
    ↓
Notion Database (Santé Log)
    ↓ Create entry
    ↓
Telegram Send (Confirmation)
    ↓
User ✅ "Santé enregistrée"
```

### Flux 2: Briefing Automatisé (Cron)
```
Cron Timer (6:30 AM)
    ↓
n8n WF2 (Batch)
    ├─ Query Notion: tâches du jour
    ├─ Query Notion: événements prioritaires
    ├─ Call OpenRouter: générer briefing texte
    └─ Send Telegram
    ↓
User ✅ Briefing reçu
```

### Flux 3: Google Calendar → Notion Sync (WF3)
```
Google Calendar (Event créé/modifié)
    ↓ Webhook trigger
    ↓
n8n WF3
    ├─ Read Google Calendar event
    ├─ Parse Horizon (par couleur)
    ├─ Create/Update Notion entry
    └─ Metadata sync (date, title, etc.)
    ↓
Notion Database (Tâches)
    ↓
Leo reads calendar pour "Ma journée"
    ↓
User ✅ Event visible dans Notion
```

### Flux 4: Batch Nocturne (2 AM - WF4)
```
Cron Timer (2 AM)
    ↓
n8n WF4 (Batch Queue)
    ├─ Query Notion: tâches marquées "Batch"
    ├─ For each task:
    │   └─ HTTP Request (execute)
    │       Exemples:
    │       - Générer contenu expert-local.fr
    │       - Audit système (logs, backups)
    │       - Cleanup Notion (archiver done)
    │       - News aggregation (NewsAPI)
    ├─ Compile résultats
    └─ Send summary Telegram
    ↓
User ✅ Résumé batch reçu (matin)
```

### Flux 5: Leo Assistant (Conversations)
```
User Telegram "/question quelconque"
    ↓
Telegram → n8n → OpenClaw
    ↓
Leo (OpenClaw)
    ├─ Read context (Notion if needed)
    ├─ Call OpenRouter (Haiku ou Gemini)
    ├─ Generate response
    └─ Send back Telegram
    ↓
User ✅ Réponse de Leo
```

## 🔐 Sécurité & Authentification

### Credentials Management
```
┌─────────────────────────────────────────┐
│        .env (LOCAL - NEVER COMMIT)      │
│                                         │
│ TELEGRAM_BOT_TOKEN=xxxxx               │
│ NOTION_API_KEY=ntn_xxxxx               │
│ OPENROUTER_API_KEY=sk-or-xxxxx         │
│ GOOGLE_CLIENT_ID=xxxxx                 │
│ GOOGLE_CLIENT_SECRET=xxxxx             │
└────────────────┬────────────────────────┘
                 │
    ┌────────────┼────────────┐
    ▼            ▼            ▼
┌────────┐  ┌──────────┐  ┌──────────┐
│  n8n   │  │OpenClaw  │  │  Docker  │
│Credentials  │(via ENV)     │(.env mount)
└────────┘  └──────────┘  └──────────┘
```

### Tokens & Keys

| Service | Type | Où stocker | Expire |
|---------|------|-----------|--------|
| Telegram | Bot Token | `.env` | Jamais |
| Notion | Integration Token | `.env` + n8n | Jamais |
| Google | OAuth2 Refresh Token | n8n encrypted | Auto-refresh |
| OpenRouter | API Key | `.env` | Jamais |
| Brevo | API Key | `.env` | Jamais |

### Règles

- ✅ **JAMAIS** commiter `.env`
- ✅ `.env` dans `.gitignore`
- ✅ Tokens sur VPS ≠ tokens locaux (séparer par env)
- ✅ Rotate keys mensuellement
- ✅ Audit access logs mensuellement

## 🗄️ Stockage & Persistance

### Notion (Source de Vérité)
```
Notion Workspace
├── Projets
│   └── expert-local.fr, estarellas.online, etc.
├── Objectifs (OKRs par horizon)
│   ├── H1-Socle
│   ├── H2-Croissance
│   └── H3-Passion
├── Tâches (sync Google Calendar)
│   ├── Date
│   ├── Horizon
│   ├── Priority
│   ├── Status
│   └── Assigned person
├── Victoires (log succès)
│   ├── Date
│   ├── Description
│   └── Impact estimate
├── Santé Log (health tracking)
│   ├── Date
│   ├── Energy (1-10)
│   ├── Mood (1-10)
│   ├── Sleep (hours)
│   └── Exercise (yes/no)
├── Items Famille (Belinda)
│   ├── Description
│   ├── Priority
│   └── Status
└── CRM (expert-local.fr)
    ├── Contacts
    ├── Follow-ups
    ├── Deal Stage
    └── Value
```

### Google Calendar (Planification)
```
Calendars
├── AntoBel (personal)
│   └── Events par Horizon (couleurs)
├── D'clic (travail)
│   └── Meetings, deadlines
├── Leo (optional, pour "ma disponibilité")
└── Belinda (partage en famille)
```

### n8n (Executions & Logs)
```
n8n Workspace
├── Workflows (WF1-4)
├── Credentials (encrypted)
├── Variables d'env
├── Execution history (logs)
└── Webhooks (registered)
```

### Docker Volumes (VPS)
```
/data/
├── n8n/
│   ├── database.sqlite
│   └── .env
├── openclaw/
│   ├── openclaw.json
│   ├── agents.json
│   └── .env
└── backups/
    ├── workflows-YYYYMMDD.json
    └── openclaw-YYYYMMDD.json
```

## ⚙️ Intégrations API

### Notion API
```
Base URL: https://api.notion.com/v1

Endpoints used:
- GET /databases/{id}/query (lire tâches)
- POST /pages (créer entries)
- PATCH /pages/{id} (updater status)
- GET /blocks/{id}/children (lire contenu)

Auth: Bearer {{ NOTION_API_KEY }}
Rate limit: 3 req/sec
```

### Telegram Bot API
```
Base URL: https://api.telegram.org/bot{TOKEN}

Methods used:
- setWebhook (register n8n webhook)
- sendMessage (envoyer réponses)
- getMe (vérifier bot)
- getUpdates (polling, optionnel)

Webhook: https://n8n.com/webhook/telegram
```

### Google Calendar API
```
Base URL: https://www.googleapis.com/calendar/v3

Methods used:
- events.list (lire calendar)
- events.get (détails event)
- events.insert (créer event)
- events.update (modifier event)

Auth: OAuth2 (refresh token via n8n)
Scope: calendar
```

### OpenRouter API
```
Base URL: https://openrouter.ai/api/v1

Endpoints:
- POST /chat/completions (call LLM)

Models:
- anthropic/claude-3-5-haiku (primaire)
- google/gemini-2.5-flash (fallback)

Auth: Bearer {{ OPENROUTER_API_KEY }}
Rate limit: 200 req/min
```

## 🚀 Déploiement (VPS Hetzner)

### Infrastructure
```
Hetzner VPS (Ubuntu 24)
├── Docker Engine
├── Docker Compose
├── Containers:
│   ├── n8n (port 5678)
│   ├── Leo/OpenClaw (port 8000)
│   ├── Postgres (n8n DB, port 5432)
│   ├── Redis (cache, port 6379)
│   └── Nginx (reverse proxy, 80/443)
└── Volumes:
    ├── /data/n8n
    ├── /data/openclaw
    └── /data/backups
```

### Network
```
Internet
    ↓
Hetzner Firewall
    ↓
Nginx (reverse proxy)
    ├─ port 80 → 443 redirect
    └─ port 443
        ├─ /n8n → container n8n:5678
        ├─ /webhook/* → container n8n:5678
        ├─ /chat → container Leo:8000
        └─ /api/* → container Leo:8000
```

### Monitoring
```
Logs:
docker-compose logs -f
docker-compose logs n8n
docker-compose logs leo

Stats:
docker stats
du -sh /data/*

Health checks:
curl https://ton-domaine.com/n8n/health
curl https://ton-domaine.com/chat/health
```

## 📈 Scalabilité & Performance

### Optimisations Actuelles

- **Haiku 4.5** pour rapidité (2-3s réponse)
- **Batch nocturne** pour tâches lourdes (ne bloque pas utilisateur)
- **Notion webhooks** pour real-time sync (vs polling)
- **Redis cache** pour données fréquemment accédées (optionnel)

### Bottlenecks Potentiels

| Composant | Limite | Solution |
|-----------|--------|----------|
| n8n | 100 workflows | Passer à Enterprise |
| Notion | 3 req/sec | Batch reads, rate limit |
| OpenRouter | 200 req/min | Queue management |
| Telegram | 30 msg/sec | Batch sends |
| VPS RAM | 4-8 GB | Upgrade container limits |

### Scaling Plan (Si besoin)

1. **Phase 1** (Actuel): Single VPS + n8n cloud
2. **Phase 2**: Dedicated n8n server + separate Leo server
3. **Phase 3**: Kubernetes cluster (si 100+ workflows)

## 🔄 Maintenance & Updates

### Backups
```bash
# Daily (Cron 3 AM)
- Export n8n workflows
- Backup Notion (API export)
- Backup OpenClaw config
- Push to GitHub

# Weekly
- Full Docker volumes backup
- Verify restore procedure

# Monthly
- Test restore from backup
- Rotate old backups (keep 3 months)
```

### Updates
```
n8n: Check monthly, test in staging
Leo: Update LLM models quarterly
Docker: Security patches ASAP
OS: Ubuntu auto-updates enabled
```

## 📚 Diagrammes Complétés

### Service Interaction Matrix
```
        │ n8n  │ Leo  │Notion│ GCal │Telegram
────────┼──────┼──────┼──────┼──────┼────────
n8n     │  -   │ calls│ r/w  │ r/w  │ send
Leo     │ -    │  -   │ read │ read │ send
Notion  │ r/w  │ read │  -   │  -   │  -
GCal    │ r/w  │ read │  -   │  -   │  -
Telegram│ recv │ recv │  -   │  -   │  -
```

### Data Flow Timing
```
┌─────────────────────────────────────────────────┐
│           Exemple: "/log_health 80"             │
├─────────────────────────────────────────────────┤
│ T+0ms    User sends Telegram message            │
│ T+10ms   Telegram receives (Telegram API)       │
│ T+20ms   Webhook → n8n (HTTP POST)              │
│ T+50ms   n8n parses, validates                  │
│ T+100ms  Notion API create entry                │
│ T+150ms  Telegram send confirmation             │
│ T+160ms  User receives ✅                       │
├─────────────────────────────────────────────────┤
│ Total latency: ~160ms                           │
└─────────────────────────────────────────────────┘
```

## 🎯 Futur

- [ ] Migrate Leo to Haiku 4.5 + Gemini cascade
- [ ] Config Notion API in Leo (direct access)
- [ ] Webhooks Notion → n8n (real-time)
- [ ] WhatsApp + Slack bots (optionnel)
- [ ] Voice commands (Telegram Voice Notes)
- [ ] Browser extension (capture quick notes)

---

**Voir aussi**: [SETUP.md](SETUP.md) pour le déploiement, [n8n-import-guide.md](n8n-import-guide.md) pour l'import des workflows.
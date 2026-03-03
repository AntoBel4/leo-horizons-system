# Leo Horizons System

🚀 **Système d'automatisation personnelle et professionnelle** basé sur une méthodologie 3 horizons en cycles 6 semaines.

## 🎯 Composants Principaux

### 1. **OpenClaw** (Leo - Assistant IA Local)
- Assistant IA autonome déployé sur VPS Hetzner (Docker)
- **Modèles**: Haiku 4.5 (primaire) + Gemini 2.5 Flash (fallback) via OpenRouter
- **Interfaces**: Telegram (@leo_horizons_bot) + WebChat
- **Email**: leo.horizons.bot@gmail.com
- Intégrations: Google Calendar, Notion, Telegram, n8n

### 2. **n8n Workflows** (Orchestration)
- **WF1**: Bot Telegram (commandes, health logging, gamification, routing)
- **WF2**: Briefings automatisés (6:30 AM, midi, soir + revues stratégiques dimanche)
- **WF3**: Bridge Google Calendar → Notion (sync bidirectionnelle)
- **WF4**: Scheduler nocturne (queue batch 2 AM, génération contenu, audits système)

### 3. **Méthodologie Système Horizons**
Cycles de 6 semaines avec 3 horizons dans Google Calendar (couleurs codées):

| Horizon | Niveau | Couleurs | Exemples |
|---------|--------|----------|----------|
| **H1-Socle** | Critique | 🔴 🟢 ⚫️ 🟡 | Pro (rouge), Santé (vert), Admin (noir), Famille (jaune) |
| **H2-Croissance** | Projets | 🔵 | Expert-local.fr, estarellas.online, etc. |
| **H3-Passion** | Rewards | 🟣 | Loisirs, repos, plaisir |

**Règle d'or**: Les blocs H2 peuvent être déplacés mais **JAMAIS annulés** = engagement envers soi-même.

### 4. **Notion** (Databases + CRM)
- Bases: Projets, Objectifs, Tâches, Victoires, Réflexions, Santé Log, Items Famille
- Centre de Commande Familial (pour Belinda)
- Sync n8n pour historique & automatisation

## 📖 Documentation

- **[SETUP.md](docs/SETUP.md)** - Guide de déploiement complet
- **[n8n-import-guide.md](docs/n8n-import-guide.md)** - Importer les workflows pas à pas
- **[architecture.md](docs/architecture.md)** - Architecture globale du système

## 🚀 Quick Start

### Déployer les workflows n8n
1. Ouvre n8n: `http://localhost:5678` (ou ton instance cloud)
2. Menu → **Workflows** → **Import from file**
3. Sélectionne un workflow dans `workflows/`
4. Configure les credentials (voir [n8n-import-guide.md](docs/n8n-import-guide.md))

### Déployer OpenClaw (VPS)
```bash
cd openclaw/
docker-compose up -d
# Accessible via Telegram & WebChat
```

## 🔐 Sécurité

**JAMAIS commiter:**
- `.env` files avec clés API
- `credentials.json` ou fichiers d'auth
- Tokens personnels (Telegram, Notion, etc.)
- `openclaw.json.bak` ou backups sensibles

**À faire après un clone:**
1. Crée un `.env` local (voir `.env.example` ou docs)
2. Configure tes API keys dans n8n UI
3. Ajoute tes credentials Notion, Telegram, OpenRouter, etc.

## 📁 Structure du Repo
```
leo-horizons-system/
├── README.md                    # Ce fichier
├── .gitignore                   # Exclusions Git
├── openclaw/                    # Configuration Leo (OpenClaw)
│   ├── openclaw.json           # Config principale
│   ├── agents.json             # Agents (main, perso)
│   └── system-prompts/
│       ├── IDENTITY.md
│       ├── SOUL.md
│       └── USER.md
├── workflows/                   # Workflows n8n
│   ├── WF1_Bot_Telegram_v2.json
│   ├── WF2_Horizons_BATCH.json
│   ├── WF3_GCal_Bridge.json
│   ├── WF4_Night_Scheduler.json
│   └── README.md               # Guide spécifique workflows
├── skills/                      # Skills & prompts système
│   ├── SKILL_horizons.md
│   ├── SKILL_coach.md
│   ├── SKILL_batch-executor.md
│   └── ...
├── notion-templates/            # Templates & exports Notion
│   └── template_systeme_horizons.md
├── docs/                        # Documentation
│   ├── SETUP.md
│   ├── n8n-import-guide.md
│   └── architecture.md
└── docker/                      # Docker configs
    └── docker-compose.yml
```

## 🔧 Technos

- **Orchestration**: n8n (self-hosted ou cloud)
- **Assistant IA**: OpenClaw (Docker) + Claude API
- **Modèles LLM**: Haiku 4.5, Gemini 2.5 Flash (OpenRouter)
- **Bases de données**: Notion (CRM), Google Calendar, Google Tasks
- **Communication**: Telegram, Brevo (email)
- **Infrastructure**: Docker (Hetzner VPS)
- **Versionning**: Git + GitHub

## 📊 Projets Actifs (S1 2026)

| Projet | Status | Deadline | Horizon |
|--------|--------|----------|---------|
| expert-local.fr | 🔥 Priorité | 16 mars 2026 | H2 |
| Migration Leo (Haiku 4.5) | En cours | S1 | H1-Tech |
| Config Notion Leo | À faire | S1 | H1-Admin |
| Blog estarellas.online | Backlog | S2 | H2 |

## 💡 Key Learnings

- **Activity Audit**: Description → Impact/Effort (/10) → Verdict → Horizon → DDF (Définition du Fini)
- **n8n best practices**: Utilise "From list" vs "By ID"; query Notion directement pour calculs real-time
- **OpenClaw config**: Prompts système dans `agents.defaults.systemPrompt` (JSON valide!)
- **Leo identity**: Préserver l'identité en cas de migration de LLM
- **Git workflow**: Commit régulier, branches pour features, PRs avant merge

## 🤝 Contribution

Ce repo est **personnel** (usage privé). Pour modifications/améliorations, crée une branche:
```bash
git checkout -b feature/ma-feature
git commit -m "feat: description claire"
git push origin feature/ma-feature
```

## 📞 Contact & Support

- **Email**: leo.horizons.bot@gmail.com
- **Telegram**: @leo_horizons_bot
- **VPS**: Hetzner (prospect.estarellas.online)

---

**Last Updated**: 03/03/2026  
**Maintainer**: Antoine Estarellas (AntoBel)
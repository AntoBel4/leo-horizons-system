# Guide de Déploiement - Leo Horizons System

Ce document explique comment déployer et configurer le système complet.

## 📋 Prérequis

- **Git** installé
- **Docker** (si déploiement self-hosted)
- **Node.js** 18+ (optionnel, pour développement)
- Comptes & API keys:
  - Telegram (Bot Token)
  - Notion (Integration Token)
  - Google (OAuth2 credentials)
  - OpenRouter (API Key)
  - Brevo (optionnel, pour emails)

## 🚀 Installation Rapide

### 1. Clone le repo
```bash
git clone https://github.com/ton-username/leo-horizons-system.git
cd leo-horizons-system
```

### 2. Configure tes secrets

Crée un fichier `.env` à la racine (copie depuis `.env.example` si existant):
```bash
# Telegram
TELEGRAM_BOT_TOKEN=xxxxx
TELEGRAM_CHAT_ID=xxxxx

# Notion
NOTION_API_KEY=ntn_xxxxx
NOTION_DATABASE_ID_TASKS=xxxxx
NOTION_DATABASE_ID_HEALTH=xxxxx
NOTION_DATABASE_ID_PROJECTS=xxxxx

# Google Calendar
GOOGLE_CLIENT_ID=xxxxx
GOOGLE_CLIENT_SECRET=xxxxx

# OpenRouter (pour Leo)
OPENROUTER_API_KEY=sk-or-xxxxx

# Brevo (optionnel)
BREVO_API_KEY=xxxxx

# n8n (si self-hosted)
N8N_ENCRYPTION_KEY=xxxxx (généré automatiquement)
N8N_USER_MANAGEMENT_JWT_SECRET=xxxxx
```

**⚠️ JAMAIS commiter le `.env` !** (il est dans `.gitignore`)

### 3. Déploie selon ton setup

## Option A: n8n Cloud (Recommandé pour Commencer)

**Avantages**: Zéro configuration, sauvegardes automatiques, support Zapier

1. Va sur [n8n.cloud](https://n8n.cloud)
2. Crée un compte gratuit
3. Crée un nouveau workflow
4. Menu → **Workflows** → **Import from file**
5. Sélectionne `workflows/WF1_Bot_Telegram_v2.json`
6. Ajoute tes credentials (Telegram, Notion, etc.)
7. Active le webhook Telegram
8. Teste avec `/help` sur Telegram

**Voir détails**: [n8n-import-guide.md](n8n-import-guide.md)

## Option B: n8n Self-hosted (Docker)
```bash
# Clone n8n
docker pull n8nio/n8n:latest

# Lance le container
docker run -it --rm \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  -e N8N_PROTOCOL=https \
  -e N8N_HOST=localhost \
  -e WEBHOOK_TUNNEL_URL=https://ton-domaine.com/ \
  n8nio/n8n

# Accessible sur http://localhost:5678
```

Ou utilise `docker-compose`:
```bash
cd docker/
docker-compose up -d
```

Puis importe les workflows comme en Option A.

## Option C: OpenClaw Complet (VPS Hetzner)

**Pour le déploiement complet avec Leo + n8n + Notion**

### Prérequis VPS
- Ubuntu 24 LTS
- Docker + Docker Compose
- ~20GB espace disque
- Domaine custom (optionnel mais recommandé)

### Étapes

1. **SSH sur le VPS**
```bash
ssh root@ton-vps-ip
```

2. **Installe Docker**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $(whoami)
```

3. **Clone le repo**
```bash
git clone https://github.com/ton-username/leo-horizons-system.git
cd leo-horizons-system
```

4. **Configure `.env` sur le VPS**
```bash
nano .env
# Copie/colle tes variables (Telegram, Notion, OpenRouter, etc.)
# Ctrl+O → Enter → Ctrl+X
```

5. **Lance OpenClaw + n8n**
```bash
cd docker/
docker-compose up -d
```

6. **Vérifie les logs**
```bash
docker-compose logs -f leo
docker-compose logs -f n8n
```

7. **Accès**
- n8n: `https://ton-domaine.com/n8n`
- Leo WebChat: `https://ton-domaine.com/chat`
- Telegram: `@leo_horizons_bot`

## 🔧 Configuration Post-Déploiement

### Ajoute les Credentials n8n

Dans n8n UI → **Settings** → **Credentials**:

1. **Telegram**
   - Type: Telegram Bot API
   - Bot Token: `TELEGRAM_BOT_TOKEN`

2. **Notion**
   - Type: Notion API
   - Integration Token: `NOTION_API_KEY`
   - (ID bases: à récupérer via Notion API)

3. **Google Calendar**
   - Type: Google OAuth2
   - Scope: `calendar,drive`

4. **OpenRouter** (pour Leo)
   - Type: HTTP Header
   - Key: `Authorization`
   - Value: `Bearer sk-or-xxxxx`

### Configure les Webhooks

#### Telegram → n8n

Dans ton bot Telegram (via BotFather):
```
/setwebhook https://ton-n8n-url/webhook/telegram
```

**Ou via API**:
```bash
curl -X POST https://api.telegram.org/bot{TOKEN}/setWebhook \
  -d url=https://ton-n8n-url/webhook/telegram
```

#### Google Calendar → n8n

Dans `WF3_GCal_Bridge.json`, configure le webhook avec ton URL n8n.

### Initialise les Bases Notion

1. Crée une Integration Notion (Notion Settings → Integrations)
2. Copie l'API Key dans `.env`
3. Dans chaque base Notion, partage l'intégration (⋯ → Connections)
4. Récupère les IDs bases via:
```bash
curl https://api.notion.com/v1/databases \
  -H "Authorization: Bearer ntn_xxxxx"
```

5. Ajoute-les dans `.env`: `NOTION_DATABASE_ID_TASKS=xxxxx`

## 📊 Vérification de la Configuration

Après déploiement, teste chaque composant:

### Test Telegram
```bash
# Envoie un message au bot
/help

# Résultat attendu: liste des commandes
```

### Test n8n
```bash
# Ouvre http://localhost:5678 (ou ton domaine)
# Vérifie que tous les workflows sont présents
# Teste un workflow en cliquant "Execute"
```

### Test Notion
```bash
# Dans n8n, crée un test node Notion → Read Database
# Vérifie que les données se chargent
```

### Test OpenRouter (Leo)
```bash
# Envoie un message à Leo via Telegram
# Vérifie la réponse (doit être rapide ~2-5s)
```

## 🐛 Dépannage

### "Webhook URL not found"
- Vérifie que n8n est accessible publiquement
- URL format: `https://ton-domaine.com/webhook/telegram`
- Teste: `curl https://ton-domaine.com/webhook/telegram`

### "Notion API Error 401"
- Vérifie l'API Key dans `.env`
- Vérifie que l'intégration est partagée dans Notion
- Teste: `curl https://api.notion.com/v1/databases -H "Authorization: Bearer ntn_xxxxx"`

### "Telegram Bot Not Responding"
- Vérifie le Bot Token (via BotFather)
- Vérifie le webhook: `/getWebhookInfo` via API
- Redéploie le webhook

### "n8n Out of Memory"
- Limite les workflows en parallèle
- Augmente la RAM du container: `docker-compose.yml` → `mem_limit: 2g`

### "Leo Responding Slowly"
- Vérifie la connexion OpenRouter
- Diminue `max_tokens` dans les prompts
- Utilise Gemini Flash au lieu de Haiku (plus rapide mais moins qualitatif)

### OpenClaw en Crash Loop (502 Bad Gateway)

**Symptômes** : Erreur 502 sur le domaine, conteneur en boucle de redémarrage.

**Diagnostic rapide** :
```bash
# 1. Vérifier les logs
docker logs openclaw --tail 50

# 2. Tester la connectivité locale
curl -I http://127.0.0.1:18789
```

**Causes fréquentes** :
1. **Config JSON invalide** : Clés obsolètes (`host`, `agent`) dans `openclaw.json`
   → Supprimer le fichier et redémarrer le conteneur
2. **Permissions (EACCES)** : `chown -R 1000:1000` sur le volume config
3. **Réseau Docker** : Vérifier `OPENCLAW_HOST=0.0.0.0` dans docker-compose.yml
4. **Caddyfile** : Utiliser `reverse_proxy openclaw:18789` (pas `localhost`)
5. **Modèle trop lourd** : Passer de Opus à Haiku 4.5 dans l'onglet Agents

**Guide complet** : [TROUBLESHOOTING-OPENCLAW.md](TROUBLESHOOTING-OPENCLAW.md)

## 🔄 Maintenance

### Sauvegarde Régulière
```bash
# Exporte les workflows n8n
curl http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: xxxxx" \
  > workflows/export-$(date +%Y%m%d).json

# Exporte la config OpenClaw
cp openclaw/openclaw.json openclaw/openclaw.json.bak

# Git commit
git add .
git commit -m "Backup config $(date +%Y-%m-%d)"
git push
```

### Updates
```bash
# Pull dernière version
git pull origin main

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

## 📚 Ressources

- [n8n Docs](https://docs.n8n.io)
- [Notion API](https://developers.notion.com)
- [Telegram Bot API](https://core.telegram.org/bots/api)
- [OpenRouter Docs](https://openrouter.ai/docs)

---

**Besoin d'aide ?** Consulte [n8n-import-guide.md](n8n-import-guide.md) ou l'architecture dans [architecture.md](architecture.md).
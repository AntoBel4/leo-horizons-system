# Guide Complet : Importer les Workflows n8n

Ce guide te montre **pas à pas** comment importer et configurer tes workflows n8n.

## 📖 Avant de Commencer

- Tu as une instance n8n (cloud ou self-hosted)
- Tu as les fichiers `.json` des workflows dans `workflows/`
- Tu as tes API keys/tokens à portée de main

## 🚀 Méthode 1 : Via UI n8n (Recommandée)

### Étape 1 : Ouvre n8n

- **n8n Cloud**: https://leo.estarellas.online
- **Self-hosted local**: http://localhost:5678
- **Self-hosted custom**: https://leo.estarellas.online

### Étape 2 : Crée un nouveau workflow ou importe

Menu en haut à gauche → **Workflows** → **Import from file**
```
[Menu] → Workflows → [Import from file button]
```

### Étape 3 : Sélectionne le fichier

Choisis le workflow à importer, par exemple:
- `WF1_Bot_Telegram_v2.json` (commandes Telegram)
- `WF2_Horizons_BATCH.json` (briefings automatisés)
- `WF3_GCal_Bridge.json` (sync Google Calendar)
- `WF4_Night_Scheduler.json` (tâches nocturnes)

### Étape 4 : Clique "Import"

Le workflow s'ajoute à ta liste. **Attention**: Les credentials ne sont **pas** importées (sécurité).

## 🔐 Étape 5 : Configure les Credentials

Après import, tu veras des **nodes en jaune** (❌ credentials manquantes).

### Ajouter une Credential

1. Clique sur un node jaune (ex: Telegram node)
2. Onglet **"Credentials"** → **"+ Add new"**
3. Entre le **nom** (ex: "Telegram Bot - Leo")
4. Sélectionne le **type** (Telegram Bot API)
5. Remplis les champs:
   - **Bot Token**: Copie depuis `.env` ou BotFather
   - Clique **"Create"**

**Résultat**: Le node devient **vert** ✅

### Credentials Principaux à Ajouter

#### 1️⃣ Telegram Bot API
```
Type: Telegram Bot API
Bot Token: 123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
```

Récupère le token via **BotFather** (@BotFather sur Telegram):
```
/newbot → réponds aux questions → copie le token
```

#### 2️⃣ Notion API
```
Type: Notion API
Integration Token: ntn_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Récupère-le:
1. Va sur https://www.notion.com/my-integrations
2. Crée une nouvelle intégration → **Internal Integration**
3. Copie le **token**
4. Dans Notion UI: partage chaque base avec l'intégration (⋯ → Connections)

#### 3️⃣ Google Calendar (OAuth2)
```
Type: Google OAuth2
Client ID: xxxxx.apps.googleusercontent.com
Client Secret: GOCSP-xxxxx
```

Récupère-le:
1. Va sur [Google Cloud Console](https://console.cloud.google.com)
2. Crée un projet → Active "Google Calendar API"
3. Credentials → OAuth 2.0 Client IDs → "Web Application"
4. Ajoute redirect: `http://localhost:5678/rest/oauth2-callback` (ou ton domaine)
5. Copie Client ID & Secret

#### 4️⃣ OpenRouter (pour Leo)
```
Type: HTTP Header Authentication
Key: Authorization
Value: Bearer sk-or-xxxxxxxxxxxxx
```

Récupère-le:
1. Va sur https://openrouter.ai
2. Crée un compte → API keys
3. Copie ta clé API

#### 5️⃣ Brevo (Optionnel - Emails)
```
Type: Brevo API
API Key: xxxxxxxxxxxxx
```

Récupère-le:
1. Va sur https://www.brevo.com
2. Settings → SMTP & API → API keys
3. Copie la clé

## 🔄 Ajouter les Variables d'Environnement

n8n peut lire des variables d'environnement pour plus de sécurité.

### Option 1 : Via `.env` (Self-hosted)

Crée un fichier `.env` à la racine:
```env
TELEGRAM_BOT_TOKEN=xxxxx
NOTION_API_KEY=ntn_xxxxx
NOTION_DATABASE_ID_TASKS=xxxxx
OPENROUTER_API_KEY=sk-or-xxxxx
```

### Option 2 : Via n8n UI (Cloud ou Self-hosted)

1. **Settings** → **Environment Variables**
2. Clique **"+ Add Variable"**
3. Remplis:
   - **Name**: `TELEGRAM_BOT_TOKEN`
   - **Value**: `xxxxx`
   - **Type**: Secret (🔒)
4. Clique **"Save"**

### Utiliser la Variable dans un Workflow

Dans n8n, utilise la syntaxe:
```
{{ $env.TELEGRAM_BOT_TOKEN }}
```

**Exemple** dans un Telegram node:
```
Credentials → Token field → {{ $env.TELEGRAM_BOT_TOKEN }}
```

## 📊 Configuration Détaillée par Workflow

### WF1: Bot Telegram (Commandes)

**Nodes nécessaires:**
- 🟦 **Telegram Bot** (credential: Telegram Bot API)
- 🟨 **Notion DB** (credential: Notion API)
- 🟪 **HTTP Request** (pour OpenRouter si Leo intégré)

**Nodes à configurer:**

1. **Telegram Trigger**
   - Credentials: Telegram Bot API
   - Webhook: Auto-généré par n8n
   - Test: `/help` sur Telegram → doit recevoir réponse

2. **Notion Read/Create**
   - Credentials: Notion API
   - Database ID: Copie depuis `.env` ou URI Notion
   - ✅ Utilise "From list" (sélectionne visuelle) au lieu de "By ID"

3. **Telegram Send**
   - Credentials: Telegram Bot API
   - Chat ID: `{{ $json.chat.id }}` (du trigger)

**Teste:**
```
/start → doit retourner un message de bienvenue
/help → liste des commandes
/log_health 80 → doit créer une entrée Notion
```

### WF2: Briefings Automatisés (Batch)

**Schedule**: Cron (6:30 AM, midi, 6 PM, dimanche revue)

**Nodes nécessaires:**
- 🔵 **Cron Trigger**
- 🟨 **Notion DB** (lire tâches du jour)
- 🟪 **HTTP Request** (générer texte via OpenRouter)
- 🟦 **Telegram Send** (envoyer briefing)

**Configuration:**

1. **Cron Trigger**
```
   Hour: 6
   Minute: 30
   Day of Week: * (tous les jours)
```
   Pour dimanche revue: Ajoute un autre Cron avec `Day of Week: 0`

2. **Notion Database Query**
   - Filter: `Status != 'Done'` (tâches non complétées)
   - Sort: `Priority DESC`

3. **HTTP Request (OpenRouter)**
```
   Method: POST
   URL: https://openrouter.ai/api/v1/chat/completions
   Auth: Bearer {{ $env.OPENROUTER_API_KEY }}
   Body (JSON):
   {
     "model": "anthropic/claude-3-5-haiku",
     "messages": [
       {
         "role": "user",
         "content": "Génère un briefing pour {{ $now.toFormat('dd/MM/yyyy') }}\n\nTâches: {{ $json.tasks.map(t => t.name).join(', ') }}"
       }
     ],
     "max_tokens": 500
   }
```

4. **Telegram Send**
   - Chat ID: `{{ $env.TELEGRAM_CHAT_ID }}`
   - Message: `{{ $json.choices[0].message.content }}`

**Teste:**
```
Execute manually → doit envoyer un briefing sur Telegram
```

### WF3: Google Calendar Bridge

**Trigger**: Webhook HTTP (appelé par Google Calendar)

**Nodes nécessaires:**
- 🟦 **Webhook HTTP** (recevoir les changements Calendar)
- 🟩 **Google Calendar Read** (lire event)
- 🟨 **Notion Create/Update** (synchroniser)

**Configuration:**

1. **Webhook Trigger**
   - Path: `/webhook/gcal`
   - URL complète: `https://coaching.estarellas.online/webhook/gcal`

2. **Google Calendar Node**
   - Credentials: Google OAuth2
   - Action: "Get Event"
   - Calendar ID: `primary` (ou spécifique)
   - Event ID: `{{ $json.resource.id }}`

3. **Notion Create Database Entry**
   - Credentials: Notion API
   - Database: "Tâches"
   - Map les champs:
     - `Title` ← Calendar event title
     - `Date` ← event.start.dateTime
     - `Horizon` ← event.colorId (code couleur Horizons)

**Teste:**
```
Crée/modifie un event Google Calendar → doit créer une entrée Notion
```

### WF4: Scheduler Nocturne (Batch 2 AM)

**Schedule**: Cron 2 AM chaque jour

**Nodes nécessaires:**
- 🔵 **Cron Trigger** (2 AM)
- 🟨 **Notion Database** (lire tâches batch)
- 🟪 **HTTP Requests** (exécuter tâches)
- 📊 **Aggregator** (compiler résultats)
- 📧 **Email** ou **Telegram** (résumé)

**Configuration:**

1. **Cron Trigger**
```
   Hour: 2
   Minute: 0
```

2. **Notion Query**
   - Filter: `Batch = true` AND `Completed = false`
   - Résultat: liste des tâches batch

3. **HTTP Request** (exécuter chaque tâche)
   - Loop sur les résultats Notion
   - Exemple: générer contenu expert-local.fr
```
   POST https://prospect.estarellas.online/api/content-gen
   Body: {{ $json.content_params }}
```

4. **Aggregator** (optionnel)
   - Compile tous les résultats
   - Format pour rapport

5. **Telegram Send**
   - Résumé: "✅ 5 tâches batch exécutées"

**Teste:**
```
Execute manually → doit exécuter toutes les tâches batch
Vérifie les logs: docker-compose logs n8n
```

## 🧪 Testing Each Workflow

### Méthode 1 : Execute Manual

Dans n8n UI → bouton **"Execute Workflow"** (▶️)

**Regarde l'output** de chaque node (clique sur le node → inspect)

### Méthode 2 : Webhook Test

Pour les workflows avec webhooks (Telegram, Calendar):
```bash
# Test webhook Telegram
curl -X POST https://coaching.estarellas.online/webhook/telegram \
  -H "Content-Type: application/json" \
  -d '{
    "update_id": 123,
    "message": {
      "message_id": 1,
      "chat": {"id": 999, "type": "private"},
      "text": "/help"
    }
  }'
```

### Méthode 3 : Production Testing

- **Telegram**: Envoie un message réel au bot
- **Calendar**: Crée/modifie un event
- **Batch**: Attend 2 AM ou force via "Execute"

## 🐛 Dépannage des Imports

### Problème: "Credential not found"
- ✅ Ajoute la credential manuellement (voir étape 5)
- ✅ Utilise `{{ $env.VARIABLE }}` au lieu d'une credential stockée

### Problème: "Database not found" (Notion)
- ✅ Utilise "From list" pour sélectionner visuellement
- ✅ N'utilise **pas** "By ID" (cause 404 silencieux)
- ✅ Vérifie que l'intégration Notion a accès à la base

### Problème: "Invalid token" (Telegram/Notion)
- ✅ Copie/colle à nouveau le token (pas d'espace)
- ✅ Vérifie qu'il n'y a pas de caractères cachés

### Problème: "Webhook not triggered"
- ✅ Teste avec `curl` (voir Testing)
- ✅ Vérifie que l'URL est publiquement accessible
- ✅ Regarde les logs n8n: `docker-compose logs -f n8n`

### Problème: "Out of memory" ou timeout
- ✅ Réduis le nombre de records à traiter (add filters)
- ✅ Augmente les timeouts: **Settings** → **Advanced** → Timeouts
- ✅ Augmente RAM du container

## 📚 Ressources Additionnelles

- [n8n Documentation](https://docs.n8n.io)
- [Notion API](https://developers.notion.com)
- [Telegram Bot API](https://core.telegram.org/bots/api)
- [OpenRouter Documentation](https://openrouter.ai/docs)

## ✅ Checklist d'Import

- [ ] Tous les workflows importés (WF1-4)
- [ ] Credentials ajoutées (Telegram, Notion, Google, OpenRouter)
- [ ] Variables d'environnement configurées
- [ ] Webhooks testés (curl ou production)
- [ ] Chaque workflow exécuté manuellement ✅
- [ ] Logs vérifiés (pas d'erreurs)
- [ ] Schedules activés (Cron triggers)
- [ ] Telegram bot répond ✅
- [ ] Notion entries créées ✅
- [ ] Briefings reçus ✅

---

**Besoin d'aide ?** Consulte [SETUP.md](SETUP.md) pour le déploiement complet ou [architecture.md](architecture.md) pour comprendre le système.
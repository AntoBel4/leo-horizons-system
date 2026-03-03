# n8n Workflows

Cette collection contient **5 workflows n8n** pour l'automatisation du système Horizons.

## 📋 Workflows

### 1. WF1_Bot_Telegram_v2.1.json
**Rôle**: Bot Telegram autonome avec commandes, logging, gamification

**Fonctionnalités**:
- Commandes: `/help`, `/start`, `/log_health`, `/status`
- Health tracking (energy, mood, sleep)
- Gamification (points, badges)
- Routing vers Leo (assistant IA)
- Intégrations: Telegram API, Notion CRM

**Trigger**: Telegram incoming messages
**Credentials nécessaires**:
- Telegram Bot API (Bot Token)
- Notion API (pour logging)

**Fréquence**: Real-time

---

### 2. WF2_Briefings_v2.3.json
**Rôle**: Génération automatique de briefings quotidiens

**Fonctionnalités**:
- Briefing 6:30 AM: Agenda du jour + tâches prioritaires
- Briefing midi: Check-in + points importants
- Briefing 6 PM: Résumé jour + réflexions
- Revue Dimanche: Semaine écoulée + planning semaine

**Trigger**: Cron schedules
- 6:30 AM, 12:00 PM, 6:00 PM (tous les jours)
- 10:00 AM (dimanches uniquement)

**Credentials nécessaires**:
- Notion API (lire tâches)
- OpenRouter API (générer texte avec Haiku)
- Telegram Bot API (envoyer briefings)

**Format**: Markdown + emojis
**Destinataire**: Telegram direct message

---

### 3. WF3_GCal_Bridge.json
**Rôle**: Synchronisation bidirectionnelle Google Calendar ↔ Notion

**Fonctionnalités**:
- Lis events Google Calendar
- Parse couleurs (Horizons: H1-Pro 🔴, H1-Santé 🟢, etc.)
- Crée/Update entries dans Notion Tâches
- Sync métadata: date, titre, description, assigné

**Trigger**: Webhook HTTP (event changes)

**Credentials nécessaires**:
- Google Calendar OAuth2
- Notion API

**Direction**: Google Calendar → Notion (uni-directionnelle pour l'instant)

---

### 4. WF4_Night_Scheduler_v1.0.json
**Rôle**: Batch queue nocturne (2 AM) pour tâches lourdes

**Fonctionnalités**:
- Execute tâches marquées "Batch=true"
- Génération contenu (expert-local.fr, blog)
- Audits système (logs, backups)
- Cleanup Notion (archiver completed)
- News aggregation (NewsAPI)

**Trigger**: Cron 2:00 AM chaque jour

**Credentials nécessaires**:
- Notion API
- OpenRouter API (si génération contenu)
- External APIs (NewsAPI, expert-local.fr, etc.)

**Résultat**: Summary email/Telegram le matin

---

### 5. WF4a_GCal_Write_Webhook.json
**Rôle**: Webhook pour écrire/modifier events Google Calendar

**Fonctionnalités**:
- Reçoit POST requests pour créer events
- Assigne Horizon (couleur)
- Gère les conflits d'horaire
- Sync back à Notion

**Trigger**: HTTP POST webhook

**Credentials nécessaires**:
- Google Calendar API (write access)
- Notion API

**Endpoint**: `https://ton-n8n.com/webhook/gcal-write`

---

## 🚀 Importer les Workflows

### Méthode 1: Via UI n8n (Recommandée)

1. Ouvre n8n: `http://localhost:5678` ou `https://n8n.cloud`
2. Menu → **Workflows** → **Import from file**
3. Sélectionne un fichier `.json`
4. Clique **Import**
5. Configure les credentials (voir section ci-dessous)

### Méthode 2: Via CLI n8n
```bash
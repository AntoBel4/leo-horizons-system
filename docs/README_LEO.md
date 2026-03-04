# README Leo Horizons System
*Documentation complète du système Léo — Assistant IA personnel d'Antoine Estarellas*
*Version : 2.0 | Dernière mise à jour : Mars 2026*

---

## Architecture complète

```
                    ANTOINE (Utilisateur)
                         |
            +------------+------------+
            |                         |
        Telegram               WebChat
  @leo_horizons_bot    coaching.estarellas.online
            |                         |
            +------------+------------+
                         |
                    +---------+
                    |  Caddy  |  (Reverse Proxy + SSL)
                    +----+----+
                         |
            +------------+------------+
            |                         |
    +-------+-------+        +-------+-------+
    |   OpenClaw    |        |     n8n       |
    |    (Leo)      |        | (Orchestration)|
    |  port 8080    |        |  port 5678    |
    +-------+-------+        +-------+-------+
            |                         |
            +------------+------------+
                         |
        +----------------+----------------+
        |                |                |
   +---------+    +----------+    +----------+
   | Notion  |    |  Google  |    | Telegram |
   |   API   |    | Calendar |    |   API    |
   +---------+    +----------+    +----------+

Infrastructure : VPS Hetzner (Ubuntu 22.04 LTS)
Conteneurisation : Docker + docker-compose
Tunnel : Cloudflare Tunnel + Zero Trust
```

---

## Services et URLs

| Service | URL | Port interne | Description |
|---------|-----|--------------|-------------|
| OpenClaw (Leo) | coaching.estarellas.online | 8080 | Assistant IA principal |
| n8n | coaching.estarellas.online/n8n | 5678 | Orchestration workflows |
| Dashboard | coaching.estarellas.online/dashboard | 8080 | Panneau de contrôle |
| WF3 Webhook | coaching.estarellas.online/webhook/gcal-leo | 5678 | Lecture Google Calendar |
| WF4a Webhook | coaching.estarellas.online/webhook/google-calendar-create | 5678 | Écriture Google Calendar |
| Telegram Bot | @leo_horizons_bot | — | Interface Telegram |

---

## Structure des fichiers

```
leo-horizons-system/
|-- .env.example              # Template variables d'environnement
|-- .gitignore                # Fichiers exclus du repo
|-- README.md                 # Documentation projet (GitHub)
|
|-- identity/                 # Fichiers d'identité de Léo
|   |-- SOUL.md               # Valeurs et comportements
|   |-- USER.md               # Profil d'Antoine
|   |-- IDENTITY.md           # Fiche technique
|   |-- AGENTS.md             # Configuration des agents
|   +-- BOOTSTRAP.md          # Procédure de démarrage
|
|-- skills/                   # Compétences de Léo
|   |-- SKILL_coach.md        # Persona et interaction
|   |-- SKILL_horizons.md     # Google Calendar + Horizons
|   |-- SKILL_n8n-executor.md # Webhooks n8n
|   |-- SKILL_notion.md       # Accès direct Notion
|   |-- SKILL_batch-executor.md # File nocturne
|   |-- SKILL_mode-switch.md  # Routage LLM
|   +-- SKILL_gemini.md       # YouTube + Gemini
|
|-- workflows/                # Workflows n8n (JSON)
|   |-- WF1_Bot_Telegram_v2.1.json
|   |-- WF2_Briefings_v2.3.json
|   |-- WF3_GCal_Bridge.json
|   |-- WF4_Night_Scheduler_v1.0.json
|   +-- WF4a_GCal_Write_Webhook.json
|
|-- openclaw/                 # Configuration OpenClaw
|   |-- openclaw.json.example
|   +-- auth-profiles.json.example
|
|-- docker/                   # Configuration Docker
|   |-- docker-compose.yml
|   +-- Caddyfile
|
|-- dashboard/                # Dashboard de contrôle
|   +-- index.html
|
+-- docs/                     # Documentation
    |-- SETUP.md
    |-- architecture.md
    |-- n8n-import-guide.md
    |-- README_LEO.md          # Ce fichier
    |-- COMMANDES_LEO.md
    +-- CHANGELOG_LEO.md
```

---

## Commandes de maintenance courantes

### Statut des services
```bash
# Voir tous les conteneurs
docker compose -f docker/docker-compose.yml ps

# Logs en temps réel
docker compose -f docker/docker-compose.yml logs -f

# Logs d'un service spécifique
docker logs openclaw-leo --tail 50
docker logs n8n-coaching --tail 50

# Statistiques ressources
docker stats
```

### Redémarrage
```bash
# Redémarrer un service
docker restart openclaw-leo
docker restart n8n-coaching

# Redémarrer tout
docker compose -f docker/docker-compose.yml restart

# Arrêter tout
docker compose -f docker/docker-compose.yml down

# Démarrer tout
docker compose -f docker/docker-compose.yml up -d
```

### Vérifications rapides
```bash
# Healthcheck OpenClaw
curl -s https://coaching.estarellas.online/health

# Test webhook GCal
curl -s https://coaching.estarellas.online/webhook/gcal-leo

# Test bot Telegram
curl -s https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe

# Test API Notion
curl -s https://api.notion.com/v1/users/me \
  -H "Authorization: Bearer ${NOTION_API_KEY}" \
  -H "Notion-Version: 2022-06-28"
```

---

## Procédure de mise à jour OpenClaw

```bash
# 1. Backup
cp openclaw/openclaw.json openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)

# 2. Pull nouvelle image
docker pull ghcr.io/openclaw/openclaw:latest

# 3. Redémarrer avec la nouvelle image
docker compose -f docker/docker-compose.yml up -d openclaw

# 4. Vérifier
docker logs openclaw-leo --tail 20
curl -s https://coaching.estarellas.online/health
```

---

## Procédure de backup

### Backup quotidien (manuel ou cron)
```bash
#!/bin/bash
# backup-leo.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=./backups/$DATE
mkdir -p $BACKUP_DIR

# Config OpenClaw
cp openclaw/openclaw.json $BACKUP_DIR/

# Docker compose
cp docker/docker-compose.yml $BACKUP_DIR/

# .env (si présent)
[ -f .env ] && cp .env $BACKUP_DIR/

# Volumes Docker
docker run --rm \
  -v openclaw-data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/$DATE/openclaw-data.tar.gz /data

docker run --rm \
  -v n8n-data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/$DATE/n8n-data.tar.gz /data

# Export workflows n8n
# (via l'API n8n ou manuellement depuis l'UI)

echo "Backup terminé : $BACKUP_DIR"
```

### Automatiser avec cron
```bash
# Backup quotidien à 3h du matin
0 3 * * * cd /opt/leo-horizons-system && ./backup-leo.sh >> /var/log/leo-backup.log 2>&1
```

---

## Restauration depuis backup

```bash
# 1. Arrêter les services
docker compose -f docker/docker-compose.yml down

# 2. Restaurer les fichiers de config
cp backups/YYYYMMDD/openclaw.json openclaw/
cp backups/YYYYMMDD/.env .

# 3. Restaurer les volumes Docker
docker run --rm \
  -v openclaw-data:/data \
  -v $(pwd)/backups/YYYYMMDD:/backup \
  alpine tar xzf /backup/openclaw-data.tar.gz -C /

# 4. Redémarrer
docker compose -f docker/docker-compose.yml up -d
```

---

## Troubleshooting

### Leo ne répond pas sur Telegram
1. Vérifier que le conteneur tourne : `docker ps | grep openclaw`
2. Vérifier les logs : `docker logs openclaw-leo --tail 50`
3. Vérifier le bot Telegram : `curl https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getWebhookInfo`
4. Si webhook expiré, le réenregistrer

### Les webhooks n8n ne répondent pas
1. Vérifier que n8n tourne : `docker ps | grep n8n`
2. Vérifier les logs : `docker logs n8n-coaching --tail 50`
3. Vérifier que les workflows sont actifs dans l'UI n8n
4. Tester directement : `curl -v https://coaching.estarellas.online/webhook/gcal-leo`

### Notion renvoie des erreurs
1. **401 Unauthorized** : Clé API invalide ou expirée. Régénérer sur notion.com/my-integrations
2. **404 Not Found** : Database ID incorrect. Vérifier dans le .env
3. **429 Rate Limited** : Trop de requêtes. Attendre 1 minute
4. **400 Bad Request** : Vérifier le format des propriétés dans la requête

### Le modèle LLM ne répond pas
1. Vérifier les crédits OpenRouter : openrouter.ai/account
2. Vérifier la clé API dans le .env
3. Le fallback (Gemini Flash) devrait s'activer automatiquement
4. Si tous les modèles échouent, vérifier la connexion Internet du VPS

### Le dashboard n'affiche rien
1. Vérifier que le fichier index.html est servi par Caddy/OpenClaw
2. Vérifier les erreurs dans la console du navigateur (F12)
3. S'assurer que l'auth basique est configurée dans le Caddyfile

### Erreur "port already in use"
```bash
# Trouver le processus qui occupe le port
lsof -i :8080  # OpenClaw
lsof -i :5678  # n8n

# Arrêter le processus ou utiliser un port différent dans docker-compose.yml
```

### Espace disque insuffisant
```bash
# Vérifier l'espace
df -h

# Nettoyer Docker
docker system prune -f
docker volume prune -f  # ATTENTION : supprime les volumes non utilisés

# Vérifier la taille des logs
du -sh /var/log/
```

---

## Variables d'environnement requises

Voir `.env.example` pour la liste complète. Les variables critiques :

| Variable | Description | Où la trouver |
|----------|-------------|---------------|
| `OPENROUTER_API_KEY` | Clé API OpenRouter | openrouter.ai/keys |
| `TELEGRAM_BOT_TOKEN` | Token bot Telegram | @BotFather |
| `TELEGRAM_CHAT_ID` | ID du chat Antoine | @userinfobot |
| `NOTION_API_KEY` | Clé API Notion | notion.com/my-integrations |
| `NOTION_DATABASE_ID_*` | IDs des bases Notion | URL des pages Notion |
| `N8N_ENCRYPTION_KEY` | Clé de chiffrement n8n | Générer aléatoirement |

---

## Budget et coûts

| Poste | Coût mensuel | Notes |
|-------|-------------|-------|
| VPS Hetzner | ~5 EUR | CX11 ou CX21 |
| OpenRouter (LLM) | ~5 EUR | Haiku primary |
| Domaine | ~1 EUR | Via Cloudflare |
| Notion | Gratuit | Plan personnel |
| n8n | Gratuit | Self-hosted |
| **Total** | **~11 EUR/mois** | |

---

*Ce fichier est la documentation de référence de Leo Horizons System. En cas de doute, commencer ici.*

# BOOTSTRAP.md — Procédure de démarrage et reprise de Léo
*Version : 1.0 | Créé : Mars 2026*

---

## Ordre de lecture au démarrage

À chaque nouvelle session, Léo lit les fichiers dans cet ordre exact :

```
1. SOUL.md          → Qui je suis (valeurs, comportements non-négociables)
2. USER.md          → Qui est Antoine (profil, préférences, projets)
3. IDENTITY.md      → Ma fiche technique (modèles, intégrations, webhooks)
4. AGENTS.md        → Quel agent suis-je ? (main ou perso)
5. SKILL_coach.md   → Comment interagir avec Antoine
6. SKILL_horizons.md → Système H1/H2/H3 et Google Calendar
7. SKILL_n8n-executor.md → Webhooks disponibles
8. SKILL_notion.md  → Accès direct Notion
```

**Si un fichier est inaccessible :** Léo le signale à Antoine et continue avec les fichiers restants. Il ne bloque pas le démarrage.

---

## Vérifications au démarrage

### Check 1 — Modèle LLM actif
```
Vérifier : Quel modèle est chargé ?
Attendu : claude-haiku-4-5 (via OpenRouter)
Si KO : Fallback automatique vers gemini-2.5-flash
Action : Informer Antoine si fallback activé
```

### Check 2 — Webhooks n8n accessibles
```
Vérifier : GET ${N8N_WEBHOOK_BASE_URL}/webhook/gcal-leo
Attendu : Réponse HTTP 200 avec JSON
Si KO : Marquer calendrier comme indisponible
Action : Informer Antoine "Les webhooks n8n ne répondent pas"
Commande debug : docker logs n8n-coaching --tail 20
```

### Check 3 — API Notion accessible
```
Vérifier : GET https://api.notion.com/v1/users/me
Header : Authorization: Bearer ${NOTION_API_KEY}
Attendu : Réponse HTTP 200
Si KO : Marquer Notion comme indisponible
Action : Informer Antoine "L'API Notion ne répond pas"
```

### Check 4 — Telegram opérationnel
```
Vérifier : Le bot @leo_horizons_bot répond aux messages
Attendu : Messages reçus et traités
Si KO : Vérifier le token et le webhook Telegram
Commande debug : curl https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe
```

---

## Procédure de démarrage normal

```
1. Lire les fichiers d'identité (ordre ci-dessus)
2. Identifier l'agent actif (main ou perso)
3. Exécuter les 4 checks de démarrage
4. Si tout OK : prêt à répondre
5. Si check(s) KO : informer Antoine des services indisponibles
6. Fonctionner en mode dégradé si nécessaire
```

### Mode dégradé

| Service down | Impact | Ce que Léo peut encore faire |
|--------------|--------|------------------------------|
| n8n | Pas de GCal | Conversations, coaching, Notion direct |
| Notion | Pas de données structurées | Conversations, coaching, GCal via n8n |
| OpenRouter (Haiku) | Fallback Gemini | Tout, mais qualité réduite |
| OpenRouter (tout) | Pas de LLM | Rien — système hors service |
| Telegram | Pas de messagerie | WebChat uniquement |

---

## Procédure de récupération

### Service n8n down
```bash
# 1. Vérifier le statut du conteneur
docker ps | grep n8n

# 2. Vérifier les logs
docker logs n8n-coaching --tail 50

# 3. Redémarrer le conteneur
docker restart n8n-coaching

# 4. Vérifier que les webhooks répondent
curl -s https://coaching.estarellas.online/webhook/gcal-leo
```

### Service OpenClaw down
```bash
# 1. Vérifier le statut
docker ps | grep openclaw

# 2. Vérifier les logs
docker logs openclaw-leo --tail 50

# 3. Redémarrer
docker restart openclaw-leo

# 4. Vérifier le healthcheck
curl -s https://coaching.estarellas.online/health
```

### API Notion inaccessible
```bash
# 1. Tester l'API directement
curl -s https://api.notion.com/v1/users/me \
  -H "Authorization: Bearer ${NOTION_API_KEY}" \
  -H "Notion-Version: 2022-06-28"

# 2. Si 401 : la clé API a expiré ou a été révoquée
#    → Régénérer sur https://www.notion.com/my-integrations

# 3. Si 429 : rate limit atteint
#    → Attendre 1 minute et réessayer

# 4. Si timeout : problème réseau
#    → Vérifier la connectivité du VPS
```

### Telegram bot ne répond pas
```bash
# 1. Vérifier le bot
curl -s https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe

# 2. Vérifier le webhook
curl -s https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getWebhookInfo

# 3. Réenregistrer le webhook si nécessaire
curl -s -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/setWebhook \
  -d "url=https://coaching.estarellas.online/webhook/telegram"
```

---

## Procédure de redémarrage complet

En cas de redémarrage du VPS ou de mise à jour majeure :

```bash
# 1. Se connecter au VPS
ssh user@vps-ip

# 2. Aller dans le répertoire du projet
cd /opt/leo-horizons-system

# 3. Pull les dernières images
docker compose -f docker/docker-compose.yml pull

# 4. Redémarrer tous les services
docker compose -f docker/docker-compose.yml up -d

# 5. Vérifier les statuts
docker compose -f docker/docker-compose.yml ps

# 6. Vérifier les healthchecks
docker compose -f docker/docker-compose.yml ps --format "table {{.Name}}\t{{.Status}}"

# 7. Tester les endpoints
curl -s https://coaching.estarellas.online/health
curl -s https://coaching.estarellas.online/webhook/gcal-leo
```

---

## Backup avant modification

**Règle absolue :** Avant toute modification de configuration, créer un backup.

```bash
# Backup config OpenClaw
cp openclaw/openclaw.json openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)

# Backup docker-compose
cp docker/docker-compose.yml docker/docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)

# Backup .env
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)

# Backup complet des volumes Docker
docker run --rm -v openclaw-data:/data -v $(pwd)/backups:/backup alpine \
  tar czf /backup/openclaw-data-$(date +%Y%m%d).tar.gz /data
```

---

## Mise à jour OpenClaw

```bash
# 1. Backup de la config actuelle
cp openclaw/openclaw.json openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)

# 2. Pull la dernière image
docker pull ghcr.io/openclaw/openclaw:latest

# 3. Redémarrer avec la nouvelle image
docker compose -f docker/docker-compose.yml up -d openclaw

# 4. Vérifier la version
docker inspect openclaw-leo --format '{{.Config.Image}}'

# 5. Tester
curl -s https://coaching.estarellas.online/health
```

---

*Ce fichier est le manuel de survie de Léo. En cas de doute, suivre ces procédures dans l'ordre.*

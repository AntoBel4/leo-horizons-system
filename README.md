# Système Horizons — Workspace Léo

## Réparation rapide en cas de crash gateway

### 1. Vérifier l'état
docker ps -a --filter name=openclaw
docker logs openclaw --tail 30

### 2. Si openclaw.json invalide
cp /root/n8n-docker/openclaw_data/openclaw.json.bak /root/n8n-docker/openclaw_data/openclaw.json
docker restart openclaw && sleep 15 && docker logs openclaw --tail 10

### 3. Si Caddy absent
cd /root/n8n-docker && docker compose up -d caddy

### 4. Vérifier le modèle actif
docker logs openclaw 2>&1 | grep "agent model"

### 5. Config openclaw.json minimale fonctionnelle
Voir NordPass pour TELEGRAM_BOT_TOKEN et GATEWAY_TOKEN.
Structure minimale :
- agents.defaults.model.primary
- channels.telegram.enabled + botToken
- gateway.port + mode + auth.token

## Architecture agents
- main (Leo) : Orchestrateur — Gemini Flash / Haiku
- atlas : Veille/Recherche — Llama 3.3
- clavis : SEO — Gemini Flash
- maya-blog : Redaction Blog — Haiku
- maya-local : Copywriting Expert-Local — Haiku
- graphix : Prompts visuels — Gemini Flash
- pulse : Community Manager — Gemini Flash

## Supabase
Project ID : zpldoneburdicjapnigd
Tables : agent_logs, content_pipeline, content_assets

## GitHub
Repository : AntoBel4/leo-horizons-system
Credentials : jamais dans ce repo — utiliser NordPass

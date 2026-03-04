#!/bin/bash
# ============================================
# Script de déploiement OpenClaw (Leo)
# ============================================
# Usage: ssh root@ton-vps-ip 'bash -s' < deploy-openclaw.sh
#    ou: scp deploy-openclaw.sh root@ton-vps-ip: && ssh root@ton-vps-ip bash deploy-openclaw.sh
# ============================================

set -e

DOCKER_DIR="${HOME}/n8n-docker"
VOLUME_PATH="/var/lib/docker/volumes/n8n-docker_openclaw_config/_data"

echo "=========================================="
echo " DÉPLOIEMENT OPENCLAW (LEO)"
echo "=========================================="

# 1. Vérifier Docker
echo ""
echo "[1/8] Vérification Docker..."
if ! command -v docker &> /dev/null; then
    echo "ERREUR: Docker n'est pas installé."
    echo "Installe-le avec: curl -fsSL https://get.docker.com | sh"
    exit 1
fi
echo "  OK - Docker $(docker --version | cut -d' ' -f3)"

# 2. Créer le dossier si nécessaire
echo ""
echo "[2/8] Préparation du dossier ${DOCKER_DIR}..."
mkdir -p "${DOCKER_DIR}"
cd "${DOCKER_DIR}"
echo "  OK - Dossier prêt"

# 3. Arrêter les conteneurs existants
echo ""
echo "[3/8] Arrêt des conteneurs existants..."
docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true
docker stop openclaw caddy 2>/dev/null || true
docker rm openclaw caddy 2>/dev/null || true
echo "  OK - Conteneurs arrêtés"

# 4. Écrire le docker-compose.yml
# NOTE: network_mode: host est REQUIS car OpenClaw écoute toujours
# sur 127.0.0.1 (codé en dur, la clé "host" dans le JSON est refusée).
# Avec network_mode: host, le 127.0.0.1 du conteneur = celui du VPS.
echo ""
echo "[4/8] Écriture docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
services:
  openclaw:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw
    restart: unless-stopped
    network_mode: host
    environment:
      - TZ=Europe/Paris
    volumes:
      - openclaw_config:/home/node/.openclaw

  caddy:
    image: caddy:2-alpine
    container_name: caddy
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config

volumes:
  openclaw_config:
  caddy_data:
  caddy_config:
EOF
echo "  OK"

# 5. Écrire le Caddyfile
# NOTE: Avec network_mode: host, on utilise 127.0.0.1 (pas un nom de service)
echo ""
echo "[5/8] Écriture Caddyfile..."
cat > Caddyfile << 'EOF'
leo.estarellas.online {
	reverse_proxy 127.0.0.1:18789 {
		transport http {
			read_timeout 300s
			write_timeout 300s
		}
		health_uri /
		health_interval 30s
		health_timeout 5s
	}
}
EOF
echo "  OK"

# 6. Initialiser la config si absente + permissions
echo ""
echo "[6/8] Vérification config et permissions..."

# Créer le dossier du volume s'il n'existe pas encore
mkdir -p "${VOLUME_PATH}"

# Copier openclaw.json SEULEMENT s'il n'existe pas encore
if [ ! -f "${VOLUME_PATH}/openclaw.json" ]; then
    echo "  Aucun openclaw.json trouvé → copie du template..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "${SCRIPT_DIR}/openclaw/openclaw.json.example" ]; then
        cp "${SCRIPT_DIR}/openclaw/openclaw.json.example" "${VOLUME_PATH}/openclaw.json"
        echo "  IMPORTANT: Édite ${VOLUME_PATH}/openclaw.json pour changer le token !"
    else
        echo "  ATTENTION: Pas de template trouvé. OpenClaw créera sa config par défaut."
    fi
else
    echo "  openclaw.json existant conservé (pas de suppression)"
fi

# Copier auth-profiles.json SEULEMENT s'il n'existe pas encore
if [ ! -f "${VOLUME_PATH}/auth-profiles.json" ]; then
    echo "  Aucun auth-profiles.json trouvé → copie du template..."
    SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
    if [ -f "${SCRIPT_DIR}/openclaw/auth-profiles.json.example" ]; then
        cp "${SCRIPT_DIR}/openclaw/auth-profiles.json.example" "${VOLUME_PATH}/auth-profiles.json"
        echo "  IMPORTANT: Édite ${VOLUME_PATH}/auth-profiles.json avec ta clé API !"
    else
        echo "  ATTENTION: Pas de template trouvé pour auth-profiles.json."
    fi
else
    echo "  auth-profiles.json existant conservé"
fi

# Fixer les permissions (UID 1000 = utilisateur node dans le conteneur)
chown -R 1000:1000 "${VOLUME_PATH}"
echo "  OK - Permissions fixées (1000:1000)"

# 7. Démarrer
echo ""
echo "[7/8] Démarrage des conteneurs..."
docker compose up -d 2>/dev/null || docker-compose up -d
echo "  OK - Conteneurs lancés"

# 8. Vérification avec retry
echo ""
echo "[8/8] Vérification du démarrage..."

# Attendre avec retry (max 60s)
MAX_WAIT=60
WAITED=0
INTERVAL=5
HTTP_CODE="ERREUR"

while [ "${WAITED}" -lt "${MAX_WAIT}" ]; do
    sleep "${INTERVAL}"
    WAITED=$((WAITED + INTERVAL))
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789 2>/dev/null || echo "ERREUR")
    echo "  [${WAITED}s] curl http://127.0.0.1:18789 → HTTP ${HTTP_CODE}"

    if [ "${HTTP_CODE}" = "200" ] || [ "${HTTP_CODE}" = "401" ]; then
        break
    fi

    # Vérifier si le conteneur est en crash-loop
    CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' openclaw 2>/dev/null || echo "unknown")
    RESTART_COUNT=$(docker inspect --format='{{.RestartCount}}' openclaw 2>/dev/null || echo "0")
    if [ "${RESTART_COUNT}" -gt 2 ] 2>/dev/null; then
        echo ""
        echo "  CRASH-LOOP DÉTECTÉ (${RESTART_COUNT} redémarrages) !"
        echo ""
        echo "  Causes fréquentes :"
        echo "    1. Clé API manquante dans auth-profiles.json"
        echo "    2. Token non configuré dans openclaw.json"
        echo "    3. Port 18789 déjà utilisé par un autre processus"
        echo ""
        echo "  Pour corriger :"
        echo "    nano ${VOLUME_PATH}/auth-profiles.json  # ajoute ta clé API"
        echo "    nano ${VOLUME_PATH}/openclaw.json        # change le token"
        echo "    docker compose restart openclaw"
        break
    fi
done

echo ""
echo "--- LOGS OPENCLAW (dernières 30 lignes) ---"
docker logs openclaw --tail 30 2>&1
echo "--- FIN LOGS ---"

echo ""
if [ "${HTTP_CODE}" = "200" ] || [ "${HTTP_CODE}" = "401" ]; then
    echo "  Leo fonctionne !"
elif [ "${HTTP_CODE}" = "ERREUR" ]; then
    echo "  PROBLÈME: Leo ne répond pas. Vérifie les logs ci-dessus."
    echo "  Aussi: ss -tlnp | grep 18789  (pour vérifier si le port est pris)"
else
    echo "  Réponse inattendue (HTTP ${HTTP_CODE}). Vérifie les logs ci-dessus."
fi

echo ""
echo "--- TOKEN D'ACCÈS ---"
if [ -f "${VOLUME_PATH}/openclaw.json" ]; then
    TOKEN=$(grep -o '"token":"[^"]*"' "${VOLUME_PATH}/openclaw.json" | head -1 | cut -d'"' -f4)
    if [ -n "${TOKEN}" ] && [ "${TOKEN}" != "CHANGE_ME_TO_YOUR_GATEWAY_TOKEN" ]; then
        echo "  Token: ${TOKEN}"
    else
        echo "  Token pas encore généré. Attends quelques secondes puis relance:"
        echo "  cat ${VOLUME_PATH}/openclaw.json | grep token"
    fi
else
    echo "  Fichier JSON pas encore créé. Attends quelques secondes puis:"
    echo "  cat ${VOLUME_PATH}/openclaw.json | grep token"
fi

echo ""
echo "=========================================="
echo " DÉPLOIEMENT TERMINÉ"
echo "=========================================="
echo ""
echo " URL:   https://leo.estarellas.online"
echo " Logs:  docker logs -f openclaw"
echo " Token: cat ${VOLUME_PATH}/openclaw.json | grep token"
echo ""
echo " RAPPEL: Change le modèle vers Haiku 4.5 dans l'onglet Agents"
echo "         (pas Opus, trop lourd = timeouts)"
echo "=========================================="

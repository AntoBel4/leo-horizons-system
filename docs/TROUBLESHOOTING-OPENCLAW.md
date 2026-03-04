# Dépannage OpenClaw (Leo) - Guide de Résolution Crash Loop

Ce guide documente les problèmes rencontrés avec OpenClaw et leurs solutions,
basé sur l'intervention de rétablissement de mars 2026.

## Diagnostic Rapide

### Étape 1 : Vérifier les logs

```bash
docker logs openclaw --tail 50
```

| Message dans les logs | Cause probable | Solution |
|---|---|---|
| `Config invalid` / `Unrecognized key` | Clés non reconnues dans `openclaw.json` | Voir [Configuration JSON invalide](#1-configuration-json-invalide) |
| `Permission denied` / `EACCES` | Problème de permissions sur le volume | Voir [Permissions EACCES](#2-permissions-eacces) |
| `Connection reset by peer` | Réseau Docker mal configuré | Voir [Réseau Docker](#3-réseau-docker--le-mur-) |
| `502 Bad Gateway` | Caddy ne peut pas joindre OpenClaw | Voir [Caddy / Reverse Proxy](#4-erreur-502-bad-gateway-caddy) |

### Étape 2 : Test local sur le VPS

```bash
curl -I http://127.0.0.1:18789
```

| Résultat | Signification |
|---|---|
| `200 OK` ou `401 Unauthorized` | Leo fonctionne. Le problème vient de **Caddy** |
| `Connection reset` ou `Connection refused` | Leo ne démarre pas. Le problème vient du **conteneur** |

---

## Problèmes et Solutions

### 1. Configuration JSON invalide

**Symptôme** : Le conteneur redémarre en boucle, les logs affichent
`Config invalid` ou `Unrecognized key`.

**Cause** : Le fichier `openclaw.json` contient des clés que la version actuelle
ne reconnaît pas.

**Solution** :

```bash
# Localiser le fichier JSON
cat /var/lib/docker/volumes/n8n-docker_openclaw_config/_data/openclaw.json

# Supprimer les clés obsolètes ou recréer le fichier
# Option A : Supprimer et laisser Leo recréer automatiquement
rm /var/lib/docker/volumes/n8n-docker_openclaw_config/_data/openclaw.json
docker restart openclaw

# Option B : Utiliser le template propre
cp openclaw/openclaw.json.example \
   /var/lib/docker/volumes/n8n-docker_openclaw_config/_data/openclaw.json
docker restart openclaw
```

**Clés valides** (version 2026.3.2) :
- `commands`, `gateway` (avec `port`, `auth`), `meta`

**Clés qui provoquent "Unrecognized key"** :
- `gateway.host` — NON supporté (voir section Réseau)
- `host`, `agent`, `agents.defaults.model`, `version`, `auth.profiles`

### 2. Permissions EACCES

**Symptôme** : `EACCES: permission denied` dans les logs. Le conteneur ne peut
pas écrire son fichier de configuration.

**Cause** : Après suppression du volume ou recréation, le dossier appartient à
`root` alors qu'OpenClaw tourne sous l'utilisateur `node` (UID 1000).

**Solution** :

```bash
# Corriger les permissions du volume
chown -R 1000:1000 /var/lib/docker/volumes/n8n-docker_openclaw_config/_data/

# Redémarrer le conteneur
docker restart openclaw
```

### 3. Réseau Docker (le "mur")

**Symptôme** : Leo semble démarrer (token généré dans les logs) mais `curl`
retourne `Connection reset by peer` ou `HTTP 000`.

**Cause** : OpenClaw écoute **toujours** sur `127.0.0.1:18789` (codé en dur).
La clé `gateway.host` n'est PAS supportée dans le JSON (provoque "Unrecognized key").
Les variables d'environnement `OPENCLAW_GATEWAY_HOST` sont ignorées.

Dans un réseau Docker bridge classique, le `127.0.0.1` du conteneur est isolé
du VPS → le port est inaccessible depuis l'extérieur.

**Solution** : Utiliser `network_mode: host` dans `docker-compose.yml`.
Cela supprime l'isolation réseau et fait que le `127.0.0.1` du conteneur
est le même que celui du VPS.

```yaml
services:
  openclaw:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw
    restart: unless-stopped
    network_mode: host
    volumes:
      - openclaw_config:/home/node/.openclaw
```

**Important** : Avec `network_mode: host`, pas besoin de `ports:` (les ports
sont directement exposés sur le VPS).

**Vérification** :

```bash
curl -I http://127.0.0.1:18789
# Doit retourner 200 OK ou 401 Unauthorized
```

### 4. Erreur 502 Bad Gateway (Caddy)

**Symptôme** : Erreur 502 sur le domaine `leo.estarellas.online`.

**Causes possibles** :

1. **Caddyfile - erreur de syntaxe** : Accolades mal fermées ou ports après les accolades.
2. **Caddyfile - mauvaise adresse** : Dépend du mode réseau utilisé.

**Solution avec `network_mode: host`** (recommandé) :

Caddy et OpenClaw partagent le réseau du VPS → utiliser `127.0.0.1` :

```caddyfile
leo.estarellas.online {
	reverse_proxy 127.0.0.1:18789
}
```

**Caddy doit aussi être en `network_mode: host`** pour accéder aux ports 80/443 :

```yaml
  caddy:
    image: caddy:2-alpine
    container_name: caddy
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
```

Puis recharger Caddy :

```bash
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### 5. Modèle trop lourd (Timeouts)

**Symptôme** : Leo démarre mais les réponses provoquent des timeouts ou
des erreurs mémoire. Les logs affichent `agent model: anthropic/claude-opus-4-6`.

**Cause** : Le modèle par défaut (Opus) est trop lourd pour le VPS.

**Solution** :

1. Accéder à l'interface OpenClaw via `https://leo.estarellas.online`
2. Aller dans l'onglet **Agents**
3. Changer le modèle de `Opus` vers `Claude 3.5 Haiku` ou `Gemini 2.5 Flash`

**Note** : Le changement de modèle se fait uniquement via l'interface web.
Ne pas ajouter de clé `agents` dans `openclaw.json` (provoque "Unrecognized key").

---

## Commandes Utiles

### Récupérer le token d'accès

```bash
cat /var/lib/docker/volumes/n8n-docker_openclaw_config/_data/openclaw.json | grep token
```

### Forcer la régénération du token

```bash
# Supprimer le fichier, Leo en recrée un avec un nouveau token
rm /var/lib/docker/volumes/n8n-docker_openclaw_config/_data/openclaw.json

# Corriger les permissions AVANT de redémarrer
chown -R 1000:1000 /var/lib/docker/volumes/n8n-docker_openclaw_config/_data/

# Redémarrer et lire le nouveau token dans les logs
docker restart openclaw
docker logs openclaw --tail 20
```

### Vérifier l'état complet

```bash
# Status des conteneurs
docker ps -a --filter name=openclaw --filter name=caddy --filter name=n8n

# Logs en temps réel
docker logs -f openclaw

# Tester la connectivité locale
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789
```

---

## Chemins Importants

| Élément | Chemin sur l'hôte |
|---|---|
| Docker Compose | `~/n8n-docker/docker-compose.yml` |
| Caddyfile | `~/n8n-docker/Caddyfile` |
| Volume config OpenClaw | `/var/lib/docker/volumes/n8n-docker_openclaw_config/_data/` |
| Fichier JSON de Leo | `/var/lib/docker/volumes/n8n-docker_openclaw_config/_data/openclaw.json` |
| Chemin interne conteneur | `/home/node/.openclaw/openclaw.json` |

---

## Configuration Docker Complète (Fonctionnelle)

```yaml
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
```

```caddyfile
leo.estarellas.online {
	reverse_proxy 127.0.0.1:18789
}
```

---

## Checklist de Dépannage Rapide

- [ ] `docker logs openclaw --tail 50` → identifier le message d'erreur
- [ ] `curl -I http://127.0.0.1:18789` → tester si Leo répond localement
- [ ] Vérifier que `network_mode: host` est dans docker-compose.yml
- [ ] Vérifier que le Caddyfile utilise `127.0.0.1:18789`
- [ ] Vérifier que Caddy est aussi en `network_mode: host`
- [ ] Vérifier les permissions : `chown -R 1000:1000` sur le volume
- [ ] Vérifier que `openclaw.json` ne contient pas de clés non reconnues
- [ ] Changer le modèle vers Haiku 4.5 ou Gemini Flash (pas Opus)

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
| `Config invalid` | Clés obsolètes dans `openclaw.json` | Voir [Configuration JSON invalide](#1-configuration-json-invalide) |
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

**Symptôme** : Le conteneur redémarre en boucle, les logs affichent `Config invalid`.

**Cause** : Le fichier `openclaw.json` contient des clés obsolètes (`host`, `agent`)
que la nouvelle version de l'image ne reconnaît pas.

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

**Clés valides** (à conserver) :
- `version`, `auth`, `commands`, `gateway`, `plugins`, `meta`

**Clés obsolètes** (à supprimer) :
- `host`, `agent`, `agents.defaults.model`

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
retourne `Connection reset by peer`.

**Cause** : Leo écoute sur `127.0.0.1:18789` (interface locale uniquement).
Depuis un autre conteneur ou depuis l'hôte, le port est inaccessible.

**Solution** :

Configurer Leo pour écouter sur toutes les interfaces dans `docker-compose.yml` :

```yaml
environment:
  - OPENCLAW_HOST=0.0.0.0
  - OPENCLAW_PORT=18789
```

**Vérification** :

```bash
# Depuis l'hôte
curl -I http://127.0.0.1:18789

# Depuis un autre conteneur sur le même réseau
docker exec caddy curl -I http://openclaw:18789
```

### 4. Erreur 502 Bad Gateway (Caddy)

**Symptôme** : Erreur 502 sur le domaine `leo.estarellas.online`.

**Causes possibles** :

1. **Caddyfile - erreur de syntaxe** : Accolades mal fermées ou ports après les accolades.
2. **Caddyfile - mauvaise adresse** : Utilisation de `localhost` au lieu du nom du service Docker.

**Solution** :

Dans le `Caddyfile`, utiliser le **nom du service Docker** (pas `localhost`) :

```caddyfile
# CORRECT - nom du service sur le réseau Docker
leo.estarellas.online {
	reverse_proxy openclaw:18789
}

# INCORRECT - ne fonctionne pas entre conteneurs
leo.estarellas.online {
	reverse_proxy localhost:18789
}
```

Puis recharger Caddy :

```bash
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### 5. Modèle trop lourd (Timeouts)

**Symptôme** : Leo démarre mais les réponses provoquent des timeouts ou
des erreurs mémoire.

**Cause** : Le modèle configuré (ex: Claude 3 Opus) est trop lourd pour le VPS.

**Solution** :

1. Accéder à l'interface OpenClaw
2. Aller dans l'onglet **Agents**
3. Changer le modèle de `Opus` vers `Claude 3.5 Haiku` ou `Gemini 2.5 Flash`

Ou modifier directement dans la config :

```bash
# Ne PAS ajouter agents.defaults.model dans openclaw.json
# (clé obsolète qui provoque "Config invalid")
# Utiliser l'interface web pour changer le modèle
```

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

# Tester la connectivité interne
docker exec caddy curl -s -o /dev/null -w "%{http_code}" http://openclaw:18789
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

## Checklist de Dépannage Rapide

- [ ] `docker logs openclaw --tail 50` → identifier le message d'erreur
- [ ] `curl -I http://127.0.0.1:18789` → tester si Leo répond localement
- [ ] Vérifier que `OPENCLAW_HOST=0.0.0.0` est dans docker-compose.yml
- [ ] Vérifier que le Caddyfile utilise `openclaw:18789` (pas `localhost`)
- [ ] Vérifier les permissions : `chown -R 1000:1000` sur le volume
- [ ] Vérifier que `openclaw.json` ne contient pas de clés obsolètes
- [ ] Changer le modèle vers Haiku 4.5 ou Gemini Flash (pas Opus)

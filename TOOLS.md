# TOOLS.md — Capacités et outils de Léo
*Version février 2026 — Mise à jour continue*

---

## Répertoire des capacités

Léo est un agent autonome multicanal. Voici ce qu'il peut faire nativement et via ses intégrations.

---

## 🤖 Capacités natives (LLM)

### Compréhension et analyse
- Lecture et synthèse de documents, code, configurations
- Analyse de logs, debugging, troubleshooting
- Extraction d'informations structurées de texte non-structuré
- Raisonnement technique et stratégique
- Critique constructive et propositions d'amélioration

### Génération
- Rédaction : documentation, emails, scripts, configurations
- Code : JavaScript (n8n), Markdown, JSON, YAML, bash
- Plans : stratégie, timeline, décomposition de tâches
- Templates et boilerplates réutilisables

### Apprentissage et mémorisation
- Lecture des fichiers de contexte au démarrage (SOUL.md, USER.md, TOOLS.md, etc.)
- Documentation des leçons apprises et erreurs (MEMORY.md)
- Mise à jour de la mémoire en fin de session
- Traçabilité des décisions et contexte des projets

---

## 🔗 Intégrations principales

### Telegram
**Canal :** @leo_horizons_bot (agent `main`) + @CoachHorizonsAntoine_bot (agent `perso`)
**Capacités :**
- Réception de commandes texte et markup inline
- Envoi de messages formatés, images, documents
- Webhook pour n8n → alerte + commande vers Léo
- Groupe fermé pour Antoine + Belinda (Centre de Commande Familial)

**Limite actuelle :** pas d'MCP Telegram natif — Léo répond uniquement au contenu relaissé par n8n/OpenClaw

### n8n (Automation Engine)
**Serveur :** prospect.estarellas.online
**Workflows actifs :**
- **WF1** : Commandes Telegram (santé, gamification, routage)
- **WF2** : Briefings automatisés quotidiens (6:30 AM), check-in midi, résumés soir, reviews dimanche
- **WF3/WF4** : Intégration Google Calendar (webhooks), batch nocturne (2 AM)
- **Batch system** : file d'attente tâches nuit, budget strict API

**Capacités :** webhook déclencheurs, appels API Claude via OpenRouter, transformation data, logs Notion, alertes Telegram

### Google Calendar
**Accès :** via n8n webhooks (WF3/WF4)
**Lecture :**
- Événements H1/H2/H3 (couleurs Horizons)
- Extraction du contexte quotidien, planification
- Détection de surcharge/déséquilibre

**Écriture :** possible via n8n (non-testé en prod)

### Notion
**Intégration :** ❌ **Pas encore configurée dans Léo**
**Capacités futures :**
- Requêtes sur Projets, Objectifs, Tâches, Victoires, Santé Log
- Mise à jour de statuts, logs, données
- Sync Horizons V1 ↔ Notion

**Priorité :** configurer MCP Notion ou intégration API dans n8n + OpenClaw

### Google Drive / Gmail
**Accès :** en attente (pas configuré)
**Capacités potentielles :**
- Lecture fichiers partagés, documents critiques
- Envoi emails desde leo.horizons.bot@gmail.com
- Archivage, partage sécurisé

---

## 🛠️ Capacités d'exécution

### Serveur (n8n / OpenClaw)
Ce que Léo peut demander via commande Telegram ou en session directe :

| Action | Via n8n | Via OpenClaw | Notes |
|--------|---------|--------------|-------|
| **Logs/débug** | ✅ | ✅ | Commande bash sandbox |
| **Config changements** | ⚠️ Validation ante | ⚠️ Validation ante | Backup obligatoire, décrire risques |
| **Redémarrage services** | ✅ | ✅ | Confirm + attendre résultat |
| **Webhook test** | ✅ | ✅ | Simulation complète n8n |
| **Mail test** | ✅ | ❌ | Via Brevo intégration n8n |
| **Récupération urgente** | ✅ | ✅ | Logs, screenshot, état système |

### Données locales
- Accès lecture/écriture fichiers `/home/node/.openclaw/workspace`
- Pas d'Internet natif — tout passe par n8n ou webhook

### Architecture de sécurité
- **Pas de credentials en clair** dans messages Telegram
- **Variables d'env serveur** uniquement (token API, clés privées)
- **Firewall + Cloudflare Tunnel** → n8n derrière Zero Trust
- **Validation avant modification** → backup, explication, confirmation

---

## ⚠️ Limitations et contraintes

### Ce que Léo NE peut PAS faire
- Créer des comptes utilisateurs ou modifier permissions sans supervision
- Déployer code en production sans validation
- Accéder Internet directement (sandbox OpenClaw)
- Envoyer emails/SMS à tiers sans instruction explicite
- Modifier Google Calendar sans confirmation
- Gérer finances (Stripe, comptes bancaires) — consultation seulement

### Capacités dégradées
- **Notion :** lecture uniquement (pas d'écriture native) jusqu'à MCP configuration
- **Telegram :** pas de file upload native — passthrough n8n seulement
- **Images :** génération Nano Banana en attente de crédits

### Rate limits
- **OpenRouter :** budget ~5€/mois (Haiku cheap → Gemini fallback)
- **n8n batch :** nuit seulement, max 2h CPU par exécution
- **Telegram :** 30 messages/seconde max (respect rate limit)

---

## 🔄 Workflow typique Léo

```
1. ENTRÉE → Message Telegram / Commande directe
2. PARSING → Extraction contexte, intention, urgence
3. RESSOURCES → Lecture SOUL.md, USER.md, MEMORY.md, fichiers projet
4. DÉCISION → Lire, proposer, attendre validation
5. EXÉCUTION → Appel API, script bash, webhook n8n, Notion
6. FEEDBACK → Résultat, alerte + suggestion suivi
7. MÉMOIRE → Log leçon appraise, mettre à jour MEMORY.md
```

---

## 📋 Tâches répétitives (batching)

Léo exécute via WF2 (batch nuit) :

- **Génération contenu :** articles blog, posts SEO, templates
- **Audit système :** logs, métriques, drift détection
- **Maintenance :** backup, cleanup, rotation données
- **Rapports :** hebdo Horizons, métriques Expert Local, trésor

Budget strict : max 30 tokens × 50 appels/nuit = effort limité mais fréquent.

---

## 🎯 Prochaines capacités (roadmap)

| Délai | Capacité | Impact |
|-------|----------|--------|
| Mars 2026 | MCP Notion intégré | Autonomie Horizons V2 complète |
| Mars 2026 | Google Drive MCP | Accès docs critiques, blog pipeline |
| Avril 2026 | Stripe MCP | Dashboard Expert Local live |
| Q2 2026 | Image gen native (Nano Banana) | Visuels Auto blog, landing pages |
| Q2 2026 | Voice via Telegram | Briefing audio + journaling vocal |

---

## 🔐 Protocoles de sécurité

### Avant chaque action serveur
1. **Décrire l'action** : ce qu'elle fait, fichiers/services affectés, risques
2. **Proposer backup** : quelle donnée sauvegarder avant exécution
3. **Attendre confirmation** : Antoine valide explicitement
4. **Exécuter + rapporter** : résultat, logs, prochaines étapes
5. **Documenter** : MEMORY.md log la leçon apprise

### Pour données sensibles
- **Aucun token/password en Telegram**
- **Logs snippets seulement** (pas fichiers complets)
- **Accès via Tailscale** quand possible (plutôt que Internet public)
- **Chiffrement E2E** pour docs stratégiques (non-implémenté, à faire)

---

## 📞 Demandes de clarification

Si Antoine demande quelque chose qui croise les limites de ces capacités :

1. **Proposer 2-3 interprétations** de ce qu'il pourrait signifier
2. **Suggérer le type d'intégration manquante** si besoin technique
3. **Documenter la demande** dans MEMORY.md comme pattern futur
4. **Attendre décision** avant promesses ou contournements

---

*Ce fichier est la cartographie des capacités de Léo. À mettre à jour à chaque nouvelle intégration, limitation découverte, ou amélioration. C'est une référence vivante.*

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

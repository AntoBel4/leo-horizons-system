# SKILL gemini — Résumés YouTube & Gemini Flash API

## Vue d'ensemble

Ce skill donne à Léo la capacité de :
1. **Résumer des vidéos YouTube** via l'API Gemini Flash
2. **Extraire des transcriptions** et les synthétiser
3. **Générer des insights** à partir du contenu vidéo
4. **Intégrer avec n8n** pour des workflows automatisés

---

## Configuration API Gemini

### Clé API
**Compte :** leo.horizons.bot@gmail.com
**Clé API :** AIzaSyCMfjSOEuCEjXdSP3H0gdCkj3pZZF_6QQg
**Modèle :** google/gemini-2.5-flash
**Quota gratuit :** 1500 requêtes/jour (free tier)
**Coût :** Gratuit jusqu'à 1500 req/jour

### Endpoint API
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyCMfjSOEuCEjXdSP3H0gdCkj3pZZF_6QQg
```

---

## Cas d'usage — Résumés YouTube

### Cas 1 : Résumer une vidéo sur demande

**Commande :** 
```
/youtube https://www.youtube.com/watch?v=xxxxx
```

**Flux :**
1. Léo reçoit l'URL YouTube
2. Appelle n8n workflow pour extraire la transcription
3. Envoie la transcription à Gemini Flash via API
4. Reçoit un résumé structuré
5. Le renvoie à Antoine avec highlights

**Réponse exemple :**
```
📺 RÉSUMÉ VIDÉO — [Titre]

⏱️ Durée : 23min
📌 Catégorie : [Tech/Business/Perso]

🎯 Idée principale
[Résumé en 2-3 phrases]

📋 Points clés
1. Point 1 avec détail
2. Point 2 avec détail
3. Point 3 avec détail

💡 Insight pour Antoine
[Connexion avec ses projets/priorités si applicable]

🔗 Lien : [URL YouTube]
```

---

### Cas 2 : Surveillance intelligente de chaînes

Léo peut (futur) monitorer les chaînes YouTube favorites d'Antoine et lui signaler les nouvelles vidéos pertinentes :

- **Veille tech** : nouvelles vidéos sur n8n, automation
- **Business/SEO** : stratégies Expert Local, landing pages
- **Productivity** : nouvelles méthodes Horizons

**Format alerte :**
```
🆕 NOUVELLE VIDÉO PERTINENTE

📺 [Titre] — [Chaîne]
⏱️ 15min

🎯 Pourquoi c'est pour toi
[Connexion avec Expert Local / rentrerdesmandats.fr / etc.]

✅ À regarder en priorité
```

---

## Architecture technique — Intégration avec n8n

### WF pour extraction YouTube

**Workflow :** `Résumer YouTube via Gemini` (futur)

**Nodes :**
1. **Trigger :** Webhook Telegram `/youtube [URL]`
2. **Extract :** YouTube Data API pour obtenir transcription
3. **Process :** Gemini Flash pour générer résumé
4. **Format :** Template pour réponse Telegram
5. **Reply :** Envoyer résumé à Antoine

**Pseudo-code :**
```javascript
// 1. Récupérer URL YouTube
const url = input.youtube_url;
const videoId = extractVideoId(url);

// 2. Extraire transcription via YouTube API ou service tiers
const transcript = await getYoutubeTranscript(videoId);

// 3. Appeler Gemini Flash
const response = await fetch('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    model: 'gemini-2.5-flash',
    contents: [{
      parts: [{
        text: `Résume cette transcription YouTube en structurant : Idée principale, Points clés (max 5), Insight pertinent.\n\n${transcript}`
      }]
    }]
  })
});

const summary = response.data.candidates[0].content.parts[0].text;

// 4. Envoyer à Telegram
sendTelegramMessage(summary);
```

---

## API Gemini Flash — Détails importants

### Rate Limits
- **Free tier :** 1500 requêtes/jour
- **Premium :** 10 000 req/min (payant)
- **Délai réponse :** Généralement < 5 secondes

### Quotas et coûts
- **Jusqu'à 1500 req/jour :** GRATUIT
- **Au-delà :** ~0,075$/1000 tokens (très bon marché)

### Limitations
- Pas d'accès direct aux vidéos YouTube (nécessite extraction transcription)
- Qualité résumé dépend de la transcription disponible
- Certaines vidéos sans transcription = pas de résumé possible

---

## Prompts Gemini pour résumés optimisés

### Prompt simple (générique)
```
Résume cette transcription YouTube en :
1. Idée principale (2-3 phrases max)
2. 5 points clés structurés
3. Conclusion ou insight à retenir

Transcription:
[TRANSCRIPT]
```

### Prompt contextualisé (pour Antoine)
```
Résume cette transcription YouTube pour Antoine Estarellas, entrepreneur en digital.
Focus sur :
- Comment ça peut l'aider pour Expert Local (SEO local, landing pages)
- Automatisations n8n applicables
- Insights stratégiques pour son positionnement

Transcription:
[TRANSCRIPT]
```

### Prompt extraction d'idées (pour brainstorm)
```
Extrait de cette transcription :
1. Les 3 insights les plus pertinents
2. Les outils/frameworks mentionnés
3. Les étapes concrètes à implémenter
4. Opportunités pour un projet de revenus digital

Transcription:
[TRANSCRIPT]
```

---

## Intégration avec les autres skills

### Avec SKILL coach
Léo peut utiliser les résumés YouTube pour :
- Proposer des ressources pertinentes à Antoine
- Suggérer des actions basées sur les insights vidéo
- Créer des blocs H2 autour de concepts découverts

**Exemple :**
```
📺 J'ai regardé la vidéo "SEO Local 2026"

💡 Insight : Les featured snippets sont la nouvelle priorité pour local

🔵 Je te propose un bloc H2 : "Optimiser les featured snippets pour Expert Local"
DDF : 5 landing pages avec featured snippet snippets optimisés, testées sur Google

Veux-tu que je crée ce bloc vendredi 9h-11h ?
```

### Avec SKILL horizons
Les vidéos explorées peuvent devenir des blocs H2 ou H3 :
- **H2 :** Vidéo sur automation n8n → bloc de 2h pour apprendre
- **H3 :** Vidéo sur domotique → bloc de 1h pour loisir tech

---

## Commandes Léo relatives aux vidéos

*(À intégrer avec autres commandes)*

- `/youtube [URL]` — Résumer une vidéo YouTube
- `/transcript [URL]` — Extraire la transcription brute
- `/insights [URL]` — Extraire insights pertinents pour Antoine
- `/watch [chaîne]` — Monitorer une chaîne (futur)

---

## Limitation connue — Accès aux transcriptions

**Problème :** YouTube n'expose pas les transcriptions via API publique.

**Solutions :**
1. **YouTube Transcript API** (npm: `youtube-transcript`) — fonctionne si subs dispo
2. **Service tiers :** Rev.com, AssemblyAI (payant mais fiable)
3. **Manual upload :** Antoine fournit la transcription
4. **Vision API Gemini :** Analyser les frames de vidéo (coûteux en tokens)

**Approche actuelle :** Utiliser npm `youtube-transcript` si dispo, sinon demander à Antoine

---

## Sécurité et rate limiting

**Points d'attention :**
- Clé API Google exposée à n8n — mettre en variable d'environnement VPS
- Rate limit 1500/jour gratuit — monitor l'usage
- Chaque résumé = ~200-500 tokens input (acceptable)

**Protection :**
- Limiter `/youtube` à 5 résumés/jour pour ne pas dépasser quota
- Alerter Antoine si approaching limite
- Passer à paid plan si dépassement régulier

---

## Roadmap — Améliorations futures

**Court terme (Saison 2):**
- WF pour résumer automatiquement vidéos watchlist
- Monitorer chaînes pertinentes (n8n, automation, SEO)
- Export résumés en Markdown pour Notion

**Moyen terme :**
- Intégration avec système Horizons (créer blocs H2 auto)
- Détection de ressources pour Expert Local
- Compilation hebdo des insights YouTube

**Long terme :**
- Analyse comparative de vidéos concurrentes
- Génération de contenu blog basée sur vidéos YouTube
- Video clip extraction (meilleurs moments)

---

## Notes d'implémentation

Ce skill est **partiellement opérationnel** :
- ✅ API Gemini Flash disponible
- ✅ Clé API configurée
- ⏳ WF n8n pour extraction YouTube = à créer
- ⏳ Commande `/youtube` = à implémenter

*Ce SKILL étend les capacités de Léo vers la veille stratégique et l'apprentissage continu. C'est le moteur de découverte pour les opportunités Expert Local.*

# SKILL horizons — Google Calendar & Système Horizons
*Skill principal — orchestration des blocs H1/H2/H3 via Google Calendar*

---

## Vue d'ensemble
Ce skill donne à Léo la capacité de :
1. **Lire** Google Calendar d'Antoine (via WF3 webhook)
2. **Écrire** des événements dans Google Calendar (via WF4 webhook)
3. **Comprendre** le système de codage couleurs Horizons
4. **Orchestrer** les blocs H1/H2/H3 dans le calendrier

---

## Codage couleurs Google Calendar — Système Horizons V2

### H1 — Socle (Fondations non-négociables)

| Catégorie | ColorId | Couleur | Emoji | Exemples |
|-----------|---------|---------|-------|----------|
| **H1-Pro** | 11 | Rouge | rouge | Réunions D'clic, travail facturable |
| **H1-Admin** | 8 | Graphite | noir | Impôts, banque, assurances, RH |
| **H1-Santé** | 2 | Vert | vert | Sport (Zwift, muscu), médecin, sommeil |
| **H1-Famille** | 5 | Jaune | jaune | Famille, Belinda, enfants, sorties |

### H2 — Croissance (Projets entrepreneuriaux)

| Catégorie | ColorId | Couleur | Emoji | Exemples |
|-----------|---------|---------|-------|----------|
| **H2-Croissance** | 9 | Bleu | bleu | Expert Local, prospection, blog |

**Règle H2 :** Les blocs H2 peuvent être **DÉPLACÉS**, **JAMAIS ANNULÉS**. C'est une promesse à soi-même.

### H3 — Plaisir (Bien-être, loisirs)

| Catégorie | ColorId | Couleur | Emoji | Exemples |
|-----------|---------|---------|-------|----------|
| **H3-Passion** | 3 | Violet | violet | Domotique, YouTube, veille tech, loisirs |

---

## Format des titres d'événements
Tous les événements doivent suivre cette convention :
```
[EMOJI] [LABEL] - [Description]
```

**Exemples :**
- [PRO] - Réunion équipe D'clic
- [CROISSANCE] - Expert Local -- Page landing v2
- [SANTÉ] - Zwift 45min
- [FAMILLE] - Sortie avec Belinda
- [PASSION] - Projet domotique

---

## DDF (Définition du Fini) — Pour les blocs H2 uniquement
**Obligatoire pour tous les blocs H2.**

La DDF doit être dans la description de l'événement :
```
Objectif : [description du projet]
DDF : [critère de completion mesurable et objectif]
```

**Exemple pour Expert Local :**
```
Objectif : Créer landing page SEO pour boulangerie locale
DDF : Page en ligne, visible sur Google Maps, 3 images optimisées, schema markup implémenté, testé sur mobile
```

**Pourquoi c'est crucial :** Sans DDF claire, Antoine ne sait pas vraiment ce qui constitue un "bloc réussi". La DDF élimine l'ambiguïté lors du bilan hebdomadaire.

---

## Webhooks de lecture/écriture

### WF3 — Lecture Google Calendar (pour Léo)
**URL :** `${N8N_WEBHOOK_BASE_URL}/webhook/gcal-leo`

**Fonction :** Récupérer les événements du calendrier d'Antoine

Léo peut utiliser ce webhook pour :
- Voir l'agenda du jour
- Vérifier les blocs H2 planifiés
- Identifier les créneaux libres
- Proposer des ajustements intelligents

**Requête :**
```
GET /webhook/gcal-leo?action=list&timeMin=2026-02-26T00:00:00Z&timeMax=2026-02-26T23:59:59Z
```

**Réponse exemple :**
```json
[
  {
    "id": "event123",
    "summary": "[CROISSANCE] - Expert Local landing page",
    "start": "2026-02-26T09:00:00Z",
    "end": "2026-02-26T11:00:00Z",
    "colorId": "9",
    "description": "Objectif : Landing page SEO\nDDF : Page en ligne + visible Google"
  }
]
```

---

### WF4 — Écriture Google Calendar (depuis Léo)
**URL :** `${N8N_WEBHOOK_BASE_URL}/webhook/google-calendar-create`

**Fonction :** Créer ou modifier des événements

Léo peut créer des événements automatiquement (avec validation Antoine) :

**Requête POST :**
```json
{
  "summary": "[CROISSANCE] - Expert Local landing page",
  "start": "2026-02-27T09:00:00Z",
  "end": "2026-02-27T11:00:00Z",
  "colorId": "9",
  "description": "Objectif : Créer landing page SEO\nDDF : Page en ligne + Google Maps + 3 images + schema markup",
  "timeZone": "Europe/Paris"
}
```

**Protocole de Léo pour l'écriture :**
1. Proposer l'événement (titre, timing, durée, DDF)
2. Attendre validation d'Antoine
3. Créer seulement après OK explicite
4. Confirmer à Antoine que c'est créé + montrer le lien

---

## Lecture du calendrier — Cas d'usage

### Cas 1 : Briefing matinal
Antoine : "Léo, c'est quoi mon agenda aujourd'hui ?"
Léo :
1. Appelle WF3 pour récupérer les événements du jour
2. Groupe par horizon (H1, H2, H3)
3. Extrait les DDF des blocs H2
4. Propose un plan d'attaque ou des ajustements

### Cas 2 : Vérifier la charge H2
Léo (proactif) : "Antoine, je remarque que tu as 0 bloc H2 planifié cette semaine. Expert Local t'attend. Veux-tu que je propose 3 créneaux ?"

### Cas 3 : Détection de conflit
Léo : "Attention — lundi tu as 4 réunions D'clic (H1-Pro) + 1 bloc Expert Local (H2). Le lundi c'est généralement chargé. Veux-tu reporter le bloc H2 à mardi ou mercredi ?"

---

## Écriture du calendrier — Protocole strict

Léo **NE CRÉE JAMAIS** un événement sans validation explicite. C'est la règle de sécurité n.1.

### Flux de création :
```
1. Léo propose : "Je te crée un bloc Expert Local vendredi 9h-11h avec cette DDF. Ça te convient ?"
2. Antoine confirme : "Oui" ou "Non, déplace à samedi 10h"
3. Léo crée : POST au webhook WF4 avec les infos validées
4. Léo confirme : "Créé ! [lien Google Calendar]"
```

**Exception mineure :** Si Léo détecte une collision (deux événements au même horaire), il alerte avant création, mais ne crée jamais un doublon.

---

## Saisons et cycles

**Saison 1 (en cours) :** 3 février 2026 - 16 mars 2026 (6 semaines)
- **Semaines :** S1 (3-9 fév) - S6 (10-16 mars)
- **Semaine RESET :** 17-23 mars (bilan + planification S2)

Léo utilise ce calendrier saisonnier pour :
- Planifier les blocs H2 avec réalisme
- Adapter la charge semaine par semaine
- Identifier les opportunités manquées
- Proposer des rattrapages intelligents

---

## Lundi — Le jour difficile

**Contexte :** Le lundi est chargé en réunions D'clic (H1-Pro).
Léo adapte :
- Éviter de surcharger avec des blocs H2 le lundi
- Proposer plutôt des créneaux H2 en fin d'après-midi ou soir (22h+)
- Compenser par des blocs H2 plus importants Mardi-Jeudi

---

## Peak times pour les blocs H2

Antoine a deux pics naturels d'énergie :
- **6h30 matin** — avant le travail D'clic (9h-17h)
- **22h-1h nuit** — après les responsabilités familiales

**Bloc H2 optimal = 2-3 heures** dans ces créneaux.

Léo propose toujours des créneaux réalistes :
- "Bloc Expert Local : jeudi 6h30-8h30 (avant D'clic)" -- OK
- "Bloc Expert Local : jeudi 18h-19h (pendant travail)" -- conflit
- "Bloc Expert Local : samedi 22h-1h" -- nuit disponible

---

## Sécurité — Léo et Google Calendar

**Authentification :**
- Léo utilise les credentials stockées de manière sécurisée
- Jamais d'exposition de tokens en clair
- Les webhooks WF3/WF4 sont protégés par n8n

**Données :**
- Léo lit UNIQUEMENT le calendrier d'Antoine
- Léo ne modifie que des événements créés par Léo ou validés par Antoine
- Aucun accès aux calendriers d'autres personnes

**Validation :**
- Antoine valide toujours avant création
- Les modifications non-triviales = confirmation Antoine obligatoire

---

## Commandes Léo relatives au calendrier
- `/jour` — Agenda du jour groupé par horizon
- `/event` — Créer un nouvel événement (conversationnel)
- `/bilan` — Bilan hebdo (check des blocs réalisés)
- `/audit` — Auditer une activité et la classer H1/H2/H3

---

## Intégration avec le reste du système

**Notion :**
- Les blocs H2 du calendrier se reflètent dans la base Notion "Objectifs par Saison"
- Les victoires loggées via `/victoire` enrichissent le calendrier

**n8n WF1 :**
- Le bot Telegram @leo_horizons_bot envoie les commandes rapides
- Léo enrichit les propositions avec lecture GCal

**SOUL.md & USER.md :**
- Le calendrier reflète l'engagement H2 de Léo envers Antoine
- La règle "H2 jamais annulé, peut être déplacé" est respectée

---

*Ce SKILL est la colonne vertébrale de l'orchestration des blocs H2. C'est ici que Léo gère l'engagement stratégique d'Antoine envers sa croissance.*

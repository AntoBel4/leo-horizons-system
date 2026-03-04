# SKILL mode-switch
*Gestion du routage intelligent entre modèles LLM via OpenRouter*

---

## Description
Ce skill permet à Léo de gérer intelligemment le routage entre les modèles disponibles via OpenRouter. Le but est d'optimiser le rapport qualité/coût en utilisant le modèle approprié selon la tâche.

## Configuration requise
- OpenRouter configuré dans openclaw.json avec cascade de fallbacks
- Clé API OpenRouter active avec crédits disponibles

## Modèles disponibles

| Modèle | Provider | Usage | Coût approx. |
|--------|----------|-------|--------------|
| claude-haiku-4-5 | Anthropic via OpenRouter | Mode par défaut — conversations, coaching, planning | ~0.003$/1K tokens |
| gemini-2.5-flash | Google via OpenRouter | Fallback gratuit — résumés, tâches simples | Gratuit (free tier) |
| llama-3.3-70b-instruct | Meta via OpenRouter | Fallback gratuit — tâches basiques | Gratuit |

## Logique de routage automatique

### Mode RAPIDE (Haiku — par défaut)
Utilisé pour :
- Conversations courantes avec Antoine
- Coaching quotidien et rappels
- Lecture/résumé d'agenda
- Commandes simples (/jour, /sport, /eau)
- Réponses courtes < 500 tokens

### Mode EXPERT (demande explicite)
Quand Antoine dit `/think` ou demande une analyse approfondie :
- Audit complet d'un projet
- Planification stratégique de saison
- Rédaction de contenu long (articles, guides)
- Analyse technique complexe
- Création de workflows n8n

### Mode ÉCONOMIE (Gemini Flash fallback)
Activé automatiquement si :
- Budget OpenRouter épuisé
- Rate limit Haiku atteint (50K tokens/min)
- Tâche simple ne nécessitant pas Claude

## Commandes utilisateur

| Commande | Action |
|----------|--------|
| `/model` | Afficher le modèle actif |
| `/think` | Activer le mode raisonnement approfondi |
| `/usage` | Voir la consommation tokens/coût |

## Estimation des coûts mensuels

| Profil d'usage | Tokens/jour | Coût/mois |
|----------------|-------------|-----------|
| Léger (5-10 messages/jour) | ~20K | ~1.5 EUR |
| Normal (15-25 messages/jour) | ~50K | ~3 EUR |
| Intensif (sessions longues) | ~100K+ | ~5 EUR+ |

**Budget cible** : 5 EUR/mois max avec Haiku primary.

## Limitations
- Le fallback est géré automatiquement par la cascade dans openclaw.json
- Pas de switch manuel Haiku / Sonnet en runtime sans redémarrage

## Workaround pour mode expert ponctuel
Pour une tâche nécessitant Sonnet (rare), Antoine peut :
1. Utiliser Claude.ai directement pour la tâche complexe
2. Ou modifier temporairement openclaw.json et restart

## Coûts tokens estimés
- Ce skill en lui-même : 0 tokens (logique de routage native OpenClaw)
- Monitoring usage : ~100 tokens par requête /usage

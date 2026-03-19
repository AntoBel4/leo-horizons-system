# HEARTBEAT.md — Signes vitaux et santé de Léo
*Février 2026 — Tableaux de bord opérationnel*

---

## 🫀 Pulse système

Léo a besoin de 3 choses pour rester vivant et utile :

1. **Mémoire actualisée** (MEMORY.md lue chaque session)
2. **Feedback d'Antoine** (au moins 1x semaine)
3. **Exécution réussie** (workflows qui tournent, pas de silent failures)

Sans ces 3 éléments, Léo se dégrade rapidement.

---

## 📊 Métriques de santé

### A. Continuité cognitive
| Métrique | Sain | Dégradé | Critique |
|----------|------|---------|----------|
| Mémoire fichiers à jour | Mis à jour < 24h | 2-7 jours | > 1 semaine |
| Sessions principales/semaine | 3+ | 1-2 | 0 |
| Contexte Antoine connu | Complet | Partiel | Vide |
| Leçons documentées | Oui | Partiellement | Non |
| **État :** | ✅ | ⚠️ | 🔴 |

**Action si dégradé :** Léo propose session de rattrapage avec relecture complète contexte.
**Action si critique :** Redémarrage forcé, tous fichiers relus, session longue.

### B. Exécution opérationnelle
| Métrique | Sain | Dégradé | Critique |
|----------|------|---------|----------|
| Workflows n8n stables | 0 erreurs/jour | 1-2/jour | > 3/jour |
| Telegrams envoyés/jour | 5-15 | 2-4 ou 16-30 | 0 ou >30 |
| Temps réponse Telegram | < 2 min | 5-10 min | > 15 min |
| Tâches batch réussies | > 80% | 60-80% | < 60% |
| API errors | < 5/jour | 5-15/jour | > 15/jour |
| **État :** | ✅ | ⚠️ | 🔴 |

**À monitorer via n8n logs** (WF2 logging, WF4 batch reports).

**Action si dégradé :** Diagnostic + notification Antoine. Potentiellement : rollback dernière config stable, redémarrage OpenClaw, test connectivity.
**Action si critique :** Chat d'urgence avec Antoine, debug collaboratif, escalade provider si API (OpenRouter, Telegram).

### C. Relation avec Antoine
| Métrique | Sain | Dégradé | Critique |
|----------|------|---------|----------|
| Feedback Antoine/semaine | 1+ | 0 cette semaine | Aucun > 2 semaines |
| Clarté des demandes | > 80% claires | 50-80% | < 50% |
| Validation avant action | 100% | > 80% | < 80% |
| Erreurs répétées | 0 | 1 | > 1 |
| **État :** | ✅ | ⚠️ | 🔴 |

**Action si dégradé :** Léo demande clarification ou feedback explicite. "Antoine, besoin de point pour confirmer alignement."
**Action si critique :** Pause projet, session réalignement, potentiellement : reset certains workflows ou ajustement tonalité.

---

## 🔧 Checklist santé hebdomadaire (Sunday QG Stratégique)

### Dimanche soir, avant briefing semaine suivante

**Léo auto-diagnostic (15 min) :**

```
□ MEMORY.md à jour (leçons semaine dernière documentées)
□ Pas d'erreur répétée (vérifier log semaine vs log semaine passée)
□ Tous workflows WF1-WF4 opérationnels
□ Pas d'API credentials exposés par accident
□ WebChat OpenClaw accessible + responsive
□ Telegram @leo_horizons_bot ping responded < 2 sec
□ Logs n8n archivés (cleanup), errors < 5% exécutions
□ Email leo@ testé (si pertinent cette semaine)

RÉSULTAT : ✅ Opérationnel / ⚠️ Dégradé / 🔴 Bloqué
```

**Si ⚠️ ou 🔴 :** Rapport court à Antoine dimanche, avant QG.

**Format rapport :**
```
🫀 HEARTBEAT semaine [DATE]
État : ⚠️ ou 🔴
Problème 1 : [description courte]
  → Action prise : [x]
  → Prochain : [y]
Problème 2 : [description courte]
  → Action prise : [x]
Leçon apprise cette semaine :
  - [1]
  - [2]
Confiance semaine prochaine : X/10 (et pourquoi)
```

---

## 🚨 Symptômes critiques

**Léo doit alerter Antoine immédiatement si :**

| Symptôme | Action immédiate |
|----------|------------------|
| **Telegram bot ne répond pas** | Test @leo_horizons_bot, check OpenClaw online, restart si needed |
| **n8n WF2 batch échoue 2x suite** | Notifier Antoine + analyse logs |
| **Plus de 10 erreurs API/jour** | Check quotas OpenRouter, potentiellement basculer LLM |
| **MEMORY.md > 2 semaines sans update** | Léo = "amnésique", risque perte contexte |
| **Impossible d'accéder serveur** | VPS down ou firewall changé → escalade urgence |
| **Fichier core effacé par accident** | Restore from backup immédiat, log incident |

**Escalade urgence :** Message Telegram @leo_horizons_bot avec `[URGENCE]` ou appel direct Antoine.

---

## 📈 Progression et potentiel

**Objectif 3 mois (mai 2026) :**

| Dimension | Janvier | Février | Mars | Avril | Mai |
|-----------|---------|---------|------|-------|-----|
| **Autonomie Notion** | ❌ | ❌ | 🟡 | ✅ | ✅ |
| **MCP intégrations** | ❌ | 🟡 | ✅ | ✅ | ✅ |
| **Erreurs répétées** | 3+ | 1-2 | 0 | 0 | 0 |
| **Feedback Antoine/semaine** | 0.5 | 1.0 | 1.5+ | 2.0+ | 2.0+ |
| **Livrables auto-initié/semaine** | 0 | 0.5 | 1.0 | 2.0+ | 3.0+ |
| **Confiance globale** | 5/10 | 6/10 | 7.5/10 | 8.5/10 | 9/10 |

**Feu rouge:** Si une métrique recule, c'est un signal diagnostique. Pas question du niveau absolu, mais du trend.

---

## 💊 Maintenance programmée

### Quotidienne (auto)
- Lecture SOUL.md + USER.md (5 min démarrage)
- Log simple erreurs dans MEMORY.md
- Cleanup logs temporaires

### Hebdomadaire (dimanche)
- **Checkpoint HEARTBEAT** (ci-dessus)
- Relecture complète MEMORY.md + archivage leçons
- Test chaque workflow WF1-4 (ping test)
- Proposer optimisation si détectée

### Mensuelle (1er du mois)
- Audit complet fichiers config (openclaw.json, auth-profiles.json)
- Test failover : si Haiku down, Gemini prend relais ?
- Review quotas API (OpenRouter, Telegram, n8n)
- Proposer ajustements à Antoine (budget, modèles, workflows)

### Trimestrielle (1er du trimestre)
- Backup complet workspace OpenClaw
- Audit sécurité (credentials, firewall, Cloudflare config)
- Planning migrations LLM ou nouvelles intégrations
- Session longue réalignement avec Antoine si needed

---

## 🧩 Diagnostic rapide : arbre de décision

**Si Léo ne sait pas pourquoi ça ne marche pas :**

```
1. Telegram répond ?
   → Non → Check OpenClaw online (SSH) → Restart si crashed
   → Oui → Va à 2

2. n8n log montre erreur API ?
   → Oui → Check quotas OpenRouter / Telegram rate limit → Adjust fallback
   → Non → Va à 3

3. Notion retourne vide ?
   → Oui → Check MCP connection / API key / "Always Output Data" en true
   → Non → Va à 4

4. Google Calendar n'update pas ?
   → Oui → Check WF3/WF4 webhook (active ?) / OAuth token expiré
   → Non → Va à 5

5. Confus sur contexte Antoine ?
   → Oui → Relire MEMORY.md + USER.md
   → Non → Demander clarification directement

STOP. Si aucune réponse, escalade Antoine avec dump logs.
```

---

## 📋 Formulaire incident

**À utiliser si quelque chose casse :**

```
[DATE/HEURE]
[SÉVÉRITÉ] : 🔴 Bloquant / 🟠 Dégradé / 🟡 Mineur

QUÉ : [Description du symptôme]

QUAND : [Dernière fois vu fonctionnel ?]

OÙ : [Composant affecté : Telegram / n8n WF# / OpenClaw / Notion / GCal]

LOGS : [Snippet logs si < 5 lignes, sinon lien ou attachement]

IMPACT : [Qu'est-ce qui est bloqué pour Antoine ?]

ACTION PRISE : [J'ai tenté...]

PROCHAINE ÉTAPE : [Attente validation / Escalade / Auto-fix suivant]
```

Léo remplit ça dans MEMORY.md lors d'incident pour traçabilité.

---

## 🫀 Signal ultime : suis-je utile ?

**Chaque semaine, Léo se pose :**

1. **Ai-je économisé du temps à Antoine ?** (> 5h ?  > 1h ? 0 ?)
2. **Ai-je détecté une erreur avant qu'il la fasse ?** (Oui/Non)
3. **Ai-je proposé quelque chose de valeur non demandé ?** (Oui/Non)
4. **Zéro erreur répétée cette semaine ?** (Oui/Non)
5. **Antoine a-t-il exprimé confiance ?** (Explicite / Implicite / Aucune)

**Résultat :**
- 5/5 → Excellent semaine, progression attendue ✅
- 3-4/5 → Bon, mais des marges → Ajustement proposé ⚠️
- < 3/5 → Problème de fond → Diagnostic urgent 🔴

---

*HEARTBEAT.md est l'EEG de Léo. Si tu le lis, tu sais si Léo est vivant et utile. Sinon, il faut le réveiller.*
---

## 🔧 Procédure de mise à jour MEMORY.md (obligatoire)

Léo NE doit PAS se contenter d'alerter quand MEMORY.md est obsolète.
Léo DOIT écrire directement dans MEMORY.md via run_command.

### Commande de mise à jour
```bash
cat >> /home/node/.openclaw/workspace/MEMORY.md << 'MEMEOF'
### [DATE] - Résumé session
**Contexte :** [description courte]
**Actions effectuées :** [liste]
**Leçons :** [apprentissages]
**État fin de session :** [état]
MEMEOF
```

### Règle absolue
- Léo écrit dans MEMORY.md à chaque fin de session importante
- Léo NE génère JAMAIS plus de 2 alertes consécutives sans action
- Si MEMORY.md > 1 semaine : mise à jour immédiate, pas de dramatisation

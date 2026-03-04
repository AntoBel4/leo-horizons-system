---
name: image-generator
description: Générer des images pour le contenu marketing (expert-local, landing pages, réseaux sociaux) via providers gratuits/économiques
---

# SKILL image-generator

## Description
Ce skill permet à Leo de générer des images pour le contenu marketing et les projets H2 d'Antoine. Focus sur des providers gratuits ou très économiques.

## Providers recommandés (par ordre de priorité)

### 1. Pollinations.ai (GRATUIT — recommandé principal)
API gratuite, sans inscription, sans clé API.

```bash
# Génération simple via URL
curl -s "https://image.pollinations.ai/prompt/professional%20website%20design%20for%20local%20business%20artisan%20french?width=1200&height=630&seed=42&model=flux" \
  -o image_output.jpg
```

**Avantages** : 100% gratuit, pas de rate limit agressif, modèles Flux disponibles
**Limites** : Qualité variable, pas de contrôle fin

### 2. Stability AI (Free tier)
100 crédits gratuits/jour.

```bash
curl -s -X POST "https://api.stability.ai/v2beta/stable-image/generate/sd3" \
  -H "Authorization: Bearer STABILITY_API_KEY" \
  -H "Accept: image/*" \
  -F "prompt=modern website mockup for french artisan business, professional, clean design" \
  -F "output_format=png" \
  -o output.png
```

### 3. Together AI (Free tier pour Flux)
Modèle Flux Schnell gratuit.

```bash
curl -s -X POST "https://api.together.xyz/v1/images/generations" \
  -H "Authorization: Bearer TOGETHER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "black-forest-labs/FLUX.1-schnell-Free",
    "prompt": "professional digital marketing infographic for local business",
    "width": 1024,
    "height": 768,
    "n": 1
  }' | python3 -c "import sys,json,base64; d=json.load(sys.stdin); open('output.png','wb').write(base64.b64decode(d['data'][0]['b64_json']))"
```

## Cas d'usage Antoine

### 1. Images pour expert-local.fr
- Visuels de diagnostic digital
- Illustrations avant/après optimisation
- Photos de couverture articles blog

### 2. Images pour landing pages
- Hero images rentrerdesmandats.fr
- Illustrations features/bénéfices
- Bannières réseaux sociaux

### 3. Thumbnails YouTube
- Miniatures vidéos tech
- Visuels de couverture

## Prompts optimisés par projet

### expert-local.fr
```
professional digital audit report mockup, french small business,
clean modern design, blue and white color scheme, data visualization,
high quality, photorealistic
```

### rentrerdesmandats.fr
```
real estate digital marketing dashboard, modern french interface,
property listings, professional blue theme, data analytics view
```

### estarellas.online
```
professional portfolio website screenshot, modern minimalist design,
dark theme, developer portfolio, clean typography
```

## Formats recommandés
| Usage | Dimensions | Format |
|-------|-----------|--------|
| Hero banner | 1920x1080 | JPG |
| Blog featured | 1200x630 | JPG |
| Social media | 1080x1080 | PNG |
| YouTube thumbnail | 1280x720 | JPG |
| Favicon | 512x512 | PNG |

## Coûts estimés
- **Pollinations** : GRATUIT
- **Stability AI** : Gratuit (100 crédits/jour ≈ 10-20 images)
- **Together AI** : Gratuit (Flux Schnell)
- **Budget total** : 0€/mois en usage normal

## Limitations
- Pas de génération de visages réalistes (risque deep fake)
- Les prompts en anglais donnent de meilleurs résultats
- Pollinations peut être lent (5-15 secondes)
- Pas de modification/inpainting avancé sans API payante

## Fallback
Si tous les providers gratuits sont down :
1. Utiliser Canva (gratuit, templates pro)
2. Unsplash/Pexels pour photos stock gratuites
3. Informer Antoine et attendre

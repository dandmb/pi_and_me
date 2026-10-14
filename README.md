# 🐶 Pi & Moi — Application Mathématique CP → 3e

Application mobile ludo-éducative d'apprentissage des mathématiques du CP à la 3e (Cycles 2, 3 et 4) avec un compagnon virtuel bienveillant : **Pi le chiot**.

100 % gratuit · Zéro publicité · Respect du temps d'écran · Conforme Google Play Familles & RGPD.

---

## 🛠 Stack Technique

- **Framework** : Flutter (iOS & Android) — Dart 3
- **State Management** : `flutter_riverpod: ^2.5.1`
- **Stockage Local** : `shared_preferences: ^2.3.2` (Offline-first avec Repository Pattern)
- **Typographie** : `google_fonts: ^6.2.1`
  - **Quicksand** (500, 600, 700) pour tous les textes et interfaces
  - **Lexend** (600, 700, 800) pour tous les nombres, calculs et fractions
- **Graphismes & Animations** : `flutter_svg`, `flutter_animate`
- **Moteur de rendu** : Impeller

---

## 🎨 Design System & Charte Graphique

L'application suit une charte graphique tactile et bienveillante ([`DESIGN_SYSTEM.md`](../../antigravity/brain/ebbfc4a2-b35c-4965-b02f-0835634c80ce/DESIGN_SYSTEM.md)) :

- **Couleurs d'action** : Bleu Électrique (`sky600 #1899D6` en face, `sky700 #0D8ABC` en bord 3D). **L'orange d'action est formellement proscrit.**
- **Boutons physiques (« Chunky »)** : Rebord 3D plein de 4 px à 6 px avec enfoncement tactile physique (`onTapDown`), sans ombre floue d'IA.
- **Accessibilité** : Cibles tactiles ≥ 56 px côté enfant, contrastes conformes WCAG 2.1 AA.
- **Mascotte Pi** : Rendu 2D Flat vectoriel détouré avec ombre de contact ovale indépendante au sol.

---

## 📂 Architecture du Projet (Feature-First)

Le projet adopte une structure propre, modulaire et sans over-ingénierie :

```text
lib/
├── main.dart                  # Point d'entrée avec ProviderScope et Bootstrap
├── core/                      # Socle réutilisable
│   ├── theme/                 # Charte graphique (AppColors, AppText, AppSpace, AppTheme)
│   ├── widgets/               # Composants UI partagés (ChunkyButton, etc.)
│   └── storage/               # Stockage local et clés de persistance
└── features/                  # Modules fonctionnels
    ├── splash/                # Écran 0 : Splash & saut de Pi
    ├── profile/               # Modèle enfant (Léa, CP→3e, avatar) & stockage local
    ├── onboarding/            # Écran 1 : Écran onboarding & sélecteur de classe
    ├── home/                  # Écran 1 bis : Salon de Pi & ses 3 jauges (Faim, Joie, Énergie)
    ├── quiz/                  # Écran 2 & 3 : Moteur mathématique adaptatif & résultats
    ├── care/                  # Écran 4 : Soins et interactions avec Pi
    ├── shop/                  # Écran 5 : Boutique d'accessoires (en Os dorés 🦴)
    └── parent/                # Écran 6 & 7 : Limite quotidienne 6/6 & Espace Parents
```

---

## 🚀 Démarrage Rapide

### Prérequis
- Flutter SDK `>= 3.13.0`
- Xcode (pour iOS) / Android Studio (pour Android)

### Installation
```bash
# Récupération des dépendances
flutter pub get

# Lancement des tests unitaires et widgets
flutter test

# Analyse du code
flutter analyze

# Lancer l'application sur émulateur ou device
flutter run
```

---

## 🌿 Règles Git & Workflow

- La branche **`dev`** est la branche d'intégration principale.
- Tout nouveau développement part d'une branche dédiée : `feature/<nom-du-dev>` créée depuis `dev`.
- Chaque étape de développement comprend :
  1. Le code fonctionnel sans over-ingénierie.
  2. Les tests unitaires / widget tests validés (`flutter test` au vert ✅).
  3. La mise à jour de la documentation `README.md`.
- Le merge sur `dev` est effectué sur GitHub après revue.

---

## 🗺 Feuille de Route (Roadmap)

- [x] **Phase 1.1** : Socle technique, Design System WCAG, `ChunkyButton`, assets de Pi & tests.
- [x] **Phase 1.2** : Modèle enfant (`ChildProfile`, `SchoolGrade`), persistance locale `shared_preferences` & providers Riverpod (`activeProfileProvider`).
- [ ] **Phase 1.3** : Écrans Splash (saut de Pi) et Onboarding (sélecteur CP→3e).
- [ ] **Phase 2** : Moteur de génération mathématique CP→3e & Quiz adaptatif.
- [ ] **Phase 3** : Compagnon Pi, état des 3 jauges & boucle de soin.
- [ ] **Phase 4** : Économie des Os dorés, inventaire & boutique de déguisements.
- [ ] **Phase 5** : Limite quotidienne 6/6 & Espace Parents sécurisé (porte mathématique).

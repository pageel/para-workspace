<div align="center">

<img src="../assets/logo.svg" width="120" alt="PARA Workspace Logo">

# PARA Workspace

**Le Framework d'Espace de Travail pour Humains et Agents IA**

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.7.7-blue.svg)](../../CHANGELOG.md)
![Type](https://img.shields.io/badge/type-workspace_framework-blueviolet.svg)
[![Antigravity](https://img.shields.io/badge/Antigravity-verified-E37400?logo=google&logoColor=white)](https://antigravity.google/)

<a href="../../README.md"><b>🇺🇸 English</b></a> •
    <a href="./vi-VN.md"><b>🇻🇳 Tiếng Việt</b></a> •
    <a href="./zh-CN.md"><b>🇨🇳 中文</b></a> •
    <a href="./es-ES.md"><b>🇪🇸 Español</b></a> •
    <a href="./fr-FR.md"><b>🇫🇷 Français</b></a>

</div>

---

| Section | Description |
| :--- | :--- |
| [🌌 Vue d'ensemble](#-vue-densemble) | Ce que c'est, les trois principes fondateurs |
| [📂 Architecture](#-architecture) | Structure du dépôt + structure de l'espace de travail généré |
| [📥 Installation](#-installation) | Prérequis, configuration, profils, dépannage |
| [🧠 Le Noyau](#-le-noyau) | Invariants, heuristiques, contrats |
| [🛠️ Référence CLI](#-référence-cli) | Toutes les commandes CLI |
| [📑 Catalogue des Workflows](#-catalogue-des-workflows) | 24 flux de travail (workflows) régis |
| [🛡️ Catalogue des Règles](#-catalogue-des-règles) | 11 règles de gouvernance |
| [🧩 Catalogue des Compétences](#-catalogue-des-compétences) | 3 compétences (skills) réutilisables |
| [🧩 Gestion des Tâches](#-gestion-des-tâches-modèle-hybride-à-3-fichiers) | Modèle hybride à 3 fichiers |
| [🔄 Mise à jour](#-mise-à-jour-des-versions) | Mise à jour automatique + nouvelle installation |
| [🗺️ Feuille de Route](#-feuille-de-route) | Historique des versions + fonctionnalités prévues |

## 🌌 Vue d'ensemble

**PARA Workspace** est un framework d'espace de travail open source qui définit comment les humains et les agents d'intelligence artificielle organisent les connaissances et collaborent sur des projets. Il est distribué sous forme de **dépôt (repo)** contenant un noyau (constitution), des outils CLI et des modèles — à partir desquels est généré **l'espace de travail (workspace)** où vous travaillez réellement. Le noyau applique des invariants et des règles heuristiques afin que chaque espace de travail soit prévisible, auditable et adapté aux agents IA.

### Trois Principes Fondateurs

1. **Repo ≠ Workspace (Dépôt ≠ Espace de travail)** — Le dépôt contient la gouvernance (noyau, CLI, modèles) et ne contient jamais de données utilisateur.
2. **Workspace = Runtime (Espace de travail = Environnement d'exécution)** — Généré par `para init`, chaque espace de travail est une instance indépendante où vous et votre Agent travaillez.
3. **Kernel = Constitution (Noyau = Constitution)** — Règles immuables que tous les espaces de travail doivent suivre. Toute modification nécessite une RFC et une augmentation de version.

```mermaid
flowchart TD
    R["🏛️ Repo\n(Constitution + Compilateur)"]
    W["💻 Workspace\n(Système d'exploitation Runtime)"]
    A["🤖 Agent\n(Environnement d'exécution)"]
    R -->|para init| W
    W -->|agent attach| A

    style R fill:#4a90d9,stroke:#2c5f8a,color:#fff
    style W fill:#50c878,stroke:#2e8b57,color:#fff
    style A fill:#ff8c42,stroke:#cc6633,color:#fff
```

---

## 📂 Architecture

### Structure du Dépôt (Ce Dépôt)

```
para-workspace/
├── .github/             # 🤖 CI/CD — validate-pr.yml, CODEOWNERS
├── rfcs/                # 📝 Processus RFC — TEMPLATE.md
├── kernel/              # 🧠 Constitution
│   ├── KERNEL.md
│   ├── invariants.md    # 11 règles strictes (modification nécessite une maj MAJOR)
│   ├── heuristics.md    # 10 conventions souples
│   ├── schema/          # Schémas JSON pour workspace, project, backlog, etc.
│   └── examples/        # Exemples de conformité valides/invalides
├── cli/                 # 🔧 Compilateur
│   ├── para             # Point d'entrée (compatible Bash 3.2+)
│   ├── lib/             # Bibliothèques (logger, validator, rollback)
│   └── commands/        # Commandes (init, scaffold, status, migrate, install, etc.)
├── templates/           # 📦 Échafaudage & Bibliothèques Régies
│   ├── common/agents/   # Workflows, règles, compétences et catalog.yml
│   │   └── projects/    # Modèle .project.yml
│   └── profiles/        # Préréglages (dev, general)
├── tests/               # 🧪 Tests d'intégration
├── docs/                # 📖 Documentation
├── CONTRIBUTING.md
├── VERSIONING.md
├── CHANGELOG.md
└── VERSION
```

### Structure de l'Espace de Travail (Généré par `para init`)

```
<your-workspace>/
├── Projects/                          # Tâches orientées par objectifs
│   ├── my-app/                        # Projet standard (type: standard)
│   │   ├── repo/                      #   Code source (dépôt git)
│   │   ├── artifacts/                 #   Plans, tâches, décisions
│   │   ├── sessions/                  #   Journaux de session
│   │   ├── docs/                      #   Documentation du projet
│   │   └── project.md                 #   Contrat du projet
│   └── my-ecosystem/                  # Projet Écosystème (type: ecosystem)
│       ├── artifacts/                 #   Plans partagés et backlog
│       └── project.md                 #   satellites: [app, api, ...], PAS de repo/
├── Areas/                             # Responsabilités continues (ex: santé, finances)
│   ├── Workspace/                     # Journal de bord maître, audits, file SYNC
│   └── Learning/                      # Connaissances partagées (via /learn)
├── Resources/                         # Références et outils
│   ├── ai-agents/                     # Capture du Noyau et bibliothèques régies
│   └── references/                    # Dépôt original PARA (lecture seule)
├── Archive/                           # Stockage inactif pour éléments terminés
├── _inbox/                            # Zone d'atterrissage pour téléchargements externes
├── .agents/                           # Copies des bibliothèques régies (Auto-synchronisées)
│   ├── rules.md                       # Index déclencheur des règles (toujours chargé)
│   ├── skills.md                      # Index déclencheur des compétences
│   ├── rules/                         # Règles d'agent actives
│   ├── skills/                        # Compétences d'agent actives
│   └── workflows/                     # Flux de travail d'agent actifs
├── .para/                             # État du système (NE PAS MODIFIER)
│   ├── archive/                       # Coffre d'archives obsolètes
│   ├── backups/                       # Sauvegardes horodatées
│   └── audit.log                      # Historique d'audit des actions
├── para                               # Script CLI (Bootstrapper)
└── .para-workspace.yml                # Configuration des métadonnées racinaires
```

---

## 📥 Installation

### Prérequis

- **Plateforme d'Agent IA** (voir compatibilités ci-dessous)
- **Git** (requis — pour cloner et mettre à jour)
- **Bash** 3.2+ (Natif sur Linux/macOS, Git Bash ou WSL sur Windows)

### Étape 1 : Cloner et Installer

```bash
# Cloner le dépôt au bon endroit
mkdir -p Resources/references
git clone https://github.com/pageel/para-workspace.git Resources/references/para-workspace

# Accorder les permissions d'exécution
chmod +x Resources/references/para-workspace/cli/para
chmod +x Resources/references/para-workspace/cli/commands/*.sh

# Initialiser l'espace de travail avec un profil
./Resources/references/para-workspace/cli/para init --profile=dev --lang=en
```

### Étape 2 : Vérifier

```bash
./para status
# ✅ Si vous voyez le rapport de santé, l'installation est réussie
```

### Mise à jour

```bash
# Extraire la dernière version de GitHub et resynchroniser l'espace
./para update

# Prévisualiser les changements avant application
./para update --dry-run
```

---

## 🧠 Le Noyau

Le Noyau est la **constitution** de PARA Workspace — les règles que tous les espaces de travail doivent respecter.

### Invariants (Règles strictes)
11 règles fondamentales (toute modification exige une version MAJOR), telles que `I1` (Structure stricte des dossiers), `I2` (Modèle hybride à 3 fichiers), `I10` (Séparation Repo/Workspace), etc.

### Heuristiques (Règles souples)
10 directives (modification nécessitant des paramètres MINOR/PATCH) couvrant le nommage, les priorités contextuelles et la gestion des éléments de connaissances (KI).

---

## 🛠️ Référence CLI

```bash
# Commandes principales
para init [--profile] [--lang]  # Créer un espace de travail
para status [--json]            # Vérifier la santé du système
para update                     # Mettre à jour et migrer
para scaffold <type> <name>     # Créer une architecture de dossiers
para install [--force]          # Synchroniser les bibliothèques régies
para archive <type> <name>      # Revue et archivage
para migrate [--from] [--to]    # Utilitaire de migration

# Commandes IA
@[/para-workflow] list          # Gérer les workflows
@[/para-rule] list              # Gérer les règles
```

---

## 📑 Catalogue (Workflows, Règles et Compétences)

Le système intègre :
- **24 Workflows :** Des gestionnaires de tâches (`/backlog`), des scénarios d'ouverture (`/open`), des audits (`/para-audit`) jusqu'aux systèmes de connaissances (`/para-knowledge`).
- **11 Règles de Gouvernance :** Protègent le versionnement, les bonnes pratiques Git (VCS) ou évitent les mutations risquées.
- **3 Compétences (Skills) :** Facilitent la compréhension des composants statiques (`PARA Kit`), des diagrammes ou de l'architecture des pages web (`Page Map`).

---

## 🏗️ Architecture des Règles — Chargement à Deux Niveaux & Défense en Profondeur

PARA Workspace s'appuie sur une structure de **Divulgation Progressive** (Progressive Disclosure). L'agent IA lit seulement des index maîtres très courts (`.agents/rules.md`), économisant ainsi environ 90 % de tokens.

Pour protéger l'Intelligence Artificielle de la perte de mémoire (amnésie après de longues conversations), quatre couches de validation (Defense-in-Depth) et des contrôles pré-vol automatiques sont en place.

---

## 🧩 Gestion des Tâches (Modèle Hybride à 3 Fichiers)

Résout les problèmes d'amnésie des IA en divisant le monolithe du Backlog en :
- `backlog.md` (Total et stratégique)
- `sprint-current.md` (Piste active modifiable par l'IA)
- `done.md` (Historique ajout-seulement avec balises `#session`)

Initié avec `/open` et terminé/synchronisé avec `/end`.

---

## 📚 Système de Connaissances (v1.7.0)

Introduit l'écosystème "Knowledge Items (KIs)" pour s'intégrer nativement avec Antigravity ou des technologies similaires. Encapsulez des fragments de connaissances robustes qui ne périment pas et peuvent être partagés sans frontières.

---

## 🔄 Mise à jour des Versions

La fonctionnalité `./para update` permet d'obtenir en continu les toutes dernières améliorations structurelles, en archivant les dossiers modifiés obsolètes dans une zone sécurisée, réduisant les conflits et offrant une restauration transparente.

---

## 🗺️ Feuille de Route

Version actuelle : **1.7.6** (Skill Catalog Architecture).
Mises à jour prévues : **v1.8.0** (Départements système) et **v1.9.0** (Limites communautaires).

---

## 🤝 Contribution

Rendez-vous sur [CONTRIBUTING.md](../../CONTRIBUTING.md) pour découvrir les principes directeurs. Tout invariant de modification exigeant une RFC stricte.

---

Conçu avec ❤️ par **Pageel**. Standardisant l'avenir de la méthode PKM Agent.

_Version : 1.7.6_

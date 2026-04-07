<div align="center">

<img src="../assets/logo.svg" width="120" alt="PARA Workspace Logo">

# PARA Workspace

**Le Framework d'Espace de Travail pour les Humains et les Agents IA**

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.7.6-blue.svg)](../../CHANGELOG.md)
![Type](https://img.shields.io/badge/type-workspace_framework-blueviolet.svg)
[![Antigravity](https://img.shields.io/badge/Antigravity-verified-E37400?logo=google&logoColor=white)](https://antigravity.google/)

<a href="../../README.md"><b>🇺🇸 English</b></a> •
    <a href="./vi-VN.md"><b>🇻🇳 Tiếng Việt</b></a> •
    <a href="./zh-CN.md"><b>🇨🇳 中文</b></a> •
    <a href="./es-ES.md"><b>🇪🇸 Español</b></a> •
    <a href="./fr-FR.md"><b>🇫🇷 Français</b></a>

</div>

---

> 🚧 **Traduction en cours** — Ce fichier est actuellement un espace réservé. Les contributions pour la traduction française sont les bienvenues !
>
> En attendant, veuillez consulter le [README en anglais](../../README.md) pour la documentation complète.

## 🌌 Aperçu

**PARA Workspace** est un framework d'espace de travail open source qui définit comment les humains et les agents IA organisent les connaissances et collaborent sur des projets. Il est distribué sous forme de **dépôt** contenant un noyau (constitution), des outils CLI et des templates — qui génèrent des **espaces de travail** où vous travaillez réellement.

### Trois Principes Fondamentaux

1. **Repo ≠ Workspace** — Le dépôt contient la gouvernance (noyau, CLI, templates). Il ne contient jamais de données utilisateur.
2. **Workspace = Runtime** — Généré par `para init`, chaque espace de travail est une instance autonome.
3. **Kernel = Constitution** — Règles immuables que tous les espaces de travail doivent suivre.

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

## 📥 Installation

```bash
# Cloner le dépôt
mkdir -p Resources/references
git clone https://github.com/pageel/para-workspace.git Resources/references/para-workspace

# Définir les permissions
chmod +x Resources/references/para-workspace/cli/para
chmod +x Resources/references/para-workspace/cli/commands/*.sh

# Initialiser l'espace de travail
./Resources/references/para-workspace/cli/para init --profile=dev --lang=en
```

## 🤝 Contribuer

Les contributions pour la traduction complète en français sont les bienvenues ! Consultez [CONTRIBUTING.md](../../CONTRIBUTING.md) pour les directives.

---

Construit avec ❤️ par **Pageel**. Standardiser l'avenir du PKM Agent.

_Version : 1.7.6_

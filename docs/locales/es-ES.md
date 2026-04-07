<div align="center">

<img src="../assets/logo.svg" width="120" alt="PARA Workspace Logo">

# PARA Workspace

**El Framework de Espacio de Trabajo para Humanos y Agentes IA**

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

> 🚧 **Traducción en progreso** — Este archivo es actualmente un marcador de posición. ¡Las contribuciones para la traducción al español son bienvenidas!
>
> Mientras tanto, consulte el [README en inglés](../../README.md) para la documentación completa.

## 🌌 Descripción General

**PARA Workspace** es un framework de espacio de trabajo de código abierto que define cómo los humanos y los agentes de IA organizan el conocimiento y colaboran en proyectos. Se distribuye como un **repositorio** que contiene un kernel (constitución), herramientas CLI y plantillas — que generan **espacios de trabajo** donde realmente trabajas.

### Tres Principios Fundamentales

1. **Repo ≠ Workspace** — El repositorio contiene gobernanza (kernel, CLI, plantillas). Nunca contiene datos de usuario.
2. **Workspace = Runtime** — Generado por `para init`, cada espacio de trabajo es una instancia independiente.
3. **Kernel = Constitución** — Reglas inmutables que todos los espacios de trabajo deben seguir.

```mermaid
flowchart TD
    R["🏛️ Repo\n(Constitución + Compilador)"]
    W["💻 Workspace\n(Sistema Operativo Runtime)"]
    A["🤖 Agent\n(Entorno de Ejecución)"]
    R -->|para init| W
    W -->|agent attach| A

    style R fill:#4a90d9,stroke:#2c5f8a,color:#fff
    style W fill:#50c878,stroke:#2e8b57,color:#fff
    style A fill:#ff8c42,stroke:#cc6633,color:#fff
```

## 📥 Instalación

```bash
# Clonar el repositorio
mkdir -p Resources/references
git clone https://github.com/pageel/para-workspace.git Resources/references/para-workspace

# Establecer permisos
chmod +x Resources/references/para-workspace/cli/para
chmod +x Resources/references/para-workspace/cli/commands/*.sh

# Inicializar el espacio de trabajo
./Resources/references/para-workspace/cli/para init --profile=dev --lang=en
```

## 🤝 Contribuir

¡Las contribuciones para la traducción completa al español son bienvenidas! Consulte [CONTRIBUTING.md](../../CONTRIBUTING.md) para las directrices.

---

Construido con ❤️ por **Pageel**. Estandarizando el futuro del PKM Agent.

_Versión: 1.7.6_

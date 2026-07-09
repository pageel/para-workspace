---
tags: [mobile, cross-platform, offline-first, app-store]
stack: [react-native, expo, typescript, sqlite, eas]
scale: [small, medium, large]
complexity: intermediate
---

# Reference Architecture: Cross-Platform Mobile (React Native + Expo)

## 1. Topology
*   **Framework**: React Native with Expo (Managed workflow for rapid development, bare workflow for native modules).
*   **Build & Distribution**: EAS Build (cloud) + EAS Submit (App Store / Google Play).
*   **Backend Communication**: REST API or GraphQL via `fetch` / Apollo Client / TanStack Query.
*   **OTA Updates**: Expo Updates for over-the-air JavaScript bundle updates (skip app store review for non-native changes).

## 2. Navigation & Routing
*   **Router**: Expo Router (file-based routing, similar to Next.js App Router).
*   **Layout Structure**:
    ```
    app/
    ├── (auth)/             # Auth group (login, register)
    │   ├── login.tsx
    │   └── register.tsx
    ├── (tabs)/             # Main tab navigation
    │   ├── _layout.tsx     # Tab bar config
    │   ├── index.tsx       # Home tab
    │   ├── search.tsx      # Search tab
    │   └── profile.tsx     # Profile tab
    ├── [id].tsx            # Dynamic route
    └── _layout.tsx         # Root layout (auth guard)
    ```
*   **Deep Linking**: Configure `app.json` → `scheme` for custom URL schemes (`myapp://`) and Universal Links.

## 3. Data & Storage Architecture
*   **Remote State**: TanStack Query (React Query) for server state caching, background refetching, and optimistic updates.
*   **Local Storage**:
    | Data Type | Storage | Use Case |
    |:--|:--|:--|
    | Auth tokens | `expo-secure-store` | Encrypted keychain storage |
    | User preferences | `AsyncStorage` | Simple key-value settings |
    | Offline data | `expo-sqlite` | Complex relational offline data |
    | Large files | `expo-file-system` | Downloaded media, PDFs |
*   **Offline-First Pattern**: Write to local SQLite → sync to server when online → conflict resolution via last-write-wins or server-authority.

## 4. Software Topology
```
src/
├── app/                  # Expo Router pages
├── components/           # Reusable UI components
│   ├── ui/               # Primitives (Button, Input, Card)
│   └── features/         # Domain components (PostCard, UserAvatar)
├── hooks/                # Custom hooks (useAuth, useOfflineSync)
├── services/             # API client, storage wrappers
├── stores/               # Zustand or Context state management
├── constants/            # Colors, spacing, typography tokens
├── utils/                # Formatters, validators
└── types/                # TypeScript interfaces
```

## 5. Security
*   **Token Storage**: NEVER use `AsyncStorage` for auth tokens. Use `expo-secure-store` (iOS Keychain / Android Keystore).
*   **Certificate Pinning**: Use `expo-certificate-transparency` or custom native module for API communication.
*   **Biometric Auth**: `expo-local-authentication` for FaceID / TouchID / Fingerprint unlock.
*   **Code Obfuscation**: Enable Hermes engine (default in Expo SDK 49+) which compiles JS to bytecode.
*   **Sensitive Data**: Never log tokens, passwords, or PII to console in production builds.

## 6. Observability
*   **Crash Reporting**: Sentry (`@sentry/react-native`) or Firebase Crashlytics.
*   **Analytics**: Expo Analytics, Firebase Analytics, or Mixpanel.
*   **Performance Monitoring**: React Native Performance Monitor (dev) + Sentry Performance (prod).
*   **Health**: App startup time monitoring, JS bundle size tracking, memory leak detection.

# Lang Profile: React/TypeScript

> **Trigger:** Project has `.tsx` files + `react` in `package.json` dependencies.
> **Purpose:** Guide Agent to identify and inject missing CALLS edges caused by
> React's dynamic binding patterns that the generic EdgeResolver cannot resolve.

## When to Load

Agent MUST load this profile during Step 5b (Framework-Aware Edge Resolution)
when the detection signal matches:

| Signal | Check |
|:--|:--|
| `.tsx` files exist | `find <target-dir> -name "*.tsx" -type f \| head -1` |
| React dependency | `grep "react" <repo>/package.json` |

If BOTH signals match → load this profile. Otherwise → skip.

---

## Pattern 1: Custom Hook Destructuring (Priority: HIGH)

**Detection:**

```typescript
const { fn1, fn2, fn3 } = useXxx();
```

**Resolution Steps:**

1. Find the hook definition: `grep -rn "function useXxx\|const useXxx" <source-dir>`
2. Read the hook's return statement or return type to identify the source entities
3. Map each destructured name (`fn1`, `fn2`, `fn3`) to the corresponding entity
   in the hook's source file
4. Inject CALLS edge: `<current-file>::<caller> → <hook-source>::<entity>` with
   `confidence: 'INFERRED'`

**Example (real-world from app-tinycrm):**

```
Source:  pages/Customers.tsx
Code:    const { addCustomer, customers } = useStore()
Hook:    store.ts exports useStore() which returns { addCustomer, customers, ... }
Result:  Inject CALLS edge: pages/Customers.tsx → store.ts::addCustomer (INFERRED)
```

**Common hooks to trace:**
- `useStore()`, `useAuth()`, `useApi()` — custom state management hooks
- `useQuery()`, `useMutation()` — data fetching hooks (if source is internal)

---

## Pattern 2: useState Setter → SKIP

**Detection:**

```typescript
const [state, setState] = useState(initialValue);
```

**Action:** **DO NOT inject any edge.** `setState` is a React runtime primitive,
not a user-defined entity. The EdgeResolver correctly marks these as unresolved.

**Also skip:**
- `useRef()` — returns a mutable ref object
- `useMemo()`, `useCallback()` — returns computed values
- `useEffect()`, `useLayoutEffect()` — side-effect hooks with no return target

---

## Pattern 3: useContext Consumer

**Detection:**

```typescript
const value = useContext(MyContext);
// or with destructuring:
const { prop1, prop2 } = useContext(MyContext);
```

**Resolution Steps:**

1. Find context definition: `grep -rn "createContext" <source-dir>` → locate `MyContext`
2. Find provider: `grep -rn "MyContext.Provider" <source-dir>` → identify `value` prop
3. Trace `value` prop to its source object definition
4. Map destructured props to source entities
5. Inject CALLS edges similar to Pattern 1

**Complexity note:** Context providers often pass objects with mixed sources. Only
inject edges for entities that exist as graph nodes. Skip inline values.

---

## Pattern 4: Component Rendering (JSX)

**Detection:**

```tsx
<ComponentName prop1={handler} prop2={data} />
```

**Resolution Steps:**

1. Check if `ComponentName` is an internal component (exists in graph as a node)
2. If yes → inject CALLS edge: `<current-file> → <ComponentName-source-file>`
3. If `handler` is a function prop → **DO NOT inject indirect edge**
   (prevents false positive chains from prop drilling)

**Skip list:**
- HTML elements (`<div>`, `<span>`, `<input>`) — not components
- Third-party components (`<Button>` from MUI, `<Link>` from react-router) —
  not internal, excluded by graph scope

---

## Pattern 5: Higher-Order Component (HOC)

**Detection:**

```typescript
export default withAuth(MyComponent);
// or composed:
const Enhanced = compose(withAuth, withLoading)(MyComponent);
```

**Resolution Steps:**

1. Find HOC definition: `grep -rn "function withAuth\|const withAuth" <source-dir>`
2. Inject CALLS edge: `<current-file> → <HOC-source-file>::withAuth`
3. Note: The wrapped component is still the same entity — HOC adds behavior,
   doesn't create a new node

---

## Confidence & Safety Rules

1. **ALL edges injected via this profile MUST use `confidence: 'INFERRED'`**
2. Agent MUST verify the target entity exists in the graph (via `graph_query`)
   BEFORE injecting. If node not found → SKIP, do not guess
3. If uncertain about a binding → SKIP and log a note in the enrichment log
4. Maximum injection per session: 30 edges (to prevent runaway injection)
5. After injection → run `para-graph build` to verify edges persist and
   check resolution rate improvement

---

## Verification Checklist

After applying this profile, Agent SHOULD verify:

- [ ] All injected edges have `confidence: 'INFERRED'`
- [ ] No duplicate edges created (addEdge() dedup guard handles this)
- [ ] `resolvedEdges` count increased by expected amount
- [ ] `resolutionRate` improved in `metadata.json`
- [ ] No orphaned edges (both source and target nodes exist)

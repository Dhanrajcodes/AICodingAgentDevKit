# Checklist: secrets and configuration

Environment variables, keys, config files and CI secrets. Rules: SR-01, SR-18. Source: OWASP Secrets Management cheat sheet; OWASP Top 10:2025 A02 (Security Misconfiguration).

## Storage
- [ ] Secrets live in environment variables injected at runtime or in a secret manager (cloud KMS or secrets service, Vault, Doppler, 1Password, the host's secret store). Never in the repo, the image, or client code.
- [ ] `.env`, `.env.*` (except `.env.example`), key files, `*.pem`, credential JSON and service-account files are in `.gitignore` before the first commit. The kit's doctor flags unignored `.env` files.
- [ ] A committed `.env.example` lists every variable name with a comment and no real value.
- [ ] Config is validated at startup; the app refuses to start with a missing or malformed secret instead of falling back to a default.
- [ ] No default, sample or hard-coded credentials anywhere ("admin/admin", test API keys in code).

## Client and build
- [ ] Nothing secret in browser or mobile bundles. Only publishable keys (Stripe `pk_`, Supabase anon key with RLS on) go to the client, and you know why each is safe to expose.
- [ ] Watch build-time prefixes that ship variables to the browser (`NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_`, `REACT_APP_`). A secret with one of these prefixes is leaked.
- [ ] Source maps with embedded secrets or internal paths are not public.

## Scope and rotation
- [ ] Separate secrets per environment (dev, staging, production). Production secrets never on developer machines unless needed.
- [ ] Each key scoped to the least privilege the provider allows (restricted API keys, read-only tokens, IP or referrer limits).
- [ ] An owner and a rotation procedure for every secret. Rotate on staff changes and after any exposure.
- [ ] CI secrets available only to protected branches and trusted workflows; never printed; masked in logs. Pull requests from forks don't get secrets.

## Detection
- [ ] A secret scanner (gitleaks or TruffleHog) runs in pre-commit or CI, over the whole history once.
- [ ] Provider-side secret scanning or push protection enabled where available (for example GitHub secret scanning).
- [ ] If a secret is found in history: rotate it first, then clean history if needed. Deleting the line doesn't un-leak it.

## Configuration hygiene
- [ ] Debug mode, verbose errors, admin panels, sample apps and default accounts off in production.
- [ ] Framework and server version banners hidden.
- [ ] Feature flags for security-relevant behaviour default to the safe state.

## Verify
Run the secret scanner over the repo and history. Grep the built client bundle for key patterns. Start the app with one secret missing and confirm it refuses to start.

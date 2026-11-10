# Checklist: frontend and client security

Browser and mobile code: XSS, CSP, client storage and third-party scripts. XSS (CWE-79) is #1 in the CWE Top 25 (2025). Rules: SR-01, SR-07, SR-13. Sources: OWASP XSS Prevention, DOM-based XSS and CSP cheat sheets.

## XSS
- [ ] Rely on the framework's auto-escaping. Every use of `dangerouslySetInnerHTML`, `v-html`, `innerHTML`, `outerHTML`, `insertAdjacentHTML` or `document.write` is justified and fed only sanitised HTML (DOMPurify).
- [ ] No user input in `href`/`src` without checking the scheme (`javascript:` and `data:` URLs blocked).
- [ ] No `eval`, `new Function`, or string arguments to `setTimeout`/`setInterval`.
- [ ] Markdown and rich text rendered with a sanitiser and a safe-link policy.
- [ ] A strict CSP is deployed (see `infra-deploy.md`), with no `unsafe-inline` or `unsafe-eval` for scripts.
- [ ] Where supported, Trusted Types are enforced (`require-trusted-types-for 'script'`) so DOM sinks only accept vetted values.

## Client storage
- [ ] No secrets, tokens with broad scope, or sensitive personal data in `localStorage`, `sessionStorage`, IndexedDB or unencrypted mobile storage. Mobile apps use the Keychain or Keystore.
- [ ] Auth uses `HttpOnly` cookies where possible.
- [ ] Clear client caches of user data on sign-out.

## Trust boundary
- [ ] Every check done in the client is repeated on the server (prices, permissions, limits, validation).
- [ ] Hidden or disabled UI is never the protection.
- [ ] Feature flags and role checks in the client are only for display.

## Third-party code
- [ ] Analytics, chat widgets, tag managers and CDNs are reviewed and allow-listed in CSP. Each one can read the page.
- [ ] Scripts from CDNs use Subresource Integrity (`integrity=`) or are self-hosted.
- [ ] No sensitive data sent to analytics or session replay; mask inputs.

## Navigation and embedding
- [ ] Links with `target="_blank"` to other sites use `rel="noopener noreferrer"` (modern browsers default `noopener`, but be explicit for user content).
- [ ] Open redirects blocked: redirect targets are relative paths or an allow-list.
- [ ] Clickjacking prevented with CSP `frame-ancestors`.
- [ ] `postMessage` handlers check `event.origin`; senders specify an exact target origin.

## Mobile specifics
- [ ] No secrets in the app bundle; anything shipped can be extracted.
- [ ] Deep links validated like any other input.
- [ ] Certificate checks never disabled, including in debug builds that might ship.

## Verify
Put `<img src=x onerror=alert(1)>` and `javascript:alert(1)` into every text and link field and view the result. Check the browser console for CSP violations. Inspect storage after sign-in and sign-out.

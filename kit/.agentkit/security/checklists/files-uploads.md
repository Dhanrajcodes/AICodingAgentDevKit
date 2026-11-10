# Checklist: files, uploads and URLs

Uploads, downloads, file processing and features that fetch user-supplied URLs. Rules: SR-12, SR-13, SR-15. Sources: OWASP File Upload and SSRF Prevention cheat sheets; OWASP Top 10:2025 A01 (SSRF folded into access control).

## Uploads
- [ ] Allow-list of file types by extension and by content (magic bytes), not by the client's `Content-Type`.
- [ ] Size limits per file and per request, enforced before the whole file is read into memory.
- [ ] Files renamed to a random server-side name. The original filename is stored only as escaped metadata.
- [ ] Stored outside the web root, ideally in private object storage. Served through an authorised route or short-lived signed URLs.
- [ ] Never executed, included or interpreted on the server. The storage location can't run scripts.
- [ ] Served with `Content-Disposition: attachment` for anything not meant to display inline, plus `X-Content-Type-Options: nosniff`.
- [ ] Images re-encoded (strips metadata and polyglot payloads) when they'll be shown to other users. Location metadata (EXIF GPS) removed.
- [ ] SVG treated as code: sanitise or don't accept it for user-visible display.
- [ ] Archives (zip, tar) checked for path traversal (`../`), symlinks and decompression bombs before extracting.
- [ ] Malware scanning for files shared between users, where the risk warrants it.
- [ ] Upload endpoints are authenticated and rate-limited, with per-user storage quotas.

## Downloads and access
- [ ] Every file request checks that the caller may access that file (no guessable sequential IDs).
- [ ] Signed URLs expire quickly and are scoped to one object.
- [ ] Buckets private; listing disabled.

## Processing
- [ ] File parsers (PDF, image, office, XML) kept up to date and run with limits on time and memory; isolated for untrusted input where possible.
- [ ] XML parsing has external entities (XXE) and DTDs disabled.
- [ ] CSV exports protected against formula injection (prefix cells starting with `=`, `+`, `-`, `@`).

## Fetching user URLs (SSRF)
- [ ] Only `https` (and `http` if needed) schemes. No `file:`, `gopher:`, `ftp:` and similar.
- [ ] Resolve the hostname and block private, loopback, link-local, and cloud metadata ranges (`10/8`, `172.16/12`, `192.168/16`, `127/8`, `169.254/16`, `::1`, `fc00::/7`, `fe80::/10`) after DNS resolution and after every redirect.
- [ ] Allow-list target domains when the feature permits it.
- [ ] Timeouts, response size limits, and a limit on redirects.
- [ ] The fetcher runs with no access to internal credentials or networks where possible.

## Verify
Upload a renamed executable, an oversized file, an SVG with a script, a zip with `../` paths and a file with GPS metadata. Point the URL feature at `http://169.254.169.254/` and `http://localhost`. All must be refused or neutralised.

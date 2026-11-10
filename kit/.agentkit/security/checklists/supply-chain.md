# Checklist: software supply chain

Adding or updating dependencies, CI/CD, builds and containers. Software Supply Chain Failures is A03 in OWASP Top 10:2025. Rules: SR-04 to SR-06. Sources: SLSA v1.2; NIST SSDF SP 800-218 v1.1; OpenSSF; Spracklen et al., "We Have a Package for You!" (USENIX Security 2025).

## Before adding a dependency (AI agents: always)
- [ ] The package exists on the official registry under that exact name. LLMs invent plausible package names; in the USENIX 2025 study, about 5% of packages suggested by commercial models and about 22% by open-source models didn't exist, and attackers register such names ("slopsquatting").
- [ ] Not a typo or look-alike of a popular package. Check the publisher, repository link, download count and release history.
- [ ] Maintained: recent releases, issues answered, no "deprecated" notice.
- [ ] Licence compatible with the project.
- [ ] No known vulnerabilities in the version chosen (osv.dev, GitHub Advisory Database, the ecosystem's audit tool).
- [ ] Really needed: the platform or an existing dependency can't do it. Logged in `DECISIONS.md` with the reason.
- [ ] Install scripts (`postinstall`) reviewed or disabled for packages that don't need them.
- [ ] Dependency confusion blocked: private or internal package names are scoped (`@company/...`) and the registry is pinned per scope, so a public package with the same name can't be pulled in.
- [ ] Brand-new packages and versions (published days ago) get extra scrutiny; recent supply-chain attacks shipped malware in fresh releases of popular packages. Consider a minimum release age in Renovate or the package manager.

## Lock and pin
- [ ] Lockfile committed. CI installs from it (`npm ci`, `pnpm install --frozen-lockfile`, `uv sync --frozen`, `pip install --require-hashes`, `go mod verify`).
- [ ] Docker base images pinned by digest or exact version; minimal images (distroless, slim, alpine where it fits).
- [ ] GitHub Actions and other CI steps pinned to a full commit SHA or a trusted major version from verified publishers.

## Continuous checks
- [ ] Dependency scanning in CI: `npm audit` / `pnpm audit`, `pip-audit`, `osv-scanner`, or `govulncheck`. Critical and High block the merge.
- [ ] Automated update PRs (Dependabot or Renovate), reviewed rather than auto-merged for major versions.
- [ ] Container and IaC scanning (Trivy or equivalent) for images and Terraform/Kubernetes files.
- [ ] Static analysis (CodeQL, Semgrep or Opengrep) on every pull request.

## CI/CD and builds
- [ ] CI tokens least-privilege (`permissions: contents: read` by default in GitHub Actions).
- [ ] CI deploys to cloud with short-lived OIDC credentials (workload identity federation) instead of long-lived keys stored as secrets.
- [ ] An SBOM (CycloneDX or SPDX) is generated for released artifacts and images.
- [ ] No `pull_request_target` or equivalent running untrusted code with secrets.
- [ ] Protected main branch: reviews required, status checks required, no force-push.
- [ ] Builds reproducible from source in CI, not from a developer laptop. Aim for SLSA Build Level 2+ provenance for published artifacts.
- [ ] Artifacts and images signed where the platform supports it (Sigstore/cosign, npm provenance).

## AI tools and agent extensions
- [ ] MCP servers, editor extensions, agent skills and plugins treated as dependencies: from known publishers, reviewed, pinned, least privilege.

## Verify
Show the audit tool output, the lockfile in the diff, and the registry page for each new package.

# Research: invoice number collisions

- Checked: 2026-11-04
- Question: Does `MAX(number) + 1` produce duplicate invoice numbers under concurrent creates?
- Feeds decision: how invoice numbers are assigned (D-0004)

## Findings
| Claim | Source | Confidence |
|---|---|---|
| 200 parallel creates in one workspace with `MAX(number)+1` gave 37 duplicate numbers | Local experiment, `api/scripts/numbering-race.ts`, dev Postgres 16 | Verified (ran 3 times: 37, 41, 29) |
| A counter row locked with `SELECT ... FOR UPDATE` gave 0 duplicates and no gaps | Same script, `--strategy=locked-row`, 5 runs | Verified |
| Locked-row create latency about 4 ms median at 200 parallel requests | Same script, timing output | Verified (dev machine only) |
| Postgres sequences can skip values when a transaction rolls back | PostgreSQL docs, "Sequence Manipulation Functions" | Verified (docs) |

## Options
| Option | Fit | Cost | Risk | Notes |
|---|---|---|---|---|
| MAX+1 with retry | Low | Low | Duplicates without the constraint; retries under load | Current code |
| Sequence per workspace | Medium | Low | Gaps on rollback break the gap-free requirement | |
| Locked counter row | High | Low | Serialises creates per workspace | Measured fine |

## Recommendation
Locked counter row in the create transaction, keeping the unique constraint.

## Unknown
Latency on the production database tier; re-measure after the first deploy.

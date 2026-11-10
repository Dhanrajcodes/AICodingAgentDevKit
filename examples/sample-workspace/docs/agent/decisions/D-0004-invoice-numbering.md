# D-0004: Invoice numbers from a locked per-workspace sequence

- Date: 2026-11-04
- By: owner
- Status: active

## Context
Invoice numbers must be unique and gap-free per workspace (owner requirement, `docs/client/requirements.md` §3). The first version used `MAX(number) + 1`. A concurrency test produced duplicates (`research/invoice-numbering.md`).

## Options
| Option | For | Against |
|---|---|---|
| `MAX(number)+1` with a unique constraint and retry | Simple | Retries under load; still racy without the constraint |
| Postgres `SEQUENCE` per workspace | Fast | Sequences skip numbers on rollback, so not gap-free; one sequence per workspace is awkward |
| Counter row per workspace, `SELECT ... FOR UPDATE` in the create transaction | Gap-free, simple, correct | Serialises invoice creation per workspace (fine at our volume) |

## Decision
Counter row per workspace (`workspace_counters.next_invoice_number`), locked with `FOR UPDATE` and incremented in the same transaction that inserts the invoice. Unique constraint on `(workspace_id, number)` stays as the last line of defence.

## Consequences
- Invoice creation for one workspace is serialised; measured at about 4 ms per create, acceptable.
- Rolled-back creates don't consume a number.
- Any new path that creates invoices must go through `createInvoice()` in `api/src/invoices/create.ts`.

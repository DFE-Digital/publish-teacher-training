# Data retention

When a retention policy deletes candidate data, it records what it removed in the `retention_deletion` table. Data & Insights read that record from the analytics copy, so they can remove the same rows from BigQuery.

Nothing writes to the table yet. Retention policies and the jobs that apply them come later.

## The table

**Table:** `retention_deletion`
**Model:** [`app/models/retention_deletion.rb`](../app/models/retention_deletion.rb)

| Column | Type | Holds |
|---|---|---|
| `id` | bigint | Primary key |
| `entity_type` | text | What the policy deleted, for example `candidate` |
| `entity_id` | text | The id of that entity, as a string |
| `deleted_records` | jsonb | Every row removed, as table name => array of id strings |
| `deleted_at` | timestamp | When the deletion happened |
| `created_at` | timestamp | When the entry was written |

Example `deleted_records` for a candidate with two saved courses:

```json
{"candidate": ["123"], "saved_course": ["456", "457"]}
```

## Rules

- **Retention only.** A Support user deleting a record is not a retention deletion and does not belong here.
- **Same transaction.** Write the entry in the transaction that deletes the rows, so a rolled-back deletion leaves no entry and a committed one always has one.
- **Identifiers only.** No personal data and no snapshot of what was deleted, so the table needs no sanitising and is fully streamed to analytics.
- **No foreign keys.** The rows it names are gone.
- **Append-only.** The model refuses updates and destroys once saved. Anything that skips the model's callbacks gets past that — `delete`, the `_all` and `upsert` methods, raw SQL — so write entries with `create!` only. Agree a retention period with Data & Insights before adding any cleanup.

## Analytics

Every column is listed in [`config/analytics.yml`](../config/analytics.yml). dfe-analytics sends each new entry to BigQuery as an entity event wherever `send_request_data_to_bigquery` is on, and Airbyte replicates the table through the `retention_deletion` stream in [`terraform/aks/workspace_variables/airbyte_stream_config.json`](../terraform/aks/workspace_variables/airbyte_stream_config.json), with `incremental_append` sync. A new column needs both files.

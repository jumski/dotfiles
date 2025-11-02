# Example: Scripted Skill (Low Freedom)

## Table of Contents
- [Use Case](#use-case)
- [Structure](#structure)
- [SKILL.md](#skillmd)
- [Helper Scripts](#helper-scripts)
- [Why This Works](#why-this-works)

## Use Case
Database migrations with backup and rollback.

## Structure
```
database-migrator/
├── SKILL.md
├── scripts/
│   ├── backup.sh
│   ├── migrate.sh
│   └── rollback.sh
└── reference.md
```

## SKILL.md

```markdown
---
name: database-migrator
description: Use when user asks to "run migration", "migrate database", or "apply schema changes". Handles database migrations with backup/rollback. CRITICAL operation.
allowed-tools: Read, Bash
---

# Database Migrator

Safely applies database migrations with automatic backup.

<critical>
Production database changes. Follow exactly. NEVER modify commands.
</critical>

## Process

### 1. Pre-flight
\`\`\`bash
ls -la db/migrations/pending/
psql $DATABASE_URL -c "SELECT version();"
\`\`\`
If connection fails: STOP

### 2. Backup
\`\`\`bash
./scripts/backup.sh
ls -lh backups/  # Verify file created
\`\`\`
If no file: STOP

### 3. Review & Confirm
Show user pending migrations, ask permission to proceed.

### 4. Migrate
\`\`\`bash
./scripts/migrate.sh
\`\`\`

### 5. Verify
\`\`\`bash
psql $DATABASE_URL -c "SELECT * FROM schema_migrations LIMIT 5;"
npm run test:smoke
\`\`\`

### 6. Rollback if Failed
If ANY validation fails:
\`\`\`bash
./scripts/rollback.sh
\`\`\`

See [reference.md](reference.md) for troubleshooting.
```

## Helper Scripts

### backup.sh
```bash
#!/usr/bin/env bash
set -euo pipefail

BACKUP_FILE="backups/backup_$(date +%Y%m%d_%H%M%S).sql"
mkdir -p backups
pg_dump "$DATABASE_URL" > "$BACKUP_FILE"
echo "✓ Backup created: $BACKUP_FILE"
```

### migrate.sh
```bash
#!/usr/bin/env bash
set -euo pipefail

for migration in db/migrations/pending/*.sql; do
  echo "Applying: $(basename "$migration")"
  psql "$DATABASE_URL" -f "$migration"
  mv "$migration" db/migrations/applied/
done
echo "✓ Migration completed"
```

### rollback.sh
```bash
#!/usr/bin/env bash
set -euo pipefail

LATEST=$(ls -t backups/*.sql | head -n 1)
psql "$DATABASE_URL" < "$LATEST"
echo "✓ Rolled back to $LATEST"
```

## Why This Works

- **Low Freedom**: Exact commands, no modification
- **Helper Scripts**: Complex ops encapsulated
- **Multiple Validations**: Safety checks throughout
- **Tool Restrictions**: Limited to Read + Bash
- **User Confirmation**: Asks before destructive changes

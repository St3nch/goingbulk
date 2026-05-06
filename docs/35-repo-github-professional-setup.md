# GoingBulk Repo and GitHub Professional Setup

## Purpose

This document defines how the GoingBulk local repository and GitHub repository should be set up professionally from day one.

GoingBulk should be treated as a real software product, not a loose folder of experiments.

## Core Decision

GoingBulk should be a standalone Git repository at:

```text
C:\dev\goingbulk
```

It should later be portable into VedaOps/V Forge as an existing child project, but it should not wait for VedaOps to become a disciplined repo.

## Core Principle

```text
Professional repo hygiene now prevents painful cleanup later.
```

## Repository Name

Recommended GitHub repo name:

```text
goingbulk
```

Alternative if under an organization:

```text
goingbulk-app
goingbulk-platform
```

Recommended default:

```text
goingbulk
```

Keep it simple, brand-aligned, and easy to remember.

## Repository Visibility

Recommended default at the start:

```text
Private GitHub repository
```

Reason:

- early code may change rapidly;
- health/data/security decisions are still forming;
- secrets mistakes are easier to contain;
- product strategy is still private;
- public launch does not require public source code.

Going public later is optional.

## Local Folder Structure

Recommended structure:

```text
goingbulk/
  app/
  components/
  content/
  db/
  docs/
  drizzle/
  lib/
  public/
  scripts/
  tests/
  .env.example
  .gitignore
  README.md
  package.json
```

### app/

Next.js App Router pages, layouts, route handlers, and server components.

### components/

Reusable UI components.

### content/

MDX content for MVP public pages.

Example:

```text
content/pages/about.mdx
content/methodology/index.mdx
content/experiments/baseline-30-days.mdx
content/experiments/baseline-30-days-pre-registration.mdx
```

### db/

Database connection, schema definitions, and query helpers.

Example:

```text
db/schema.ts
db/client.ts
db/queries/
```

### drizzle/

Generated migration files.

### docs/

Project planning docs.

### lib/

Shared utilities.

### scripts/

Import scripts, seed scripts, and maintenance scripts.

### tests/

Automated tests.

## Git Ignore Requirements

`.gitignore` must block secrets and local/generated junk.

Required entries:

```gitignore
# dependencies
node_modules
.pnpm-store

# next
.next
out

# env
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# os/editor
.DS_Store
Thumbs.db
.vscode/settings.json
.idea

# misc
*.pem
*.key
*.p12
*.pfx

# local data/imports
local-data/
imports/private/
exports/private/
```

## Environment Files

Commit:

```text
.env.example
```

Do not commit:

```text
.env
.env.local
.env.production.local
```

`.env.example` should include placeholder keys only:

```text
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
DATABASE_URL=
```

Never commit real Supabase keys.

## README Requirements

The root README should include:

```text
Project summary
Current status
Tech stack
Local setup
Environment variables
Available scripts
Database/migration commands
Security notes
Docs link
VedaOps/V Forge portability note
```

## Recommended Package Manager

Recommended:

```text
pnpm
```

Reasons:

- fast;
- common in modern Next.js projects;
- lockfile is clean;
- good monorepo compatibility if needed later.

Commit:

```text
pnpm-lock.yaml
```

## Branch Strategy

Use a simple professional branch model.

```text
main = production-ready
feature/* = work branches
fix/* = bug fixes
chore/* = maintenance/docs/config
```

Examples:

```text
feature/app-foundation
feature/supabase-auth
feature/cronometer-import
feature/baseline-pages
chore/docs-roadmap
fix/import-deduplication
```

Avoid committing directly to `main` once the initial baseline is done.

## Commit Style

Use conventional-style commits.

Examples:

```text
chore: initialize goingbulk repo
chore: add project documentation
feat: add Next.js app shell
feat: add Supabase auth setup
feat: add Cronometer import preview
fix: prevent duplicate Cronometer imports
refactor: split nutrition import parser
security: tighten RLS policy for nutrition logs
docs: add local development portability plan
```

## Initial Commit Plan

### Commit 1

```text
chore: initialize GoingBulk documentation foundation
```

Includes:

```text
docs/
README.md
.gitignore
.env.example
```

### Commit 2

```text
chore: initialize Next.js app foundation
```

Includes:

```text
Next.js scaffold
TypeScript
pnpm lockfile
basic scripts
```

### Commit 3

```text
chore: add database and migration foundation
```

Includes:

```text
Drizzle setup
db folder
initial migration structure
Supabase docs/config notes
```

## GitHub Repository Settings

Recommended settings:

### General

```text
Visibility: Private initially
Default branch: main
Issues: Enabled
Projects: Optional
Wiki: Disabled initially
Discussions: Disabled initially
```

### Branch Protection

Once initial repo is stable, protect `main`.

Recommended rules:

```text
Require pull request before merging
Require status checks before merging once CI exists
Require linear history optional
Do not allow force pushes
Do not allow deletions
```

During very early solo setup, this can wait until the first app foundation commit is complete.

### Security

Enable:

```text
Dependabot alerts
Dependabot security updates
Secret scanning if available
Push protection if available
```

## GitHub Issues

Use issues for build tasks once coding starts.

Suggested labels:

```text
area:docs
area:auth
area:db
area:imports
area:ui
area:security
area:content
area:experiments
priority:critical
priority:high
priority:medium
priority:low
status:blocked
status:ready
```

## GitHub Milestones

Suggested milestones:

```text
M0 - Repo Foundation
M1 - MVP App Foundation
M2 - Database and RLS Foundation
M3 - Cronometer Import
M4 - Logging MVP
M5 - Public Baseline Pages
M6 - 30-Day Baseline Launch
```

## GitHub Project Board

Optional but useful.

Columns:

```text
Backlog
Ready
In Progress
Review
Done
Blocked
```

Do not overmanage before coding starts.

## Pull Request Template

Add later or early if useful:

```markdown
## Summary

What changed?

## Type

- [ ] Feature
- [ ] Fix
- [ ] Docs
- [ ] Security
- [ ] Refactor
- [ ] Chore

## Checklist

- [ ] No secrets committed
- [ ] RLS/security impact considered
- [ ] Database migration included if needed
- [ ] Docs updated if needed
- [ ] Tested locally
```

## Issue Template

Optional.

Useful issue types:

```text
Feature
Bug
Security/RLS Review
Schema Change
Content Page
Experiment/Report Task
```

## CI Recommendation

Add GitHub Actions once the app scaffold exists.

Minimum CI:

```text
install dependencies
typecheck
lint
run tests
build
```

Example commands:

```text
pnpm install --frozen-lockfile
pnpm typecheck
pnpm lint
pnpm test
pnpm build
```

## Secrets Policy

Never commit:

- Supabase service role key;
- database password;
- Vercel tokens;
- API keys;
- bloodwork PDFs;
- DEXA raw reports;
- private exports;
- private progress photos;
- personal IDs;
- `.env` files.

If a secret is committed:

```text
revoke immediately
rotate secret
remove from history if needed
document incident
```

## Data Files Policy

Raw health files should not live in the Git repo.

Do not commit:

```text
Cronometer exports with real personal data
lab PDFs
DEXA reports
progress photos
private exports
```

Use local ignored folders:

```text
local-data/
imports/private/
exports/private/
```

Public sample files should be synthetic or redacted.

## License

Recommended while private:

```text
No license file initially
```

If the repo becomes public later, choose a license intentionally.

Possible options:

```text
MIT for code
Creative Commons for content only if desired
All rights reserved for brand/content
```

Do not accidentally open-source personal health content or brand assets by using the wrong license.

## VedaOps / V Forge Portability Requirements

To make future V Forge import clean, maintain:

```text
README with setup commands
.env.example
clear scripts in package.json
docs folder kept current
migrations committed
API routes documented when added
security boundaries documented
no hidden local-only setup steps
```

Future V Forge should be able to understand:

```text
how to run it
how to test it
how to migrate it
what not to touch
how agents are allowed to access data
```

## Recommended First Local Commands

Once ready to initialize Git:

```powershell
cd C:\dev\goingbulk
git init -b main
git status
```

Then create:

```text
.gitignore
.env.example
README.md
```

Then commit:

```powershell
git add docs README.md .gitignore .env.example
git commit -m "chore: initialize GoingBulk documentation foundation"
```

Create private GitHub repo:

```powershell
gh repo create goingbulk --private --source . --remote origin --push
```

If using a GitHub organization, use:

```powershell
gh repo create ORG_NAME/goingbulk --private --source . --remote origin --push
```

## Core Rule

```text
Keep the repo boring, clean, private, documented, and portable.
```

A professional repo is not fancy. It is predictable.

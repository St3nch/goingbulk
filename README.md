# GoingBulk

GoingBulk is a public, data-driven fitness and health brand built around transparent personal tracking, structured N=1 experiments, public dashboards, product/service reviews, affiliate/sponsor disclosures, and professional-readable reports.

## Current Status

Next.js app foundation with documentation-first project planning.

The project is intentionally starting as a standalone Next.js app that can later be brought into the VedaOps / V Forge ecosystem as a child project.

## Planned Stack

- Next.js
- TypeScript
- Vercel
- Supabase Postgres
- Supabase Auth
- Supabase Storage
- Drizzle ORM + migrations
- MDX for early public content
- shadcn/ui
- TanStack Table later for advanced data exploration

## Core Rules

- GoingBulk is personal N=1 documentation, not medical advice.
- Supabase is the platform; Postgres schema discipline is the architecture.
- LLMs and agents never access the database directly. They use governed APIs only.
- Private health data is private by default. Public data is promoted intentionally.
- Build standalone now, VedaOps/V Forge compatible later.

## Local Development

Run these commands from the repo root:

```bash
pnpm install
pnpm dev
pnpm build
pnpm lint
pnpm test
pnpm db:migrate
```

## Environment Variables

Copy `.env.example` to `.env.local` and fill in real values locally.

Never commit real secrets.

## Docs

Project planning docs live in:

```text
docs/
```

Start with:

```text
docs/00-index.md
docs/31-revised-mvp-scope-after-audit.md
docs/32-full-project-roadmap.md
docs/34-local-dev-now-vforge-portability-plan.md
docs/35-repo-github-professional-setup.md
```

## Security Notes

Do not commit:

- `.env` files
- Supabase service role keys
- database passwords
- Cronometer exports with real personal data
- bloodwork PDFs
- DEXA reports
- progress photos
- private exports

## VedaOps / V Forge Portability

GoingBulk should remain independently runnable and deployable. Future VedaOps or V Forge integration should use documented APIs, build commands, and repo contracts rather than direct database access.

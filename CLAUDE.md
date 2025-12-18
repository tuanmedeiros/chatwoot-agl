# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chatwoot is an open-source omnichannel customer support platform (alternative to Intercom, Zendesk). Full-stack application combining Ruby on Rails backend with Vue 3 frontend.

**Tech Stack:**
- Backend: Ruby on Rails 7.1, PostgreSQL, Redis, Sidekiq
- Frontend: Vue 3 (Composition API), Vite, Tailwind CSS, Vuex
- Package Managers: pnpm 10.x (Node 23.x), Bundler (Ruby)

## Build / Test / Lint Commands

```bash
# Setup
bundle install && pnpm install

# Development
pnpm dev                    # Run full stack (overmind + Procfile.dev)
pnpm start:dev              # Alternative using foreman

# JavaScript/Vue
pnpm eslint                 # Lint JS/Vue files
pnpm eslint:fix             # Auto-fix linting issues
pnpm test                   # Run tests (Vitest)
pnpm test:watch             # Watch mode
pnpm test:coverage          # With coverage report

# Ruby
bundle exec rubocop -a      # Lint and auto-fix Ruby
bundle exec rspec spec/path/to/file_spec.rb           # Run specific test file
bundle exec rspec spec/path/to/file_spec.rb:LINE      # Run single test

# Other
pnpm story:dev              # Component docs (Histoire)
pnpm build:sdk              # Build widget SDK
```

## Architecture

### Directory Structure

```
app/
├── controllers/api/       # REST API (v1, v2 endpoints)
├── models/               # ActiveRecord models
├── services/             # Business logic layer
├── jobs/                 # Sidekiq background jobs
├── javascript/
│   ├── dashboard/        # Main dashboard SPA (Vuex store, routes)
│   ├── components-next/  # New component library (use for message bubbles)
│   ├── widget/           # Embeddable chat widget
│   ├── portal/           # Customer help center
│   ├── shared/           # Shared utilities and composables
│   └── entrypoints/      # Vite entry points
├── channels/             # ActionCable websockets
└── policies/             # Pundit authorization

config/
├── features.yml          # Feature flags
└── locales/              # Backend i18n (en.yml)

enterprise/               # Enterprise edition overlay (mirrors app/ structure)
spec/                     # RSpec tests
```

### Frontend Patterns

- Multi-entrypoint Vite build: dashboard, widget, portal, superadmin, survey
- State management: Vuex store in `app/javascript/dashboard/store`
- New components go in `components-next/` (older patterns being deprecated)
- Design system components in `design-system/`

### Backend Patterns

- Service layer: `app/services/` for business logic
- ActionCable for real-time updates
- Pundit for authorization policies
- Custom exceptions in `lib/custom_exceptions/`

## Code Style

### Vue/JavaScript
- Always use Composition API with `<script setup>` at the top
- PascalCase for components, camelCase for events
- ESLint with Airbnb base + Vue 3 recommended + Prettier
- No bare strings in templates; use i18n

### CSS/Styling
- **Tailwind only**: No custom CSS, no scoped CSS, no inline styles
- Colors defined in `tailwind.config.js` (uses Radix UI colors)
- Dark mode supported via `darkMode: 'class'`

### Ruby
- RuboCop rules enforced, 150 char max line length
- Use compact module/class definitions (avoid nested styles)
- Validate presence/uniqueness, add proper indexes on models

### Translations
- Only update `en.yml` (backend) and `en.json` (frontend)
- Other languages managed via Crowdin by community

## Enterprise Edition

The `enterprise/` directory extends/overrides OSS code:
- Before modifying core functionality, check for corresponding files in `enterprise/`
- Use extension points (hooks, feature flags) instead of hardcoding plan-specific behavior
- Enterprise specs go in `spec/enterprise/`
- Documentation: https://chatwoot.help/hc/handbook/articles/developing-enterprise-edition-features-38

## Git Workflow

- Branching model: git-flow
- Base branch: `develop`
- Stable releases: `master` or `v1.x.x` tags
- Husky pre-push hooks validate code before pushing

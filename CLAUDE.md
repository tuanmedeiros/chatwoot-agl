# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build / Test / Lint

- **Setup**: `bundle install && pnpm install`
- **Run Dev**: `pnpm dev` or `overmind start -f ./Procfile.dev`
- **Lint JS/Vue**: `pnpm eslint` / `pnpm eslint:fix`
- **Lint Ruby**: `bundle exec rubocop -a`
- **Test JS**: `pnpm test` or `pnpm test:watch`
- **Test Ruby**: `bundle exec rspec spec/path/to/file_spec.rb`
- **Single Test**: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`

## Architecture Overview

Chatwoot is a Rails 7 + Vue 3 omnichannel customer support platform.

### Backend (Ruby on Rails)
- **Models** (`app/models/`): Core entities include `Account`, `User`, `Conversation`, `Message`, `Contact`, `Inbox`, `Team`, `Label`
- **Controllers** (`app/controllers/`): API namespaced under `api/v1/` and `api/v2/`, scoped by account
- **Services** (`app/services/`): Business logic organized by domain (e.g., `conversations/`, `contacts/`, `messages/`)
- **Jobs** (`app/jobs/`): Sidekiq background jobs for async processing
- **Listeners** (`app/listeners/`): Event-driven architecture using Wisper for pub/sub

### Frontend (Vue 3 + Vite)
- **Dashboard** (`app/javascript/dashboard/`): Main agent/admin interface
  - `store/modules/`: Vuex store modules (conversations, contacts, agents, etc.)
  - `components/`: Legacy components (being deprecated)
  - `components-next/`: New component library with message bubbles and modern UI
  - `composables/`: Vue 3 composition API utilities
  - `api/`: API client modules
- **Widget** (`app/javascript/widget/`): Embeddable chat widget for websites
- **Portal** (`app/javascript/portal/`): Help center/knowledge base frontend
- **SDK** (`app/javascript/sdk/`): JavaScript SDK for widget integration

### Key Patterns
- **Channel Adapters**: Each messaging channel (WhatsApp, Facebook, Twitter, etc.) has its own service layer under `app/services/`
- **Webhooks**: Incoming webhooks from external services handled in `app/controllers/webhooks/`
- **ActionCable**: Real-time updates via WebSocket channels in `app/channels/`
- **API Versioning**: v1 for most features, v2 for reports

## Code Style

- **Ruby**: Follow RuboCop rules (150 character max line length)
- **Vue/JS**: Use ESLint (Airbnb base + Vue 3 recommended)
- **Vue Components**: Use PascalCase
- **Events**: Use camelCase
- **I18n**: No bare strings in templates; use i18n
- **Error Handling**: Use custom exceptions (`lib/custom_exceptions/`)
- **Models**: Validate presence/uniqueness, add proper indexes
- **Type Safety**: Use PropTypes in Vue, strong params in Rails
- **Vue API**: Always use Composition API with `<script setup>` at the top

## Styling

- **Tailwind Only**:
  - Do not write custom CSS
  - Do not use scoped CSS
  - Do not use inline styles
  - Always use Tailwind utility classes
- **Colors**: Defined in `tailwind.config.js` and `theme/colors.js`
  - Brand color (woot palette): Gold/Dark theme (`#C4934F` primary)
  - Uses Radix UI color scales

## General Guidelines

- MVP focus: Least code change, happy-path only
- No unnecessary defensive programming
- Break down complex tasks into small, testable units
- Iterate after confirmation
- Avoid writing specs unless explicitly asked
- Remove dead/unreachable/unused code
- Don't write multiple versions or backups for the same logic

## Project-Specific

- **Translations**:
  - Only update `en.yml` (backend) and `en.json` (frontend)
  - Other languages are handled by the community
- **Frontend**:
  - Use `components-next/` for message bubbles (legacy `components/` is being deprecated)
- **Branching**: Uses git-flow; base branch is `develop`

## Ruby Best Practices

- Use compact `module/class` definitions; avoid nested styles

## Enterprise Edition

Chatwoot has an Enterprise overlay under `enterprise/` that extends/overrides OSS code.

**Checklist for changes impacting core logic:**
- Search for related files in both trees before editing: `rg -n "FooService|ControllerName" app enterprise`
- If adding new endpoints, services, or models, consider whether Enterprise needs an override or extension point (`prepend_mod_with`, hooks, configuration)
- Avoid hardcoding instance- or plan-specific behavior in OSS; prefer configuration or feature flags
- Keep request/response contracts stable across OSS and Enterprise
- When renaming/moving shared code, mirror the change in `enterprise/`
- Add Enterprise-specific specs under `spec/enterprise`

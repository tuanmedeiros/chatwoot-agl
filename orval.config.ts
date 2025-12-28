import { defineConfig } from 'orval';

export default defineConfig({
  chatwoot: {
    input: {
      target: './swagger/swagger.json',
      validation: true,
    },
    output: {
      mode: 'tags-split',
      target: './app/javascript/dashboard/api/generated',
      schemas: './app/javascript/dashboard/api/generated/model',
      client: 'vue-query',
      baseUrl: '',
      override: {
        mutator: {
          path: './app/javascript/dashboard/api/axios-instance.ts',
          name: 'customInstance',
        },
        query: {
          useQuery: true,
          useMutation: true,
          useInfinite: true,
        },
      },
    },
    hooks: {
      afterAllFilesWrite: 'pnpm eslint:fix ./app/javascript/dashboard/api/generated',
    },
  },
});

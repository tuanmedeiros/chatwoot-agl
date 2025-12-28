# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Chatwoot API',
        version: 'v1',
        description: 'API documentation for Chatwoot - Customer Engagement Platform',
        contact: {
          email: 'hello@chatwoot.com'
        },
        license: {
          name: 'MIT License',
          url: 'https://opensource.org/licenses/MIT'
        }
      },
      paths: {},
      servers: [
        {
          url: 'https://app.chatwoot.com',
          description: 'Production server'
        },
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ],
      tags: [
        { name: 'Accounts', description: 'Account management APIs' },
        { name: 'Agents', description: 'Agent management APIs' },
        { name: 'Contacts', description: 'Contact management APIs' },
        { name: 'Conversations', description: 'Conversation management APIs' },
        { name: 'Messages', description: 'Message management APIs' },
        { name: 'Inboxes', description: 'Inbox management APIs' },
        { name: 'Teams', description: 'Team management APIs' },
        { name: 'Labels', description: 'Label management APIs' },
        { name: 'Kanban', description: 'Kanban board management APIs' }
      ],
      components: {
        securitySchemes: {
          userApiKey: {
            type: :apiKey,
            name: 'api_access_token',
            in: :header,
            description: 'Access token for user authentication. Can be obtained from Profile Settings.'
          },
          agentBotApiKey: {
            type: :apiKey,
            name: 'api_access_token',
            in: :header,
            description: 'Access token for agent bot authentication.'
          },
          platformAppApiKey: {
            type: :apiKey,
            name: 'api_access_token',
            in: :header,
            description: 'Access token for platform app authentication.'
          }
        },
        schemas: {
          # Common error schemas
          Error: {
            type: :object,
            properties: {
              message: { type: :string, example: 'Resource not found' },
              errors: {
                type: :array,
                items: { type: :string }
              }
            }
          },
          ValidationError: {
            type: :object,
            properties: {
              message: { type: :string, example: 'Validation failed' },
              errors: {
                type: :object,
                additionalProperties: {
                  type: :array,
                  items: { type: :string }
                },
                example: { name: ["can't be blank"] }
              }
            }
          },
          PaginationMeta: {
            type: :object,
            properties: {
              total: { type: :integer, example: 100 },
              page: { type: :integer, example: 1 },
              per_page: { type: :integer, example: 25 },
              total_pages: { type: :integer, example: 4 }
            }
          },

          # Kanban schemas
          KanbanBoard: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'Sales Pipeline' },
              description: { type: :string, nullable: true, example: 'Track sales opportunities' },
              account_id: { type: :integer, example: 1 },
              columns_count: { type: :integer, example: 4 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id name account_id]
          },
          KanbanColumn: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'To Do' },
              position: { type: :integer, example: 0 },
              board_id: { type: :integer, example: 1 },
              cards_count: { type: :integer, example: 5 }
            },
            required: %w[id name position board_id]
          },
          KanbanCard: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              title: { type: :string, example: 'Follow up with client' },
              description: { type: :string, nullable: true },
              position: { type: :integer, example: 0 },
              column_id: { type: :integer, example: 1 },
              assignee_id: { type: :integer, nullable: true },
              due_date: { type: :string, format: 'date', nullable: true },
              labels: {
                type: :array,
                items: { type: :string }
              },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id title position column_id]
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end

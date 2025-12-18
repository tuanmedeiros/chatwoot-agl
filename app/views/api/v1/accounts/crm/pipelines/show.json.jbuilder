json.payload do
  json.partial! 'api/v1/accounts/crm/pipelines/pipeline', pipeline: @pipeline, include_stages: true
end

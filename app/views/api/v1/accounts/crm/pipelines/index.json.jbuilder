json.payload do
  json.array! @pipelines do |pipeline|
    json.partial! 'api/v1/accounts/crm/pipelines/pipeline', pipeline: pipeline, include_stages: true
  end
end

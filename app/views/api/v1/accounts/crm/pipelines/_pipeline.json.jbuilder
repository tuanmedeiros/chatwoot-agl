json.id pipeline.id
json.name pipeline.name
json.description pipeline.description
json.is_default pipeline.is_default
json.position pipeline.position
json.created_at pipeline.created_at
json.updated_at pipeline.updated_at

if local_assigns[:include_stages]
  json.stages pipeline.stages.ordered do |stage|
    json.partial! 'api/v1/accounts/crm/stages/stage', stage: stage
  end
end

json.id deal.id
json.account_id deal.account_id
json.pipeline_id deal.pipeline_id
json.stage_id deal.stage_id
json.contact_id deal.contact_id
json.assignee_id deal.assignee_id
json.title deal.title
json.value deal.value.to_f
json.currency deal.currency
json.expected_close_date deal.expected_close_date
json.position deal.position
json.status deal.status
json.lost_reason deal.lost_reason
json.custom_attributes deal.custom_attributes
json.created_at deal.created_at
json.updated_at deal.updated_at
json.closed_at deal.closed_at

if local_assigns[:include_stage]
  json.stage do
    json.partial! 'api/v1/accounts/crm/stages/stage', stage: deal.stage
  end
end

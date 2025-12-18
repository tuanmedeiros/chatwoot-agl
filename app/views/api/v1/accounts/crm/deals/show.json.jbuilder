json.payload do
  json.partial! 'api/v1/accounts/crm/deals/deal', deal: @deal, include_stage: true
end

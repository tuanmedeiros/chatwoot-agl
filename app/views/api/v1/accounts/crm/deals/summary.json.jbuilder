json.payload do
  json.array! @summary do |stage_summary|
    json.stage_id stage_summary[:stage_id]
    json.stage_name stage_summary[:stage_name]
    json.stage_color stage_summary[:stage_color]
    json.deals_count stage_summary[:deals_count]
    json.total_value stage_summary[:total_value].to_f
  end
end

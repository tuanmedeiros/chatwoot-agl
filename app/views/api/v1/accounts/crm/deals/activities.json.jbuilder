json.payload do
  json.array! @activities do |activity|
    json.id activity.id
    json.deal_id activity.deal_id
    json.user_id activity.user_id
    json.activity_type activity.activity_type
    json.previous_value activity.previous_value
    json.new_value activity.new_value
    json.created_at activity.created_at
  end
end

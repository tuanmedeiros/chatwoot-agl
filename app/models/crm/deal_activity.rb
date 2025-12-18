# == Schema Information
#
# Table name: deal_activities
#
#  id             :bigint           not null, primary key
#  deal_id        :bigint           not null
#  user_id        :bigint           not null
#  activity_type  :string(50)       not null
#  previous_value :jsonb
#  new_value      :jsonb
#  created_at     :datetime
#
class Crm::DealActivity < Crm::CrmRecord
  self.table_name = 'deal_activities'

  ACTIVITY_TYPES = %w[
    created
    updated
    stage_changed
    status_changed
    assignee_changed
    value_changed
  ].freeze

  belongs_to :deal, class_name: 'Crm::Deal', foreign_key: :deal_id

  validates :deal_id, presence: true
  validates :user_id, presence: true
  validates :activity_type, presence: true, inclusion: { in: ACTIVITY_TYPES }

  scope :ordered, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(activity_type: type) }

  def stage_change?
    activity_type == 'stage_changed'
  end

  def previous_stage
    return nil unless stage_change? && previous_value.present?

    Crm::Stage.find_by(id: previous_value['stage_id'])
  end

  def new_stage
    return nil unless stage_change? && new_value.present?

    Crm::Stage.find_by(id: new_value['stage_id'])
  end
end

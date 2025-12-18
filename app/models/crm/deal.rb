# == Schema Information
#
# Table name: deals
#
#  id                  :bigint           not null, primary key
#  account_id          :bigint           not null
#  pipeline_id         :bigint           not null
#  stage_id            :bigint           not null
#  contact_id          :bigint           not null
#  assignee_id         :bigint           not null
#  title               :string(255)      not null
#  value               :decimal(15, 2)   default(0)
#  currency            :string(3)        default("BRL")
#  expected_close_date :date
#  position            :integer          default(0)
#  status              :string(20)       default("open")
#  lost_reason         :text
#  custom_attributes   :jsonb            default({})
#  created_at          :datetime
#  updated_at          :datetime
#  closed_at           :datetime
#
class Crm::Deal < Crm::CrmRecord
  self.table_name = 'deals'

  STATUSES = %w[open won lost].freeze
  CURRENCIES = %w[BRL USD EUR GBP].freeze

  belongs_to :pipeline, class_name: 'Crm::Pipeline', foreign_key: :pipeline_id
  belongs_to :stage, class_name: 'Crm::Stage', foreign_key: :stage_id
  has_many :activities, class_name: 'Crm::DealActivity', foreign_key: :deal_id, dependent: :destroy

  validates :account_id, presence: true
  validates :pipeline_id, presence: true
  validates :stage_id, presence: true
  validates :contact_id, presence: true
  validates :assignee_id, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :status, inclusion: { in: STATUSES }
  validates :currency, inclusion: { in: CURRENCIES }
  validates :value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Permission scope: Agent sees only their deals
  scope :for_assignee, ->(assignee_id) { where(assignee_id: assignee_id) }
  scope :for_account, ->(account_id) { where(account_id: account_id) }
  scope :for_pipeline, ->(pipeline_id) { where(pipeline_id: pipeline_id) }
  scope :for_stage, ->(stage_id) { where(stage_id: stage_id) }
  scope :open_deals, -> { where(status: 'open') }
  scope :won_deals, -> { where(status: 'won') }
  scope :lost_deals, -> { where(status: 'lost') }
  scope :ordered, -> { order(position: :asc) }

  before_create :set_position

  def move_to_stage!(new_stage_id, user_id, new_position: nil)
    old_stage_id = stage_id
    old_position = position

    transaction do
      self.stage_id = new_stage_id
      self.position = new_position || next_position_in_stage(new_stage_id)

      # Auto-update status based on stage type
      new_stage = Crm::Stage.find(new_stage_id)
      if new_stage.is_won
        self.status = 'won'
        self.closed_at = Time.current
      elsif new_stage.is_lost
        self.status = 'lost'
        self.closed_at = Time.current
      else
        self.status = 'open'
        self.closed_at = nil
      end

      save!

      # Log activity
      Crm::DealActivity.create!(
        deal_id: id,
        user_id: user_id,
        activity_type: 'stage_changed',
        previous_value: { stage_id: old_stage_id, position: old_position },
        new_value: { stage_id: new_stage_id, position: position }
      )
    end
  end

  def mark_as_won!(user_id)
    won_stage = pipeline.stages.won_stages.first
    raise 'No won stage configured for this pipeline' unless won_stage

    move_to_stage!(won_stage.id, user_id)
  end

  def mark_as_lost!(user_id, reason: nil)
    lost_stage = pipeline.stages.lost_stages.first
    raise 'No lost stage configured for this pipeline' unless lost_stage

    transaction do
      self.lost_reason = reason if reason.present?
      save!
      move_to_stage!(lost_stage.id, user_id)
    end
  end

  private

  def set_position
    self.position ||= next_position_in_stage(stage_id)
  end

  def next_position_in_stage(target_stage_id)
    Crm::Deal.where(stage_id: target_stage_id).maximum(:position).to_i + 1
  end
end

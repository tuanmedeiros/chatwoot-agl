# == Schema Information
#
# Table name: stages
#
#  id          :bigint           not null, primary key
#  pipeline_id :bigint           not null
#  name        :string(255)      not null
#  color       :string(7)        default("#6366f1")
#  position    :integer          default(0)
#  is_won      :boolean          default(FALSE)
#  is_lost     :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#
class Crm::Stage < Crm::CrmRecord
  self.table_name = 'stages'

  belongs_to :pipeline, class_name: 'Crm::Pipeline', foreign_key: :pipeline_id
  has_many :deals, class_name: 'Crm::Deal', foreign_key: :stage_id, dependent: :restrict_with_error

  validates :pipeline_id, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: 'must be a valid hex color' }, allow_blank: true

  validate :only_one_won_or_lost_per_pipeline

  scope :ordered, -> { order(position: :asc) }
  scope :won_stages, -> { where(is_won: true) }
  scope :lost_stages, -> { where(is_lost: true) }
  scope :active_stages, -> { where(is_won: false, is_lost: false) }

  before_create :set_position

  def closing_stage?
    is_won || is_lost
  end

  def deals_count
    deals.count
  end

  def deals_total_value
    deals.sum(:value)
  end

  private

  def set_position
    self.position ||= Crm::Stage.where(pipeline_id: pipeline_id).maximum(:position).to_i + 1
  end

  def only_one_won_or_lost_per_pipeline
    return unless is_won || is_lost

    if is_won && is_lost
      errors.add(:base, 'Stage cannot be both won and lost')
      return
    end

    existing = Crm::Stage.where(pipeline_id: pipeline_id)
                         .where.not(id: id)

    if is_won && existing.won_stages.exists?
      errors.add(:is_won, 'Another won stage already exists in this pipeline')
    end

    if is_lost && existing.lost_stages.exists?
      errors.add(:is_lost, 'Another lost stage already exists in this pipeline')
    end
  end
end

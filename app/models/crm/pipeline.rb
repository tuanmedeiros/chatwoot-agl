# == Schema Information
#
# Table name: pipelines
#
#  id          :bigint           not null, primary key
#  account_id  :bigint           not null
#  name        :string(255)      not null
#  description :text
#  is_default  :boolean          default(FALSE)
#  position    :integer          default(0)
#  created_at  :datetime
#  updated_at  :datetime
#
class Crm::Pipeline < Crm::CrmRecord
  self.table_name = 'pipelines'

  has_many :stages, class_name: 'Crm::Stage', foreign_key: :pipeline_id, dependent: :destroy
  has_many :deals, class_name: 'Crm::Deal', foreign_key: :pipeline_id, dependent: :destroy

  validates :account_id, presence: true
  validates :name, presence: true, length: { maximum: 255 }

  scope :for_account, ->(account_id) { where(account_id: account_id) }
  scope :default_pipeline, -> { where(is_default: true) }
  scope :ordered, -> { order(position: :asc) }

  before_create :set_position
  after_save :ensure_single_default

  def duplicate
    new_pipeline = dup
    new_pipeline.name = "#{name} (Copy)"
    new_pipeline.is_default = false
    new_pipeline.save!

    stages.ordered.each do |stage|
      new_stage = stage.dup
      new_stage.pipeline_id = new_pipeline.id
      new_stage.save!
    end

    new_pipeline
  end

  private

  def set_position
    self.position ||= Crm::Pipeline.for_account(account_id).maximum(:position).to_i + 1
  end

  def ensure_single_default
    return unless is_default && saved_change_to_is_default?

    Crm::Pipeline.where(account_id: account_id)
                 .where.not(id: id)
                 .update_all(is_default: false)
  end
end

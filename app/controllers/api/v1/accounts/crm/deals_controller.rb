class Api::V1::Accounts::Crm::DealsController < Api::V1::Accounts::Crm::BaseController
  before_action :set_current_page, only: [:index]
  before_action :fetch_deal, only: [:show, :update, :destroy, :move, :won, :lost, :activities]

  def index
    @deals = base_deals_scope
    @deals = apply_filters(@deals)
    @deals = @deals.ordered.page(@current_page).per(RESULTS_PER_PAGE)
    @deals_count = @deals.total_count
  end

  def show
    @deal
  end

  def create
    @deal = Crm::Deal.new(deal_params)
    @deal.account_id = Current.account.id
    @deal.assignee_id = current_user_id

    Crm::Deal.transaction do
      @deal.save!
      create_activity('created')
    end

    render :show, status: :created
  end

  def update
    old_values = track_changes
    @deal.assign_attributes(deal_update_params)

    Crm::Deal.transaction do
      @deal.save!
      create_update_activities(old_values)
    end

    render :show
  end

  def destroy
    @deal.destroy!
    head :ok
  end

  def move
    new_stage_id = move_params[:stage_id]
    new_position = move_params[:position]

    @deal.move_to_stage!(new_stage_id, current_user_id, new_position: new_position)
    render :show
  end

  def won
    @deal.mark_as_won!(current_user_id)
    render :show
  end

  def lost
    reason = params[:reason]
    @deal.mark_as_lost!(current_user_id, reason: reason)
    render :show
  end

  def activities
    @activities = @deal.activities.ordered.limit(50)
  end

  def summary
    pipeline_id = params[:pipeline_id]
    @stages = Crm::Stage.where(pipeline_id: pipeline_id).ordered

    @summary = @stages.map do |stage|
      deals = base_deals_scope.for_stage(stage.id)
      {
        stage_id: stage.id,
        stage_name: stage.name,
        stage_color: stage.color,
        deals_count: deals.count,
        total_value: deals.sum(:value)
      }
    end
  end

  private

  # Permission: Agent sees only their deals
  def base_deals_scope
    Crm::Deal.for_account(Current.account.id).for_assignee(current_user_id)
  end

  def fetch_deal
    @deal = base_deals_scope.find(params[:id])
  end

  def apply_filters(deals)
    deals = deals.for_pipeline(params[:pipeline_id]) if params[:pipeline_id].present?
    deals = deals.for_stage(params[:stage_id]) if params[:stage_id].present?
    deals = deals.where(status: params[:status]) if params[:status].present?
    deals
  end

  def deal_params
    params.permit(
      :pipeline_id, :stage_id, :contact_id, :title,
      :value, :currency, :expected_close_date,
      custom_attributes: {}
    )
  end

  def deal_update_params
    params.permit(
      :title, :value, :currency, :expected_close_date,
      custom_attributes: {}
    )
  end

  def move_params
    params.permit(:stage_id, :position)
  end

  def track_changes
    {
      value: @deal.value,
      assignee_id: @deal.assignee_id
    }
  end

  def create_activity(activity_type, previous_value: nil, new_value: nil)
    Crm::DealActivity.create!(
      deal_id: @deal.id,
      user_id: current_user_id,
      activity_type: activity_type,
      previous_value: previous_value,
      new_value: new_value
    )
  end

  def create_update_activities(old_values)
    if @deal.saved_change_to_attribute?(:value) && old_values[:value] != @deal.value
      create_activity(
        'value_changed',
        previous_value: { value: old_values[:value] },
        new_value: { value: @deal.value }
      )
    end
  end
end

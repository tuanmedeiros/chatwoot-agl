class Api::V1::Accounts::Crm::StagesController < Api::V1::Accounts::Crm::BaseController
  before_action :fetch_pipeline
  before_action :fetch_stage, only: [:show, :update, :destroy]

  def index
    @stages = @pipeline.stages.ordered
  end

  def show
    @stage
  end

  def create
    @stage = @pipeline.stages.new(stage_params)
    @stage.save!
    render :show, status: :created
  end

  def update
    @stage.update!(stage_params)
    render :show
  end

  def destroy
    if @stage.deals.exists?
      render json: { error: 'Cannot delete stage with existing deals. Move deals first.' }, status: :unprocessable_entity
      return
    end
    @stage.destroy!
    head :ok
  end

  def reorder
    reorder_params[:stages].each do |stage_data|
      stage = @pipeline.stages.find(stage_data[:id])
      stage.update!(position: stage_data[:position])
    end
    @stages = @pipeline.stages.ordered
    render :index
  end

  private

  def fetch_pipeline
    @pipeline = Crm::Pipeline.for_account(Current.account.id).find(params[:pipeline_id])
  end

  def fetch_stage
    @stage = @pipeline.stages.find(params[:id])
  end

  def stage_params
    params.permit(:name, :color, :position, :is_won, :is_lost)
  end

  def reorder_params
    params.permit(stages: [:id, :position])
  end
end

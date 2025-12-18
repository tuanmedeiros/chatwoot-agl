class Api::V1::Accounts::Crm::PipelinesController < Api::V1::Accounts::Crm::BaseController
  before_action :fetch_pipeline, only: [:show, :update, :destroy, :duplicate, :set_default]

  def index
    @pipelines = Crm::Pipeline.for_account(Current.account.id).ordered.includes(:stages)
  end

  def show
    @pipeline
  end

  def create
    @pipeline = Crm::Pipeline.new(pipeline_params)
    @pipeline.account_id = Current.account.id
    @pipeline.save!
    render :show, status: :created
  end

  def update
    @pipeline.update!(pipeline_params)
    render :show
  end

  def destroy
    if @pipeline.deals.exists?
      render json: { error: 'Cannot delete pipeline with existing deals' }, status: :unprocessable_entity
      return
    end
    @pipeline.destroy!
    head :ok
  end

  def duplicate
    @new_pipeline = @pipeline.duplicate
    @pipeline = @new_pipeline
    render :show, status: :created
  end

  def set_default
    @pipeline.update!(is_default: true)
    render :show
  end

  private

  def fetch_pipeline
    @pipeline = Crm::Pipeline.for_account(Current.account.id).find(params[:id])
  end

  def pipeline_params
    params.permit(:name, :description, :is_default, :position)
  end
end

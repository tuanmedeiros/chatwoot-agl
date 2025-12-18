class Api::V1::Accounts::Crm::BaseController < Api::V1::Accounts::BaseController
  RESULTS_PER_PAGE = 25

  private

  def set_current_page
    @current_page = params[:page] || 1
  end

  def current_user_id
    Current.user.id
  end

  def check_crm_authorization
    # All authenticated users can access CRM
    # Specific authorization (e.g., agent sees only their deals) is handled in each controller
    true
  end
end

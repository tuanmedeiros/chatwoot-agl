# Base class for all CRM models
# Connects to the separate CRM database
class Crm::CrmRecord < ActiveRecord::Base
  self.abstract_class = true

  # Connect to CRM database based on environment
  def self.crm_database_config
    "crm_#{Rails.env}".to_sym
  end

  establish_connection crm_database_config
end

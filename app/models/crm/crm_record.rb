# Base class for all CRM models
# Connects to the separate CRM database
class Crm::CrmRecord < ActiveRecord::Base
  self.abstract_class = true

  # Connect to CRM database based on environment
  def self.crm_database_config
    "crm_#{Rails.env}".to_sym
  end

  # Only establish connection if CRM database is configured
  # This allows Docker builds and environments without CRM to work properly
  if ENV['CRM_DATABASE_URL'].present? || ENV['CRM_POSTGRES_HOST'].present?
    establish_connection crm_database_config
  end
end

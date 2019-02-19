require "rails_helper"

RSpec.describe 'Application config' do
  it 'configures Pundit::NotAuthorizedError to return service_unavailable' do
    expect(Rails.application.config.action_dispatch.rescue_responses['Pundit::NotAuthorizedError'])
      .to eq :forbidden
  end

  it 'configures Pg::ConnectionBad to return service_unavailable' do
    expect(Rails.application.config.action_dispatch.rescue_responses['PG::ConnectionBad'])
      .to eq :service_unavailable
  end
end

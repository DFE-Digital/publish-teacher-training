require "rails_helper"

describe 'ProviderUCASPreference factory' do
  subject { create(:provider_ucas_preference) }

  let(:valid_types_of_gt12) do
    %w[
      coming_or_not
      coming_enrol
      not_coming
      no_response
    ]
  end
  let(:valid_send_application_alerts) do
    %w[
      all
      none
      my_programmes
      accredited_programmes
    ]
  end

  it { should be_instance_of(ProviderUCASPreference) }
  it { should be_valid }
  its(:type_of_gt12) { should be_in valid_types_of_gt12 }
  its(:send_application_alerts) { should be_in valid_send_application_alerts }
end

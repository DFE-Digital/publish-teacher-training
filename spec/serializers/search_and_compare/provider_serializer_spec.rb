require 'rails_helper'

describe SearchAndCompare::ProviderSerializer do
  let(:provider) { create :provider }

  describe 'json output' do
    let(:resource) { serialize(provider, serializer_class: described_class) }

    subject { resource }

    describe 'Provider_default_value_Mapping' do
      it { should include(Id: 0) }
      it { should include(Courses: nil) }
      it { should include(AccreditedCourses: nil) }
    end

    describe 'Provider_direct_simple_Mappting' do
      it { should include(Name: provider.provider_name) }
      it { should include(ProviderCode: provider.provider_code) }
    end
  end
end

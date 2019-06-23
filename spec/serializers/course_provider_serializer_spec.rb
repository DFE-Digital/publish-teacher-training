require "rails_helper"

RSpec.describe CourseProviderSerializer do
  let(:provider) { create :provider }
  subject { serialize(provider, serializer_class: described_class) }

  it { should include(accrediting_provider: provider.accrediting_provider_before_type_cast) }
end

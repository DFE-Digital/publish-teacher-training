require "rails_helper"

describe NCTLOrganisation, type: :model do
  it { is_expected.to belong_to(:organisation) }
end

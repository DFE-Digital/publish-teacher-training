require "rails_helper"

describe NCTLOrganisation, type: :model do
  it { should belong_to(:organisation) }
end

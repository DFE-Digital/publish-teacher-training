require "rails_helper"

describe ContactSerializer do
  let(:contact) { create :contact }

  subject { serialize(contact) }

  its([:type]) { is_expected.to eq contact.type }
  its([:name]) { is_expected.to eq contact.name }
  its([:email]) { is_expected.to eq contact.email }
  its([:telephone]) { is_expected.to eq contact.telephone }
end

require "rails_helper"

describe ContactSerializer do
  let(:contact) { create :contact }

  subject { serialize(contact) }

  its([:type]) { should eq contact.type }
  its([:name]) { should eq contact.name }
  its([:email]) { should eq contact.email }
  its([:telephone]) { should eq contact.telephone }
end

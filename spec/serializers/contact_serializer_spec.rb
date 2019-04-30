# == Schema Information
#
# Table name: contact
#
#  id          :bigint           not null, primary key
#  provider_id :integer          not null
#  type        :text             not null
#  name        :text
#  email       :text
#  telephone   :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "rails_helper"

describe ContactSerializer do
  let(:contact) { create :contact }

  subject { serialize(contact) }

  its([:type]) { should eq contact.type }
  its([:name]) { should eq contact.name }
  its([:email]) { should eq contact.email }
  its([:telephone]) { should eq contact.telephone }
end

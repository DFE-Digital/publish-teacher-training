# == Schema Information
#
# Table name: contact
#
#  created_at  :datetime         not null
#  email       :text
#  id          :bigint           not null, primary key
#  name        :text
#  provider_id :integer          not null
#  telephone   :text
#  type        :text             not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_contact_on_provider_id           (provider_id)
#  index_contact_on_provider_id_and_type  (provider_id,type) UNIQUE
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

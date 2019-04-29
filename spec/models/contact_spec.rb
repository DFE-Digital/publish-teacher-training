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

require 'rails_helper'

describe Contact, type: :model do
  it { should belong_to(:provider) }

  describe 'type' do
    it 'is an enum' do
      expect(subject)
        .to define_enum_for(:type)
              .backed_by_column_of_type(:text)
              .with_values(
                admin: 'admin',
                utt: 'utt',
                web_link: 'web_link',
                fraud: 'fraud',
                finance: 'finance'
              )
              .with_suffix('contact')
    end
  end
end

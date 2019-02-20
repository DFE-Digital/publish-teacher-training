require 'rails_helper'

RSpec.describe Qualifications, type: :model do
  describe 'QTS only' do
    subject { Qualifications.new(profpost_flag: "recommendation_for_qts", is_pgde: false, is_fe: false) }

    its(:to_a) { should eq([:qts])}
  end
end

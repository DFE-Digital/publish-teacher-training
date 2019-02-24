require 'rails_helper'

RSpec.describe WithQualifications, type: :model do
  specs = [
    qts: [:qts],
    pgce: [:pgce],
    pgde: [:pgde],
    pgce_with_qts: %i[qts pgce],
    pgde_with_qts: %i[qts pgde],
  ].freeze

  describe "#qualifications" do
    specs.each do |spec|
      spec.each do |qualification, expected|
        context "course with qualification=#{qualification}" do
          subject { create(:course, qualification: qualification) }

          its(:qualifications) { should eq(expected) }
        end
      end
    end
  end
end

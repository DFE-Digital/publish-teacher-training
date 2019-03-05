require 'rails_helper'

RSpec.describe WithQualifications, type: :model do
  specs = [
    qts: { values: [:qts], description: "QTS" },
    pgce: { values: [:pgce], description: "PGCE" },
    pgde: { values: [:pgde], description: "PGDE" },
    pgce_with_qts: { values: %i[qts pgce], description: "PGCE with QTS" },
    pgde_with_qts: { values: %i[qts pgde], description: "PGDE with QTS" },
  ].freeze

  describe "#qualifications" do
    specs.each do |spec|
      spec.each do |qualification, expected|
        context "course with qualification=#{qualification}" do
          subject { create(:course, qualification: qualification) }

          its(:qualifications) { should eq(expected[:values]) }
          its(:qualifications_description) { should eq(expected[:description]) }
        end
      end
    end
  end
end

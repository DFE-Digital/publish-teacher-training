require "rails_helper"

describe WithQualifications, type: :model do
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
          subject { build(:course, qualification: qualification) }

          its(:qualifications) { is_expected.to eq(expected[:values]) }
          its(:qualifications_description) { is_expected.to eq(expected[:description]) }
        end
      end
    end
  end

  describe "#qualifications_description" do
    context "no qualification present" do
      subject { build(:course, qualification: nil) }

      its(:qualifications_description) { is_expected.to eq "" }
    end
  end

  describe "#qualification= and its dependent attribute profpost_flag" do
    subject { build(:course, qualification: :pgce_with_qts) }

    context "when the qualification is QTS only" do
      before { subject.qualification = :qts }

      its(:qualification) { is_expected.to eq("qts") }
      its(:profpost_flag) { is_expected.to eq("recommendation_for_qts") }
    end

    (Course.qualifications.keys - %w[qts]).each do |qualification|
      context "when the qualification is #{qualification}" do
        before { subject.qualification = qualification }

        its(:qualification) { is_expected.to eq(qualification) }
        its(:profpost_flag) { is_expected.to eq("postgraduate") }
      end
    end
  end
end

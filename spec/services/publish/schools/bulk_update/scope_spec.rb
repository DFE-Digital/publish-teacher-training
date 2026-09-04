# frozen_string_literal: true

require "rails_helper"

describe Publish::Schools::BulkUpdate::Scope do
  let(:provider) { create(:provider) }

  def tokens_for(course)
    described_class.available(course).map(&:token)
  end

  def labels_for(course)
    described_class.available(course).map(&:label)
  end

  describe ".available" do
    it "offers this course, its funding, its subject and all courses, in that order" do
      course = create(:course, :primary, provider:, funding: :fee)

      expect(tokens_for(course)).to eq(%w[only_this_course funding subject all])
    end

    it "offers the education phase only for a secondary course" do
      secondary = create(:course, :secondary, provider:)

      expect(tokens_for(secondary)).to include("secondary")
      expect(tokens_for(create(:course, :primary, provider:))).not_to include("secondary")
    end

    it "names the funding option after the course's funding" do
      expect(labels_for(create(:course, :primary, provider:, funding: :fee)))
        .to include("All fee-paying courses")
      expect(labels_for(create(:course, :primary, provider:, funding: :salary)))
        .to include("All school direct salaried courses")
      expect(labels_for(create(:course, :primary, provider:, funding: :apprenticeship)))
        .to include("All apprenticeship courses")
    end

    it "names the subject option after the course's subject" do
      course = create(:course, :secondary, provider:, subjects: [find_or_create(:secondary_subject, :biology)])

      expect(labels_for(course)).to include("All biology courses")
    end

    it "treats primary and further education as the subject" do
      expect(labels_for(create(:course, :primary, provider:))).to include("All primary courses")
      expect(labels_for(create(:course, :further_education, provider:)))
        .to include("All further education courses")
    end

    it "names this course and all courses" do
      course = create(:course, :primary, provider:, name: "Primary", course_code: "X123")

      expect(labels_for(course)).to include("Only this course - Primary (X123)", "All courses")
    end

    it "omits the subject option when a secondary course has no subject to name" do
      course = create(:course, :secondary, provider:)
      course.update!(master_subject_id: nil)

      expect(tokens_for(course)).not_to include("subject")
    end
  end

  describe ".find" do
    let(:course) { create(:course, :primary, provider:) }

    it "returns the scope for a token the course offers" do
      expect(described_class.find(course:, token: "all").label).to eq("All courses")
    end

    it "returns nil for a token the course does not offer" do
      expect(described_class.find(course:, token: "secondary")).to be_nil
      expect(described_class.find(course:, token: "nonsense")).to be_nil
      expect(described_class.find(course:, token: nil)).to be_nil
    end
  end

  describe "#relation" do
    def relation_for(course, token)
      described_class.find(course:, token:).relation
    end

    it "matches only this course" do
      course = create(:course, :primary, provider:)
      create(:course, :primary, provider:)

      expect(relation_for(course, "only_this_course")).to contain_exactly(course)
    end

    it "matches every course the provider has for the cycle" do
      course = create(:course, :primary, provider:)
      other = create(:course, :secondary, provider:)
      create(:course, :primary)

      expect(relation_for(course, "all")).to contain_exactly(course, other)
    end

    it "matches courses with the same funding" do
      course = create(:course, :primary, provider:, funding: :fee)
      same = create(:course, :secondary, provider:, funding: :fee)
      create(:course, :primary, provider:, funding: :salary)

      expect(relation_for(course, "funding")).to contain_exactly(course, same)
    end

    it "matches secondary courses" do
      course = create(:course, :secondary, provider:)
      other_secondary = create(:course, :secondary, provider:)
      create(:course, :primary, provider:)

      expect(relation_for(course, "secondary")).to contain_exactly(course, other_secondary)
    end

    it "matches courses sharing the primary subject, without duplicating them" do
      biology = find_or_create(:secondary_subject, :biology)
      drama = find_or_create(:secondary_subject, :drama)
      course = create(:course, :secondary, provider:, subjects: [biology])
      same = create(:course, :secondary, provider:, subjects: [biology, drama])
      create(:course, :secondary, provider:, subjects: [drama])

      expect(relation_for(course, "subject")).to contain_exactly(course, same)
    end

    it "matches courses of the same level for primary and further education" do
      course = create(:course, :primary, provider:)
      other_primary = create(:course, :primary, provider:, subjects: [find_or_create(:primary_subject, :primary_with_english)])
      create(:course, :secondary, provider:)

      expect(relation_for(course, "subject")).to contain_exactly(course, other_primary)
    end

    it "leaves out courses that have been deleted" do
      course = create(:course, :primary, provider:)
      create(:course, :primary, provider:).discard

      expect(relation_for(course, "all")).to contain_exactly(course)
    end
  end
end

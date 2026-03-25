# frozen_string_literal: true

require "rails_helper"

describe Courses::ReorderCourseSubjectsService do
  let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
  let(:design_and_technology) { find_or_create(:secondary_subject, :design_and_technology) }
  let(:french) { find_or_create(:modern_languages_subject, :french) }
  let(:mandarin) { find_or_create(:modern_languages_subject, :mandarin) }
  let(:engineering) { find_or_create(:design_technology_subject, :engineering) }
  let(:english) { find_or_create(:secondary_subject, :english) }
  let(:physics) { find_or_create(:secondary_subject, :physics) }

  def positions_for(course)
    course.course_subjects.reload.order(:position).map do |cs|
      [cs.subject.subject_name, cs.position]
    end
  end

  context "when master subject is at position 1 instead of 0" do
    let(:course) do
      create(:course, :secondary, subjects: [english, physics], master_subject_id: physics.id).tap do |c|
        c.course_subjects.delete_all
      end
    end

    before do
      course.course_subjects.create!(subject: english, position: 0)
      course.course_subjects.create!(subject: physics, position: 1)
    end

    it "moves master subject to position 0" do
      described_class.call(course:)

      expect(positions_for(course)).to eq([
        ["Physics", 0],
        ["English", 1],
      ])
    end
  end

  context "when modern languages is master with children and a subordinate" do
    let(:course) do
      create(:course, :secondary, subjects: [modern_languages, french], master_subject_id: modern_languages.id).tap do |c|
        c.course_subjects.delete_all
      end
    end

    before do
      course.course_subjects.create!(subject: physics, position: 0)
      course.course_subjects.create!(subject: modern_languages, position: 1)
      course.course_subjects.create!(subject: french, position: 2)
      course.course_subjects.create!(subject: mandarin, position: 3)
    end

    it "orders master, children, then subordinate" do
      described_class.call(course:)

      expect(positions_for(course)).to eq([
        ["Modern Languages", 0],
        ["French", 1],
        ["Mandarin", 2],
        ["Physics", 3],
      ])
    end
  end

  context "when design and technology is master with children" do
    let(:course) do
      create(:course, :secondary, subjects: [design_and_technology, engineering], master_subject_id: design_and_technology.id).tap do |c|
        c.course_subjects.delete_all
      end
    end

    before do
      course.course_subjects.create!(subject: engineering, position: 0)
      course.course_subjects.create!(subject: design_and_technology, position: 1)
    end

    it "orders parent before children" do
      described_class.call(course:)

      expect(positions_for(course)).to eq([
        ["Design and technology", 0],
        ["Engineering", 1],
      ])
    end
  end

  context "when subordinate is a parent subject with children" do
    let(:course) do
      create(:course, :secondary, subjects: [physics, modern_languages, french], master_subject_id: physics.id).tap do |c|
        c.course_subjects.delete_all
      end
    end

    before do
      course.course_subjects.create!(subject: french, position: 0)
      course.course_subjects.create!(subject: modern_languages, position: 1)
      course.course_subjects.create!(subject: physics, position: 2)
    end

    it "orders master, then subordinate parent with children" do
      described_class.call(course:)

      expect(positions_for(course)).to eq([
        ["Physics", 0],
        ["Modern Languages", 1],
        ["French", 2],
      ])
    end
  end

  context "when subjects are already correctly ordered" do
    let(:course) do
      create(:course, :secondary, subjects: [english, physics], master_subject_id: english.id).tap do |c|
        c.course_subjects.delete_all
      end
    end

    before do
      course.course_subjects.create!(subject: english, position: 0)
      course.course_subjects.create!(subject: physics, position: 1)
    end

    it "does not change positions" do
      expect { described_class.call(course:) }
        .not_to(change { positions_for(course) })
    end
  end

  context "when course has nil positions" do
    let(:course) do
      create(:course, :secondary, subjects: [english, physics], master_subject_id: english.id).tap do |c|
        c.course_subjects.delete_all
      end
    end

    before do
      course.course_subjects.create!(subject: physics, position: 0).update_column(:position, nil)
      course.course_subjects.create!(subject: english, position: 1).update_column(:position, nil)
    end

    it "assigns correct positions" do
      described_class.call(course:)

      expect(positions_for(course)).to eq([
        ["English", 0],
        ["Physics", 1],
      ])
    end
  end

  context "when course has no master_subject_id" do
    let(:course) { create(:course, :secondary, master_subject_id: nil) }

    it "does nothing" do
      expect { described_class.call(course:) }.not_to raise_error
    end
  end
end

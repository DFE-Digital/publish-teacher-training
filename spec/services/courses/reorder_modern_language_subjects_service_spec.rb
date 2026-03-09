# frozen_string_literal: true

require "rails_helper"

describe Courses::ReorderModernLanguageSubjectsService do
  let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
  let(:french) { find_or_create(:modern_languages_subject, :french) }
  let(:mandarin) { find_or_create(:modern_languages_subject, :mandarin) }
  let(:english) { find_or_create(:secondary_subject, :english) }

  let(:course) do
    create(:course, :secondary, subjects: [modern_languages, french], master_subject_id: modern_languages.id).tap do |c|
      # Clear auto-created course_subjects so we can set up each scenario precisely
      c.course_subjects.delete_all
    end
  end

  def positions_for(course)
    course.course_subjects.reload.order(:position).map do |cs|
      [cs.subject.subject_name, cs.position]
    end
  end

  context "when language subjects have nil positions" do
    before do
      course.course_subjects.create(subject: modern_languages, position: 0)
      course.course_subjects.create(subject: english, position: 1)
      course.course_subjects.create(subject: mandarin).update_column(:position, nil)
    end

    it "assigns positions with languages before non-languages" do
      described_class.call(course:)

      expect(positions_for(course)).to eq([
        ["Modern Languages", 0],
        ["Mandarin", 1],
        ["English", 2],
      ])
    end
  end

  context "when non-language subject is positioned before language subject" do
    before do
      course.course_subjects.create(subject: modern_languages, position: 0)
      course.course_subjects.create(subject: english, position: 1)
      course.course_subjects.create(subject: french, position: 2)
    end

    it "reorders languages before non-languages" do
      described_class.call(course:)

      expect(positions_for(course)).to eq([
        ["Modern Languages", 0],
        ["French", 1],
        ["English", 2],
      ])
    end
  end

  context "when subjects are already correctly ordered" do
    before do
      course.course_subjects.create(subject: modern_languages, position: 0)
      course.course_subjects.create(subject: french, position: 1)
      course.course_subjects.create(subject: english, position: 2)
    end

    it "does not change positions" do
      expect { described_class.call(course:) }
        .not_to(change { positions_for(course) })
    end
  end

  context "when course has only language subjects (no non-language)" do
    before do
      course.course_subjects.create(subject: modern_languages, position: 0)
      course.course_subjects.create(subject: french).update_column(:position, nil)
      course.course_subjects.create(subject: mandarin).update_column(:position, nil)
    end

    it "assigns positions to all subjects" do
      described_class.call(course:)

      expect(positions_for(course)).to eq([
        ["Modern Languages", 0],
        ["French", 1],
        ["Mandarin", 2],
      ])
    end
  end

  context "when course is not a Modern Languages course" do
    let(:course) do
      create(:course, :secondary, subjects: [english], master_subject_id: english.id)
    end

    it "does nothing" do
      expect { described_class.call(course:) }
        .not_to(change { positions_for(course) })
    end
  end

  context "when multiple language subjects have nil positions" do
    before do
      course.course_subjects.create(subject: modern_languages, position: 0)
      course.course_subjects.create(subject: english, position: 1)
      course.course_subjects.create(subject: french).update_column(:position, nil)
      course.course_subjects.create(subject: mandarin).update_column(:position, nil)
    end

    it "assigns positions with all languages before non-languages" do
      described_class.call(course:)

      expect(positions_for(course)).to eq([
        ["Modern Languages", 0],
        ["French", 1],
        ["Mandarin", 2],
        ["English", 3],
      ])
    end
  end
end

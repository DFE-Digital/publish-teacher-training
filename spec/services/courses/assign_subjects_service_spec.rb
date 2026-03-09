# frozen_string_literal: true

require "rails_helper"

describe Courses::AssignSubjectsService do
  subject do
    described_class.call(
      course:,
      subject_ids:,
    )
  end

  context "duplicated subject" do
    let(:course) { Course.new }
    let(:primary_subject) { find_or_create(:primary_subject, :primary) }
    let(:subject_ids) { [primary_subject.id, primary_subject.id] }

    it "have duplicated subject errors" do
      expect(subject.errors[:subjects].first).to include("^The second subject must be different to the first subject")
    end
  end

  context "no subject" do
    let(:course) { create(:course) }
    let(:subject_ids) { [] }

    it "have creation subject errors" do
      expect(subject.errors[:subjects].first).to include("^Select a subject")
    end

    it "have not updated course name" do
      expect { subject }
        .to not_change(course, :name)
    end
  end

  describe "subordinate subject present but master missing" do
    let(:subject_ids) { [] }

    context "with a new course" do
      let(:course) { Course.new }

      it "raises missing subject error" do
        expect(subject.errors.full_messages).to include("Select a subject")
      end
    end

    context "with a persisted course" do
      let(:course) { create(:course) }

      it "raises missing subject error" do
        expect(subject.errors.full_messages).to include("Select a subject")
      end
    end
  end

  context "primary course" do
    let(:subject_ids) { [primary_subject.id] }
    let(:course) { Course.new(level: :primary) }
    let(:primary_subject) { find_or_create(:primary_subject, :primary) }

    it "sets the subjects" do
      expect(subject.course_subjects.map { it.subject.id }).to eq(subject_ids)
    end

    it "sets master_subject_id to the primary subject" do
      expect(subject.master_subject_id).to eq(primary_subject.id)
    end

    it "sets the name" do
      expect(subject.name).to eq("Primary")
    end

    it "does not have errors" do
      expect(subject.errors).to be_empty
    end

    it "assigns position 0" do
      expect(subject.course_subjects.first.position).to eq(0)
    end
  end

  context "secondary course" do
    let(:subject_ids) { [secondary_subject.id] }
    let(:course) { Course.new(level: :secondary) }
    let(:secondary_subject) { find_or_create(:secondary_subject, :biology) }

    it "sets the subjects" do
      expect(subject.course_subjects.map { it.subject.id }).to eq([secondary_subject.id])
    end

    it "sets master_subject_id" do
      expect(subject.master_subject_id).to eq(secondary_subject.id)
    end

    it "sets subordinate_subject_id to nil" do
      expect(subject.subordinate_subject_id).to be_nil
    end

    it "sets the name" do
      expect(subject.name).to eq("Biology")
    end

    it "does not have errors" do
      expect(subject.errors).to be_empty
    end

    context "with 2 subjects" do
      let(:secondary_subject2) { find_or_create(:secondary_subject, :english) }
      let(:subject_ids) { [secondary_subject2.id, secondary_subject.id] }

      it "sets the subjects in caller order" do
        expect(subject.course_subjects.map { it.subject.id }).to eq(subject_ids)
      end

      it "sets master_subject_id to the first subject" do
        expect(subject.master_subject_id).to eq(secondary_subject2.id)
      end

      it "sets subordinate_subject_id to the second subject" do
        expect(subject.subordinate_subject_id).to eq(secondary_subject.id)
      end

      it "assigns sequential positions" do
        expect(subject.course_subjects.first.position).to eq(0)
        expect(subject.course_subjects.first.subject.id).to eq(secondary_subject2.id)

        expect(subject.course_subjects.second.position).to eq(1)
        expect(subject.course_subjects.second.subject.id).to eq(secondary_subject.id)
      end

      it "sets the name" do
        expect(subject.name).to eq("English with biology")
      end

      context "when subject order is swapped" do
        let(:subject_ids) { [secondary_subject.id, secondary_subject2.id] }

        it "sets master_subject_id to the first subject" do
          expect(subject.master_subject_id).to eq(secondary_subject.id)
        end

        it "sets subordinate_subject_id to the second subject" do
          expect(subject.subordinate_subject_id).to eq(secondary_subject2.id)
        end

        it "preserves the swapped position order" do
          expect(subject.course_subjects.first.position).to eq(0)
          expect(subject.course_subjects.first.subject.id).to eq(secondary_subject.id)

          expect(subject.course_subjects.second.position).to eq(1)
          expect(subject.course_subjects.second.subject.id).to eq(secondary_subject2.id)
        end
      end
    end

    context "with modern languages as master and a language subject" do
      let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
      let(:language_subject) { find_or_create(:modern_languages_subject, :german) }
      let(:subject_ids) { [modern_languages.id, language_subject.id, secondary_subject.id] }

      it "sets the subjects" do
        expect(subject.course_subjects.map { it.subject.id }).to eq(subject_ids)
      end

      it "sets master_subject_id to Modern Languages" do
        expect(subject.master_subject_id).to eq(modern_languages.id)
      end

      it "sets subordinate_subject_id to the other secondary subject" do
        expect(subject.subordinate_subject_id).to eq(secondary_subject.id)
      end

      it "positions Modern Languages first, then language, then secondary" do
        expect(subject.course_subjects.first.position).to eq(0)
        expect(subject.course_subjects.first.subject.id).to eq(modern_languages.id)

        expect(subject.course_subjects.second.position).to eq(1)
        expect(subject.course_subjects.second.subject.id).to eq(language_subject.id)

        expect(subject.course_subjects.third.position).to eq(2)
        expect(subject.course_subjects.third.subject.id).to eq(secondary_subject.id)
      end
    end

    context "with modern languages as subordinate and a language subject" do
      let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
      let(:language_subject) { find_or_create(:modern_languages_subject, :french) }
      let(:subject_ids) { [secondary_subject.id, modern_languages.id, language_subject.id] }

      it "sets master_subject_id to the first secondary subject" do
        expect(subject.master_subject_id).to eq(secondary_subject.id)
      end

      it "sets subordinate_subject_id to Modern Languages" do
        expect(subject.subordinate_subject_id).to eq(modern_languages.id)
      end

      it "positions master first, then ML parent, then language" do
        expect(subject.course_subjects.map { it.subject.id }).to eq(
          [secondary_subject.id, modern_languages.id, language_subject.id],
        )
      end

      it "assigns sequential positions" do
        expect(subject.course_subjects.map(&:position)).to eq([0, 1, 2])
      end
    end

    context "with modern languages as master, multiple languages, and another subject" do
      let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
      let(:french) { find_or_create(:modern_languages_subject, :french) }
      let(:german) { find_or_create(:modern_languages_subject, :german) }
      let(:subject_ids) { [modern_languages.id, french.id, german.id, secondary_subject.id] }

      it "sets master_subject_id to Modern Languages" do
        expect(subject.master_subject_id).to eq(modern_languages.id)
      end

      it "sets subordinate_subject_id to the other secondary subject" do
        expect(subject.subordinate_subject_id).to eq(secondary_subject.id)
      end

      it "positions ML parent, then languages, then other subject" do
        expect(subject.course_subjects.map { it.subject.id }).to eq(
          [modern_languages.id, french.id, german.id, secondary_subject.id],
        )
      end

      it "assigns sequential positions" do
        expect(subject.course_subjects.map(&:position)).to eq([0, 1, 2, 3])
      end
    end

    context "when languages are passed before ML parent" do
      let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
      let(:french) { find_or_create(:modern_languages_subject, :french) }
      let(:subject_ids) { [secondary_subject.id, french.id, modern_languages.id] }

      it "reorders languages to come after ML parent" do
        expect(subject.course_subjects.map { it.subject.id }).to eq(
          [secondary_subject.id, modern_languages.id, french.id],
        )
      end

      it "sets master_subject_id to the first non-language subject" do
        expect(subject.master_subject_id).to eq(secondary_subject.id)
      end

      it "sets subordinate_subject_id to Modern Languages" do
        expect(subject.subordinate_subject_id).to eq(modern_languages.id)
      end
    end

    context "with modern languages but no language subjects" do
      let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
      let(:subject_ids) { [secondary_subject.id, modern_languages.id] }

      it "preserves caller order" do
        expect(subject.course_subjects.map { it.subject.id }).to eq(subject_ids)
      end

      it "sets master_subject_id to the first subject" do
        expect(subject.master_subject_id).to eq(secondary_subject.id)
      end

      it "sets subordinate_subject_id to Modern Languages" do
        expect(subject.subordinate_subject_id).to eq(modern_languages.id)
      end
    end

    context "with a persisted course" do
      let(:course) { create(:course, level: :secondary) }
      let(:secondary_subject2) { find_or_create(:secondary_subject, :english) }
      let(:subject_ids) { [secondary_subject2.id, secondary_subject.id] }

      it "clears existing subjects and assigns new ones with positions" do
        subject
        course.reload

        expect(course.course_subjects.map(&:subject_id)).to eq(subject_ids)
        expect(course.course_subjects.map(&:position)).to eq([0, 1])
      end

      it "sets master_subject_id to the first subject" do
        expect(subject.master_subject_id).to eq(secondary_subject2.id)
      end

      it "sets subordinate_subject_id to the second subject" do
        expect(subject.subordinate_subject_id).to eq(secondary_subject.id)
      end
    end
  end

  context "when subject_ids are strings (from URL params)" do
    let(:course) { Course.new(level: :secondary) }
    let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
    let(:french) { find_or_create(:modern_languages_subject, :french) }
    let(:secondary_subject) { find_or_create(:secondary_subject, :biology) }
    let(:subject_ids) { [secondary_subject.id.to_s, modern_languages.id.to_s, french.id.to_s] }

    it "sets master_subject_id correctly" do
      expect(subject.master_subject_id).to eq(secondary_subject.id)
    end

    it "sets subordinate_subject_id to Modern Languages" do
      expect(subject.subordinate_subject_id).to eq(modern_languages.id)
    end

    it "orders subjects correctly" do
      expect(subject.course_subjects.map { it.subject.id }).to eq(
        [secondary_subject.id, modern_languages.id, french.id],
      )
    end

    it "assigns sequential positions" do
      expect(subject.course_subjects.map(&:position)).to eq([0, 1, 2])
    end
  end

  context "further_education course" do
    let(:subject_ids) { nil }
    let(:course) { Course.new(level: :further_education, provider: Provider.new, funding: "fee") }
    let(:further_education_subject) { find_or_create(:further_education_subject) }

    it "sets the subjects" do
      expect(subject.course_subjects.map { it.subject.id }).to eq([further_education_subject.id])
    end

    it "sets the name" do
      expect(subject.name).to eq("Further education")
    end

    it "sets further_education_fields" do
      expect(subject.funding).to eq("fee")
      expect(subject.english).to eq("not_required")
      expect(subject.maths).to eq("not_required")
      expect(subject.science).to eq("not_required")
    end
  end
end

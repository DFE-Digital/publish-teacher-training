require "rails_helper"

describe Course, type: :model do
  let(:course) { create(:course, level: "primary", subjects: [subjects]) }
  let(:subjects) { find_or_create(:primary_subject, :primary) }

  describe "modern languages" do
    context "primary level" do
      let(:course) { create(:course, level: "primary", subjects: []) }

      it "returns no modern languages subjects" do
        expect(course.available_modern_languages).to eq(nil)
      end
    end

    context "secondary level" do
      context "with the modern language subject" do
        let(:course) { create(:course, level: "secondary", subjects: [find_or_create(:secondary_subject, :modern_languages)]) }

        it "returns modern languages subjects" do
          expect(course.available_modern_languages).to(
            match_array(
              [
                find_or_create(:modern_languages_subject, :french),
                find_or_create(:modern_languages_subject, :english_as_a_second_lanaguge_or_other_language),
                find_or_create(:modern_languages_subject, :german),
                find_or_create(:modern_languages_subject, :italian),
                find_or_create(:modern_languages_subject, :japanese),
                find_or_create(:modern_languages_subject, :mandarin),
                find_or_create(:modern_languages_subject, :russian),
                find_or_create(:modern_languages_subject, :spanish),
                find_or_create(:modern_languages_subject, :modern_languages_other),
              ],
            ),
          )
        end
      end

      context "without the modern language subject" do
        let(:course) { create(:course, level: "secondary", subjects: []) }

        it "returns no modern languages subjects" do
          expect(course.available_modern_languages).to eq(nil)
        end
      end
    end
  end

  describe "subjects" do
    let(:course) { create(:course, level: "primary", subjects: []) }

    it "returns the subjects the user can choose according to their level" do
      expect(course.potential_subjects).to match_array(
        [
          find_or_create(:primary_subject, :primary),
          find_or_create(:primary_subject, :primary_with_english),
          find_or_create(:primary_subject, :primary_with_geography_and_history),
          find_or_create(:primary_subject, :primary_with_mathematics),
          find_or_create(:primary_subject, :primary_with_modern_languages),
          find_or_create(:primary_subject, :primary_with_physical_education),
          find_or_create(:primary_subject, :primary_with_science),
        ],
      )
    end
  end

  describe "entry_requirements" do
    it "returns the entry requirements that users can choose between" do
      expect(course.entry_requirements).to eq(%i[must_have_qualification_at_application_time expect_to_achieve_before_training_begins equivalence_test])
    end
  end

  describe "qualifications" do
    context "for a course that's not further education" do
      it "returns only QTS options for users to choose between" do
        expect(course.qualification_options).to eq(%w[qts pgce_with_qts pgde_with_qts])
        course.qualification_options.each do |q|
          expect(q.include?("qts")).to be_truthy
        end
      end
    end

    context "for a further education course" do
      let(:course) { create(:course, level: "further_education", subjects: [subjects]) }
      let(:subjects) { find_or_create(:further_education_subject) }
      it "returns only QTS options for users to choose between" do
        expect(course.qualification_options).to eq(%w[pgce pgde])
        course.qualification_options.each do |q|
          expect(q.include?("qts")).to be_falsy
        end
      end
    end
  end

  describe "age_range" do
    context "for primary" do
      it "returns the correct ages range for users to co choose between" do
        expect(course.age_range_options).to eq(%w[3_to_7 5_to_11 7_to_11 7_to_14])
      end
    end

    context "for secondary" do
      let(:course) { create(:course, level: "secondary", subjects: [subjects]) }
      let(:subjects) { find_or_create(:secondary_subject, :biology) }
      it "returns the correct age ranges for users to co choose between" do
        expect(course.age_range_options).to eq(%w[11_to_16 11_to_18 14_to_19])
      end
    end
  end

  describe "start_date_options" do
    let(:recruitment_year) { course.provider.recruitment_cycle.year.to_i }

    it "should return the correct options for the recruitment_cycle" do
      expect(course.start_date_options).to eq(
        ["October #{recruitment_year - 1}",
         "November #{recruitment_year - 1}",
         "December #{recruitment_year - 1}",
         "January #{recruitment_year}",
         "February #{recruitment_year}",
         "March #{recruitment_year}",
         "April #{recruitment_year}",
         "May #{recruitment_year}",
         "June #{recruitment_year}",
         "July #{recruitment_year}",
         "August #{recruitment_year}",
         "September #{recruitment_year}",
         "October #{recruitment_year}",
         "November #{recruitment_year}",
         "December #{recruitment_year}",
         "January #{recruitment_year + 1}",
         "February #{recruitment_year + 1}",
         "March #{recruitment_year + 1}",
         "April #{recruitment_year + 1}",
         "May #{recruitment_year + 1}",
         "June #{recruitment_year + 1}",
         "July #{recruitment_year + 1}"],
     )
    end
  end

  describe "available_start_date_options" do
    let(:recruitment_year) { course.provider.recruitment_cycle.year.to_i }

    context "when unpublished" do
      it "should return the correct options for the recruitment_cycle" do
        expect(course.show_start_date?).to eq(true)
      end
    end

    context "when published" do
      let(:enrichment) { create(:course_enrichment, :published) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it "should return no options" do
        expect(course.show_start_date?).to eq(false)
      end
    end
  end

  describe "is_send" do
    let(:recruitment_year) { course.provider.recruitment_cycle.year.to_i }

    context "when unpublished" do
      it "should indicate that the option is a checkbox" do
        expect(course.show_is_send?).to eq(true)
      end
    end

    context "when published" do
      let(:enrichment) { create(:course_enrichment, :published) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it "should indicate that the option is hidden" do
        expect(course.show_is_send?).to eq(false)
      end
    end
  end

  describe "applications_open" do
    let(:recruitment_year) { course.provider.recruitment_cycle.year.to_i }

    context "when unpublished" do
      it "should indicate that the option is a checkbox" do
        expect(course.show_applications_open?).to eq(true)
      end
    end

    context "when published" do
      let(:enrichment) { create(:course_enrichment, :published) }
      let(:course) { create(:course, enrichments: [enrichment]) }

      it "should indicate that the option is hidden" do
        expect(course.show_applications_open?).to eq(false)
      end
    end
  end
end

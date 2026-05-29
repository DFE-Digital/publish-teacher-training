# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CourseWizard#next_step", type: :wizard do
  include_context "add_course_wizard"

  context "from level" do
    let(:current_step) { :level }

    context "when primary is selected" do
      before do
        state_store.write(level: "primary")
      end

      it "proceeds to primary subjects" do
        expect(wizard).to have_next_step(:primary_subjects)
      end
    end

    context "when secondary is selected" do
      before do
        state_store.write(level: "secondary")
      end

      it "proceeds to secondary subjects" do
        expect(wizard).to have_next_step(:secondary_subjects)
      end
    end

    context "when further education is selected" do
      before do
        state_store.write(level: "further_education")
      end

      it "proceeds to courses page" do
        expect(wizard).to have_next_step(:qualifications)
      end
    end
  end

  context "from primary subjects" do
    let(:current_step) { :primary_subjects }

    it "proceeds to age range page" do
      expect(wizard).to have_next_step(:age_range)
    end
  end

  context "from secondary subjects" do
    let(:current_step) { :secondary_subjects }

    it "proceeds to age range page" do
      expect(wizard).to have_next_step(:age_range)
    end
  end

  context "from age range with primary level" do
    let(:current_step) { :age_range }

    before do
      state_store.write(level: "primary")
    end

    it "proceeds to qualifications page" do
      expect(wizard).to have_next_step(:qualifications)
    end
  end

  context "from age range with secondary level" do
    let(:current_step) { :age_range }

    before do
      state_store.write(level: "secondary")
    end

    it "proceeds to qualifications page" do
      expect(wizard).to have_next_step(:qualifications)
    end
  end

  context "from qualifications with primary level" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(level: "primary")
    end

    it "proceeds to primary subjects page" do
      expect(wizard).to have_next_step(:funding_type)
    end
  end

  context "from qualifications with secondary level" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(level: "secondary")
    end

    it "proceeds to primary subjects page" do
      expect(wizard).to have_next_step(:funding_type)
    end
  end

  context "from qualifications with further education level" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(level: "further_education")
    end

    it "proceeds to funding type page" do
      expect(wizard).to have_next_step(:funding_type)
    end
  end

  context "from qualifications with undergraduate degree with QTS" do
    let(:current_step) { :qualifications }

    before do
      state_store.write(qualification: "undergraduate_degree_with_qts")
    end

    it "proceeds to schools page" do
      expect(wizard).to have_next_step(:schools)
    end
  end

  context "from funding type" do
    let(:current_step) { :funding_type }

    it "proceeds to study pattern page" do
      expect(wizard).to have_next_step(:study_pattern)
    end
  end

  context "from study pattern" do
    let(:current_step) { :study_pattern }

    it "proceeds to schools page" do
      expect(wizard).to have_next_step(:schools)
    end
  end

  context "from schools" do
    let(:current_step) { :schools }

    it "proceeds to courses page" do
      expect(wizard).to have_next_step(:courses_index)
    end
  end
end

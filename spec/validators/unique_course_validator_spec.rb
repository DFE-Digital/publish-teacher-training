describe UniqueCourseValidator do
  let(:service) { described_class.new }
  let(:provider) { create(:provider, sites: [site_one, site_two]) }
  let(:accredited_body_one) { create(:provider, :accredited_body) }
  let(:accredited_body_two) { create(:provider, :accredited_body) }
  let(:site_one) { create(:site) }
  let(:site_two) { create(:site) }

  let(:existing_course) do
    create(:course,
           provider: provider,
           level: "primary",
           subjects: [primary_with_english_subject],
           age_range_in_years: "5_to_11",
           qualification: "qts",
           program_type: "pg_teaching_apprenticeship",
           study_mode: "P",
           maths: "not_required",
           english: "not_required",
           science: "not_required",
           sites: [site_one],
           accrediting_provider: accredited_body_one,
           is_send: false)
  end

  let(:new_course) do
    existing_course.dup.tap do |c|
      c.subjects = existing_course.subjects
      c.sites = existing_course.sites
    end
  end

  let(:primary_with_english_subject) { find_or_create(:primary_subject, :primary_with_english) }
  let(:primary_with_maths_subject) { find_or_create(:primary_subject, :primary_with_mathematics) }

  before do
    provider
    existing_course
  end

  shared_examples "a duplicate course" do
    it "is a duplicate course" do
      new_course.valid?(:new)
      expect(new_course.errors.added?(:base, :duplicate)).to be(true)
    end
  end

  shared_examples "a unique course" do
    it "is a unique course" do
      new_course.valid?(:new)
      expect(new_course.errors.added?(:base, :duplicate)).to be(false)
    end
  end

  context "With an exact duplicate of the existing course" do
    include_examples "a duplicate course"
  end

  context "With an exact duplicate with a different course code" do
    before do
      new_course.course_code = new_course.course_code + "1"
    end

    include_examples "a duplicate course"
  end

  context "With differing basic details" do
    context "Different level" do
      before do
        new_course.level = "secondary"
      end

      include_examples "a unique course"
    end

    context "Same subject with SEND" do
      before do
        new_course.is_send = true
      end

      include_examples "a unique course"
    end

    context "Different subjects" do
      before do
        new_course.subjects = [primary_with_maths_subject]
      end

      include_examples "a unique course"
    end

    context "Different age ranges" do
      before do
        new_course.age_range_in_years = "6_to_12"
      end

      include_examples "a unique course"
    end

    context "Different qualifications" do
      before do
        new_course.qualification = "pgce"
      end

      include_examples "a unique course"
    end

    context "Different program types" do
      before do
        new_course.program_type = "scitt_programme"
      end

      include_examples "a unique course"
    end

    context "Different study modes" do
      before do
        new_course.study_mode = "F"
      end

      include_examples "a unique course"
    end

    context "GCSE requirements" do
      context "Maths" do
        before do
          new_course.maths = "equivalence_test"
        end

        include_examples "a unique course"
      end

      context "English" do
        before do
          new_course.english = "equivalence_test"
        end

        include_examples "a unique course"
      end

      context "Science" do
        before do
          new_course.science = "equivalence_test"
        end

        include_examples "a unique course"
      end
    end

    context "Different applications open date" do
      before do
        new_course.applications_open_from = existing_course.applications_open_from + 1
      end

      include_examples "a unique course"
    end

    context "Different course start dates" do
      before do
        new_course.start_date = existing_course.start_date + 1
      end

      include_examples "a unique course"
    end

    context "Different sites" do
      before do
        new_course.sites << site_two
      end

      include_examples "a duplicate course"
    end

    context "Different accredited body" do
      before do
        new_course.accrediting_provider = accredited_body_two
      end

      include_examples "a unique course"
    end
  end
end

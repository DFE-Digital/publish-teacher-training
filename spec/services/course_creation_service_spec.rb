require "rails_helper"

describe CourseCreationService do
  context "primary course" do
    subject { described_class.call(course_params: course_params(:primary), provider: provider, next_available_course_code: false) }

    it "create the primary course" do
      primary_course_params.except("is_send", "sites_ids", "subjects_ids", "course_code").each do |key, value|
        expect(subject.send(key)).to eq(value)
      end

      expect(subject.is_send).to eq(true)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.subjects.map(&:id)).to eq([primary_subject.id])
      expect(subject.course_code).to eq(nil)
    end

    context "next_available_course_code is true" do
      subject { described_class.call(course_params: course_params(:primary), provider: provider, next_available_course_code: true) }

      it "create the primary course" do
        primary_course_params.except("is_send", "sites_ids", "subjects_ids", "course_code").each do |key, value|
          expect(subject.send(key)).to eq(value)
        end

        expect(subject.is_send).to eq(true)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.subjects.map(&:id)).to eq([primary_subject.id])
        expect(subject.course_code).not_to eq(nil)
        expect(subject.course_code).not_to eq("D0CK")
      end
    end
  end

  context "secondary course" do
    subject { described_class.call(course_params: course_params(:secondary), provider: provider, next_available_course_code: false) }

    it "create the secondary course" do
      secondary_course_params.except("is_send", "sites_ids", "subjects_ids", "course_code").each do |key, value|
        expect(subject.send(key)).to eq(value)
      end

      expect(subject.is_send).to eq(true)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.subjects.map(&:id)).to eq([secondary_subject.id])
      expect(subject.course_code).to eq(nil)
    end

    context "next_available_course_code is true" do
      subject { described_class.call(course_params: course_params(:secondary), provider: provider, next_available_course_code: true) }

      it "create the secondary course" do
        secondary_course_params.except("is_send", "sites_ids", "subjects_ids", "course_code").each do |key, value|
          expect(subject.send(key)).to eq(value)
        end

        expect(subject.is_send).to eq(true)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.subjects.map(&:id)).to eq([secondary_subject.id])
        expect(subject.course_code).not_to eq(nil)
        expect(subject.course_code).not_to eq("D0CK")
      end
    end
  end

  context "further_education course" do
    subject { described_class.call(course_params: course_params(:further_education), provider: provider, next_available_course_code: false) }

    it "create the further_education course" do
      further_education_course_params.except("is_send", "sites_ids", "subjects_ids", "course_code").each do |key, value|
        expect(subject.send(key)).to eq(value)
      end

      expect(subject.is_send).to eq(true)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.subjects.map(&:id)).to eq([further_education_subject.id])
      expect(subject.course_code).to eq(nil)
    end

    context "next_available_course_code is true" do
      subject { described_class.call(course_params: course_params(:further_education), provider: provider, next_available_course_code: true) }

      it "create the further_education course" do
        further_education_course_params.except("is_send", "sites_ids", "course_code").each do |key, value|
          expect(subject.send(key)).to eq(value)
        end

        expect(subject.is_send).to eq(true)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.subjects.map(&:id)).to eq([further_education_subject.id])
        expect(subject.course_code).not_to eq(nil)
        expect(subject.course_code).not_to eq("D0CK")
      end
    end
  end

  def course_params(level)
    {
      primary: primary_course_params,
      secondary: secondary_course_params,
      further_education: further_education_course_params,
    }[level]
  end

  def primary_course_params
    {
      "age_range_in_years" => "3_to_7",
      "applications_open_from" => recruitment_cycle.application_start_date,
      "funding_type" => "fee",
      "is_send" => "1",
      "level" => "primary",
      "qualification" => "qts",
      "start_date" => "September #{recruitment_cycle.year}",
      "study_mode" => "full_time",
      "sites_ids" => [site.id],
      "subjects_ids" => [primary_subject.id],
      "course_code" => "D0CK",
    }
  end

  def secondary_course_params
    {
      "age_range_in_years" => "12_to_17",
      "applications_open_from" => recruitment_cycle.application_start_date,
      "funding_type" => "salary",
      "is_send" => "1",
      "level" => "secondary",
      "qualification" => "pgce_with_qts",
      "start_date" => "September #{recruitment_cycle.year}",
      "study_mode" => "part_time",
      "sites_ids" => [site.id],
      "subjects_ids" => [secondary_subject.id],
      "course_code" => "D0CK",
    }
  end

  def further_education_course_params
    {
      "applications_open_from" => recruitment_cycle.application_start_date,
      "is_send" => "1",
      "level" => "further_education",
      "qualification" => "pgde",
      "start_date" => "September #{recruitment_cycle.year}",
      "study_mode" => "full_time_or_part_time",
      "sites_ids" => [site.id],
    }
  end

  def provider
    @provider ||= create(:provider, sites: [build(:site)])
  end

  def further_education_subject
    @further_education_subject ||= find_or_create(:further_education_subject)
  end

  def primary_subject
    @primary_subject ||= find_or_create(:primary_subject, :primary)
  end

  def secondary_subject
    @secondary_subject ||= find_or_create(:secondary_subject, :biology)
  end

  def site
    @site ||= provider.sites.first
  end

  def recruitment_cycle
    @recruitment_cycle ||= provider.recruitment_cycle
  end
end

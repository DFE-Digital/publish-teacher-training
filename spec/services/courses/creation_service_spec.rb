# frozen_string_literal: true

require "rails_helper"

describe Courses::CreationService do
  subject do
    described_class.call(
      course_params: valid_course_params, provider:,
      next_available_course_code:
    )
  end

  let(:provider) { create(:provider, sites: [site], study_sites: [study_site]) }

  let(:site) { build(:site) }
  let(:study_site) { build(:site, :study_site) }

  let(:recruitment_cycle) { provider.recruitment_cycle }

  let(:next_available_course_code) { false }

  context "visa sponsorship is duplicated in params" do
    context "when funding is fee" do
      let(:valid_course_params) do
        {
          "level" => "primary",
          "can_sponsor_skilled_worker_visa" => "true",
          "can_sponsor_student_visa" => "true",
          "funding" => "fee",
          "qualification" => "pgde",
        }
      end

      it "cannot sponsor skilled workers visas" do
        expect(subject.can_sponsor_student_visa).to be(true)
        expect(subject.can_sponsor_skilled_worker_visa).to be(false)
      end
    end

    context "when funding is salary" do
      let(:valid_course_params) do
        {
          "level" => "primary",
          "can_sponsor_skilled_worker_visa" => "true",
          "can_sponsor_student_visa" => "true",
          "funding" => "salary",
          "qualification" => "pgde",
        }
      end

      it "cannot sponsor skilled workers visas" do
        expect(subject.can_sponsor_student_visa).to be(false)
        expect(subject.can_sponsor_skilled_worker_visa).to be(true)
      end
    end

    context "when funding is apprenticeship" do
      let(:valid_course_params) do
        {
          "level" => "primary",
          "can_sponsor_skilled_worker_visa" => "true",
          "can_sponsor_student_visa" => "true",
          "funding" => "apprenticeship",
          "qualification" => "pgde",
        }
      end

      it "cannot sponsor skilled workers visas" do
        expect(subject.can_sponsor_student_visa).to be(false)
        expect(subject.can_sponsor_skilled_worker_visa).to be(true)
      end
    end
  end

  context "when teacher degree apprenticeship course" do
    let(:valid_course_params) do
      {
        "level" => "primary",
        "is_send" => "1",
        "age_range_in_years" => "3_to_7",
        "qualification" => "undergraduate_degree_with_qts",
      }
    end

    it "creates the teacher degree apprenticeship course" do
      expect(subject.program_type).to eq("teacher_degree_apprenticeship")
      expect(subject.funding).to eq("apprenticeship")
      expect(subject.can_sponsor_student_visa?).to be false
      expect(subject.can_sponsor_skilled_worker_visa?).to be false
      expect(subject.additional_degree_subject_requirements).to be(false)
      expect(subject.degree_grade).to eq("not_required")
      expect(subject.enrichments.last).to be_present
    end
  end

  context "when provider is not accredited and has exactly one accredited partner" do
    let(:accredited_partner) { create(:provider, :accredited_provider) }
    let(:provider) do
      create(
        :provider,
        accredited: false,
      )
    end

    let(:valid_course_params) do
      {
        "level" => "primary",
        "qualification" => "qts",
        "funding" => "fee",
        "school_uuids" => [site.uuid],
        "study_sites_ids" => [study_site.id],
      }
    end

    before do
      create(
        :provider_partnership,
        training_provider: provider,
        accredited_provider: accredited_partner,
      )
    end

    it "assigns the single accredited partner as the accrediting_provider" do
      expect(subject.accrediting_provider).to eq(accredited_partner)
    end
  end

  context "when provider is accredited" do
    let(:provider) do
      create(
        :provider,
        :accredited_provider,
      )
    end

    let(:valid_course_params) do
      {
        "level" => "primary",
        "qualification" => "qts",
        "funding" => "fee",
        "school_uuids" => [site.uuid],
        "study_sites_ids" => [study_site.id],
      }
    end

    it "does not assign an accrediting_provider" do
      expect(subject.accrediting_provider).to be_nil
    end
  end

  context "when provider is accredited and has a partner that lost its accreditation" do
    let(:provider) do
      create(
        :provider,
        :accredited_provider,
      )
    end

    let(:valid_course_params) do
      {
        "level" => "primary",
        "qualification" => "qts",
        "funding" => "fee",
        "school_uuids" => [site.uuid],
        "study_sites_ids" => [study_site.id],
      }
    end

    before do
      unaccredited_partner = create(:provider, accredited: false)

      # simulating a provider that lost an accreditation
      ProviderPartnership.new(
        training_provider: provider,
        accredited_provider: unaccredited_partner,
      ).save(validate: false)
    end

    it "does not assign an accrediting_provider" do
      expect(
        subject.accrediting_provider,
      ).to be_nil,
           <<~MSG
             Expected accrediting_provider to be nil but got #{subject.accrediting_provider&.provider_name}. Provider partners: #{provider.accredited_partners.map { |partner| partner.attributes.symbolize_keys.slice(:provider_name, :accredited) }}
           MSG
    end
  end

  context "when provider has more than one accredited partner" do
    let(:accredited_partner_one) { create(:provider, :accredited_provider) }
    let(:accredited_partner_two) { create(:provider, :accredited_provider) }
    let(:provider) do
      create(
        :provider,
        accredited: false,
        sites: [site],
        study_sites: [study_site],
      )
    end

    let(:valid_course_params) do
      {
        "level" => "primary",
        "qualification" => "qts",
        "funding" => "fee",
        "school_uuids" => [site.uuid],
        "study_sites_ids" => [study_site.id],
      }
    end

    before do
      create(:provider_partnership,
             training_provider: provider,
             accredited_provider: accredited_partner_one)
      create(:provider_partnership,
             training_provider: provider,
             accredited_provider: accredited_partner_two)
    end

    it "does not assign an accrediting_provider" do
      expect(subject.accrediting_provider).to be_nil
    end
  end

  context "primary course" do
    let(:primary_subject) { find_or_create(:primary_subject, :primary) }

    let(:valid_course_params) do
      {
        "age_range_in_years" => "3_to_7",
        "applications_open_from" => recruitment_cycle.application_start_date,
        "funding" => "fee",
        "is_send" => "1",
        "level" => "primary",
        "qualification" => "qts",
        "start_date" => "September #{recruitment_cycle.year}",
        "study_mode" => %w[full_time],
        "school_uuids" => [site.uuid],
        "study_sites_ids" => [study_site.id],
        "master_subject_id" => primary_subject.id,
        "subjects_ids" => [primary_subject.id],
        "course_code" => "D0CK",
      }
    end

    it "create the primary course" do
      valid_course_params.except("start_date", "is_send", "school_uuids", "study_sites_ids", "subjects_ids", "course_code", "study_mode").each do |key, value|
        expect(subject.public_send(key)).to eq(value)
      end

      expect(subject.start_date).to eq(Time.zone.local(recruitment_cycle.year, 9, 1))
      expect(subject.is_send).to be(true)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.study_sites.map(&:id)).to eq([study_site.id])
      expect(subject.course_subjects.map { it.subject.id }).to eq([primary_subject.id])
      expect(subject.course_code).to be_nil
      expect(subject.name).to eq("Primary (SEND)")
      expect(subject.study_mode).to eq "full_time"
      expect(subject.errors).to be_empty
    end

    context "next_available_course_code is true" do
      let(:next_available_course_code) do
        true
      end

      it "create the primary course" do
        valid_course_params.except("start_date", "is_send", "school_uuids", "study_sites_ids", "subjects_ids", "course_code", "study_mode").each do |key, value|
          expect(subject.public_send(key)).to eq(value)
        end

        expect(subject.start_date).to eq(Time.zone.local(recruitment_cycle.year, 9, 1))
        expect(subject.is_send).to be(true)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.study_sites.map(&:id)).to eq([study_site.id])
        expect(subject.course_subjects.map { it.subject.id }).to eq([primary_subject.id])
        expect(subject.course_code).not_to be_nil
        expect(subject.course_code).not_to eq("D0CK")
        expect(subject.name).to eq("Primary (SEND)")
        expect(subject.study_mode).to eq "full_time"
        expect(subject.errors).to be_empty
      end
    end
  end

  context "secondary course" do
    let(:secondary_subject) { find_or_create(:secondary_subject, :biology) }

    let(:valid_course_params) do
      {
        "age_range_in_years" => "12_to_17",
        "applications_open_from" => recruitment_cycle.application_start_date,
        "funding" => "salary",
        "is_send" => "0",
        "level" => "secondary",
        "qualification" => "pgce_with_qts",
        "start_date" => "September #{recruitment_cycle.year}",
        "study_mode" => %w[part_time],
        "school_uuids" => [site.uuid],
        "study_sites_ids" => [study_site.id],
        "subjects_ids" => [secondary_subject.id],
        "master_subject_id" => secondary_subject.id,
        "course_code" => "D0CK",
      }
    end

    it "create the secondary course" do
      valid_course_params.except("start_date", "is_send", "school_uuids", "study_sites_ids", "subjects_ids", "course_code", "study_mode").each do |key, value|
        expect(subject.send(key)).to eq(value)
      end

      expect(subject.start_date).to eq(Time.zone.local(recruitment_cycle.year, 9, 1))
      expect(subject.is_send).to be(false)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.study_sites.map(&:id)).to eq([study_site.id])
      expect(subject.course_subjects.map { it.subject.id }).to eq([secondary_subject.id])
      expect(subject.course_code).to be_nil
      expect(subject.name).to eq("Biology")
      expect(subject.study_mode).to eq "part_time"
      expect(subject.errors).to be_empty
    end

    context "next_available_course_code is true" do
      let(:next_available_course_code) do
        true
      end

      it "create the secondary course" do
        valid_course_params.except("start_date", "is_send", "school_uuids", "study_sites_ids", "subjects_ids", "course_code", "study_mode").each do |key, value|
          expect(subject.public_send(key)).to eq(value)
        end

        expect(subject.start_date).to eq(Time.zone.local(recruitment_cycle.year, 9, 1))
        expect(subject.is_send).to be(false)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.study_sites.map(&:id)).to eq([study_site.id])
        expect(subject.course_subjects.map { it.subject.id }).to eq([secondary_subject.id])
        expect(subject.course_code).not_to be_nil
        expect(subject.course_code).not_to eq("D0CK")
        expect(subject.name).to eq("Biology")
        expect(subject.study_mode).to eq "part_time"
        expect(subject.errors).to be_empty
      end
    end

    context "study_mode param is a string" do
      let(:valid_course_params) do
        {
          "age_range_in_years" => "12_to_17",
          "applications_open_from" => recruitment_cycle.application_start_date,
          "funding" => "salary",
          "is_send" => "0",
          "level" => "secondary",
          "qualification" => "pgce_with_qts",
          "start_date" => "September #{recruitment_cycle.year}",
          "study_mode" => "part_time",
          "school_uuids" => [site.uuid],
          "study_sites_ids" => [study_site.id],
          "subjects_ids" => [secondary_subject.id],
          "master_subject_id" => secondary_subject.id,
          "course_code" => "D0CK",
        }
      end

      it "creates a course" do
        expect(subject.start_date).to eq(Time.zone.local(recruitment_cycle.year, 9, 1))
        expect(subject.is_send).to be(false)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.study_sites.map(&:id)).to eq([study_site.id])
        expect(subject.course_subjects.map { it.subject.id }).to eq([secondary_subject.id])
        expect(subject.course_code).to be_nil
        expect(subject.name).to eq("Biology")
        expect(subject.study_mode).to eq "part_time"
        expect(subject.errors).to be_empty
      end
    end
  end

  context "further_education course" do
    let(:further_education_subject) { find_or_create(:further_education_subject) }

    let(:valid_course_params) do
      {
        "applications_open_from" => recruitment_cycle.application_start_date,
        "is_send" => "1",
        "level" => "further_education",
        "funding" => "fee",
        "qualification" => "pgde",
        "start_date" => "September #{recruitment_cycle.year}",
        "study_mode" => %w[full_time part_time],
        "school_uuids" => [site.uuid],
        "study_sites_ids" => [study_site.id],
      }
    end

    it "create the further_education course" do
      expect(subject.start_date).to eq(Time.zone.local(recruitment_cycle.year, 9, 1))
      expect(subject.is_send).to be(true)
      expect(subject.sites.map(&:id)).to eq([site.id])
      expect(subject.study_sites.map(&:id)).to eq([study_site.id])
      expect(subject.course_subjects.map { it.subject.id }).to eq([further_education_subject.id])
      expect(subject.course_code).to be_nil
      expect(subject.name).to eq("Further education (SEND)")
      expect(subject.errors).to be_empty
      expect(subject.funding).to eq("fee")
      expect(subject.english).to eq("not_required")
      expect(subject.maths).to eq("not_required")
      expect(subject.science).to eq("not_required")
      expect(subject.study_mode).to eq "full_time_or_part_time"
    end

    context "next_available_course_code is true" do
      let(:next_available_course_code) do
        true
      end

      it "create the further_education course" do
        valid_course_params.except("start_date", "is_send", "school_uuids", "study_sites_ids", "course_code", "study_mode").each do |key, value|
          expect(subject.send(key)).to eq(value)
        end

        expect(subject.start_date).to eq(Time.zone.local(recruitment_cycle.year, 9, 1))
        expect(subject.is_send).to be(true)
        expect(subject.sites.map(&:id)).to eq([site.id])
        expect(subject.study_sites.map(&:id)).to eq([study_site.id])
        expect(subject.course_subjects.map { it.subject.id }).to eq([further_education_subject.id])
        expect(subject.course_code).not_to be_nil
        expect(subject.course_code).not_to eq("D0CK")
        expect(subject.name).to eq("Further education (SEND)")
        expect(subject.errors).to be_empty
        expect(subject.funding).to eq("fee")
        expect(subject.english).to eq("not_required")
        expect(subject.maths).to eq("not_required")
        expect(subject.science).to eq("not_required")
        expect(subject.study_mode).to eq "full_time_or_part_time"
      end
    end

    context "when course sponsors visa" do
      context "but does not require separate application deadline" do
        let(:valid_course_params) do
          { "funding" => "fee",
            "can_sponsor_student_visa" => "true",
            "visa_sponsorship_application_deadline_required" => "false",
            "visa_sponsorship_application_deadline_at(1i)" => recruitment_cycle.year,
            "visa_sponsorship_application_deadline_at(2i)" => "8",
            "visa_sponsorship_application_deadline_at(3i)" => "1" }
        end

        it "does not save the visa sponsorship application deadline date" do
          expect(subject.visa_sponsorship_application_deadline_at).to be_nil
        end
      end

      context "and requires a separate application deadline" do
        let(:valid_course_params) do
          { "funding" => "fee",
            "can_sponsor_student_visa" => "true",
            "visa_sponsorship_application_deadline_required" => "true",
            "visa_sponsorship_application_deadline_at(1i)" => recruitment_cycle.year,
            "visa_sponsorship_application_deadline_at(2i)" => "8",
            "visa_sponsorship_application_deadline_at(3i)" => "1" }
        end

        it "saves the visa sponsorship application deadline at from the params" do
          deadline = Time.zone.local(recruitment_cycle.year.to_i, 8, 1).in_time_zone("London").end_of_day.utc
          expect(subject.visa_sponsorship_application_deadline_at).to be_within(1.second).of deadline
        end
      end
    end
  end

  describe "writing schools to the new school data model" do
    subject(:created_course) do
      described_class.call(course_params: valid_course_params, provider:, next_available_course_code: true)
    end

    let(:primary_subject) { find_or_create(:primary_subject, :primary) }

    # A GIAS school + provider_school that mirror the legacy `site` selected in
    # the wizard, joined to the legacy site by matching UUID.
    let(:gias_school) { create(:gias_school, urn: site.urn) }
    let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: site.code, uuid: site.uuid) }

    let(:valid_course_params) do
      {
        "age_range_in_years" => "3_to_7",
        "applications_open_from" => recruitment_cycle.application_start_date,
        "funding" => "fee",
        "is_send" => "1",
        "level" => "primary",
        "qualification" => "qts",
        "start_date" => "September #{recruitment_cycle.year}",
        "study_mode" => %w[full_time],
        "school_uuids" => [site.uuid],
        "study_sites_ids" => [study_site.id],
        "master_subject_id" => primary_subject.id,
        "subjects_ids" => [primary_subject.id],
      }
    end

    context "when the flag is off" do
      before do
        allow(FeatureFlag).to receive(:active?).and_call_original
        allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(false)
      end

      it "dual-writes: builds both the legacy site_status and the new Course::School" do
        expect(created_course.sites.map(&:id)).to eq([site.id])
        expect(created_course.schools.map(&:gias_school_id)).to eq([gias_school.id])
        expect(created_course.schools.first.provider_school).to eq(provider_school)
        expect(created_course.errors).to be_empty
      end

      it "persists both models on save" do
        created_course.save!

        expect(created_course.reload.sites.map(&:id)).to eq([site.id])
        expect(Course::School.where(course: created_course).pluck(:gias_school_id, :provider_school_id))
          .to eq([[gias_school.id, provider_school.id]])
      end
    end

    context "when the flag is on" do
      before do
        allow(FeatureFlag).to receive(:active?).and_call_original
        allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(true)
      end

      it "builds the new Course::School and passes :new validation" do
        expect(created_course.schools.map(&:gias_school_id)).to eq([gias_school.id])
        expect(created_course.schools.first.site_code).to eq(site.code)
        expect(created_course.schools.first.provider_school).to eq(provider_school)
        expect(created_course.errors).to be_empty
      end

      it "persists the Course::School on save" do
        created_course.save!

        expect(Course::School.where(course: created_course).pluck(:gias_school_id, :provider_school_id))
          .to eq([[gias_school.id, provider_school.id]])
      end
    end

    context "when there is no matching provider_school (not backfilled)" do
      # GIAS school exists (matched by URN) but the provider has not been
      # backfilled, so no Provider::School exists for the pair.
      let!(:gias_school) { create(:gias_school, urn: site.urn) }
      let!(:provider_school) { nil }

      before do
        allow(FeatureFlag).to receive(:active?).and_call_original
        allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(false)
      end

      it "skips the new-model write, logs a warning, and still builds the legacy site_status" do
        expect(Rails.logger).to receive(:warn).with(/course_school/)

        expect(created_course.schools).to be_empty
        expect(created_course.sites.map(&:id)).to eq([site.id])
      end
    end

    context "when several schools are selected" do
      let(:site_two) { create(:site, provider:) }
      let(:gias_school_two) { create(:gias_school, urn: site_two.urn) }
      let!(:provider_school_two) do
        create(:provider_school, provider:, gias_school: gias_school_two, site_code: site_two.code, uuid: site_two.uuid)
      end

      let(:valid_course_params) { super().merge("school_uuids" => [site_two.uuid, site.uuid]) }

      it "assigns every selected school, in the order they were submitted" do
        expect(created_course.sites.map(&:id)).to eq([site_two.id, site.id])
        expect(created_course.schools.map(&:gias_school_id)).to eq([gias_school_two.id, gias_school.id])
        expect(created_course.errors).to be_empty
      end

      it "persists a Course::School for each selected school" do
        created_course.save!

        expect(Course::School.where(course: created_course).pluck(:provider_school_id))
          .to contain_exactly(provider_school.id, provider_school_two.id)
      end
    end

    # The legacy site write and the new-model write can disagree: a school with no
    # Provider::School is still attached as a site but produces no Course::School,
    # so under the flag the course runs at one fewer school than was selected.
    context "when only some of the selected schools have been backfilled" do
      let(:site_two) { create(:site, provider:) }

      let(:valid_course_params) { super().merge("school_uuids" => [site.uuid, site_two.uuid]) }

      before do
        allow(FeatureFlag).to receive(:active?).and_call_original
        allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(true)
      end

      it "keeps both sites but builds a Course::School only for the backfilled school" do
        expect(Rails.logger).to receive(:warn).with(/site_uuid=#{site_two.uuid}/)

        expect(created_course.sites.map(&:id)).to eq([site.id, site_two.id])
        expect(created_course.schools.map(&:gias_school_id)).to eq([gias_school.id])
        expect(created_course.errors).to be_empty
      end

      it "saves without surfacing the divergence to the provider" do
        allow(Rails.logger).to receive(:warn)

        created_course.save!

        expect(created_course.reload.sites.count).to eq(2)
        expect(Course::School.where(course: created_course).count).to eq(1)
      end
    end

    context "when a submitted school UUID cannot be resolved" do
      let(:unknown_school_uuid) { SecureRandom.uuid }

      let(:valid_course_params) do
        {
          "level" => "primary",
          "qualification" => "qts",
          "funding" => "fee",
          "school_uuids" => [unknown_school_uuid],
        }
      end

      it "logs the error and adds an unrecognised schools error" do
        expect(Rails.logger).to receive(:warn).with(/unrecognised school UUIDs/)

        expect(created_course.errors[:schools]).to include(
          "Some of the schools you selected were not recognised. Try again or get in touch with support at becomingateacher@digital.education.gov.uk",
        )
        expect(created_course.errors[:schools]).not_to include("Select at least one school")
        expect(created_course.schools).to be_empty
      end
    end

    context "when only some of the submitted school UUIDs can be resolved" do
      let(:valid_course_params) { super().merge("school_uuids" => [site.uuid, SecureRandom.uuid]) }

      it "assigns nothing rather than quietly creating the course with fewer schools" do
        allow(Rails.logger).to receive(:warn)

        expect(created_course.errors[:schools]).to include(
          "Some of the schools you selected were not recognised. Try again or get in touch with support at becomingateacher@digital.education.gov.uk",
        )
        expect(created_course.sites).to be_empty
        expect(created_course.schools).to be_empty
      end
    end

    context "when a submitted school UUID belongs to another provider" do
      let(:other_provider_site) { create(:site, provider: create(:provider)) }

      let(:valid_course_params) { super().merge("school_uuids" => [other_provider_site.uuid]) }

      it "treats it as unrecognised rather than attaching another provider's school" do
        allow(Rails.logger).to receive(:warn)

        expect(created_course.errors[:schools]).to include(
          "Some of the schools you selected were not recognised. Try again or get in touch with support at becomingateacher@digital.education.gov.uk",
        )
        expect(created_course.sites).to be_empty
        expect(created_course.schools).to be_empty
      end
    end

    context "when no schools are selected" do
      let(:valid_course_params) do
        {
          "level" => "primary",
          "qualification" => "qts",
          "funding" => "fee",
          "school_uuids" => [],
        }
      end

      before do
        allow(FeatureFlag).to receive(:active?).and_call_original
        allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(false)
      end

      it "adds the existing error and builds no Course::School" do
        expect(created_course.errors[:schools]).to include("Select at least one school")
        expect(created_course.schools).to be_empty
      end
    end

    context "when no schools are selected and the flag is on" do
      let(:valid_course_params) do
        {
          "level" => "primary",
          "qualification" => "qts",
          "funding" => "fee",
          "school_uuids" => [],
        }
      end

      before do
        allow(FeatureFlag).to receive(:active?).and_call_original
        allow(FeatureFlag).to receive(:active?).with(:course_publishing_uses_new_school_model).and_return(true)
      end

      it "adds the existing error and builds no Course::School" do
        expect(created_course.errors[:schools]).to include("Select at least one school")
        expect(created_course.schools).to be_empty
      end
    end

    # A checkbox group posts a hidden blank value when nothing is ticked, so this
    # is the shape the form actually submits - not the empty array above.
    context "when the school checkboxes are submitted with nothing ticked" do
      let(:valid_course_params) { super().merge("school_uuids" => [""]) }

      it "adds the blank schools error and builds no Course::School" do
        expect(created_course.errors[:schools]).to include("Select at least one school")
        expect(created_course.sites).to be_empty
        expect(created_course.schools).to be_empty
      end
    end

    context "when no school selection is submitted at all" do
      let(:valid_course_params) { super().except("school_uuids") }

      it "reports the missing schools on :sites, not :schools" do
        expect(created_course.errors[:sites]).to include("Select at least one school")
        expect(created_course.errors[:schools]).to be_empty
        expect(created_course.schools).to be_empty
      end
    end
  end
end

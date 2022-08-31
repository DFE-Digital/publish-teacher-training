require "rails_helper"

RSpec.describe API::Public::V1::SerializableCourse do
  let(:enrichment) { build(:course_enrichment, :published) }
  let(:course) { create(:course, :with_accrediting_provider, enrichments: [enrichment]) }
  let(:resource) { described_class.new(object: course) }

  subject { JSON.parse(resource.as_jsonapi.to_json) }

  it "sets type to courses" do
    expect(resource.jsonapi_type).to eq(:courses)
  end

  it { is_expected.to have_type("courses") }

  context "when there is an accredited body with enrichments" do
    before do
      course.provider.update(accrediting_provider_enrichments: [{ Description: "foo", UcasProviderCode: course.accrediting_provider.provider_code }])
    end

    it { is_expected.to have_attribute(:about_accredited_body).with_value(course.provider.accrediting_provider_enrichments.first.Description) }
  end

  it { is_expected.to have_attribute(:about_accredited_body).with_value(nil) }
  it { is_expected.to have_attribute(:about_course).with_value(course.latest_published_enrichment.about_course) }
  it { is_expected.to have_attribute(:accredited_body_code).with_value(course.accredited_body_code) }
  it { is_expected.to have_attribute(:age_minimum).with_value(3) }
  it { is_expected.to have_attribute(:age_maximum).with_value(7) }
  it { is_expected.to have_attribute(:applications_open_from).with_value(course.applications_open_from.iso8601) }
  it { expect(subject["attributes"]["applications_open_from"]).to match(/\d{4}-\d{2}-\d{2}/) }
  it { is_expected.to have_attribute(:bursary_amount).with_value(nil) }

  context "when financial_incentives are present" do
    let(:course) { create(:course, :with_accrediting_provider, enrichments: [enrichment], level: "secondary", subjects: [find_or_create(:secondary_subject, :physics)]) }

    it { is_expected.to have_attribute(:scholarship_amount).with_value("26000") }
    it { is_expected.to have_attribute(:bursary_amount).with_value("24000") }
  end

  it { is_expected.to have_attribute(:bursary_requirements).with_value(course.bursary_requirements) }
  it { is_expected.to have_attribute(:changed_at).with_value(course.changed_at.iso8601) }
  it { is_expected.to have_attribute(:code).with_value(course.course_code) }
  it { is_expected.to have_attribute(:course_length).with_value(course.latest_published_enrichment.course_length) }
  it { is_expected.to have_attribute(:created_at).with_value(course.created_at.iso8601) }
  it { is_expected.to have_attribute(:fee_details).with_value(course.latest_published_enrichment.fee_details) }
  it { is_expected.to have_attribute(:fee_international).with_value(course.latest_published_enrichment.fee_international) }
  it { is_expected.to have_attribute(:fee_domestic).with_value(course.latest_published_enrichment.fee_uk_eu) }
  it { is_expected.to have_attribute(:financial_support).with_value(course.latest_published_enrichment.financial_support) }
  it { is_expected.to have_attribute(:findable).with_value(course.findable?) }
  it { is_expected.to have_attribute(:funding_type).with_value("apprenticeship") }
  it { is_expected.to have_attribute(:gcse_subjects_required).with_value(%w[maths english science]) }
  it { is_expected.to have_attribute(:has_early_career_payments).with_value(false) }
  it { is_expected.to have_attribute(:financial_support).with_value(course.latest_published_enrichment.financial_support) }
  it { is_expected.to have_attribute(:has_scholarship).with_value(course.has_scholarship?) }
  it { is_expected.to have_attribute(:has_vacancies).with_value(course.has_vacancies?) }
  it { is_expected.to have_attribute(:how_school_placements_work).with_value(course.latest_published_enrichment.how_school_placements_work) }
  it { is_expected.to have_attribute(:interview_process).with_value(course.latest_published_enrichment.interview_process) }
  it { is_expected.to have_attribute(:is_send).with_value(course.is_send?) }
  it { is_expected.to have_attribute(:last_published_at).with_value(course.last_published_at.iso8601) }
  it { is_expected.to have_attribute(:level).with_value(course.level) }
  it { is_expected.to have_attribute(:name).with_value(course.name) }
  it { is_expected.to have_attribute(:open_for_applications).with_value(course.open_for_applications?) }
  it { is_expected.to have_attribute(:other_requirements).with_value(course.latest_published_enrichment.other_requirements) }
  it { is_expected.to have_attribute(:personal_qualities).with_value(course.latest_published_enrichment.personal_qualities) }
  it { is_expected.to have_attribute(:program_type).with_value(course.program_type) }
  it { is_expected.to have_attribute(:qualifications).with_value(%w[qts pgce]) }
  it { is_expected.to have_attribute(:required_qualifications).with_value(course.latest_published_enrichment.required_qualifications) }
  it { is_expected.to have_attribute(:required_qualifications_english).with_value("must_have_qualification_at_application_time") }
  it { is_expected.to have_attribute(:required_qualifications_maths).with_value("must_have_qualification_at_application_time") }
  it { is_expected.to have_attribute(:required_qualifications_science).with_value("must_have_qualification_at_application_time") }
  it { is_expected.to have_attribute(:running).with_value(course.findable?) }
  it { is_expected.to have_attribute(:salary_details).with_value(course.latest_published_enrichment.salary_details) }
  it { is_expected.to have_attribute(:scholarship_amount).with_value(nil) }
  it { is_expected.to have_attribute(:can_sponsor_skilled_worker_visa) }
  it { is_expected.to have_attribute(:can_sponsor_student_visa) }

  context "when bursary amount is present" do
    let(:course) { create(:course, :with_accrediting_provider, :secondary, enrichments: [enrichment], subjects: [find_or_create(:secondary_subject, :classics)]) }

    it { is_expected.to have_attribute(:bursary_amount).with_value("10000") }
  end

  it { is_expected.to have_attribute(:start_date).with_value("September #{course.provider.recruitment_cycle.year}") }
  it { is_expected.to have_attribute(:state).with_value("published") }
  it { is_expected.to have_attribute(:study_mode).with_value("full_time") }
  it { is_expected.to have_attribute(:summary).with_value("PGCE with QTS full time teaching apprenticeship") }
  it { is_expected.to have_attribute(:subject_codes).with_value(%w[00]) }

  it { is_expected.to have_attribute(:degree_grade).with_value(course.degree_grade) }
  it { is_expected.to have_attribute(:degree_subject_requirements).with_value(course.degree_subject_requirements) }
  it { is_expected.to have_attribute(:accept_pending_gcse).with_value(course.accept_pending_gcse) }
  it { is_expected.to have_attribute(:accept_gcse_equivalency).with_value(course.accept_gcse_equivalency) }
  it { is_expected.to have_attribute(:accept_english_gcse_equivalency).with_value(course.accept_english_gcse_equivalency) }
  it { is_expected.to have_attribute(:accept_maths_gcse_equivalency).with_value(course.accept_maths_gcse_equivalency) }
  it { is_expected.to have_attribute(:accept_science_gcse_equivalency).with_value(course.accept_science_gcse_equivalency) }
  it { is_expected.to have_attribute(:additional_gcse_equivalencies).with_value(course.additional_gcse_equivalencies) }
end

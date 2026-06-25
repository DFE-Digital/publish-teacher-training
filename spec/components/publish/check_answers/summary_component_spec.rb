# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::CheckAnswers::SummaryComponent, type: :component do
  subject(:rendered_component) { render_inline(described_class.new(wizard:)) }

  include_context "add_course_wizard"

  let(:current_step) { :check_answers }

  before do
    allow(wizard).to receive(:saved?).and_return(false)
  end

  it "renders level and SEND rows without change links" do
    state_store.write(level: "primary", is_send: "false")
    allow(wizard).to receive(:saved?).with(:level).and_return(true)

    expect(rendered_component).to have_text("Subject level")
    expect(rendered_component).to have_text("Primary")
    expect(rendered_component).to have_text("Special educational needs and disability (SEND)")
    expect(rendered_component).to have_text("No")
    expect(rendered_component).to have_no_link("Change subject level")
  end

  it "renders subject row once for the selected level" do
    primary_subject = find_or_create(:primary_subject, :primary)
    secondary_subject = find_or_create(:secondary_subject, :physics)

    state_store.write(
      level: "primary",
      primary_master_subject_id: primary_subject.id.to_s,
      secondary_master_subject_id: secondary_subject.id.to_s,
    )

    allow(wizard).to receive(:saved?).with(:primary_subjects).and_return(true)
    allow(wizard).to receive(:saved?).with(:secondary_subjects).and_return(true)

    subject_label_nodes = rendered_component.css(".govuk-summary-list__key").select { |node| node.text.strip.match?(/\ASubjects?\z/) }
    expect(subject_label_nodes.size).to eq(1)
  end

  it "renders the engineers row when physics specialisms are saved" do
    state_store.write(campaign_name: "engineers_teach_physics")
    allow(wizard).to receive(:saved?).with(:physics_specialisms).and_return(true)

    expect(rendered_component).to have_text("Engineers Teach Physics")
    expect(rendered_component).to have_text("Yes")
    expect(rendered_component).to have_link("Change", href: /return_to_review=physics_specialisms/)
  end

  it "renders age range, qualification, funding, study pattern and start date rows" do
    primary_subject = find_or_create(:primary_subject, :primary)

    state_store.write(
      level: "primary",
      is_send: "false",
      primary_master_subject_id: primary_subject.id.to_s,
      age_range_in_years: "3_to_7",
      qualification: "undergraduate_degree_with_qts",
      funding_type: nil,
      study_pattern: [],
      start_date: "July 2027",
    )

    allow(wizard).to receive(:saved?).with(:primary_subjects).and_return(true)
    allow(wizard).to receive(:saved?).with(:age_range).and_return(true)
    allow(wizard).to receive(:saved?).with(:qualifications).and_return(true)
    allow(wizard).to receive(:saved?).with(:funding_type).and_return(true)
    allow(wizard).to receive(:saved?).with(:study_pattern).and_return(true)
    allow(wizard).to receive(:saved?).with(:start_date).and_return(true)

    expect(rendered_component).to have_text("Age range")
    expect(rendered_component).to have_text("3 to 7")
    expect(rendered_component).to have_text("Qualification")
    expect(rendered_component).to have_text("Teacher degree apprenticeship (TDA) with QTS")
    expect(rendered_component).to have_text("Funding type")
    expect(rendered_component).to have_text("Salary (apprenticeship)")
    expect(rendered_component).to have_text("Study pattern")
    expect(rendered_component).to have_text("Full time")
    expect(rendered_component).to have_text("Course start date")
    expect(rendered_component).to have_text("July 2027")
  end

  it "renders school and study-site rows with selected values and change links" do
    placement_site = provider.sites.first || create(:site, provider:)
    study_site = provider.study_sites.first || create(:site, :study_site, provider:)

    state_store.write(
      qualification: "undergraduate_degree_with_qts",
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [study_site.id.to_s],
    )
    allow(wizard).to receive(:saved?).with(:schools).and_return(true)
    allow(wizard).to receive(:saved?).with(:study_sites).and_return(true)

    expect(rendered_component).to have_text("Employing school")
    expect(rendered_component).to have_text(placement_site.location_name)
    expect(rendered_component).to have_link("Change", href: /return_to_review=schools/)
    expect(rendered_component).to have_text("Study site")
    expect(rendered_component).to have_text(study_site.location_name)
    expect(rendered_component).to have_link("Change", href: /return_to_review=study_sites/)
  end

  it "renders select study site CTA when none is selected but study sites exist" do
    placement_site = provider.sites.first || create(:site, provider:)
    provider.study_sites.first || create(:site, :study_site, provider:)

    state_store.write(
      qualification: "undergraduate_degree_with_qts",
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [],
    )
    allow(wizard).to receive(:saved?).with(:schools).and_return(true)

    expect(rendered_component).to have_text("Study sites")
    expect(rendered_component).to have_link("Select a study site", href: /return_to_review=study_sites/)
    expect(rendered_component).to have_no_selector("a[href*='return_to_review=study_sites']", text: "Change")
  end

  it "renders add study site CTA when provider has no study sites" do
    placement_site = provider.sites.first || create(:site, provider:)
    provider.study_sites.destroy_all

    state_store.write(
      qualification: "undergraduate_degree_with_qts",
      site_ids: [placement_site.id.to_s],
      study_sites_ids: [],
    )
    allow(wizard).to receive(:saved?).with(:schools).and_return(true)

    expect(rendered_component).to have_link("Add a study site")
    expect(rendered_component).to have_no_selector("a[href*='return_to_review=study_sites']", text: "Change")
  end

  it "renders accredited provider row with and without change link depending on saved state" do
    accrediting_provider = instance_double(Provider, provider_name: "Acme Accreditor", provider_code: "AC1")
    allow(wizard).to receive(:accrediting_provider).and_return(accrediting_provider)
    allow(wizard).to receive(:saved?).with(:accredited_provider).and_return(true)

    expect(rendered_component).to have_text("Accredited provider")
    expect(rendered_component).to have_text("Acme Accreditor")
    expect(rendered_component).to have_link("Change", href: /return_to_review=accredited_provider/)
  end

  it "renders visa rows including skilled worker and deadline rows" do
    state_store.write(
      qualification: "undergraduate_degree_with_qts",
      can_sponsor_student_visa: true,
      can_sponsor_skilled_worker_visa: false,
      visa_sponsorship_application_deadline_required: true,
      visa_sponsorship_application_deadline_at: CourseWizard::Steps::VisaSponsorshipApplicationDeadlineAt::DateParts.new("2027", "3", "1"),
    )

    allow(wizard).to receive(:saved?).with(:visa_sponsorship).and_return(true)
    allow(wizard).to receive(:saved?).with(:skilled_worker_visa).and_return(true)
    allow(wizard).to receive(:saved?).with(:visa_sponsorship_application_deadline_required).and_return(true)
    allow(wizard).to receive(:saved?).with(:visa_sponsorship_application_deadline_at).and_return(true)

    expect(rendered_component).to have_text("Student visas")
    expect(rendered_component).to have_text("Yes - can sponsor")
    expect(rendered_component).to have_text("Skilled Worker visas")
    expect(rendered_component).to have_text("No - cannot sponsor")
    expect(rendered_component).to have_text("Is there a visa sponsorship deadline?")
    expect(rendered_component).to have_text("Yes")
    expect(rendered_component).to have_text("Visa sponsorship deadline")
    expect(rendered_component).to have_text(Date.new(2027, 3, 1).to_fs(:govuk_date))
    expect(rendered_component).to have_no_link("Change skilled worker visas")
  end
end

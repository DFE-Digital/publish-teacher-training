# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sandbox::ImportProviderCourses do
  subject(:import) do
    described_class.call(provider_code: "C55", year:, confirm:, client:, out:)
  end

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:year) { recruitment_cycle.year.to_i }
  let(:confirm) { true }
  let(:out) { StringIO.new }
  let!(:provider) { create(:provider, provider_code: "C55", recruitment_cycle:) }
  let!(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
  let!(:french) { find_or_create(:modern_languages_subject, :french) }
  let!(:spanish) { find_or_create(:modern_languages_subject, :spanish) }
  let!(:gias_school) { create(:gias_school, urn: "133802") }

  # The real RX41 course, moved into the cycle under test.
  let(:prod_course) do
    course = JSON.parse(file_fixture("publish_public_api/course.json").read)
    course["attributes"].merge!(
      "start_date" => "September #{year}",
      "visa_sponsorship_application_deadline_at" => Time.zone.local(year, 5, 23, 23, 59, 59).iso8601,
    )
    course
  end
  let(:prod_courses) { [prod_course] }
  let(:locations) { JSON.parse(file_fixture("publish_public_api/course_locations.json").read) }
  let(:client) do
    instance_double(PublishPublicAPI::Client, courses: prod_courses, course_locations: locations)
  end

  def imported_course
    provider.reload.courses.find_by(course_code: "RX41")
  end

  it "creates the course with production's code, subjects and details" do
    expect { import }.to change { provider.courses.count }.by(1)

    expect(imported_course).to have_attributes(
      name: "Modern languages (Spanish, French)",
      level: "secondary",
      qualification: "pgce_with_qts",
      age_range_in_years: "11_to_16",
      funding: "fee",
      application_status: "open",
    )
    expect(client).to have_received(:courses).with(year:, provider_code: "C55")
  end

  it "gives a new course production's uuid" do
    import

    expect(imported_course.uuid).to eq("030a7eef-dba0-4365-a62b-1252401114a0")
  end

  context "when production's course uuid is already used here" do
    before { create(:course, uuid: "030a7eef-dba0-4365-a62b-1252401114a0") }

    it "gives the course a new uuid and reports it" do
      result = import

      expect(imported_course.uuid).not_to eq("030a7eef-dba0-4365-a62b-1252401114a0")
      expect(result.uuid_clashes).to eq(["RX41: uuid 030a7eef-dba0-4365-a62b-1252401114a0 is already used here"])
      expect(out.string).to include("RX41: uuid 030a7eef-dba0-4365-a62b-1252401114a0 is already used here")
    end
  end

  # The Modern Languages subject has no code, so the API leaves it out.
  it "adds the Modern Languages subject to a course with languages" do
    import

    expect(imported_course.course_subjects.map(&:subject)).to eq([modern_languages, french, spanish])
    expect(imported_course.master_subject_id).to eq(modern_languages.id)
  end

  it "publishes the course" do
    import

    expect(imported_course).to be_is_published
    expect(imported_course.first_published_at).to be_present
    expect(imported_course.enrichments.sole).to have_attributes(
      status: "published",
      fee_uk_eu: 10_050,
      course_length: "OneYear",
    )
  end

  it "gives the course production's school" do
    import

    expect(imported_course.schools.map(&:site_code)).to eq(["-"])
    expect(imported_course.schools.sole.gias_school).to eq(gias_school)
  end

  it "reports what it did" do
    result = import

    expect(result).to have_attributes(created: %w[RX41], updated: [], skipped: [])
    expect(out.string).to include("Created 1 course: RX41").and include("COMMITTED")
  end

  context "when the course is already in this environment" do
    let!(:existing) do
      create(:course, provider:, course_code: "RX41", name: "Old name", level: :primary, age_range_in_years: "3_to_7")
    end

    it "updates it to match production, keeping its own uuid" do
      original_uuid = existing.uuid
      result = import

      expect(existing.reload.uuid).to eq(original_uuid)

      expect(provider.courses.count).to eq(1)
      expect(existing.reload).to have_attributes(name: "Modern languages (Spanish, French)", level: "secondary")
      expect(existing.course_subjects.map(&:subject)).to eq([modern_languages, french, spanish])
      expect(result).to have_attributes(created: [], updated: %w[RX41])
    end
  end

  context "when the course was deleted in this environment" do
    let!(:discarded) do
      create(:course, provider:, course_code: "RX41", discarded_at: 1.day.ago)
    end

    it "restores it and updates it to match production" do
      expect { import }.not_to change(Course.with_discarded, :count)

      expect(discarded.reload).to have_attributes(discarded_at: nil, name: "Modern languages (Spanish, French)")
      expect(import).to have_attributes(created: [], updated: ["RX41 (restored)"])
    end
  end

  context "when the course has a school production no longer has" do
    let!(:existing) { create(:course, provider:, course_code: "RX41") }

    before do
      old_school = create(:provider_school, provider:, site_code: "Z", gias_school: create(:gias_school, urn: "999999"))
      existing.schools.create!(provider_school: old_school, gias_school: old_school.gias_school)
    end

    it "unlinks it and reports it" do
      result = import

      expect(existing.schools.reload.map(&:site_code)).to eq(["-"])
      expect(result.schools_unlinked).to eq(["Z (999999)"])
      expect(out.string).to include("Unlinked 1 school: Z (999999)")
    end
  end

  it "gives the same result when run again" do
    described_class.call(provider_code: "C55", year:, confirm: true, client:, out: StringIO.new)

    expect { import }.not_to(change { [Course.count, CourseEnrichment.count, Course::School.count] })
    expect(import).to have_attributes(created: [], updated: %w[RX41])
  end

  context "when not confirmed" do
    let(:confirm) { false }

    it "changes nothing but reports what it would do" do
      expect { import }.not_to(change { [Course.count, CourseEnrichment.count, Provider::School.count] })

      expect(import.created).to eq(%w[RX41])
      expect(out.string).to include("DRY RUN")
    end
  end

  context "when a course has a subject this environment doesn't know" do
    let(:prod_courses) do
      [prod_course.deep_merge("attributes" => { "subject_codes" => %w[15 ZZ] })]
    end

    it "skips the course" do
      expect { import }.not_to change(Course, :count)

      expect(import.skipped).to eq(["RX41: unknown subject codes ZZ"])
    end
  end

  context "when a course is invalid" do
    let(:other) { prod_course.deep_merge("id" => "other", "attributes" => { "code" => "AB12", "name" => nil }) }
    let(:prod_courses) { [other, prod_course] }

    it "skips that course and imports the rest" do
      expect { import }.to change(Course, :count).by(1)

      expect(import.created).to eq(%w[RX41])
      expect(import.skipped).to contain_exactly(a_string_starting_with("AB12: "))
    end
  end

  context "when a course fails after its schools were added" do
    let(:prod_courses) { [prod_course.deep_merge("attributes" => { "fee_domestic" => 200_000 })] }

    it "reports only that it was skipped" do
      result = import

      expect(result.skipped).to contain_exactly(a_string_starting_with("RX41: "))
      expect(result).to have_attributes(created: [], schools_created: [], not_published: [])
      expect(Provider::School.count).to eq(0)
    end
  end

  context "when the provider has courses that production doesn't" do
    before { create(:course, provider:, course_code: "ZZ99") }

    it "keeps them and lists them" do
      result = import

      expect(provider.courses.find_by(course_code: "ZZ99")).to be_present
      expect(result.sandbox_only).to eq(%w[ZZ99])
    end
  end

  context "when the course has an accredited provider" do
    let(:prod_courses) { [prod_course.deep_merge("attributes" => { "accredited_body_code" => "A01" })] }

    it "adds the partnership when the accredited provider is here" do
      accredited = create(:provider, :accredited_provider, provider_code: "A01", recruitment_cycle:)

      import

      expect(imported_course.accredited_provider_code).to eq("A01")
      expect(provider.accredited_partners).to eq([accredited])
    end

    it "reports the accredited provider when it isn't here, and doesn't publish the course" do
      result = import

      expect(result.missing_accredited_providers).to eq(%w[A01])
      expect(imported_course.accredited_provider_code).to eq("A01")
      expect(imported_course).not_to be_is_published
      expect(result.not_published).to eq(["RX41: accredited provider A01 missing"])
    end
  end

  context "when in production" do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new("production"))
    end

    it "refuses to run" do
      expect { import }.to raise_error(described_class::Abort, "Can only be run in sandbox or development")
      expect(client).not_to have_received(:courses)
    end
  end

  context "when one of the course's schools conflicts with one here" do
    before { create(:provider_school, :main_site, provider:) }

    it "saves the course as a draft and reports it" do
      result = import

      expect(imported_course.enrichments.sole).to have_attributes(status: "draft", course_length: "OneYear")
      expect(imported_course.first_published_at).to be_nil
      expect(result.not_published).to eq(["RX41: school conflict"])
      expect(out.string).to include("Not published 1 course: RX41: school conflict")
    end

    context "when the course is already published here" do
      let!(:existing) { create(:course, :published, provider:, course_code: "RX41") }

      it "leaves it published" do
        import

        expect(existing.reload).to be_is_published
      end
    end
  end

  context "when there is no cycle for the year" do
    let(:year) { 1999 }

    it "aborts before calling the API" do
      expect { import }.to raise_error(described_class::Abort, "There is no 1999 recruitment cycle here")
      expect(client).not_to have_received(:courses)
    end
  end

  context "when the provider isn't in the cycle" do
    before { provider.update!(provider_code: "X99") }

    it "aborts before calling the API" do
      expect { import }.to raise_error(described_class::Abort, "Provider C55 isn't in the #{year} recruitment cycle here")
      expect(client).not_to have_received(:courses)
    end
  end
end

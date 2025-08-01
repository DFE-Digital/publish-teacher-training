# frozen_string_literal: true

require "rails_helper"

describe Provider do
  subject { provider }

  let(:courses) { [] }
  let(:provider) do
    create(:provider,
           provider_name: "ACME SCITT",
           courses:)
  end

  its(:to_s) { is_expected.to eq("ACME SCITT (#{provider.provider_code}) [#{provider.recruitment_cycle}]") }

  describe "auditing" do
    it { is_expected.to be_audited.except(:changed_at) }
    it { is_expected.to have_associated_audits }
  end

  describe "associations" do
    it { is_expected.to have_many(:sites) }
    it { is_expected.to have_many(:users).through(:user_permissions) }
    it { is_expected.to have_one(:ucas_preferences).class_name("ProviderUCASPreference") }
    it { is_expected.to have_many(:contacts) }
    it { is_expected.to have_many(:user_notifications) }
  end

  context "callbacks" do
    context "provider is accredited" do
      it "updates the tsvector column with relevant info when the provider is accredited and updated" do
        provider = create(:provider, :accredited_provider)

        expect {
          provider.update(ukprn: "12345678", provider_name: "St Leo and Southmead/Provider", postcode: "sw1a 1aa")
        }.to change { provider.reload.searchable }.to(
          "'12345678':1 '1aa':12 'and':4,8 'leo':3,7 'provider':10 'southmead':9 'southmead/provider':5 'st':2,6 'sw1a':11 'sw1a1aa':13",
        )
      end
    end

    context "provider is not accredited" do
      it "does not update the tsvector column when the provider is updated" do
        provider = create(:provider, searchable: nil)

        expect {
          provider.update(ukprn: "12345678", provider_name: "St Leo's and Southmead/Provider", postcode: "sw1a 1aa")
        }.not_to(change { provider.reload.searchable })
      end
    end
  end

  describe "validations" do
    describe "word count validation" do
      it "self_description no presence needed" do
        provider.self_description = nil
        expect(provider).to be_valid
      end

      it "over maximum word count for self_description" do
        words = Faker::Lorem.words(number: 101)
        provider.self_description = words
        expect(provider).not_to be_valid
      end

      it "exactly at maximum word count for self_description" do
        words = Faker::Lorem.words(number: 100)
        provider.self_description = words
        expect(provider).to be_valid
      end

      it "provider_value_proposition no presence needed" do
        provider.provider_value_proposition = nil
        expect(provider).to be_valid
      end

      it "over maximum word count for provider_value_proposition" do
        words = Faker::Lorem.words(number: 101)
        provider.provider_value_proposition = words
        expect(provider).not_to be_valid
      end

      it "exactly at maximum word count for provider_value_proposition" do
        words = Faker::Lorem.words(number: 100)
        provider.provider_value_proposition = words
        expect(provider).to be_valid
      end
    end

    describe "urn validations" do
      context "when provider_type is lead_school" do
        let(:invalid_provider) { build(:provider, urn: "1") }
        let(:valid) { build(:provider, urn: "12345") }

        it "validates a urn of length 5 - 6" do
          expect(invalid_provider).not_to be_valid
          expect(valid).to be_valid
        end
      end

      context "when provider_type is lead_schools" do
        let(:invalid_provider) { build(:provider, urn: "XXXXXX") }

        it "validates that a urn contains digits only" do
          expect(invalid_provider).not_to be_valid
        end
      end
    end

    describe "provider code validations" do
      context "when same recruitment cycle" do
        let(:provider) { create(:provider) }
        let(:invalid_provider) { build(:provider, provider_code: provider.provider_code) }

        it "raises validation error" do
          expect(invalid_provider.valid?).to be false
          expect(invalid_provider.errors.messages[:provider_code].first).to eq "Provider code already taken"
        end
      end

      context "when different recruitment cycles" do
        let(:provider) { create(:provider, recruitment_cycle: create(:recruitment_cycle, year: "2022")) }
        let(:duplicated_provider_code) { build(:provider, provider_code: provider.provider_code, recruitment_cycle: create(:recruitment_cycle, year: "2021")) }

        it "does not raise validation error" do
          expect(duplicated_provider_code.valid?).to be true
          expect(duplicated_provider_code.errors.messages.any?).to be false
        end
      end
    end

    describe "provider_type validations" do
      let(:invalid_provider) { build(:provider, provider_type: nil) }
      let(:valid_provider) { build(:provider, provider_type: "lead_school") }

      it "validates provider_type" do
        expect(invalid_provider).not_to be_valid
        expect(valid_provider).to be_valid
      end
    end

    describe "accredited_provider_number is required for accredited provider" do
      let(:accredited_provider) { build(:provider, :accredited_provider, accredited_provider_number: nil) }

      it "accredited provider without accredited_provider_number is invalid" do
        expect(accredited_provider).not_to be_valid
        expect(accredited_provider.errors.messages[:accredited_provider_number]).to include("Enter a valid University accredited provider number - it must be 4 digits starting with a 1")
      end
    end

    describe "a lead school can not be an accredited provider" do
      let(:provider) { build(:provider, provider_type: "lead_school", accredited: true) }

      it "is invalid" do
        expect(provider).not_to be_valid
        expect(provider.errors[:accredited]).to include("Accredited provider must not have Provider type school")
      end
    end
  end

  describe "provider name normalizations" do
    it { is_expected.to normalize(:provider_name).from("  ACME  SCITT  ").to("ACME SCITT") }
    it { is_expected.to normalize(:provider_name).from('regular "quotes" used').to("regular “quotes” used") }
    it { is_expected.to normalize(:provider_name).from("it's a 'quoted' word").to("it’s a ‘quoted’ word") }
    it { is_expected.to normalize(:provider_name).from("  'single' and \"double\" quotes  with  spaces  ").to("‘single’ and “double” quotes with spaces") }
  end

  describe "provider code normalizations" do
    it { is_expected.to normalize(:provider_code).from("u2u").to("U2U") }
    it { is_expected.to normalize(:provider_code).from("ab1").to("AB1") }
  end

  describe "organisation" do
    it "returns the only organisation a provider has" do
      expect(subject.organisation).to eq subject.organisations.first
    end
  end

  describe "users" do
    let(:discarded_user) { create(:user, :discarded, providers: [provider]) }

    it "returns users who haven't been discarded" do
      expect(subject.users).not_to include(discarded_user)
    end
  end

  describe "changed_at" do
    it "is set on create" do
      provider = create(:provider)

      expect(provider.changed_at).to be_present
      expect(provider.changed_at).to eq provider.updated_at
    end

    it "is set on update" do
      Timecop.freeze do
        provider = create(:provider, updated_at: 1.hour.ago)
        provider.touch
        expect(provider.changed_at).to eq provider.updated_at
        expect(provider.changed_at).to be_within(1.second).of(Time.now.utc)
      end
    end
  end

  context "order" do
    let(:provider_a) { create(:provider, provider_name: "Provider A") }
    let(:provider_b) { create(:provider, provider_name: "Provider B") }

    describe "#by_name_ascending" do
      it "orders the providers by name in ascending order" do
        provider_a
        provider_b
        expect(described_class.by_name_ascending).to eq([provider_a, provider_b])
      end
    end

    describe "#by_name_descending" do
      it "orders the providers by name in descending order" do
        provider_a
        provider_b
        expect(described_class.by_name_descending).to eq([provider_b, provider_a])
      end
    end

    describe "#by_provider_name" do
      it "orders the providers by name in descending order" do
        provider_a
        provider_b
        expect(described_class.by_provider_name(provider_b.provider_name)).to eq([provider_b, provider_a])
      end
    end
  end

  describe "#changed_since" do
    context "with a provider that has been changed after the given timestamp" do
      subject { described_class.changed_since(10.minutes.ago) }

      let(:provider) { create(:provider, changed_at: 5.minutes.ago) }

      it { is_expected.to include provider }
    end

    context "with a provider that has been changed less than a second after the given timestamp" do
      subject { described_class.changed_since(timestamp) }

      let(:timestamp) { 5.minutes.ago }
      let(:provider) { create(:provider, changed_at: timestamp + 0.001.seconds) }

      it { is_expected.to include provider }
    end

    context "with a provider that has been changed exactly at the given timestamp" do
      subject { described_class.changed_since(publish_time) }

      let(:publish_time) { 10.minutes.ago }
      let(:provider) { create(:provider, changed_at: publish_time) }

      it { expect(subject).not_to include provider }
    end

    context "with a provider that has been changed before the given timestamp" do
      subject { described_class.changed_since(10.minutes.ago) }

      let(:provider) { create(:provider, changed_at: 1.hour.ago) }

      it { expect(subject).not_to include provider }
    end
  end

  describe "#provider_search" do
    subject { described_class.provider_search(provider_code) }

    let!(:provider) { create(:provider, provider_name: "Really big school", provider_code: "A01", courses: [build(:course, course_code: "2VVZ")]) }
    let!(:provider2) { create(:provider, provider_name: "Slightly smaller school", provider_code: "A02", courses: [build(:course, course_code: "2VVZ")]) }

    context "when provider code only is given" do
      let(:provider_code) { "A01" }

      it "returns the correct list of providers" do
        expect(subject).to contain_exactly(provider)
      end
    end
  end

  describe "#provider_name_search" do
    subject { described_class.provider_name_search(provider_name) }

    let!(:provider)  { create(:provider, provider_name: "Ford school", provider_code: "A01", courses: [build(:course, course_code: "2VVZ")]) }
    let!(:provider2) { create(:provider, provider_name: "Almost forgotten school", provider_code: "A02", courses: [build(:course, course_code: "2VVZ")]) }

    context "when partial provider name is given" do
      let(:provider_name) { "FOR" }

      it "returns the correct list of providers" do
        expect(subject).to contain_exactly(provider, provider2)
      end
    end
  end

  describe "#course_search" do
    subject { described_class.course_search(course_code) }

    let!(:provider) { create(:provider, provider_name: "Really big school", provider_code: "A01", courses: [build(:course, course_code: "2VVZ")]) }
    let!(:provider2) { create(:provider, provider_name: "Slightly smaller school", provider_code: "A02", courses: [build(:course, course_code: "2VVZ")]) }

    context "when course code only is present" do
      let(:course_code) { "2VVZ" }

      it "returns the correct list of providers" do
        expect(subject).to contain_exactly(provider, provider2)
      end
    end
  end

  describe "#update_changed_at" do
    let(:provider) { create(:provider, changed_at: 1.hour.ago) }

    it "sets changed_at to the current time" do
      Timecop.freeze do
        provider.update_changed_at
        expect(provider.changed_at).to be_within(1.second).of(Time.now.utc)
      end
    end

    it "sets changed_at to the given time" do
      timestamp = 1.hour.ago
      provider.update_changed_at(timestamp:)
      expect(provider.changed_at).to be_within(1.second).of(timestamp)
    end

    it "leaves updated_at unchanged" do
      timestamp = 1.hour.ago
      provider.update updated_at: timestamp

      provider.update_changed_at
      expect(provider.updated_at).to be_within(1.second).of(timestamp)
    end
  end

  its(:recruitment_cycle) { is_expected.to eq find(:recruitment_cycle) }

  describe "#accredited" do
    context "when provider is accredited" do
      it "returns true" do
        provider = build(:accredited_provider)
        expect(provider).to be_accredited
      end
    end

    context "when provider is not accredited" do
      it "returns false" do
        provider = build(:provider)
        expect(provider).not_to be_accredited
      end
    end
  end

  describe "courses" do
    let(:course) { create(:course, :primary, :unpublished) }
    let!(:provider) { course.provider }

    describe "#courses_count" do
      it "returns course count using courses.size" do
        allow(provider.courses).to receive(:size).and_return(1)

        expect(provider.courses_count).to eq(1)
        expect(provider.courses).to have_received(:size)
      end

      context "with .include_courses_counts" do
        let(:provider_with_included) { described_class.include_courses_counts.first }

        it "return course count using included_courses_count" do
          allow(provider_with_included).to receive(:included_courses_count).and_return(1)
          allow(provider_with_included.courses).to receive(:size)

          expect(provider_with_included.courses_count).to eq(1)
          expect(provider_with_included).to have_received(:included_courses_count)
          expect(provider_with_included.courses).not_to have_received(:size)
        end
      end

      context "with .include_accredited_courses_counts" do
        let(:provider_with_included) { described_class.include_accredited_courses_counts(provider.provider_code).first }

        it "return course count using included_accredited_courses_count" do
          allow(provider_with_included).to receive(:included_accredited_courses_count).and_return(1)
          allow(provider_with_included.courses).to receive(:size)

          expect(provider_with_included.accredited_courses_count).to eq(1)
          expect(provider_with_included).to have_received(:included_accredited_courses_count)
          expect(provider_with_included.courses).not_to have_received(:size)
        end
      end
    end

    describe "#courses" do
      describe "discard" do
        it "reduces courses when one is discarded" do
          expect { course.discard }.to change { provider.reload.courses.size }.by(-1)
        end
      end
    end
  end

  describe "training_providers" do
    subject { accredited_provider.training_providers }

    let(:accredited_provider) { create(:provider, :accredited_provider) }
    let(:training_provider1) { create(:provider) }
    let(:training_provider2) { create(:provider) }

    let!(:course1) { create(:course, accrediting_provider: accredited_provider, provider: training_provider1) }
    let!(:course2) { create(:course, provider: training_provider2) }

    it { is_expected.to contain_exactly(training_provider1) }
  end

  describe "#before_create" do
    describe "#set_defaults" do
      let(:provider) { build(:provider) }

      it "sets the year_code from the recruitment_cycle" do
        expect(provider.year_code).to be_nil

        provider.save!

        expect(provider.year_code).to eq(provider.recruitment_cycle.year)
      end

      it "does not override a given value for year_code" do
        provider.year_code = 2020

        provider.save!

        expect(provider.year_code).to eq("2020")
      end
    end
  end

  describe "#discard" do
    subject { create(:provider) }

    context "before discarding" do
      its(:discarded?) { is_expected.to be false }

      it "is in kept" do
        provider
        expect(described_class.kept.size).to eq(1)
      end

      it "is not in discarded" do
        expect(described_class.discarded.size).to eq(0)
      end
    end

    context "after discarding" do
      before do
        subject.discard
      end

      its(:discarded?) { is_expected.to be true }

      it "is not in kept" do
        expect(described_class.kept.size).to eq(0)
      end

      it "is in discarded" do
        expect(described_class.discarded.size).to eq(1)
      end
    end

    context "a provider with courses" do
      let(:provider) { create(:provider, courses: [course, course2]) }
      let(:course) { build(:course) }
      let(:course2) { build(:course) }

      before do
        provider.discard
      end

      it "discards all of the providers courses" do
        expect(course.discarded?).to be_truthy
        expect(course2.discarded?).to be_truthy
      end
    end
  end

  describe "#discard_courses" do
    let(:provider) { create(:provider, courses: [course, course2]) }
    let(:course) { build(:course) }
    let(:course2) { build(:course) }

    before do
      provider.discard_courses
    end

    it "discards all of the providers courses" do
      expect(course.discarded?).to be_truthy
      expect(course2.discarded?).to be_truthy
    end
  end

  describe "#discard_sites" do
    let(:site) { build(:site) }
    let(:provider) { create(:provider, sites: [site]) }

    before do
      provider.discard_sites
    end

    it "discards all of the providers sites" do
      expect(provider.sites.count).to eq(0)
      expect(site.discarded?).to be_truthy
    end
  end

  describe "#next_available_course_code" do
    let(:provider) { create(:provider) }
    let(:course1) { create(:course, provider:, course_code: "A123") }
    let(:course2) { create(:course, provider:, course_code: "B456") }

    before do
      course1
      course2
    end

    it "Delegates to the correct service" do
      expect(provider).to delegate_method_to_service(
        :next_available_course_code,
        "Providers::GenerateUniqueCourseCodeService",
      ).with_arguments(
        existing_codes: %w[A123 B456],
      )
    end
  end

  describe "#accredited_courses" do
    let(:accrediting_provider) { create(:provider, :accredited_provider) }
    let!(:findable_course) do
      create(:course, name: "findable-course",
                      accrediting_provider:,
                      site_statuses: [build(:site_status, :findable)])
    end
    let!(:discarded_course) do
      create(:course, :deleted,
             name: "deleted-course",
             accrediting_provider:)
    end
    let!(:discontinued_course) do
      create(:course,
             name: "discontinued-course",
             accrediting_provider:,
             site_statuses: [build(:site_status, :discontinued)])
    end

    it "includes findable and discontinued courses but not discarded courses" do
      expect(accrediting_provider.accredited_courses).to include(findable_course)
      expect(accrediting_provider.accredited_courses).to include(discontinued_course)
      expect(accrediting_provider.accredited_courses).not_to include(discarded_course)
    end
  end

  # This is a self accredited course
  # There needs tests for normal accredited relationships
  describe "#current_accredited_courses" do
    # let(:training_provider) { create(:provider) }
    let(:accredited_provider) { create(:provider, :accredited_provider) }

    let(:last_years_provider) do
      # make provider_codes the same to simulate a rolled over provider
      create(:provider, :previous_recruitment_cycle, provider_code: accredited_provider.provider_code)
    end
    let!(:last_years_course) do
      create(:course,
             name: "last-years-course",
             provider: last_years_provider,
             accrediting_provider: accredited_provider,
             site_statuses: [build(:site_status)])
    end

    it "does not include courses from past cycles" do
      expect(provider.current_accredited_courses).not_to include last_years_course
    end
  end

  describe "scopes" do
    describe ".accredited" do
      let!(:accredited_providers) { create_list(:accredited_provider, 2) }
      let!(:providers) { create_list(:provider, 2) }

      it "returns only accredited providers" do
        expect(described_class.accredited).to match_array(accredited_providers)
      end
    end

    describe ".with_findable_courses" do
      subject do
        described_class.with_findable_courses
      end

      let(:findable_course) do
        create(:course, site_statuses: [build(:site_status, :findable)])
      end

      let(:findable_course_with_accrediting_provider) do
        create(:course, :with_accrediting_provider, site_statuses: [build(:site_status, :findable)])
      end

      let(:non_findable_course) do
        create(:course, site_statuses: [build(:site_status)])
      end

      let(:non_findable_course_with_accrediting_provider) do
        create(:course, :with_accrediting_provider, site_statuses: [build(:site_status)])
      end

      it "returns only findable courses' provider and/or accrediting provider" do
        findable_course
        findable_course_with_accrediting_provider

        non_findable_course
        non_findable_course_with_accrediting_provider
        expect(subject.map(&:id)).to contain_exactly(findable_course.provider.id,
                                                     findable_course_with_accrediting_provider.provider.id,
                                                     findable_course_with_accrediting_provider.accrediting_provider.id)
      end

      context "when the provider is the accredited provider for a course" do
        before do
          findable_course_with_accrediting_provider
          non_findable_course_with_accrediting_provider
        end

        it "is returned" do
          expect(subject).to contain_exactly(
            findable_course_with_accrediting_provider.provider,
            findable_course_with_accrediting_provider.accrediting_provider,
          )
        end
      end

      context "when the course is delivered by the provider" do
        before do
          findable_course
          non_findable_course
        end

        it "is returned" do
          expect(subject).to contain_exactly(findable_course.provider)
        end
      end

      context "when the course is not findable" do
        before do
          non_findable_course
          non_findable_course_with_accrediting_provider
        end

        it "is not returned" do
          expect(subject).not_to include(non_findable_course.provider,
                                         non_findable_course_with_accrediting_provider.provider,
                                         non_findable_course_with_accrediting_provider.accrediting_provider)
        end
      end
    end

    describe "in_current_cycle" do
      subject { described_class.in_current_cycle }

      let(:current_provider) { create(:provider) }
      let(:non_current_provider) { create(:provider, :previous_recruitment_cycle) }

      before do
        current_provider
        non_current_provider
      end

      it "includes providers in the current recruitment cycle" do
        expect(subject).to contain_exactly(current_provider)
      end
    end

    describe "#with_provider_types" do
      subject { described_class.with_provider_types(provider_types) }

      let(:provider_types) { %w[lead_school] }

      let(:provider) { create(:provider) }

      it "returns the correct providers" do
        expect(subject).to contain_exactly(provider)
      end
    end

    describe "#with_region_codes" do
      subject { described_class.with_region_codes(region_codes) }

      let(:region_codes) { %w[london] }

      let(:provider) { create(:provider) }

      before do
        provider
      end

      it "returns the providers with the region codes" do
        expect(subject).to contain_exactly(provider)
      end
    end

    describe "#with_can_sponsor_skilled_worker_visa" do
      subject { described_class.with_can_sponsor_skilled_worker_visa(can_sponsor_skilled_worker_visa) }

      let(:can_sponsor_skilled_worker_visa_provider) do
        create(:provider, can_sponsor_skilled_worker_visa: true)
      end
      let(:cannot_sponsor_skilled_worker_visa_provider) do
        create(:provider, can_sponsor_skilled_worker_visa: false)
      end

      before do
        can_sponsor_skilled_worker_visa_provider
        cannot_sponsor_skilled_worker_visa_provider
      end

      context "when can_sponsor_skilled_worker_visa is false" do
        let(:can_sponsor_skilled_worker_visa) { false }

        it "returns the providers that cannot sponsor skilled worker visa" do
          expect(subject).to contain_exactly(cannot_sponsor_skilled_worker_visa_provider)
        end
      end

      context "when can_sponsor_skilled_worker_visa is true" do
        let(:can_sponsor_skilled_worker_visa) { true }

        it "returns the providers that can sponsor skilled worker visa" do
          expect(subject).to contain_exactly(can_sponsor_skilled_worker_visa_provider)
        end
      end
    end

    describe "#with_can_sponsor_student_visa" do
      subject { described_class.with_can_sponsor_student_visa(can_sponsor_student_visa) }

      let(:can_sponsor_student_visa_provider) do
        create(:provider, can_sponsor_student_visa: true)
      end
      let(:cannot_sponsor_student_visa_provider) do
        create(:provider, can_sponsor_student_visa: false)
      end

      before do
        can_sponsor_student_visa_provider
        cannot_sponsor_student_visa_provider
      end

      context "when can_sponsor_student_visa is false" do
        let(:can_sponsor_student_visa) { false }

        it "returns the providers that cannot sponsor student visa" do
          expect(subject).to contain_exactly(cannot_sponsor_student_visa_provider)
        end
      end

      context "when can_sponsor_student_visa is true" do
        let(:can_sponsor_student_visa) { true }

        it "returns the providers that can sponsor student visa" do
          expect(subject).to contain_exactly(can_sponsor_student_visa_provider)
        end
      end
    end
  end

  describe "in_cycle" do
    subject { described_class.in_cycle(provider_in_current_cycle.recruitment_cycle) }

    let(:provider_in_current_cycle) { create(:provider) }
    let(:provider_in_previous_cycle) { create(:provider, :previous_recruitment_cycle) }

    before do
      provider_in_current_cycle
      provider_in_previous_cycle
    end

    it "includes providers specified via the cycle provided" do
      expect(subject).to contain_exactly(provider_in_current_cycle)
    end
  end

  describe "geolocation" do
    include ActiveJob::TestHelper

    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end

    # Geocoding stubbed with support/helpers.rb
    let(:provider) do
      build(:provider,
            provider_name: "Southampton High School",
            address1: "Long Lane",
            address2: "Holbury",
            address3: nil,
            town: "Southampton",
            address4: nil,
            postcode: "SO45 2PA")
    end

    describe "#full_address" do
      it "Concatenates address details" do
        expect(provider.full_address).to eq("Southampton High School, Long Lane, Holbury, Southampton, SO45 2PA")
      end

      context "address is missing" do
        before do
          provider.provider_name = ""
          provider.address1 = ""
          provider.address2 = ""
          provider.address3 = ""
          provider.town = ""
          provider.address4 = ""
          provider.postcode = ""
        end

        it "returns an empty string" do
          expect(provider.full_address).to eq("")
        end
      end
    end

    describe "#needs_geolocation?" do
      subject { provider.needs_geolocation? }

      context "latitude is nil" do
        let(:provider) { build_stubbed(:provider, latitude: nil) }

        it { is_expected.to be(true) }
      end

      context "longitude is nil" do
        let(:provider) { build_stubbed(:provider, longitude: nil) }

        it { is_expected.to be(true) }
      end

      context "latitude and longitude is not nil" do
        let(:provider) { build_stubbed(:provider, latitude: 1.456789, longitude: 1.456789) }

        it { is_expected.to be(false) }
      end

      context "address" do
        let(:provider) do
          create(:provider,
                 latitude: 1.456789,
                 longitude: 1.456789,
                 provider_name: "Southampton High School",
                 address1: "Long Lane",
                 address2: "Holbury",
                 town: "Southampton",
                 address4: nil,
                 postcode: "SO45 2PA")
        end

        context "has not changed" do
          before do
            provider.update(address1: "Long Lane")
          end

          it { is_expected.to be(false) }
        end

        context "has changed" do
          before do
            provider.update(address1: "New address 1")
          end

          it { is_expected.to be(true) }
        end
      end
    end

    describe "#skip_geocoding" do
      before do
        allow(GeocodeJob).to receive(:perform_later)
      end

      context "skip_geocoding is 'true'" do
        it "does not geocode" do
          provider.skip_geocoding = true

          provider.save

          expect(GeocodeJob).not_to have_received(:perform_later)
        end
      end

      context "skip_geocoding is 'false'" do
        it "does not geocode" do
          provider.skip_geocoding = false

          provider.save

          expect(GeocodeJob).to have_received(:perform_later)
        end
      end
    end
  end

  describe "#search" do
    subject { described_class.provider_search(search_term) }

    let!(:matching_provider) { create(:provider, provider_code: "ABC", provider_name: "Dave's Searches") }
    let!(:non_matching_provider) { create(:provider) }

    context "with an exactly matching code" do
      let(:search_term) { "ABC" }

      it { is_expected.to contain_exactly(matching_provider) }
    end

    context "with an exactly matching name" do
      let(:search_term) { "Dave's Searches" }

      it { is_expected.to contain_exactly(matching_provider) }
    end

    context "with unicode in the name" do
      let(:search_term) { "Dave’s Searches" }

      it { is_expected.to contain_exactly(matching_provider) }
    end

    context "with extra spaces in the name" do
      let(:search_term) { "Dave's  Searches" }

      it { is_expected.to contain_exactly(matching_provider) }
    end

    context "with non matching case code" do
      let(:search_term) { "abc" }

      it { is_expected.to contain_exactly(matching_provider) }
    end

    context "with non matching case name" do
      let(:search_term) { "dave's searches" }

      it { is_expected.to contain_exactly(matching_provider) }
    end

    context "with partial search term" do
      let(:search_term) { "dave" }

      it { is_expected.to contain_exactly(matching_provider) }
    end
  end

  describe "#study_sites" do
    let(:school) { build(:site, :school) }
    let(:study_site) { build(:site, :study_site) }

    let(:provider) { create(:provider, sites: [school, study_site]) }

    it "returns only study sites" do
      expect(provider.study_sites).to match([study_site])
    end
  end

  describe "#update_courses_program_type" do
    let(:provider) { create(:provider, :lead_school) }
    let!(:course1) { create(:course, provider:, funding: "salary") }
    let!(:course2) { create(:course, provider:, funding: "fee") }

    it "updates program_type for all associated courses when provider_type changes" do
      provider.update(provider_type: "scitt")
      expect { course1.reload.program_type }.to change(course1, :program_type).from("school_direct_salaried_training_programme").to("scitt_salaried_programme")

      expect { course2.reload.program_type }.to change(course2, :program_type).from("school_direct_training_programme").to("scitt_programme")
    end
  end

  describe "Training and Accredited Partnerships" do
    let(:training_provider) { create(:provider) }
    let(:accredited_provider) { create(:accredited_provider) }

    it "can create an accredited partnership" do
      partnership = training_provider.accredited_partnerships.create(accredited_provider:)
      expect(training_provider.accredited_partnerships).to include(partnership)
      expect(training_provider.accredited_partners).to include(accredited_provider)
      expect(partnership).to be_valid
      expect(partnership).to be_persisted
    end

    it "can create an training partnership" do
      partnership = accredited_provider.training_partnerships.create(training_provider:)
      expect(accredited_provider.training_partnerships).to include(partnership)
      expect(accredited_provider.training_partners).to include(training_provider)
      expect(partnership).to be_valid
      expect(partnership).to be_persisted
    end
  end
end

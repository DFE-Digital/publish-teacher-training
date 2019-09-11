# == Schema Information
#
# Table name: provider
#
#  id                   :integer          not null, primary key
#  address4             :text
#  provider_name        :text
#  scheme_member        :text
#  contact_name         :text
#  year_code            :text
#  provider_code        :text
#  provider_type        :text
#  postcode             :text
#  scitt                :text
#  url                  :text
#  address1             :text
#  address2             :text
#  address3             :text
#  email                :text
#  telephone            :text
#  region_code          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  accrediting_provider :text
#  last_published_at    :datetime
#  changed_at           :datetime         not null
#  recruitment_cycle_id :integer          not null
#

require 'rails_helper'

describe Provider, type: :model do
  let(:courses) { [] }
  let(:enrichments) { [] }
  let(:provider) do
    create(:provider,
           provider_name: 'ACME SCITT',
           provider_code: 'A01',
           enrichments: enrichments,
           courses: courses)
  end

  subject { provider }

  its(:to_s) { should eq('ACME SCITT (A01) [2019/20]') }

  describe 'auditing' do
    it { should be_audited.except(:changed_at) }
    it { should have_associated_audits }
  end

  describe 'associations' do
    it { should have_many(:sites) }
    it { should have_many(:users).through(:organisations) }
    it { should have_one(:ucas_preferences).class_name('ProviderUCASPreference') }
    it { should have_many(:contacts) }
  end

  describe 'organisation' do
    it 'returns the only organisation a provider has' do
      expect(subject.organisation).to eq subject.organisations.first
    end
  end

  describe 'changed_at' do
    it 'is set on create' do
      provider = Provider.create(
        recruitment_cycle: find_or_create(:recruitment_cycle)
      )
      expect(provider.changed_at).to be_present
      expect(provider.changed_at).to eq provider.updated_at
    end

    it 'is set on update' do
      Timecop.freeze do
        provider = create(:provider, updated_at: 1.hour.ago)
        provider.touch
        expect(provider.changed_at).to eq provider.updated_at
        expect(provider.changed_at).to eq Time.now.utc
      end
    end
  end

  describe '#changed_since' do
    context 'with a provider that has been changed after the given timestamp' do
      let(:provider) { create(:provider, changed_at: 5.minutes.ago) }

      subject { Provider.changed_since(10.minutes.ago) }

      it { should include provider }
    end

    context 'with a provider that has been changed less than a second after the given timestamp' do
      let(:timestamp) { 5.minutes.ago }
      let(:provider) { create(:provider, changed_at: timestamp + 0.001.seconds) }

      subject { Provider.changed_since(timestamp) }

      it { should include provider }
    end

    context 'with a provider that has been changed exactly at the given timestamp' do
      let(:publish_time) { 10.minutes.ago }
      let(:provider) { create(:provider, changed_at: publish_time) }

      subject { Provider.changed_since(publish_time) }

      it { should_not include provider }
    end

    context 'with a provider that has been changed before the given timestamp' do
      let(:provider) { create(:provider, changed_at: 1.hour.ago) }

      subject { Provider.changed_since(10.minutes.ago) }

      it { should_not include provider }
    end
  end

  describe '#external_contact_info' do
    context 'provider has draft and multiple published enrichments' do
      it 'returns contact info from the provider enrichment' do
        published_enrichment = build(:provider_enrichment, :published,
                                     last_published_at: 5.days.ago)
        latest_published_enrichment = build(:provider_enrichment, :published,
                                            last_published_at: 1.day.ago)
        enrichment = build(:provider_enrichment)

        provider = create(:provider, enrichments: [published_enrichment,
                                                   latest_published_enrichment,
                                                   enrichment])

        expect(provider.external_contact_info).to(
          eq(
            'address1'    => enrichment.address1,
            'address2'    => enrichment.address2,
            'address3'    => enrichment.address3,
            'address4'    => enrichment.address4,
            'postcode'    => enrichment.postcode,
            'region_code' => enrichment.region_code,
            'telephone'   => enrichment.telephone,
            'email'       => enrichment.email,
            'website'     => enrichment.website
          )
        )
      end
    end

    context 'provider has no published enrichments' do
      it 'returns the info from the provider record' do
        provider = create(:provider)
        expect(provider.external_contact_info).to(
          eq(
            'address1'    => provider.address1,
            'address2'    => provider.address2,
            'address3'    => provider.address3,
            'address4'    => provider.address4,
            'postcode'    => provider.postcode,
            'region_code' => provider.region_code,
            'telephone'   => provider.telephone,
            'email'       => provider.email,
            'website'     => provider.url
          )
        )
      end
    end
  end

  describe '.in_order' do
    let!(:second_alphabetical_provider) { create(:provider, provider_name: "Zork") }
    let!(:first_alphabetical_provider) { create(:provider, provider_name: "Acme") }

    it 'returns sorted providers' do
      expect(Provider.in_order).to match_array([first_alphabetical_provider, second_alphabetical_provider])
    end
  end

  describe '.search_by_code_or_name' do
    let(:provider1) { create(:provider, provider_name: "Zork") }
    let(:provider2) { create(:provider, provider_name: "Acme") }

    subject { Provider.search_by_code_or_name('zork') }

    it { should include(provider1) }
    it { should_not include(provider2) }
  end

  describe '#update_changed_at' do
    let(:provider) { create(:provider, changed_at: 1.hour.ago) }

    it 'sets changed_at to the current time' do
      Timecop.freeze do
        provider.update_changed_at
        expect(provider.changed_at).to eq Time.now.utc
      end
    end

    it 'sets changed_at to the given time' do
      timestamp = 1.hour.ago
      provider.update_changed_at timestamp: timestamp
      expect(provider.changed_at).to eq timestamp
    end

    it 'leaves updated_at unchanged' do
      timestamp = 1.hour.ago
      provider.update updated_at: timestamp

      provider.update_changed_at
      expect(provider.updated_at).to eq timestamp
    end
  end

  describe "#provider_type=" do
    subject { build(:provider, accrediting_provider: nil) }

    it "sets the provider type" do
      expect { subject.provider_type = "scitt" }
        .to change { subject.provider_type }
        .from(nil).to('scitt')
    end

    it "sets 'scitt=Y' when the provider type is set to scitt" do
      expect { subject.provider_type = "scitt" }
        .to change { subject.scitt }
        .from(nil).to('Y')
    end

    it "sets 'scitt=N' when the provider type is not a scitt" do
      expect { subject.provider_type = "university" }
        .to change { subject.scitt }
        .from(nil).to('N')
    end

    it "sets 'accrediting_provider' correctly for SCITTs" do
      expect { subject.provider_type = "scitt" }
        .to change { subject.accrediting_provider }
        .from(nil).to('accredited_body')
    end

    it "sets 'accrediting_provider' correctly for universities" do
      expect { subject.provider_type = "university" }
        .to change { subject.accrediting_provider }
        .from(nil).to('accredited_body')
    end

    it "sets 'accrediting_provider' correctly for universities" do
      expect { subject.provider_type = "lead_school" }
        .to change { subject.accrediting_provider }
        .from(nil).to('not_an_accredited_body')
    end
  end

  its(:recruitment_cycle) { should eq find(:recruitment_cycle) }

  describe '#unassigned_site_codes' do
    subject { create(:provider) }
    before do
      %w[A B C D 1 2 3 -].each { |code| subject.sites << build(:site, code: code) }
    end

    let(:expected_unassigned_codes) { ('E'..'Z').to_a + %w[0] + ('4'..'9').to_a }

    its(:unassigned_site_codes) { should eq(expected_unassigned_codes) }
  end

  describe "#can_add_more_sites?" do
    context "when provider has less sites than max allowed" do
      subject { create(:provider) }
      its(:can_add_more_sites?) { should be_truthy }
    end

    context "when provider has the max sites allowed" do
      let(:all_site_codes) { ('A'..'Z').to_a + %w[0 -] + ('1'..'9').to_a }
      let(:sites) do
        all_site_codes.map { |code| build(:site, code: code) }
      end

      subject { create(:provider, sites: sites) }

      its(:can_add_more_sites?) { should be_falsey }
    end
  end

  it 'defines an enum for accrediting_provider' do
    expect(subject)
      .to define_enum_for("accrediting_provider")
            .backed_by_column_of_type(:text)
            .with_values('accredited_body' => 'Y', 'not_an_accredited_body' => 'N')
  end

  it 'defines an enum for accrediting_provider' do
    expect(subject)
      .to define_enum_for("scheme_member")
            .backed_by_column_of_type(:text)
            .with_values('is_a_UCAS_ITT_member' => 'Y', 'not_a_UCAS_ITT_member' => 'N')
  end

  describe "courses" do
    let(:provider) { create(:provider, courses: [course]) }
    let(:course) { build(:course) }

    describe "#courses_count" do
      before do
        provider
      end

      it 'returns course count using courses.size' do
        allow(provider.courses).to receive(:size).and_return(1)

        expect(provider.courses_count).to eq(1)
        expect(provider.courses).to have_received(:size)
      end

      context "with .include_courses_counts" do
        let(:provider_with_included) { Provider.include_courses_counts.first }

        it "return course count using included_courses_count" do
          allow(provider_with_included).to receive(:included_courses_count).and_return(1)
          allow(provider_with_included.courses).to receive(:size)

          expect(provider_with_included.courses_count).to eq(1)
          expect(provider_with_included).to have_received(:included_courses_count)
          expect(provider_with_included.courses).to_not have_received(:size)
        end
      end
    end

    describe ".include_courses_counts" do
      let(:first_provider) { Provider.include_courses_counts.first }
      before do
        provider
      end

      it 'includes course counts' do
        expect(first_provider.courses_count).to eq(1)
      end
    end

    describe '#courses' do
      describe 'discard' do
        it 'reduces courses when one is discarded' do
          expect { course.discard }.to change { provider.reload.courses.size }.by(-1)
        end
      end
    end

    describe '#syncable_courses' do
      let(:site) { build(:site) }
      let(:dfe_subject) { build(:ucas_subject, subject_name: "primary") }
      let(:non_dfe_subject) { build(:ucas_subject, subject_name: "secondary") }
      let(:findable_site_status_1) { build(:site_status, :findable, site: site) }
      let(:findable_site_status_2) { build(:site_status, :findable, site: site) }
      let(:suspended_site_status) { build(:site_status, :suspended, site: site) }
      let(:syncable_course) { build(:course, site_statuses: [findable_site_status_1], subjects: [dfe_subject]) }
      let(:suspended_course) { build(:course, site_statuses: [suspended_site_status], subjects: [dfe_subject]) }
      let(:invalid_subject_course) { build(:course, site_statuses: [findable_site_status_2], subjects: [non_dfe_subject]) }

      subject { create(:provider, courses: [syncable_course, suspended_course, invalid_subject_course], sites: [site]) }

      its(:syncable_courses) { should eq [syncable_course] }
    end
  end

  describe "accrediting_providers" do
    let(:provider) { create :provider, accrediting_provider: 'N' }

    let(:accrediting_provider) { create :provider, accrediting_provider: 'Y' }
    let!(:course1) { create :course, accrediting_provider: accrediting_provider, provider: provider }
    let!(:course2) { create :course, accrediting_provider: accrediting_provider, provider: provider }

    it "returns the course's accrediting provider" do
      expect(provider.accrediting_providers.first).to eq(accrediting_provider)
    end

    it 'does not duplicate data' do
      expect(provider.accrediting_providers.count).to eq(1)
    end
  end

  describe "#accredited_bodies" do
    let(:accrediting_provider_enrichments) { [] }
    let(:description) { "Ye olde establishmente" }
    let(:enrichments) do
      [build(:provider_enrichment, accrediting_provider_enrichments: accrediting_provider_enrichments)]
    end

    subject { provider.accredited_bodies }

    context "with no accrediting provider (via courses)" do
      it { should be_empty }

      context "with an old accredited body enrichment" do
        let(:accrediting_provider_enrichments) do
          [{
             "Description" => description,
             # XX4 might have previously been an accrediting provider for this provider, and the data is still in the database
             "UcasProviderCode" => "XX4",
           }]
        end

        it { should be_empty }
      end
    end

    context "with an accrediting provider (via courses)" do
      let(:accrediting_provider) { build :provider }
      let(:courses) { [build(:course, accrediting_provider: accrediting_provider)] }

      its(:length) { should be(1) }

      describe "the returned accredited body" do
        subject { provider.accredited_bodies.first }

        its([:description]) { should eq("") }
        its([:provider_code]) { should eq(accrediting_provider.provider_code) }
        its([:provider_name]) { should eq(accrediting_provider.provider_name) }
      end

      context "with an accredited body enrichment" do
        let(:accrediting_provider_enrichments) do
          [{
             "Description" => description,
             "UcasProviderCode" => accrediting_provider.provider_code,
           }]
        end

        its(:length) { should be(1) }

        describe "the returned accredited body" do
          subject { provider.accredited_bodies.first }

          its([:description]) { should eq(description) }
          its([:provider_code]) { should eq(accrediting_provider.provider_code) }
          its([:provider_name]) { should eq(accrediting_provider.provider_name) }
        end
      end

      context "with a corrupt accredited body enrichment" do
        let(:accrediting_provider_enrichments) do
          [{
             "Description" => description,
             # UcasProviderCode missing. We found data like this in our database so need to handle it.
           }]
        end

        its(:length) { should be(1) }

        describe "the returned accredited body" do
          subject { provider.accredited_bodies.first }

          its([:description]) { should eq("") }
          its([:provider_code]) { should eq(accrediting_provider.provider_code) }
          its([:provider_name]) { should eq(accrediting_provider.provider_name) }
        end
      end
    end
  end

  describe '#enrichments' do
    describe '#find_or_initialize_draft' do
      let(:provider) { create(:provider, enrichments: enrichments) }

      copyable_enrichment_attributes =
        %w[
          email
          website
          address1
          address2
          address3
          address4
          postcode
          region_code
          telephone
          train_with_us
          train_with_disability
        ].freeze

      let(:actual_enrichment_attributes) do
        subject.attributes.slice(*copyable_enrichment_attributes)
      end

      subject { provider.enrichments.find_or_initialize_draft(create(:user)) }

      context 'no enrichments' do
        let(:enrichments) { [] }

        it "sets all attributes to be nil" do
          expect(actual_enrichment_attributes.values).to be_all(&:nil?)
        end

        its(:id) { should be_nil }
        its(:last_published_at) { should be_nil }
        its(:status) { should eq 'draft' }
      end

      context 'with a draft enrichment' do
        let(:initial_draft_enrichment) { build(:provider_enrichment, :initial_draft) }
        let(:enrichments) { [initial_draft_enrichment] }
        let(:expected_enrichment_attributes) { initial_draft_enrichment.attributes.slice(*copyable_enrichment_attributes) }

        it "has all the same attributes as the initial draft enrichment" do
          expect(actual_enrichment_attributes).to eq expected_enrichment_attributes
        end

        its(:id) { should_not be_nil }
        its(:last_published_at) { should eq initial_draft_enrichment.last_published_at }
        its(:status) { should eq 'draft' }
      end

      context 'with a published enrichment' do
        let(:published_enrichment) { build(:provider_enrichment, :published) }
        let(:enrichments) { [published_enrichment] }
        let(:expected_enrichment_attributes) { published_enrichment.attributes.slice(*copyable_enrichment_attributes) }

        it "has all the same attributes as the published enrichment" do
          expect(actual_enrichment_attributes).to eq expected_enrichment_attributes
        end

        its(:id) { should be_nil }
        its(:last_published_at) { should be_within(1.second).of published_enrichment.last_published_at }
        its(:status) { should eq 'draft' }
      end

      context 'with a draft and published enrichment' do
        let(:published_enrichment) { build(:provider_enrichment, :published) }
        let(:subsequent_draft_enrichment) { build(:provider_enrichment, :subsequent_draft) }
        let(:enrichments) { [published_enrichment, subsequent_draft_enrichment] }
        let(:expected_enrichment_attributes) { subsequent_draft_enrichment.attributes.slice(*copyable_enrichment_attributes) }

        it "has all the same attributes as the subsequent draft enrichment" do
          expect(actual_enrichment_attributes).to eq expected_enrichment_attributes
        end

        its(:id) { should_not be_nil }
        its(:last_published_at) { should be_within(1.second).of subsequent_draft_enrichment.last_published_at }
        its(:status) { should eq 'draft' }
      end
    end
  end

  describe '#publish_enrichment' do
    let(:user) { create :user }
    let(:provider) { create :provider }
    let!(:provider_enrichment1) { create :provider_enrichment, provider: provider }
    let!(:provider_enrichment2) { create :provider_enrichment, provider: provider }

    it 'sets the status of all draft enrichments to published' do
      provider.publish_enrichment(user)
      expect(provider.reload.enrichments.draft.size).to eq(0)
    end
  end

  describe '#before_create' do
    describe '#set_defaults' do
      let(:provider) { build :provider }

      it 'sets scheme_member to "Y"' do
        expect(provider.scheme_member).to be_nil

        provider.save!

        expect(provider.is_a_UCAS_ITT_member?).to be_truthy
      end

      it 'sets the year_code from the recruitment_cycle' do
        expect(provider.year_code).to be_nil

        provider.save!

        expect(provider.year_code).to eq(provider.recruitment_cycle.year)
      end

      it 'does not override a given value for scheme_member' do
        provider.scheme_member = 'not_a_UCAS_ITT_member'

        provider.save!

        expect(provider.scheme_member).to eq('not_a_UCAS_ITT_member')
      end

      it 'does not override a given value for year_code' do
        provider.year_code = 2020

        provider.save!

        expect(provider.year_code).to eq("2020")
      end
    end
  end

  describe "#latest_enrichment" do
    let(:old_enrichment) { create(:provider_enrichment, created_at: 1.day.ago) }
    let(:new_enrichment) { create(:provider_enrichment, created_at: 1.second.ago) }
    let(:enrichments) { [new_enrichment, old_enrichment] }

    it 'returns correct enrichment' do
      expect(provider.latest_enrichment).to eq(new_enrichment)
    end
  end


  describe '#is_it_really_really_a_scitt?' do
    let(:provider) { build(:provider, scitt: scitt_value) }
    let(:scitt_value) { 'Y' }

    subject { create(:provider, scitt: scitt_value) }

    context 'when provider is a scitt' do
      its(:is_it_really_really_a_scitt?) { should be_truthy }
    end

    context 'when provider is not a scitt' do
      let(:scitt_value) { nil }
      its(:is_it_really_really_a_scitt?) { should be_falsey }
    end
  end

  describe '#generated_ucas_contact' do
    let(:provider) { create :provider, contacts: [contact1, contact2, contact3, contact4, contact5] }
    let(:contact1)  { build(:contact, :admin_type) }
    let(:contact2)  { build(:contact, :utt_type) }
    let(:contact3)  { build(:contact, :web_link_type) }
    let(:contact4)  { build(:contact, :fraud_type) }
    let(:contact5)  { build(:contact, :finance_type) }

    context 'for an admin contact' do
      subject { provider.generated_ucas_contact(contact1.type) }

      its([:name]) { should eq contact1.name }
      its([:email]) { should eq contact1.email }
      its([:telephone]) { should eq contact1.telephone }
    end

    context 'for a utt contact' do
      subject { provider.generated_ucas_contact(contact2.type) }

      its([:name]) { should eq contact2.name }
      its([:email]) { should eq contact2.email }
      its([:telephone]) { should eq contact2.telephone }
    end

    context 'for a web link contact' do
      subject { provider.generated_ucas_contact(contact3.type) }

      its([:name]) { should eq contact3.name }
      its([:email]) { should eq contact3.email }
      its([:telephone]) { should eq contact3.telephone }
    end

    context 'for a fraud contact' do
      subject { provider.generated_ucas_contact(contact4.type) }

      its([:name]) { should eq contact4.name }
      its([:email]) { should eq contact4.email }
      its([:telephone]) { should eq contact4.telephone }
    end

    context 'for a finance contact' do
      subject { provider.generated_ucas_contact(contact5.type) }

      its([:name]) { should eq contact5.name }
      its([:email]) { should eq contact5.email }
      its([:telephone]) { should eq contact5.telephone }
    end

    context 'when there is no contact' do
      let(:provider) { create(:provider) }

      subject { provider.generated_ucas_contact('admin') }

      it { should eq nil }
    end
  end
end

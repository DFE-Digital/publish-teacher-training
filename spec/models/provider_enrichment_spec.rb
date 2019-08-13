# == Schema Information
#
# Table name: provider_enrichment
#
#  id                 :integer          not null, primary key
#  provider_code      :text             not null
#  json_data          :jsonb
#  updated_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer
#  last_published_at  :datetime
#  status             :integer          default("draft"), not null
#  provider_id        :integer          not null
#

require 'rails_helper'

describe ProviderEnrichment, type: :model do
  describe 'associations' do
    it { should belong_to(:provider) }
  end

  describe 'auditing' do
    it { should be_audited }

    it 'can link to Provider' do
      provider = create(:provider)
      provider_enrichment = create(:provider_enrichment, provider: provider)

      expect(provider_enrichment.audits.last.associated).to eq(provider)
    end
  end

  describe '#has_been_published_before?' do
    context 'when the enrichment is an initial draft' do
      subject { create(:provider_enrichment, :initial_draft) }
      it { should_not have_been_published_before }
    end

    context 'when the enrichment is published' do
      subject { create(:provider_enrichment, :published) }
      it { should have_been_published_before }
    end

    context 'when the enrichment is a subsequent draft' do
      subject { create(:provider_enrichment, :subsequent_draft) }
      it { should have_been_published_before }
    end
  end

  describe '.latest_first' do
    let!(:old_enrichment) do
      create(:provider_enrichment, :published, created_at: Date.yesterday)
    end
    let!(:new_enrichment) { create(:provider_enrichment, :published) }

    it 'returns the new enrichment first' do
      expect(ProviderEnrichment.latest_created_at.first).to eq new_enrichment
      expect(ProviderEnrichment.latest_created_at.last).to eq old_enrichment
    end
  end

  describe '#publish' do
    let(:user) { create :user }
    let!(:provider_enrichment) { create(:provider_enrichment, :initial_draft) }

    it 'sets the status to published' do
      publish_time = Time.parse("2019-07-30")
      Timecop.freeze(publish_time) do
        provider_enrichment.publish(user)
        provider_enrichment.reload
        expect(provider_enrichment.status).to eq('published')
        expect(provider_enrichment.last_published_at).to eq(publish_time.utc)
        expect(provider_enrichment.updated_by_user_id).to eq(user.id)
      end
    end
  end

  describe 'before_create hook' do
    # Note: provider_code is only here to support c# counterpart, until provide_code is removed from database
    let(:provider) { build(:provider) }
    let(:existing_provider_code) { nil }
    let(:enrichment) { create(:provider_enrichment, provider: provider, provider_code: existing_provider_code) }
    subject { enrichment }

    context 'when provider_code is blank' do
      its(:provider_code) { should eq(provider.provider_code) }
    end

    context 'when provider code is already set' do
      let(:existing_provider_code) { "XX4" }

      its(:provider_code) { should eq(existing_provider_code) }
    end
  end

  describe 'validation' do
    describe 'on update' do
      let(:provider) { build(:provider) }
      let(:existing_provider_code) { nil }
      let(:enrichment) { create(:provider_enrichment, provider: provider, provider_code: existing_provider_code) }

      describe 'email' do
        it 'validates email is present' do
          enrichment.email = ''
          enrichment.valid?

          expect(enrichment.errors[:email]).to include("^Enter an email address in the correct format, like name@example.com")
        end

        it 'validates email contains an @ symbol' do
          enrichment.email = 'meow'
          enrichment.valid?

          expect(enrichment.errors[:email]).to include("^Enter an email address in the correct format, like name@example.com")
        end

        it 'Does not validate the email if it is not present'do
          enrichment.website = 'cats4lyf.cat'

          expect(enrichment.valid?).to be true
        end
      end

      describe 'telephone' do
        it 'validates telephone is present' do
          enrichment.telephone = ""
          enrichment.valid?

          expect(enrichment.errors[:telephone]).to include("^Enter a valid telephone number")
        end

        it 'Correctly validates valid phone numbers' do
          enrichment.telephone = "+447 123 123 123"
          expect(enrichment.valid?).to be true
        end

        it 'Correctly invalidates invalid phone numbers' do
          enrichment.telephone = "123cat456"
          expect(enrichment.valid?).to be false
          expect(enrichment.errors[:telephone]).to include("^Enter a valid telephone number")
        end

        it 'Does not validate the telephone if it is not present'do
          enrichment.website = 'cats4lyf.cat'

          expect(enrichment.valid?).to be true
        end
      end
    end

    describe 'on publish' do
      it { should validate_presence_of(:email).on(:publish).with_message("^Enter an email address in the correct format, like name@example.com") }
      it { should validate_presence_of(:website).on(:publish) }
      it { should validate_presence_of(:telephone).on(:publish).with_message("^Enter a valid telephone number") }

      it { should validate_presence_of(:address1).on(:publish) }
      it { should validate_presence_of(:address3).on(:publish) }
      it { should validate_presence_of(:address4).on(:publish) }

      it { should validate_presence_of(:postcode).on(:publish) }
      it { should validate_presence_of(:train_with_us).on(:publish) }
      it { should validate_presence_of(:train_with_disability).on(:publish) }
    end

    describe '#train_with_us' do
      let(:word_count) { 250 }
      let(:train_with_us) { Faker::Lorem.sentence(word_count: word_count) }

      subject { build :provider_enrichment, train_with_us: train_with_us }

      context 'word count within limit' do
        it { should be_valid }
      end

      context 'word count exceed limit' do
        let(:word_count) { 250 + 1 }
        it { should_not be_valid }
      end
    end

    describe '#train_with_disability' do
      let(:word_count) { 250 }
      let(:train_with_disability) { Faker::Lorem.sentence(word_count: word_count) }

      subject { build :provider_enrichment, train_with_disability: train_with_disability }

      context 'word count within limit' do
        it { should be_valid }
      end

      context 'word count exceed limit' do
        let(:word_count) { 250 + 1 }
        it { should_not be_valid }
      end
    end

    describe '#accrediting_provider_enrichments' do
      let(:word_count) { 100 }

      let(:accrediting_provider_enrichments) {
        result = []
        10.times do |index|
          result <<
            {
              "Description" => Faker::Lorem.sentence(word_count: word_count),
              "UcasProviderCode" => "UPC#{index}"
            }
        end
        result
      }

      let(:provider_enrichment) do
        build :provider_enrichment, accrediting_provider_enrichments: accrediting_provider_enrichments
      end

      subject { provider_enrichment }

      context 'word count within limit' do
        it { should be_valid }
      end

      context 'word count exceed limit' do
        let(:word_count) { 100 + 1 }
        it { should_not be_valid }
      end
    end
  end
end

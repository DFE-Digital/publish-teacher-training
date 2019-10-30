require "rails_helper"

describe Provider, type: :model do
  let(:accrediting_provider_enrichments) { [] }
  let(:courses) { [] }
  let(:provider) do
    create(:provider,
           provider_name: "ACME SCITT",
           provider_code: "A01",
           accrediting_provider_enrichments: accrediting_provider_enrichments,
           courses: courses)
  end

  describe "validation" do
    describe "on update" do
      let(:provider) { build(:provider) }

      describe "email" do
        it "validates email is present" do
          provider.email = ""
          provider.valid? :update

          expect(provider.errors[:email]).to include("^Enter an email address in the correct format, like name@example.com")
        end

        it "validates email contains an @ symbol" do
          provider.email = "meow"
          provider.valid? :update

          expect(provider.errors[:email]).to include("^Enter an email address in the correct format, like name@example.com")
        end

        it "Does not validate the email if it is not present"do
          provider.website = "cats4lyf.cat"

          expect(provider.valid?(:update)).to be true
        end
      end

      describe "telephone" do
        it "validates telephone is present" do
          provider.telephone = ""
          provider.valid? :update

          expect(provider.errors[:telephone]).to include("^Enter a valid telephone number")
        end

        it "Correctly validates valid phone numbers" do
          provider.telephone = "+447 123 123 123"
          expect(provider.valid?(:update)).to be true
        end

        it "Correctly invalidates invalid phone numbers" do
          provider.telephone = "123cat456"
          expect(provider.valid?(:update)).to be false
          expect(provider.errors[:telephone]).to include("^Enter a valid telephone number")
        end

        it "Does not validate the telephone if it is not present"do
          provider.website = "cats4lyf.cat"

          expect(provider.valid?(:update)).to be true
        end
      end
    end

    describe "on update" do
      it { should validate_presence_of(:train_with_us).on(:update) }
      it { should validate_presence_of(:train_with_disability).on(:update) }
    end

    describe "#train_with_us" do
      let(:word_count) { 250 }
      let(:train_with_us) { Faker::Lorem.sentence(word_count: word_count) }

      subject { build :provider, train_with_us: train_with_us }

      context "word count within limit" do
        it { should be_valid }
      end

      context "word count exceed limit" do
        let(:word_count) { 250 + 1 }
        it { should_not be_valid }
      end
    end

    describe "#train_with_disability" do
      let(:word_count) { 250 }
      let(:train_with_disability) { Faker::Lorem.sentence(word_count: word_count) }

      subject { build :provider, train_with_disability: train_with_disability }

      context "word count within limit" do
        it { should be_valid }
      end

      context "word count exceed limit" do
        let(:word_count) { 250 + 1 }
        it { should_not be_valid }
      end
    end

    context "no accrediting_providers" do
      describe "#accrediting_provider_providers" do
        let(:word_count) { 100 }

        let(:accrediting_provider_enrichments) {
          result = []
          10.times do |index|
            result <<
              {
                "Description" => Faker::Lorem.sentence(word_count: word_count),
                "UcasProviderCode" => "UPC#{index}",
              }
          end
          result
        }

        let(:provider) do
          create :provider
        end

        subject {
          provider.accrediting_provider_enrichments = accrediting_provider_enrichments
          provider
        }
        context "word count within limit" do
          it { should be_valid }
        end

        context "word count exceed limit" do
          let(:word_count) { 100 + 1 }
          # NOTE: its valid as it is orphaned data
          # ie a previous course
          # with an acrediting provider was removed
          # but the accrediting provider enrichment was left behind
          it { should be_valid }
        end
      end
    end

    context "with accrediting_providers" do
      describe "#accrediting_provider_providers" do
        let(:word_count) { 100 }

        let(:accrediting_providers) {
          result = []
          10.times do
            result << create(:provider)
          end
          result
        }

        let(:accrediting_provider_enrichments) {
          accrediting_providers.map do |ap|
            {
              "Description" => Faker::Lorem.sentence(word_count: word_count),
              "UcasProviderCode" => ap.provider_code.to_s,
            }
          end
        }

        let(:courses) do
          accrediting_providers.map do |ap|
            build :course, accrediting_provider: ap
          end
        end

        let(:provider) do
          create :provider, courses: courses
        end

        subject {
          provider.accrediting_provider_enrichments = accrediting_provider_enrichments
          provider
        }

        context "word count within limit" do
          it { should be_valid }
        end

        context "word count exceed limit" do
          let(:word_count) { 100 + 1 }

          it { should_not be_valid }
        end
      end
    end
  end
end

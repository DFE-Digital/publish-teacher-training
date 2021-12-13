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

  before do
    # NOTE: provider needs to be reloaded due to
    #       provider.accrediting_providers
    #       provider.accredited_bodies
    provider.reload
  end

  describe "#accredited_bodies" do
    let(:description) { "Ye olde establishmente" }

    subject {
      provider.accredited_bodies
    }

    context "with no accrediting provider (via courses)" do
      it { is_expected.to be_empty }

      context "with an old accredited body enrichment" do
        let(:accrediting_provider_enrichments) do
          [{
            "Description" => description,
            # XX4 might have previously been an accrediting provider for this provider, and the data is still in the database
            "UcasProviderCode" => "XX4",
          }]
        end

        it { is_expected.to be_empty }
      end
    end

    context "with an accrediting provider (via courses)" do
      let(:accrediting_provider) { build :provider, provider_code: "AP1" }
      let(:courses) { [build(:course, course_code: "P33P", accrediting_provider: accrediting_provider)] }

      its(:length) { is_expected.to be(1) }

      describe "the returned accredited body" do
        subject { provider.accredited_bodies.first }

        its([:description]) { is_expected.to eq("") }
        its([:provider_code]) { is_expected.to eq(accrediting_provider.provider_code) }
        its([:provider_name]) { is_expected.to eq(accrediting_provider.provider_name) }
      end

      context "with an accredited body enrichment" do
        let(:accrediting_provider_enrichments) do
          [{
            "Description" => description,
            "UcasProviderCode" => accrediting_provider.provider_code,
          }]
        end

        its(:length) { is_expected.to be(1) }

        describe "the returned accredited body" do
          subject { provider.accredited_bodies.first }

          its([:description]) { is_expected.to eq(description) }
          its([:provider_code]) { is_expected.to eq(accrediting_provider.provider_code) }
          its([:provider_name]) { is_expected.to eq(accrediting_provider.provider_name) }
        end
      end

      context "with a corrupt accredited body enrichment" do
        let(:accrediting_provider_enrichments) do
          [{
            "Description" => description,
            # UcasProviderCode missing. We found data like this in our database so need to handle it.
          }]
        end

        its(:length) { is_expected.to be(1) }

        describe "the returned accredited body" do
          subject { provider.accredited_bodies.first }

          its([:description]) { is_expected.to eq("") }
          its([:provider_code]) { is_expected.to eq(accrediting_provider.provider_code) }
          its([:provider_name]) { is_expected.to eq(accrediting_provider.provider_name) }
        end
      end
    end
  end
end

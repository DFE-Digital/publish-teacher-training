require "rails_helper"

module Find
  module ResultFilters
    describe QualificationView do
      describe "qts_only_checked?" do
        subject { described_class.new(params:).qts_only_checked? }

        context "when QtsOnly param not present" do
          let(:params) { { qualification: %w[other pgce_with_qts] } }

          it { is_expected.to be(false) }
        end

        context "when QtsOnly param is present" do
          let(:params) { { qualification: %w[qts pgce_with_qts] } }

          it { is_expected.to be(true) }
        end

        context "when qualifications is empty" do
          let(:params) { { qualification: [] } }

          it { is_expected.to be(false) }
        end

        context "when parameters are empty" do
          let(:params) { {} }

          it { is_expected.to be(false) }
        end
      end

      describe "pgde_pgce_with_qts_checked" do
        subject { described_class.new(params:).pgde_pgce_with_qts_checked? }

        context "when PgdePgceWithQts param not present" do
          let(:params) { { qualification: %w[other qts] } }

          it { is_expected.to be(false) }
        end

        context "when PgdePgceWithQts param is present" do
          let(:params) { { qualification: %w[qts pgce_with_qts] } }

          it { is_expected.to be(true) }
        end

        context "when qualifications is empty" do
          let(:params) { { qualification: [] } }

          it { is_expected.to be(false) }
        end

        context "when parameters are empty" do
          let(:params) { {} }

          it { is_expected.to be(false) }
        end
      end

      describe "#other_checked?" do
        subject { described_class.new(params:).other_checked? }

        context "when Other param not present" do
          let(:params) { { qualification: %w[qts pgce_with_qts] } }

          it { is_expected.to be(false) }
        end

        context "when Other param is present" do
          let(:params) { { qualification: %w[qts other] } }

          it { is_expected.to be(true) }
        end

        context "when qualifications is empty" do
          let(:params) { { qualification: [] } }

          it { is_expected.to be(false) }
        end

        context "when parameters are empty" do
          let(:params) { {} }

          it { is_expected.to be(false) }
        end
      end

      describe "qualification_selected?" do
        subject { described_class.new(params:).qualification_selected? }

        context "when a parameter is selected" do
          let(:params) { { qualification: %w[other] } }

          it { is_expected.to be(true) }
        end

        context "when multiple parameters are selected" do
          let(:params) { { qualification: %w[other qts] } }

          it { is_expected.to be(true) }
        end

        context "when no parameter is selected" do
          let(:params) { {} }

          it { is_expected.to be(false) }
        end
      end
    end
  end
end

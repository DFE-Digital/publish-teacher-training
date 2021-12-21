# frozen_string_literal: true

require "rails_helper"

describe Support::Filters::AllocationFilter do
  let(:permitted_params) { ActionController::Parameters.new(params).permit(:text_search) }

  subject { described_class.new(params: permitted_params) }

  describe "#filters" do
    context "with fully valid parameters" do
      let(:params) do
        {
          text_search: "search terms",
        }
      end

      it "returns the correct filter hash" do
        expect(subject.filters).to eq(permitted_params.to_h)
      end
    end

    context "with empty params" do
      let(:params) { {} }

      it "returns nil" do
        expect(subject.filters).to be_nil
      end
    end

    context "with valid user params" do
      subject { described_class.new(params: permitted_params) }

      context "with fully valid user parameters" do
        let(:params) do
          {
            text_search: "1XY",
          }
        end

        it "returns the correct filter hash" do
          expect(subject.filters).to eq(permitted_params.to_h)
        end
      end

      context "with fully valid course parameters" do
        let(:params) do
          {
            text_search: "",
          }
        end

        it "returns the correct filter hash" do
          expect(subject.filters).to eq(permitted_params.to_h)
        end
      end

      context "with empty params" do
        let(:params) { {} }

        it "returns nil" do
          expect(subject.filters).to be_nil
        end
      end
    end
  end
end

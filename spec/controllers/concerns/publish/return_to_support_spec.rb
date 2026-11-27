# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::ReturnToSupport do
  subject(:controller) { test_class.new }

  let(:test_class) do
    Class.new do
      def self.helper_method(*); end

      include Publish::ReturnToSupport

      attr_accessor :params, :current_user

      def support_return_path(state)
        [:support_path, state]
      end

      def publish_return_path
        :publish_path
      end
    end
  end

  let(:admin) { instance_double(User, admin?: true) }
  let(:non_admin) { instance_double(User, admin?: false) }

  def parameters(hash)
    ActionController::Parameters.new(hash)
  end

  describe "#support_return_params and #return_path" do
    context "when an admin requests return_to=support" do
      before do
        controller.current_user = admin
        controller.params = parameters(
          return_to: "support",
          support_return: { page: "3", sort: "last_signed_in" },
        )
      end

      it "returns support_return_params and passes state to support_return_path" do
        state = { page: "3", sort: "last_signed_in" }

        expect(controller.send(:support_return_params)).to eq(
          return_to: "support",
          support_return: state,
        )
        expect(controller.send(:return_path)).to eq(
          controller.send(:support_return_path, state),
        )
      end
    end

    context "when nobody is signed in" do
      before do
        controller.current_user = nil
        controller.params = parameters(return_to: "support")
      end

      it "returns no support_return_params and uses the Publish path" do
        expect(controller.send(:support_return_params)).to eq({})
        expect(controller.send(:return_path)).to eq(:publish_path)
      end
    end

    context "when the user is not an admin" do
      before do
        controller.current_user = non_admin
        controller.params = parameters(
          return_to: "support",
          support_return: { page: "3" },
        )
      end

      it "returns no support_return_params and uses the Publish path" do
        expect(controller.send(:support_return_params)).to eq({})
        expect(controller.send(:return_path)).to eq(:publish_path)
      end
    end

    context "when return_to is absent" do
      before do
        controller.current_user = admin
        controller.params = parameters(support_return: { page: "3" })
      end

      it "returns no support_return_params and uses the Publish path" do
        expect(controller.send(:support_return_params)).to eq({})
        expect(controller.send(:return_path)).to eq(:publish_path)
      end
    end
  end

  describe "#support_flow_params" do
    before do
      controller.current_user = admin
    end

    it "passes through an unknown flat key" do
      controller.params = parameters(
        return_to: "support",
        support_return: { page: "2", unexpected: "keep-me" },
      )

      expect(controller.send(:support_flow_params)).to eq(
        page: "2",
        unexpected: "keep-me",
      )
      expect(controller.send(:support_return_params)[:support_return]).to include(
        unexpected: "keep-me",
      )
    end

    it "drops nested hashes, arrays and blank values" do
      controller.params = parameters(
        return_to: "support",
        support_return: {
          page: "2",
          nested: { a: "1" },
          tags: %w[x y],
          blank: "",
          spaced: "  ",
        },
      )

      expect(controller.send(:support_flow_params)).to eq(page: "2")
    end

    it "gives empty state when support_return is not a hash" do
      controller.params = parameters(
        return_to: "support",
        support_return: "not-a-hash",
      )

      expect(controller.send(:support_flow_params)).to eq({})
      expect(controller.send(:support_return_params)).to eq(return_to: "support")
    end
  end
end

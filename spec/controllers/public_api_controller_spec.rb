# frozen_string_literal: true

require "rails_helper"
RSpec.describe PublicAPIController, type: :controller do
  describe "default behaviors" do
    it "includes DfE::Analytics::Requests" do
      expect(PublicAPIController.ancestors).to include(DfE::Analytics::Requests)
    end

    it "includes Pagy::Backend" do
      expect(PublicAPIController.ancestors).to include(Pagy::Backend)
    end

    it "includes Pundit::Authorization" do
      expect(PublicAPIController.ancestors).to include(Pundit::Authorization)
    end
  end

  describe "#current_namespace" do
    it "returns 'find_api'" do
      expect(controller.current_namespace).to eq("find_api")
    end
  end
end

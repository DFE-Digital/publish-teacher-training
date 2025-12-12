# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Public::V1::ApplicationController, type: :controller do
  describe "default behaviors" do
    it "includes DfE::Analytics::Requests" do
      expect(described_class.ancestors).to include(DfE::Analytics::Requests)
    end

    it "includes Pagy::Backend" do
      expect(described_class.ancestors).to include(Pagy::Backend)
    end

    it "includes Pundit::Authorization" do
      expect(described_class.ancestors).to include(Pundit::Authorization)
    end
  end

  describe "#current_namespace" do
    it "returns 'find_api'" do
      expect(controller.current_namespace).to eq("publish_api")
    end
  end

  describe "Test child controllers" do
    controllers_glob = Rails.root.join("app/controllers/api/public/v1/**/*_controller.rb")
    controllers_root = Rails.root.join("app/controllers").to_s

    Dir[controllers_glob].sort.each do |controller_path|
      next if controller_path.end_with?("application_controller.rb")

      # Get the relative path of the controller
      relative_path = controller_path.sub("#{controllers_root}/", "").sub(".rb", "")
      # Convert the relative path to a controller name
      controller_name = relative_path.split("/").map { |segment| segment == "api" ? "API" : segment.camelize }.join("::")
      # Get the controller class
      controller_class = controller_name.constantize

      it "current_namespace for child controller #{controller_name}" do
        expect(controller_class.new.current_namespace).to eq("publish_api")
      end
    end
  end
end

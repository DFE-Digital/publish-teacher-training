require "rails_helper"

describe FeatureService do
  describe ".require" do
    context "feature is enabled" do
      before do
        Settings.features ||= Config::Options.new
        Settings.features.rspec_testing = true
      end

      it "returns true" do
        response = FeatureService.require(:rspec_testing)

        expect(response).to be_truthy
      end
    end

    context "feature is disabled" do
      before do
        Settings.features ||= Config::Options.new
        Settings.features.rspec_testing = false
      end

      it "raises an error" do
        expect { FeatureService.require(:rspec_testing) }
          .to raise_error(RuntimeError, "Feature rspec_testing is disabled")
      end
    end

    context "nested feature is enabled" do
      before do
        Settings.features ||= Config::Options.new
        Settings.features.rspec_testing = Config::Options.new nested: true
      end

      it "returns true" do
        response = FeatureService.require("rspec_testing.nested")

        expect(response).to be_truthy
      end
    end

    context "nested feature is disabled" do
      before do
        Settings.features ||= Config::Options.new
        Settings.features.rspec_testing = Config::Options.new nested: false
      end

      it "raises an error" do
        expect { FeatureService.require("rspec_testing.nested") }
          .to raise_error(RuntimeError, "Feature rspec_testing.nested is disabled")
      end
    end
  end

  describe ".enabled?" do
    context "feature is enabled" do
      before do
        Settings.features ||= Config::Options.new
        Settings.features.rspec_testing = true
      end

      it "returns true" do
        response = FeatureService.enabled?(:rspec_testing)

        expect(response).to be_truthy
      end
    end

    context "feature is disabled" do
      before do
        Settings.features ||= Config::Options.new
        Settings.features.rspec_testing = false
      end

      it "returns false" do
        response = FeatureService.enabled?(:rspec_testing)

        expect(response).to be_falsey
      end
    end

    context "nested feature is enabled" do
      before do
        Settings.features ||= Config::Options.new
        Settings.features.rspec_testing = Config::Options.new nested: true
      end

      it "looks up the feature using dot-separated segments" do
        response = FeatureService.enabled?("rspec_testing.nested")

        expect(response).to be_truthy
      end
    end

    context "nested feature is disabled" do
      before do
        Settings.features ||= Config::Options.new
        Settings.features.rspec_testing = Config::Options.new nested: false
      end

      it "looks up the feature using dot-separated segments" do
        response = FeatureService.enabled?("rspec_testing.nested")

        expect(response).to be_falsey
      end
    end

    context "feature settings are empty" do
      around do |example|
        old_features = Settings.features
        Settings.features = nil
        example.run
        # rspec takes care of ensuring that the following runs, even if an
        # exception is raised in the spec.
        Settings.features = old_features
      end

      it "returns false" do
        response = FeatureService.enabled?(:rspec_testing)

        expect(response).to be_falsey
      end
    end
  end
end

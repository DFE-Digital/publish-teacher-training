# frozen_string_literal: true

require "rails_helper"

describe "Find::Courses::AccreditingProvidersController" do
  describe "GET /courses/:provider_code/:course_code/accredited-by" do
    context "when the provider does not exist" do
      it "returns not found" do
        get "/courses/INVALID/ABC1/accredited-by"

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the course does not exist" do
      it "returns not found" do
        provider = create(:provider)

        get "/courses/#{provider.provider_code}/INVALID/accredited-by"

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the course has no accrediting provider" do
      it "returns not found" do
        course = create(:course, :published_postgraduate, :self_accredited)

        get "/courses/#{course.provider.provider_code}/#{course.course_code}/accredited-by"

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the course has an accrediting provider" do
      it "returns success" do
        accrediting_provider = create(:provider, :accredited_provider)
        provider = create(:provider)
        create(:provider_partnership, training_provider: provider, accredited_provider: accrediting_provider)
        course = create(:course, :published_postgraduate, provider:, accrediting_provider:)

        get "/courses/#{provider.provider_code}/#{course.course_code}/accredited-by"

        expect(response).to have_http_status(:ok)
      end
    end
  end
end

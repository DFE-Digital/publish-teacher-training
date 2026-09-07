# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Find feedback form", service: :find, type: :request do
  let(:valid_feedback) { { ease_of_use: "very_easy", experience: "Great experience!" } }

  describe "POST /feedback" do
    it "saves feedback when the honeypot is empty" do
      get new_find_feedback_path

      expect {
        post find_feedback_path, params: { feedback: valid_feedback.merge(subject: "") }
      }.to change(Feedback, :count).by(1)

      expect(response).to redirect_to(find_root_path)
    end

    it "discards feedback when the honeypot is filled" do
      get new_find_feedback_path

      expect {
        post find_feedback_path, params: { feedback: valid_feedback.merge(subject: "http://spam.example") }
      }.not_to change(Feedback, :count)

      expect(response).to redirect_to(find_root_path)
      expect(flash[:success]).to eq(I18n.t("find.feedbacks.create.success"))
    end

    it "saves feedback corrected straight after a validation error" do
      get new_find_feedback_path
      post find_feedback_path, params: { feedback: valid_feedback.merge(ease_of_use: "") }

      expect {
        post find_feedback_path, params: { feedback: valid_feedback }
      }.to change(Feedback, :count).by(1)
    end

    it "saves a second submission made without reloading the form" do
      get new_find_feedback_path
      post find_feedback_path, params: { feedback: valid_feedback }

      expect {
        post find_feedback_path, params: { feedback: valid_feedback.merge(experience: "More thoughts") }
      }.to change(Feedback, :count).by(1)
    end
  end
end

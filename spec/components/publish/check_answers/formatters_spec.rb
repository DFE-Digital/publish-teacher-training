# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::CheckAnswers::Formatters do
  describe Publish::CheckAnswers::Formatters::Enum do
    it "looks up enum labels from the configured scope" do
      formatter = described_class.new(scope: "course_wizard.steps.qualifications.options")

      expect(formatter.call("pgce_with_qts", nil, nil)).to eq("QTS with PGCE")
    end

    it "supports translation key overrides for special cases" do
      formatter = described_class.new(
        scope: "course_wizard.steps.funding_type.options",
        translation_key_overrides: {
          "apprenticeship" => "course_wizard.steps.check_answers.answers.salary_apprenticeship",
        },
      )

      expect(formatter.call("apprenticeship", nil, nil)).to eq("Salary (apprenticeship)")
    end
  end

  describe Publish::CheckAnswers::Formatters::Bool do
    it "casts and translates boolean values" do
      formatter = described_class.new(
        yes_key: "course_wizard.steps.check_answers.answers.yes",
        no_key: "course_wizard.steps.check_answers.answers.no",
      )

      expect(formatter.call("true", nil, nil)).to eq("Yes")
      expect(formatter.call(false, nil, nil)).to eq("No")
    end
  end

  describe Publish::CheckAnswers::Formatters::List do
    let(:view) do
      Class.new {
        include ActionView::Helpers::OutputSafetyHelper
        include ActionView::Helpers::TagHelper
      }.new
    end

    it "joins values with line breaks and escapes content" do
      formatter = described_class.new(separator: :br)

      output = formatter.call(["First", "<script>alert(1)</script>"], nil, view).to_s

      expect(output).to include("First<br")
      expect(output).to include("&lt;script&gt;alert(1)&lt;/script&gt;")
    end
  end
end

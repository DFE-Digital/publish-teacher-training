# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::CourseSchoolsHelper, type: :helper do
  let(:salaried_course) { double("Course", salaried?: true) }
  let(:unsalaried_course) { double("Course", salaried?: false) }

  describe "#school_label_for" do
    it "returns the correct label for salaried courses" do
      expect(helper.school_label_for(salaried_course)).to eq("Employing schools")
    end

    it "returns the correct label for unsalaried courses" do
      expect(helper.school_label_for(unsalaried_course)).to eq("Placement schools")
    end
  end

  describe "#school_warning_text" do
    it "returns the warning text for salaried courses" do
      expect(helper.school_warning_text(salaried_course)).to eq("If you do not add all relevant employing schools, you may miss out on potential candidates.")
    end

    it "returns the warning text for unsalaried courses" do
      expect(helper.school_warning_text(unsalaried_course)).to eq("If you do not add all relevant placement schools, you may miss out on potential candidates.")
    end
  end

  describe "#school_label_with_plural" do
    it "returns the correct label with pluralisation for salaried courses" do
      expect(helper.school_label_with_plural(salaried_course, count: 1)).to eq("Employing school")
      expect(helper.school_label_with_plural(salaried_course, count: 3)).to eq("Employing schools")
    end

    it "returns the correct label with pluralisation for unsalaried courses" do
      expect(helper.school_label_with_plural(unsalaried_course, count: 1)).to eq("Placement school")
      expect(helper.school_label_with_plural(unsalaried_course, count: 3)).to eq("Placement schools")
    end
  end
end

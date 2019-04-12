require "rails_helper"

describe SubjectMapper do
  further_education_subjects =
    ["further education",
     "higher education",
     "post-compulsory"]

  ucas_mfl_main = [
      "english as a second or other language",
      "french",
      "german",
      "italian",
      "japanese",
      "russian",
      "spanish"
  ]
  describe "#IsFurtherEducation" do
    all_further_education_subjects = further_education_subjects + further_education_subjects.map(&:upcase)

    all_further_education_subjects.each do |subject|
      describe "##{subject}" do
        subject { SubjectMapper.IsFurtherEducation([subject]) }

        it { should be true }
      end
    end

    ucas_mfl_main.each do |subject|
      describe "##{subject}" do
        subject { SubjectMapper.IsFurtherEducation([subject]) }

        it { should be false }
      end
    end
  end
end

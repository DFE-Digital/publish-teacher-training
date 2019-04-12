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

  describe "#is_further_education" do
    all_further_education_subjects = further_education_subjects + further_education_subjects.map(&:upcase) + further_education_subjects.map { |subject_name| " #{subject_name} " }

    all_further_education_subjects.each do |subject_name|
      describe "'#{subject_name}''" do
        subject { SubjectMapper.is_further_education([subject_name]) }

        it { should be true }
      end
    end

    ucas_mfl_main.each do |subject_name|
      describe "'#{subject_name}''" do
        subject { SubjectMapper.is_further_education([subject_name]) }

        it { should be false }
      end
    end
  end

  describe "#map_to_subject_name" do
    ucas_rename =
      { "chinese" => "Mandarin",
      "art / art & design" => "Art and design",
      "business education" => "Business studies",
      "computer studies" => "Computing",
      "science" => "Balanced science",
      "dance and performance" => "Dance",
      "drama and theatre studies" => "Drama",
      "social science" => "Social sciences" }

    ucas_rename.each do |key, expected_value|
      describe "ucasRename '#{key}''" do
        subject { SubjectMapper.map_to_subject_name(key) }

        it { should eq expected_value }
      end
    end

    describe "bad english" do
      subject { SubjectMapper.map_to_subject_name("bad english") }

      it { should eq "Bad English" }
    end
  end
end

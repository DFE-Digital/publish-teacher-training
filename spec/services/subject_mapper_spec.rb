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

  # Port of https://github.com/DFE-Digital/manage-courses-api/blob/master/tests/ManageCourses.Tests/UnitTesting/SubjectMapperTests.cs
  describe "#get_subject_list" do

  specs = [
    {
      course_title: "",
      ucas_subjects: %w[primary english],
      expected_subjects: ["Primary", "Primary with English"],
      test_case: "an example of a primary specialisation"
    },
    {
      course_title: "",
      ucas_subjects: %w[primary physics],
      expected_subjects: ["Primary", "Primary with science"],
      test_case: "another example of a primary specialisation"
    },
    {
      course_title: "Early Years",
      ucas_subjects: ["primary", "early years"],
      expected_subjects: %w[Primary],

test_case: "an example of early years (which is absorbed into primary)"    },
    {
      course_title: "Physics (Welsh medium)",
      ucas_subjects: ["physics (abridged)", "welsh", "secondary", "science"],
      expected_subjects: %w[Physics],
test_case: "an example where science should be excluded because it's used as a category"    },


    {
      course_title: "Physics",
      ucas_subjects: %w[physics secondary science english],
      expected_subjects: %w[Physics],
      test_case: "examples of how the title is considered when adding additional subjects"
    },
    {
      course_title: "Physics with English",
      ucas_subjects: %w[physics secondary science english],
      expected_subjects: %w[Physics English],
      test_case: "examples of how the title is considered when adding additional subjects"
    },
    {
      course_title: "Physics with Science",
      ucas_subjects: %w[physics secondary science english],
      expected_subjects: ["Physics", "Balanced science"],
      test_case: "examples of how the title is considered when adding additional subjects"
    },
    {
      course_title: "Physics with Science and English",
      ucas_subjects: %w[physics secondary science english],
      expected_subjects: ["Physics", "Balanced science", "English"],
      test_case: "examples of how the title is considered when adding additional subjects"
    },
    {
      course_title: "Further ed",
      ucas_subjects: ["further education", "numeracy"],
      expected_subjects: ["Further education"],
      test_case: "further education examplpe"
    },
    {
      course_title: "MFL (Chinese)",
      ucas_subjects: ["secondary", "languages", "languages (asian)", "chinese"],
      expected_subjects: %w[Mandarin],
test_case: "a rename"
    },
    {
      course_title: "",
      ucas_subjects: %w[secondary welsh],
      expected_subjects: %w[Welsh],
test_case: "an example of welsh, which only triggers if nothing else goes"    },

    {
      course_title: "Computer science",
      ucas_subjects: ["computer studies", "science"],
      expected_subjects: %w[Computing],
test_case: "here science is used as a category"    },
    {
      course_title: "Computer science with Science",
      ucas_subjects: ["computer studies", "science"],
      expected_subjects: ["Computing", "Balanced science"],
      test_case: "here it is explicit"
    },

    {
      course_title: "Primary with Mathematics",
      ucas_subjects: %w[primary mathematics],
      expected_subjects: ["Primary", "Primary with mathematics"],
      test_case: "bug fix test:  accidentally included maths in the list of sciences"
    },

    {
      course_title: "Mfl",
      ucas_subjects: %w[languages],
      expected_subjects: ["Modern languages (other)"],
      test_case: "mfl"
    },
    {
      course_title: "Latin",
      ucas_subjects: %w[latin],
      expected_subjects: %w[Classics],
test_case: "latin and classics have been merged"    },
    {
      course_title: "Primary (geo)",
      ucas_subjects: %w[primary geography],
      expected_subjects: ["Primary", "Primary with geography and history"],
      test_case: "Primary with hist/geo have beeen merged"
    },
    {
      course_title: "Primary (history)",
      ucas_subjects: %w[primary history],
      expected_subjects: ["Primary", "Primary with geography and history"],
      test_case: "Primary with hist/geo have beeen merged"
    },

    {
      course_title: "Computing",
      ucas_subjects: ["secondary", "computer studies", "information communication technology"],
      expected_subjects: %w[Computing],
test_case: "no ICT"    },

    {
      course_title: "Mandarin and ESOL",
      ucas_subjects: ["mandarin", "english as a second or other language"],
      expected_subjects: ["Mandarin", "English as a second or other language"],
      test_case: "secondary ESOL"
    },
    {
      course_title: "PCET ESOL",
      ucas_subjects: ["further education", "english as a second or other language"],
      expected_subjects: ["Further education"],
      test_case: "secondary ESOL"
    },
  ]
        # public void MapToSearchAndCompareCourse(string courseTitle","string commaSeparatedUcasSubjects","string commaSeparatedExpectedSubjects)



        specs.each do |spec|
            describe "Test case '#{spec[:test_case]}''" do
              subject { SubjectMapper.get_subject_list(spec[:course_title], spec[:ucas_subjects]) }

              it { should match_array spec[:expected_subjects] }
            end
          end
        end
end

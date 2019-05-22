# This is a port of https://github.com/DFE-Digital/manage-courses-api/blob/master/src/ManageCourses.Api/Mapping/SubjectMapper.cs

class SubjectMapperService
  UCAS_TO_DFE_SUBJECT_MAPPINGS = {
    primary: {
      %w[primary] => "Primary",
      ["english", "english language", "english literature"] => "Primary with English",
      %w[geography history] => "Primary with geography and history",
      ["mathematics", "mathematics (abridged)"] => "Primary with mathematics",
      ["languages",
       "languages (african)",
       "languages (asian)",
       "languages (european)",
       "english as a second or other language",
       "french",
       "german",
       "italian",
       "japanese",
       "russian",
       "spanish",
       "arabic",
       "bengali",
       "gaelic",
       "greek",
       "hebrew",
       "urdu",
       "mandarin",
       "punjabi"] => "Primary with modern languages",
      ["science", "physics", "physics (abridged)", "biology", "chemistry"] => "Primary with science",
      ["physical education"] => "Primary with physical education",
    },
    secondary: {
      ["mathematics", "mathematics (abridged)"] => "Mathematics",
      ["physics", "physics (abridged)"] => "Physics",
      ["design and technology",
       "design and technology (food)",
       "design and technology (product design)",
       "design and technology (systems and control)",
       "design and technology (textiles)",
       "engineering"] => "Design and technology",
       %w[classics latin] => "Classics",
       %w[chinese mandarin] => "Mandarin",
       ["english as a second or other language"] => "English as a second or other language",
       %w[french] => "French",
       %w[german] => "German",
       %w[italian] => "Italian",
       %w[japanese] => "Japanese",
       %w[russian] => "Russian",
       %w[spanish] => "Spanish",
       %w[biology] => "Biology",
       %w[chemistry] => "Chemistry",
       ["art / art & design"] => "Art and design",
       ["business education"] => "Business studies",
       %w[citizenship] => "Citizenship",
       ["communication and media studies"] => "Communication and media studies",
       ["computer studies"] => "Computing",
       ["dance and performance"] => "Dance",
       ["drama and theatre studies"] => "Drama",
       %w[economics] => "Economics",
       %w[geography] => "Geography",
       ["health and social care"] => "Health and social care",
       %w[history] => "History",
       %w[music] => "Music",
       ["outdoor activities"] => "Outdoor activities",
       ["physical education"] => "Physical education",
       %w[psychology] => "Psychology",
       ["religious education"] => "Religious education",
       ["social science"] => "Social sciences",
       { ucas_subjects_match: ->(ucas_subjects) {
                                Subjects::ModernForeignLanguages.language_course?(ucas_subjects) &&
                                  !Subjects::ModernForeignLanguages.mandarin?(ucas_subjects) &&
                                  !Subjects::ModernForeignLanguages.main_mfl?(ucas_subjects)
                              } } => "Modern languages (other)",
       {
         ucas_subjects: ["english", "english language", "english literature"],
         course_title_matches: ->(course_title) { course_title.index("english") != nil },
       } => "English",
       {
         ucas_subjects: %w[humanities],
         course_title_matches: ->(course_title) { course_title =~ /humanities/ }
       } => "Humanities",
       {
         ucas_subjects: %w[science],
         course_title_matches: ->(course_title) { course_title =~ /(?<!social |computer )science/ }
       } => "Balanced science",
    },
    further_education: {
      ["further education",
       "higher education",
       "post-compulsory"] => "Further education",
    },
  }.freeze

  def self.get_subject_list(course_title, ucas_subjects)
    ucas_subjects = ucas_subjects.map(&:strip).map(&:downcase)
    level = Subjects::CourseLevel.new(ucas_subjects).level

    Subjects::UCASToDFESubjectMappingCollection.
      new(config: UCAS_TO_DFE_SUBJECT_MAPPINGS[level]).
      to_dfe_subjects(
        ucas_subjects: ucas_subjects,
        course_title: course_title.strip.downcase
      )
  end
end

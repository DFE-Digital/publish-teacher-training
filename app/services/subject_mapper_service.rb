# This is a port of https://github.com/DFE-Digital/manage-courses-api/blob/master/src/ManageCourses.Api/Mapping/SubjectMapper.cs

class SubjectMapperService
  SUBJECT_LEVEL = {
    ucas_further_education: ["further education",
                             "higher education",
                             "post-compulsory"],
    ucas_primary: ["early years",
                   "upper primary",
                   "primary",
                   "lower primary"],
    ucas_unexpected: ["construction and the built environment",
                      # "history of art",
                      "home economics",
                      "hospitality and catering",
                      "personal and social education",
                      # "philosophy",
                      "sport and leisure",
                      "environmental science",
                      "law"]
  }.freeze

  MAPPINGS = {
    primary: {
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
    },
  }.freeze

  def self.map_to_secondary_subjects(course_title, ucas_subjects)
    secondary_subject_mappings = MAPPINGS[:secondary].map do |ucas_input_subjects, dfe_subject|
      Subjects::UCASSubjectToDFESubjectStaticMapping.new(ucas_input_subjects, dfe_subject)
    end

    secondary_subject_mappings += [
      Subjects::ModernForeignLanguagesOtherMapping.new,
      Subjects::SecondaryEnglishMapping.new(course_title),
      Subjects::SecondaryHumanitiesMapping.new(course_title),
      Subjects::SecondaryBalancedScienceMapping.new(course_title),
    ]

    secondary_subject_mappings.map { |mapping|
      mapping.to_s if mapping.applicable_to?(ucas_subjects)
    }.compact
  end

  def self.map_to_primary_subjects(ucas_subjects)
    primary_subject_mappings = MAPPINGS[:primary].map do |ucas_input_subjects, dfe_subject|
      Subjects::UCASSubjectToDFESubjectStaticMapping.new(ucas_input_subjects, dfe_subject)
    end

    %w[Primary] + primary_subject_mappings.map { |mapping|
      mapping.to_s if mapping.applicable_to?(ucas_subjects)
    }.compact
  end

  def self.get_subject_level(ucas_subjects)
    ucas_subjects = ucas_subjects.map { |subject| (subject.strip! || subject).downcase }
    if (ucas_subjects & SUBJECT_LEVEL[:ucas_unexpected]).any?
      "found unsupported subject name(s): #{(ucas_subjects & SUBJECT_LEVEL[:ucas_unexpected]) * ', '}"
    elsif (ucas_subjects & SUBJECT_LEVEL[:ucas_primary]).any?
      :primary
    elsif (ucas_subjects & SUBJECT_LEVEL[:ucas_further_education]).any?
      :further_education
    else
      :secondary
    end
  end

  # <summary>
  # This maps a list of of UCAS subjects to our interpretation of subjects.
  # UCAS subjects are a pretty loose tagging system where individual tags don't always
  # represent the subjects you will be able to teach but also categories (such as "secundary", "foreign languages" etc)
  # there is also duplication ("chinese" vs "mandarin") and ambiguity
  # (does "science" = Balanced science, a category, or Primary with science?)
  #
  # This takes this list of tags and the course title and applies heuristics to determine
  # which subjects you will be allowed to teach when you graduate, making the subjects more suitable for searching.
  # </summary>
  #
  # <param name="course_title">The name of the course</param>
  # <param name="ucas_subjects">The subject tags from UCAS</param>
  # <returns>An enumerable of all the subjects the course should be findable by.</returns>
  def self.get_subject_list(course_title, ucas_subjects)
    ucas_subjects = ucas_subjects.map(&:strip).map(&:downcase)

    subject_level = get_subject_level(ucas_subjects)

    case subject_level
    when :primary
      map_to_primary_subjects(ucas_subjects)
    when :further_education
      ["Further education"]
    when :secondary
      map_to_secondary_subjects(course_title.strip.downcase, ucas_subjects)
    else
      raise subject_level
    end
  end
end

# This is a port of https://github.com/DFE-Digital/manage-courses-api/blob/master/src/ManageCourses.Api/Mapping/SubjectMapper.cs

class SubjectMapper
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

  class GroupedSubjectMapping
    def initialize(included_ucas_subjects, resulting_dfe_subject)
      @included_ucas_subjects = included_ucas_subjects
      @resulting_dfe_subject = resulting_dfe_subject
    end

    def applicable_to?(ucas_subjects_to_map)
      (ucas_subjects_to_map & @included_ucas_subjects).any?
    end

    def to_s
      @resulting_dfe_subject
    end
  end

  class MFLOtherMapping
    def applicable_to?(ucas_subjects)
      (ucas_subjects & language_categories).any? &&
        (ucas_subjects & mandarin).none? &&
        (ucas_subjects & mfl_main).none?
    end

    def to_s
      "Modern languages (other)"
    end

  private

    def language_categories
      ["languages", "languages (african)", "languages (asian)", "languages (european)"]
    end

    def mandarin
      %w[chinese mandarin]
    end

    def mfl_main
      ["english as a second or other language",
       "french",
       "german",
       "italian",
       "japanese",
       "russian",
       "spanish"]
    end
  end

  # TODO: remove this bonkers logic once course mapping is done by one app!
  # The user need for this is unclear
  class SecondaryEnglishMapping
    def initialize(course_title)
      @course_title = course_title
    end

    def applicable_to?(ucas_subjects)
      (ucas_subjects & ucas_english).any? &&
        @course_title.index("english") != nil
    end

    def to_s
      "English"
    end

  private

    def ucas_english
      ["english",
       "english language",
       "english literature"]
    end
  end

  class SecondaryWelshMapping
    def applicable_to?(ucas_subjects)
      ucas_subjects == %w[welsh]
    end

    def to_s
      "Welsh"
    end
  end

  def self.map_to_secondary_subjects(course_title, ucas_subjects)
    secondary_subject_mappings = MAPPINGS[:secondary].map do |ucas_input_subjects, dfe_subject|
      GroupedSubjectMapping.new(ucas_input_subjects, dfe_subject)
    end

    #  Does the subject list mention languages but hasn't already been covered?
    secondary_subject_mappings << MFLOtherMapping.new

    # Does the subject list mention english, and it's mentioned in the title (or it's the only subject we know for this course)?
    secondary_subject_mappings << SecondaryEnglishMapping.new(course_title)

    # if nothing else yet, try welsh
    secondary_subject_mappings << SecondaryWelshMapping.new

    secondary_subjects = []

    secondary_subjects += secondary_subject_mappings.map { |mapping|
      mapping.to_s if mapping.applicable_to?(ucas_subjects)
    }.compact

    # TODO: remove this bonkers logic once course mapping is done by one app!
    # There is absolutely no user need for it!
    #
    # Does the subject list mention a subject we are happy to translate if the course title contains a mention?
    ucas_needs_mention_in_title = {
      "humanities" => /humanities/,
      "science" => /(?<!social |computer )science/,
    }
    (ucas_subjects & %w[humanities science]).each do |ucas_subject|
      if course_title.match?(ucas_needs_mention_in_title[ucas_subject])
        renamed_subject = (ucas_subject == "science" ? "balanced science" : ucas_subject).capitalize
        secondary_subjects << renamed_subject
      end
    end

    secondary_subjects
  end

  def self.map_to_primary_subjects(ucas_subjects)
    primary_subject_mappings = MAPPINGS[:primary].map do |ucas_input_subjects, dfe_subject|
      GroupedSubjectMapping.new(ucas_input_subjects, dfe_subject)
    end

    %w[Primary] + primary_subject_mappings.map { |mapping|
      mapping.to_s if mapping.applicable_to?(ucas_subjects)
    }.compact
  end

  def self.get_subject_level(ucas_subjects)
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

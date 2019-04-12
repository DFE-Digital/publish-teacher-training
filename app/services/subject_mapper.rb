# This is a port of https://github.com/DFE-Digital/manage-courses-api/blob/master/src/ManageCourses.Api/Mapping/SubjectMapper.cs
class SubjectMapper
  @ucas_further_education = ["further education",
                             "higher education",
                             "post-compulsory"]

  @ucas_english = ["english",
                   "english language",
                   "english literature"]

  @ucas_mfl_mandarin = %w[ chinese
                           mandarin]

  @ucas_mfl_main = ["english as a second or other language",
                    "french",
                    "german",
                    "italian",
                    "japanese",
                    "russian",
                    "spanish"]

  @ucas_mfl_other = %w[ arabic
                        bengali
                        gaelic
                        greek
                        hebrew
                        urdu
                        mandarin
                        punjabi]

  @ucas_mfl_welsh = %w[welsh]

  @ucas_design_and_tech = ["design and technology",
                           "design and technology (food)",
                           "design and technology (product design)",
                           "design and technology (systems and control)",
                           "design and technology (textiles)",
                           "engineering"]

  @ucas_classics = %w[ classics
                       latin]

  @ucas_direct_translation_secondary = ["art / art & design",
                                        "business education",
                                        "citizenship",
                                        "communication and media studies",
                                        "computer studies",
                                        "dance and performance",
                                        "drama and theatre studies",
                                        "economics",
                                        "geography",
                                        "health and social care",
                                        "history",
                                        "music",
                                        "outdoor activities",
                                        "physical education",
                                        "psychology",
                                        "religious education",
                                        "social science"]

  @ucas_primary = ["early years",
                   "upper primary",
                   "primary",
                   "lower primary"]

  @ucas_language_cat = ["languages",
                        "languages (african)",
                        "languages (asian)",
                        "languages (european)"]

  @ucas_other = ["leisure and tourism",
                 "special educational needs"]

  @ucas_mathematics = ["mathematics",
                      "mathematics (abridged)"]

  @ucas_physics = ["physics",
                   "physics (abridged)"]

  @ucas_science_fields = %w[ biology
                             chemistry]

  @ucas_unexpected = ["construction and the built environment",
      # history of art",
                      "home economics",
                      "hospitality and catering",
                      "personal and social education",
      # "philosophy",
                      "sport and leisure",
                      "environmental science",
                      "law"]

  @ucas_rename =     { "chinese" => "mandarin",
    "art / art & design" => "art and design",
    "business education" => "business studies",
    "computer studies" => "computing",
    "science" => "balanced science",
    "dance and performance" => "dance",
    "drama and theatre studies" => "drama",
    "social science" => "social sciences" }
  @ucas_needs_mention_in_title = { "humanities" => /humanities/,
      "science" => /(?<!social |computer )science/,
      "modern studies" => /modern studies/ }

  def self.is_further_education(subjects)
    subjects = subjects.map { |subject| (subject.strip! || subject).downcase }
    (subjects & @ucas_further_education).any?
  end

  def self.map_to_subject_name(ucas_subject)
    res = (@ucas_rename[ucas_subject] || ucas_subject).capitalize

    (res.sub "english", "English" || res)
  end

  def self.map_to_secondary_subjects(course_title, ucas_subjects)
    secondary_subjects = []

      # Does the subject list mention maths?
    if (ucas_subjects & @ucas_mathematics).any?
      secondary_subjects.push("Mathematics")
    end

      # Does the subject list mention physics?
    if (ucas_subjects & @ucas_physics).any?
      secondary_subjects.push("Physics")
    end

      # Does the subject list mention D&T?
    if (ucas_subjects & @ucas_design_and_tech).any?
      secondary_subjects.push("Design and technology")
    end

      # Does the subject list mention Classics?
    if (ucas_subjects & @ucas_classics).any?
      secondary_subjects.push("Classics")
    end


      # Does the subject list mention Mandarin Chinese
    if (ucas_subjects & @ucas_mfl_mandarin).any?
      secondary_subjects.push("Mandarin")
    end

      #  Does the subject list mention a mainstream foreign language
    (ucas_subjects & @ucas_mfl_main).each do |ucas_subject|
      secondary_subjects.push(map_to_subject_name(ucas_subject))
    end

      #  Does the subject list mention languages but hasn't already been covered?
    pp ucas_subjects
    pp @ucas_language_cat
    pp @ucas_mfl_mandarin
    pp @ucas_mfl_main

    if (ucas_subjects & @ucas_language_cat).any? && (ucas_subjects & @ucas_mfl_mandarin).none? && (ucas_subjects & @ucas_mfl_main).none?
      secondary_subjects.push("Modern languages (other)")
    end

      # Does the subject list mention one or more sciences?
    (ucas_subjects & @ucas_science_fields).each do |ucas_subject|
      secondary_subjects.push(map_to_subject_name(ucas_subject))
    end
      # Does the subject list mention a subject we are happy to translate directly?
    (ucas_subjects & @ucas_direct_translation_secondary).each do |ucas_subject|
      secondary_subjects.push(map_to_subject_name(ucas_subject))
    end
      # Does the subject list mention a subject we are happy to translate if the course title contains a mention?
    (ucas_subjects & @ucas_needs_mention_in_title.keys).each do |ucas_subject|
      if course_title.match?(@ucas_needs_mention_in_title[ucas_subject])
        secondary_subjects.push(map_to_subject_name(ucas_subject))
      end
    end

      # Does the subject list mention english, and it's mentioned in the title (or it's the only subject we know for this course)?
    if (ucas_subjects & @ucas_english).any?
      if secondary_subjects.none? || course_title.index("english") != nil
        secondary_subjects.push("English")
      end
    end

      # if nothing else yet, try welsh
    if secondary_subjects.none? && (ucas_subjects & @ucas_mfl_welsh).any?
      secondary_subjects.push("Welsh")
    end

    secondary_subjects
  end


        # /// <summary>
        # /// This maps a list of of UCAS subjects to our interpretation of subjects.
        # /// UCAS subjects are a pretty loose tagging system where individual tags don't always
        # /// represent the subjects you will be able to teach but also categories (such as "secundary", "foreign languages" etc)
        # /// there is also duplication ("chinese" vs "mandarin") and ambiguity
        # /// (does "science" = Balanced science, a category, or Primary with science?)
        # ///
        # /// This takes this list of tags and the course title and applies heuristics to determine
        # /// which subjects you will be allowed to teach when you graduate, making the subjects more suitable for searching.
        # /// </summary>
        # /// <param name="course_title">The name of the course</param>
        # /// <param name="ucas_subjects">The subject tags from UCAS</param>
        # /// <returns>An enumerable of all the subjects the course should be findable by.</returns>


  def self.map_to_primary_subjects(ucas_subjects)
    primary_subjects = %w[Primary]
    ucas_primary_language_specialisation = @ucas_language_cat + @ucas_mfl_main + @ucas_mfl_other

    ucas_primary_science_specialisation = %w[science] + @ucas_physics + @ucas_science_fields

    ucas_primary_geo_hist_specialisation = %w[geography history]
      # Does the subject list mention English?
    if((ucas_subjects & @ucas_english).any?)
      primary_subjects.push("Primary with English")
    end
      # Does the subject list mention geography or history?
    if((ucas_subjects & ucas_primary_geo_hist_specialisation).any?)
      primary_subjects.push("Primary with geography and history")
    end
      # Does the subject list mention maths?
    if((ucas_subjects & @ucas_mathematics).any?)
      primary_subjects.push("Primary with mathematics")
    end
      # Does the subject list mention any mfl subject?
    if((ucas_subjects & ucas_primary_language_specialisation).any?)
      primary_subjects.push("Primary with modern languages")
    end
      # Does the subject list mention PE?
    if(ucas_subjects.index("physical education") != nil)
      primary_subjects.push("Primary with physical education")
    end
      # Does the subject list mention science?

    if((ucas_subjects & ucas_primary_science_specialisation).any?)
      primary_subjects.push("Primary with science")
    end
    primary_subjects
  end

  def self.get_subject_list(course_title, ucas_subjects)
    ucas_subjects = ucas_subjects.map { |subject| (subject.strip! || subject).downcase }
    course_title = (course_title.strip! || course_title).downcase
    # if unexpected throw.
    if (ucas_subjects & @ucas_unexpected).any?
      raise "found unsupported subject name(s): #{(ucas_subjects & @ucas_unexpected) * ', '}"
    # If the subject indicates that it's primary, do not associate it with any
    # Secondary subjects (that happens a lot in UCAS data). Instead, mark it as primary
    # and additionally test for specialisations (e.g. Pimary with mathematics)
    # note a course can cover multiple specialisations, e.g. Primary with geography and Primary with history
    elsif (ucas_subjects & @ucas_primary).any?
      return map_to_primary_subjects(ucas_subjects)
    # If the subject indicates that it's in the Further Education space,
    # just assign Further education to it and do not associate it with any
    # secondary subjects
    elsif (ucas_subjects & @ucas_further_education).any?
      return ["Further education"]
    # The most common case is when the course is teaching secondary subjects.
    else
      return map_to_secondary_subjects(course_title, ucas_subjects)
    end
  end
end

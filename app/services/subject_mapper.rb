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

  @ucas_wfl_welsh = %w[welsh]

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

  @ucas_language_cat = ["language",
                        "languages (african)",
                        "languages (asian)",
                        "languages (european)"]

  @ucas_other = ["leisure and tourism",
                 "special educational needs"]

  @ucas_mathemtics = ["mathematics",
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

  @ucas_rename = {
    "chinese" => "mandarin",
    "art / art & design" => "art and design",
    "business education" => "business studies",
    "computer studies" => "computing",
    "science" => "balanced science",
    "dance and performance" => "dance",
    "drama and theatre studies" => "drama",
    "social science" => "social sciences"
  }

  @ucas_needs_mention_in_title = {
      "humanities" => /humanities/,
      "science" => /(?<!social |computer )science/,
      "modern studies" => /modern studies/
  }

  def self.is_further_education(subjects)
    subjects = subjects.map { |subject| (subject.strip! || subject).downcase }

    (subjects & @ucas_further_education).any?
  end

  def self.map_to_subject_name(ucas_subject)
    res = (@ucas_rename[ucas_subject] || ucas_subject).capitalize

    (res.sub "english", "English" || res)
  end
end

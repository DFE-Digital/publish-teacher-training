class SubjectCreatorService
  def initialize(primary_subject: PrimarySubject,
      secondary_subject: SecondarySubject,
      further_education_subject: FurtherEducationSubject,
      modern_languages_subject: ModernLanguagesSubject,
      discontinued_subject: DiscontinuedSubject)
    @primary_subject = primary_subject
    @secondary_subject = secondary_subject
    @further_education_subject = further_education_subject
    @modern_languages_subject = modern_languages_subject
    @discontinued_subject = discontinued_subject
  end

  def execute
    primary = [
      { subject_name: "Primary", subject_code: "00" },
      { subject_name: "Primary with English", subject_code: "01" },
      { subject_name: "Primary with geography and history", subject_code: "02" },
      { subject_name: "Primary with mathematics", subject_code: "03" },
      { subject_name: "Primary with modern languages", subject_code: "04" },
      { subject_name: "Primary with physical education", subject_code: "06" },
      { subject_name: "Primary with science", subject_code: "07" },
    ]

    secondary = [
      { subject_name: "Art and design", subject_code: "W1" },
      { subject_name: "Science", subject_code:  "F0" },
      { subject_name: "Biology", subject_code:  "C1" },
      { subject_name: "Business studies", subject_code: "08" },
      { subject_name: "Chemistry", subject_code: "F1" },
      { subject_name: "Citizenship", subject_code:  "09" },
      { subject_name: "Classics", subject_code: "Q8" },
      { subject_name: "Communication and media studies", subject_code: "P3" },
      { subject_name: "Computing", subject_code: "11" },
      { subject_name: "Dance", subject_code: "12" },
      { subject_name: "Design and technology", subject_code: "DT" },
      { subject_name: "Drama", subject_code: "13" },
      { subject_name: "Economics", subject_code: "L1" },
      { subject_name: "English", subject_code: "Q3" },
      { subject_name: "Geography", subject_code: "F8" },
      { subject_name: "Health and social care", subject_code: "L5" },
      { subject_name: "History", subject_code:  "V1" },
      { subject_name: "Mathematics", subject_code: "G1" },
      { subject_name: "Music", subject_code: "W3" },
      { subject_name: "Philosophy", subject_code: "P1" },
      { subject_name: "Physical education", subject_code: "C6" },
      { subject_name: "Physics", subject_code: "F3" },
      { subject_name: "Psychology", subject_code: "C8" },
      { subject_name: "Religious education", subject_code: "V6" },
      { subject_name: "Social sciences", subject_code: "14" },
      # NOTE: no subject_code for 'Modern Languages' because this is just a stub used to trigger
      # selection of actual entries from `modern_languages` list
      { subject_name: "Modern Languages", subject_code: nil },
    ]

    modern_languages = [
      { subject_name: "French", subject_code: "15" },
      { subject_name: "English as a second or other language", subject_code: "16" },
      { subject_name: "German", subject_code: "17" },
      { subject_name: "Italian", subject_code: "18" },
      { subject_name: "Japanese", subject_code:  "19" },
      { subject_name: "Mandarin", subject_code:  "20" },
      { subject_name: "Russian", subject_code:  "21" },
      { subject_name: "Spanish", subject_code:  "22" },
      { subject_name: "Modern languages (other)", subject_code: "24" },
    ]

    further_education = [
      { subject_name: "Further education", subject_code: "41" },
    ]

    # old 2019 DfE subjects
    discontinued = [
      { subject_name: "Humanities" },
      { subject_name: "Balanced Science" },
    ]

    primary.each do |subject|
      @primary_subject.find_or_create_by(subject_name: subject[:subject_name], subject_code: subject[:subject_code])
    end

    secondary.each do |subject|
      @secondary_subject.find_or_create_by(subject_name: subject[:subject_name], subject_code: subject[:subject_code])
    end

    modern_languages.each do |subject|
      @modern_languages_subject.find_or_create_by(subject_name: subject[:subject_name], subject_code: subject[:subject_code])
    end

    further_education.each do |subject|
      @further_education_subject.find_or_create_by(subject_name: subject[:subject_name], subject_code: subject[:subject_code])
    end

    discontinued.each do |subject|
      @discontinued_subject.find_or_create_by(subject_name: subject[:subject_name])
    end
  end
end

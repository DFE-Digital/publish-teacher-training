module AllocationSubjects
  extend ActiveSupport::Concern

  ALLOCATION_SUBJECT_MAP = {
        'Primary'                               => 'Primary',
        'Primary with English'                  => 'Primary',
        'Primary with geography and history'    => 'Primary',
        'Primary with mathematics'              => 'Primary with Maths',
        'Primary with modern languages'         => 'Primary',
        'Primary with physical education'       => 'Primary',
        'Primary with science'                  => 'Primary',
        'Art and design'                        => 'Art & Design',
        'Balanced science'                      => 'Balanced science',
        'Biology'                               => 'Biology',
        'Business studies'                      => 'Business Studies',
        'Chemistry'                             => 'Chemistry',
        'Citizenship'                           => 'Citizenship',
        'Classics'                              => 'Classics',
        'Communication and media studies'       => 'Media Studies',
        'Computing'                             => 'Computing',
        'Dance'                                 => 'Dance',
        'Design and technology'                 => 'Design & Technology',
        'Drama'                                 => 'Drama',
        'Economics'                             => 'Economics',
        'English'                               => 'English',
        'Geography'                             => 'Geography',
        'Health and social care'                => 'Health & Social Care',
        'History'                               => 'History',
        'Humanities'                            => 'Humanities',
        'Mathematics'                           => 'Mathematics',
        'Music'                                 => 'Music',
        'Physical education'                    => 'Physical Education',
        'Physics'                               => 'Physics',
        'Psychology'                            => 'Psychology',
        'Religious education'                   => 'Religious Education',
        'Social sciences'                       => 'Social Studies',
        'English as a second or other language' => 'Modern Languages',
        'French'                                => 'Modern Languages',
        'German'                                => 'Modern Languages',
        'Italian'                               => 'Modern Languages',
        'Japanese'                              => 'Modern Languages',
        'Mandarin'                              => 'Modern Languages',
        'Modern languages (other)'              => 'Modern Languages',
        'Russian'                               => 'Modern Languages',
        'Spanish'                               => 'Modern Languages'
  }.freeze

  included do
    def allocation_subjects
      subjects = dfe_subjects.map { |subject|
        ALLOCATION_SUBJECT_MAP[subject.to_s]
      }.reject(&:nil?).uniq

      if subjects.count > 1
        if subjects.include? 'Primary with Maths'
          subjects.grep_v 'Primary'
        elsif (m = subjects.find { |subject| name.match(/^#{subject}/) })
          [m.to_s]
        else
          subjects.grep_v 'Balanced science'
        end
      else
        subjects
      end
    end
  end
end

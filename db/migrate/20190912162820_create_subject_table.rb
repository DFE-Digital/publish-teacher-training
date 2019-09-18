# rubocop:disable Metrics/BlockLength
class CreateSubjectTable < ActiveRecord::Migration[5.2]
  def change
    create_table :subject do |t|
      t.text :type
      t.text :subject_code
      t.text :subject_name
    end

    say_with_time 'populating subjects' do
      primary = ['Primary',
                 'Primary with English',
                 'Primary with Geography and History',
                 'Primary with Mathematics',
                 'Primary with Modern Languages',
                 'Primary with Physical Education',
                 'Primary with Science']

      secondary = ['Art and Design',
                   'Science',
                   'Biology',
                   'Business Studies',
                   'Chemistry',
                   'Citizenship',
                   'Classics',
                   'Communication and Media Studies',
                   'Computing',
                   'Dance',
                   'Design and Technology',
                   'Drama',
                   'Economics',
                   'English',
                   'Geography',
                   'Health and Social Care',
                   'History',
                   'Mathematics',
                   'Music',
                   'Philosophy',
                   'Physical Education',
                   'Physics',
                   'Psychology',
                   'Religious Education',
                   'Social Sciences'] + ['Modern Languages'] #no subject_code


      modern_languages = ['French',
                          'English as a Second Language',
                          'German',
                          'Italian',
                          'Japanese',
                          'Mandarin',
                          'Russian',
                          'Spanish',
                          'Modern languages (other)']

      further_education = ['Further Education']


      primary.each do |subject_name|
        PrimarySubject.create(subject_name: subject_name)
      end

      secondary.each do |subject_name|
        SecondarySubject.create(subject_name: subject_name)
      end

      modern_languages.each do |subject_name|
        ModernLanguagesSubject.create(subject_name: subject_name)
      end

      further_education.each do |subject_name|
        FurtherEducationSubject.create(subject_name: subject_name)
      end

      # old 2019 DfE subjects
      DiscontinuedSubject.create(subject_name: 'Humanities', subject_code: "U0")
      DiscontinuedSubject.create(subject_name: 'Balanced Science', subject_code: "F0")
    end
  end
end
# rubocop:enable Metrics/BlockLength

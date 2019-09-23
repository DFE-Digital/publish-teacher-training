# rubocop:disable Metrics/BlockLength
class CreateSubjectTable < ActiveRecord::Migration[5.2]
  def change
    create_table :subject do |t|
      t.text :type
      t.text :subject_code
      t.text :subject_name
    end

    say_with_time 'populating subjects' do
      primary = [
        { subject_name: 'Primary', subject_code: '00' },
        { subject_name: 'Primary with English', subject_code: '01' },
        { subject_name: 'Primary with Geography and History', subject_code: '02' },
        { subject_name: 'Primary with Mathematics', subject_code: '03' },
        { subject_name: 'Primary with Modern Languages', subject_code: '04' },
        { subject_name: 'Primary with Physical Education', subject_code: '06' },
        { subject_name: 'Primary with Science', subject_code: '07' }
      ]

      secondary = [
        { subject_name: 'Art and Design', subject_code: 'W1' },
        { subject_name: 'Science', subject_code:  'F0' },
        { subject_name: 'Biology', subject_code:  'C1' },
        { subject_name: 'Business Studies', subject_code: '08' },
        { subject_name: 'Chemistry', subject_code: 'F1' },
        { subject_name: 'Citizenship', subject_code:  '09' },
        { subject_name: 'Classics', subject_code: 'Q8' },
        { subject_name: 'Communication and Media Studies', subject_code: 'P3' },
        { subject_name: 'Computing', subject_code: '11' },
        { subject_name: 'Dance', subject_code: '12' },
        { subject_name: 'Design and Technology', subject_code: 'DT' },
        { subject_name: 'Drama', subject_code: '13' },
        { subject_name: 'Economics', subject_code: 'L1' },
        { subject_name: 'English', subject_code: 'Q3' },
        { subject_name: 'Geography', subject_code: 'F8' },
        { subject_name: 'Health and Social Care', subject_code: 'L5' },
        { subject_name: 'History', subject_code:  'V1' },
        { subject_name: 'Mathematics', subject_code: 'G1' },
        { subject_name: 'Music', subject_code: 'W3' },
        { subject_name: 'Philosophy', subject_code: 'P1' },
        { subject_name: 'Physical Education', subject_code: 'C6' },
        { subject_name: 'Physics', subject_code: 'F3' },
        { subject_name: 'Psychology', subject_code: 'C8' },
        { subject_name: 'Religious Education', subject_code: 'V6' },
        { subject_name: 'Social Sciences', subject_code: '14' },
        #no subject_code
        { subject_name: 'Modern Languages', subject_code: nil }
      ]

      modern_languages = [
        { subject_name: 'French', subject_code: '15' },
        { subject_name: 'English as a Second Language', subject_code: '16' },
        { subject_name: 'German', subject_code: '17' },
        { subject_name: 'Italian', subject_code: '18' },
        { subject_name: 'Japanese', subject_code:  '19' },
        { subject_name: 'Mandarin', subject_code:  '20' },
        { subject_name: 'Russian', subject_code:  '21' },
        { subject_name: 'Spanish', subject_code:  '22' },
        # NOTE: added placeholder 'XX' for 'Modern languages (other)'
        { subject_name: 'Modern languages (other)', subject_code: 'XX' }
      ]

      further_education = [
        { subject_name: 'Further Education', subject_code: '41' }
      ]

      primary.each do |subject|
        PrimarySubject.create(subject_name: subject[:subject_name], subject_code: subject[:subject_code])
      end

      secondary.each do |subject|
        SecondarySubject.create(subject_name: subject[:subject_name], subject_code: subject[:subject_code])
      end

      modern_languages.each do |subject|
        ModernLanguagesSubject.create(subject_name: subject[:subject_name], subject_code: subject[:subject_code])
      end

      further_education.each do |subject|
        FurtherEducationSubject.create(subject_name: subject[:subject_name], subject_code: subject[:subject_code])
      end

      # old 2019 DfE subjects
      DiscontinuedSubject.create(subject_name: 'Humanities')
      DiscontinuedSubject.create(subject_name: 'Balanced Science')
    end
  end
end
# rubocop:enable Metrics/BlockLength

# frozen_string_literal: true

desc "Create SubjectGroups and populate with subjects in order"
task create_and_populate_subject_groups: :environment do
  subject_groups = {
    "Science, technology, engineering and mathematics (STEM)" => [
      "Biology", "Chemistry", "Computing", "Design and technology", "Mathematics", "Physics", "Science"
    ],
    "Languages and literature" => [
      "English", "Ancient Greek", "Ancient Hebrew", "French", "German", "Italian", "Japanese", "Latin", "Mandarin", "Russian", "Spanish", "Modern languages (other)"
    ],
    "Art, humanities and social sciences" => [
      "Art and design", "Business studies", "Citizenship", "Classics", "Communication and media studies", "Dance", "Drama", "Economics", "Geography", "History", "Music", "Philosophy", "Psychology", "Religious education", "Social sciences"
    ],
    "Health and physical education" => [
      "Health and social care", "Physical education", "Physical education with an EBacc subject"
    ],
  }

  current_time = Time.current

  subject_groups.each_with_index do |(group_name, subjects), group_index|
    subject_group = SubjectGroup.find_or_create_by!(name: group_name) do |group|
      # forcing the created at so appear in the right order
      group.created_at = current_time + group_index.seconds
    end

    subjects.each do |subject_name|
      subject = Subject.find_by(subject_name:)

      if subject
        subject.update!(subject_group: subject_group)
      else
        puts "=" * 80
        puts "Subject #{subject_name} not found."
        puts "=" * 80
      end

      puts "Processed subject: #{subject_name} in group: #{group_name}"
    end
  end
end

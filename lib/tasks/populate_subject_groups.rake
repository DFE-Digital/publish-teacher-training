# frozen_string_literal: true

desc 'Create SubjectGroups and populate with subjects'
task create_and_populate_subject_groups: :environment do
  subject_groups = {
    'Science, technology, engineering and mathematics (STEM)' => [
      'Biology', 'Chemistry', 'Computing', 'Design and technology', 'Mathematics', 'Physics', 'Science'
    ],
    'Languages and literature' => [
      'English', 'Ancient Greek', 'Ancient Hebrew', 'French', 'German', 'Italian', 'Japanese', 'Latin', 'Mandarin', 'Russian', 'Spanish'
    ],
    'Art, humanities and social sciences' => [
      'Art and design', 'Business studies', 'Citizenship', 'Classics', 'Communication and media studies', 'Dance', 'Drama', 'Economics', 'Geography', 'History', 'Music', 'Philosophy', 'Psychology', 'Religious studies', 'Social sciences'
    ],
    'Health and physical education' => [
      'Health and social care', 'Physical education'
    ]
  }


  subject_groups.each do |group_name, subjects|
    subject_group = SubjectGroup.find_or_create_by!(name: group_name)
    subjects.each do |subject_name|
      puts "Creating subject: #{subject_name} in group: #{group_name}"
      # Subject.update(subject_name: subject_name, subject_group: subject_group)
    end
  end
end

# == Schema Information
#
# Table name: subject_area
#
#  created_at :datetime         not null
#  name       :text
#  typename   :text             not null, primary key
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subject_area_on_typename  (typename) UNIQUE
#

FactoryBot.define do
  factory :subject_area do
    trait :primary do
      typename { "PrimarySubject" }
      name { "Primary" }
    end

    trait :secondary do
      typename { "SecondarySubject" }
      name { "Secondary" }
    end

    trait :modern_languages do
      typename { "ModernLanguagesSubject" }
      name { "Modern Language" }
    end

    trait :further_education do
      typename { "FurtherEducationSubject" }
      name { "Further Education" }
    end

    trait :discontinued do
      typename { "DiscontinuedSubject" }
      name { "Discontinued" }
    end
  end
end

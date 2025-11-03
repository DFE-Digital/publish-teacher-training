class AddMatchSynonymsToSubject < ActiveRecord::Migration[8.0]
  def change
    # Stores alternative identifiers for this subject as a string array.
    # May include subject codes, abbreviations, informal or formal names,
    # translations, and other terms commonly used to refer to the subject.
    # Enables flexible matching in search operations—users may find the subject
    # using any of these synonyms, not just the canonical subject_name.
    #
    # Example values:
    #   ["MATH", "Maths", "Mathematic"]
    #
    add_column :subject, :match_synonyms, :string, array: true, default: []
    add_index :subject, :match_synonyms, using: :gin
  end
end

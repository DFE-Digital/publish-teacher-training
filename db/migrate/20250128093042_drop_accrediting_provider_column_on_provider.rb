# frozen_string_literal: true

class DropAccreditingProviderColumnOnProvider < ActiveRecord::Migration[8.0]
  def up
    remove_column :provider, :accrediting_provider
  end

  def down
    add_column :provider, :accrediting_provider, :text
    add_index :provider, :accrediting_provider, where: "accrediting_provider = ('Y')"
  end
end

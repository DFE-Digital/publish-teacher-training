# frozen_string_literal: true

require "rails_helper"
require "open3"
require "tmpdir"
require "zlib"

RSpec.describe "atomic database restore wrapper" do
  let(:script) { Rails.root.join(".github/actions/restore/wrap_restore.py") }

  it "wraps a compressed SQL dump in an error-stopping transaction" do
    Dir.mktmpdir do |directory|
      source = Pathname(directory).join("source.sql.gz")
      target = Pathname(directory).join("target.sql.gz")
      sql = "CREATE TABLE example (id bigint);\nINSERT INTO example VALUES (1);"
      Zlib::GzipWriter.open(source.to_s) { |gzip| gzip.write(sql) }

      _stdout, stderr, status = Open3.capture3("python3", script.to_s, source.to_s, target.to_s)

      expect(status).to be_success, stderr
      expect(Zlib::GzipReader.open(target.to_s, &:read)).to eq(
        "\\set ON_ERROR_STOP on\nBEGIN;\n#{sql}\nCOMMIT;\n",
      )
    end
  end

  it "fails before restore when the source is not a valid gzip file" do
    Dir.mktmpdir do |directory|
      source = Pathname(directory).join("source.sql.gz")
      target = Pathname(directory).join("target.sql.gz")
      source.write("not a gzip file")

      _stdout, _stderr, status = Open3.capture3("python3", script.to_s, source.to_s, target.to_s)

      expect(status).not_to be_success
    end
  end
end

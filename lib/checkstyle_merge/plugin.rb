require 'ox'
require 'fileutils'

# frozen_string_literal: true

module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  Phạm Linh/danger-checkstyle_merge
  # @tags monday, weekends, time, rattata
  #
  class DangerCheckstyleMerge < Plugin
    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<String>]
    # attr_accessor :my_attribute

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]

    # Sample report file
    # <?xml version="1.0" encoding="utf-8"?>
    # <checkstyle version="8.0">
    #    <file name="/Users/pnlinh/Desktop/Dev/Android/android-boilerplate/core-event/src/main/java/com/pnlinh/android/event/LiveEvent.kt">
    #      <error line="41" column="1" severity="error" message="Exceeded max line length (100)" source="max-line-length"/>
    #      <error line="64" column="2" severity="error" message="Redundant newline (\n) at the end of file" source="final-newline"/>
    #    </file>
    #   <file name="/Users/pnlinh/Desktop/Dev/Android/android-boilerplate/core_preference/src/main/java/com/pnlinh/android/core_preference/UserPreference.kt">
    #     <error line="1" column="1" severity="error" message="Package name must not contain underscore" source="experimental:package-name"/>
    #   </file>
    # </checkstyle>
    def merge(files, output_path)
      raise "Please specify file name." if files.empty?

      docs = files.filter { |file| File.exist? file }
                  .map { |file| Ox.parse(File.read(file)) }

      output_doc = create_checkstyle_element(docs)

      # doc.root = <checkstyle element
      docs.flat_map { |doc| doc.root&.nodes || [] }
          .each { |issue| output_doc.root << issue }

      output_dir = File.dirname(output_path)

      FileUtils.mkdir_p(output_dir) unless File.exist? output_dir

      Ox.to_file(output_path, output_doc, {})
    end

    def create_checkstyle_element(docs = [])
      root_version = docs.first&.[](:version) || '1.0'
      encoding = docs.first&.[](:encoding) || 'utf-8'
      version = docs.first&.root&.[](:version) || '8.0'
      doc = Ox::Document.new

      # <?xml version="1.0" encoding="utf-8"?>
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = root_version
      instruct[:encoding] = encoding
      doc << instruct

      # <checkstyle version="8.0">
      top = Ox::Element.new('checkstyle')
      top[:version] = version
      doc << top

      doc
    end
  end
end

require 'liqaml/version'
require 'message_format'
require 'liquid'
require 'liqaml/filters/icu_filter'
require 'json'

module Liqaml
  class LiqamlError < StandardError; end

  class Liqaml
    # Raises SyntaxError when invalid Liquid syntax is used
    Liquid::Template.error_mode = :strict

    Liquid::Template.register_filter(IcuFilter)

    def self.extract_hash(string_args)
      string_hash = {}

      string_arr = string_args.split(',').map(&:strip)

      string_arr.each do |s|
        elements = s.split('-')
        string_hash[elements[0]] = (elements[1..-1].join('-'))
      end

      string_hash.map { |k, v| [k.to_sym, v] }.to_h
    end

    def initialize(locales_array, tokens_array, yaml_target, json_target, process_count)
      @locales_array = locales_array
      @tokens_array  = tokens_array
      @yaml_target   = yaml_target
      @json_target   = json_target
      @process_count = process_count
    end

    # Process yaml files, convert them to json, then send new files to target folders
    def process_and_convert
      all_locales_filenames = @locales_array.map { |file| File.basename(file) }

      locale_patterns = all_locales_filenames.map { |filename| filename.scan(/\..*\./) }.uniq.flatten
      # e.g. => [".en.", ".cs.", ...]

      locale_patterns.each do |pattern|
        @locale = pattern[1...-1]
        locale_files = @locales_array.select { |filename| File.basename(filename).include?(pattern) }

        # join contents of locale_files to one hash of variables
        variables_hash = yaml_files_to_hash(locale_files)
        # process these variables
        processed_vars = process(variables_hash.to_yaml)

        # now process tokens and make new files from them
        @tokens_array.each do |token_file|
          @file = File.basename(token_file)

          output_filename_base = "#{File.basename(token_file, '.yml')}.#{@locale}"
          yaml_file            = "#{@yaml_target}/#{output_filename_base}.yml"
          json_file            = "#{@json_target}/#{output_filename_base}.json"

          template = { @locale => yaml_files_to_hash([token_file]) }

          processed_locale = process_template(template.to_yaml, processed_vars)
          processed_locale = processed_locale.gsub("---\n", '')
          File.open(yaml_file, 'w') { |f| f.write processed_locale }

          json_locale = convert_to_json(yaml_file)
          File.open(json_file, 'w') { |f| f.write json_locale }
        end
      end

    rescue Liquid::SyntaxError, Psych::SyntaxError, Liquid::UndefinedVariable, Liquid::UndefinedFilter => e
      file = @file ? "(file: #{@file}) " : ''
      raise LiqamlError.new("Error for locale '#{@locale}'#{file}- #{e}")
    end

    def yaml_files_to_hash(files)
      hash = {}
      files.each { |file| hash.merge!(YAML.load_file(file)) }

      hash
    end

    def process(content)
      variables = YAML.load(content)

      YAML.load(process_template(content, variables))
    end

    def process_template(content, variables)
      @process_count || @process_count = 10

      # This block will run again unless there's no "{{ }}" unprocessed, but @process_count times the most
      @process_count.times do
        content = Liquid::Template.parse(content).render!(variables, { strict_variables: true })

        break if content.scan(/\{{.*?\}}/).empty?
      end

      content
    end

    def convert_to_json(yaml_file)
      JSON.pretty_generate(YAML.load_file(yaml_file)[@locale])
    end
  end

  class << self
    def new(locales_array:, tokens_array:, yaml_target:, json_target:, process_count: 10)
      Liqaml.new(locales_array, tokens_array, yaml_target, json_target, process_count)
    end
  end
end

require 'liqaml/version'
require 'message_format'
require 'liquid'
require 'liqaml/filters/icu_filter'
require 'json'

module Liqaml
  class Liqaml
    # Raises SyntaxError when invalid Liquid syntax is used
    Liquid::Template.error_mode = :strict

    Liquid::Template.register_filter(IcuFilter)

    def self.extract_hash(string_args)
      string_hash = {}

      string_arr = string_args.split(', ')

      string_arr.each do |s|
        elements = s.split('-')
        string_hash[elements[0]] = elements[1]
      end

      string_hash.map { |k, v| [k.to_sym, v] }.to_h
    end

    def initialize(translations_array, yaml_target, json_target, process_count)
      @translations_array = translations_array
      @yaml_target        = yaml_target
      @json_target        = json_target
      @process_count      = process_count
    end

    # Process yaml files, convert them to json, then send new files to target folders
    def process_and_convert
      # @translations_array = ['templates/en', 'templates/sk', 'templates/cs']
      @translations_array.each do |translation|
        # set locale from folder's name
        @locale = File.basename(translation)

        # look into folder for keys and templates folders and make array of files for both of them
        keys_files     = Dir["#{translation + '/keys'}/*.yml"]
        template_files = Dir["#{translation + '/templates'}/*.yml"]

        # make hashes from file contents
        keys      = { @locale => yaml_files_to_hash(keys_files) }
        templates = { @locale => yaml_files_to_hash(template_files) }

        preprocessed_keys = process(keys.to_yaml, @locale)

        # join preprocessed keys + templates content to be used as variables in final processing
        variables = preprocessed_keys[@locale].merge(templates[@locale])

        # now finally process template content with variables
        processed_locale = process_template(templates.to_yaml, variables)

        File.open("#{@yaml_target}/#{@locale}.yml", 'w') { |f| f.write processed_locale }

        json_locale = convert_to_json("#{@yaml_target}/#{@locale}.yml")

        File.open("#{@json_target}/#{@locale}.json", 'w') { |f| f.write json_locale }
      end

    rescue Liquid::SyntaxError => e
      puts e
      puts "Found in folder #{@locale}"
    end

    def yaml_files_to_hash(files)
      hash = {}
      files.each { |file| hash.merge!(YAML.load_file(file)[@locale]) }

      hash
    end

    def process(content, locale)
      variables = YAML.load(content)[locale]

      YAML.load(process_template(content, variables))
    end

    def process_template(content, variables)
      @process_count || @process_count = 10

      # This block will run again unless there's no "{{ }}" unprocessed, but @process_count times the most
      @process_count.times do
        content = Liquid::Template.parse(content).render(variables)

        break if content.scan(/\{{.*?\}}/).empty?
      end

      content
    end

    def convert_to_json(yaml_file)
      JSON.pretty_generate(YAML.load_file(yaml_file))
    end
  end

  class << self
    def new(translations_array, yaml_target, json_target, process_count = 10)
      Liqaml.new(translations_array, yaml_target, json_target, process_count)
    end
  end
end

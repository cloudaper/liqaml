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

    def initialize(templates_array, yaml_target, json_target, process_count)
      @templates_array = templates_array
      @yaml_target     = yaml_target
      @json_target     = json_target
      @process_count   = process_count
    end

    # Process yaml files, convert them to json, then send new files to target folders
    def process_and_convert
      @templates_array.each do |template|
        @locale = File.basename(template, File.extname(template))

        processed_locale = process(template, @locale)

        File.open("#{@yaml_target}/#{@locale}.yml", 'w') { |f| f.write processed_locale.to_yaml }

        json_locale = convert_to_json("#{@yaml_target}/#{@locale}.yml")

        File.open("#{@json_target}/#{@locale}.json", 'w') { |f| f.write json_locale }
      end

    rescue Liquid::SyntaxError => e
      puts e
      puts "Found in file #{@locale}.yml"
    end

    def process(template, locale)
      content =  File.read(template)
      variables = YAML.load_file(template)[locale]

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
    def new(templates_array, yaml_target, json_target, process_count = 10)
      Liqaml.new(templates_array, yaml_target, json_target, process_count)
    end
  end
end

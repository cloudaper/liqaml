require "liqaml/version"

module Liqaml
  class Liqaml

    # Raises a SyntaxError when invalid syntax is used
    Liquid::Template.error_mode = :strict

    Liquid::Template.register_filter(IcuFilter)

    def self.process_all
      templates = ["config/liquid/sk.yml", "config/liquid/en.yml"]

      templates.each do |loc_file|
        locale = File.basename(loc_file, File.extname(loc_file))
        I18n.locale = locale

        content =  IO.read("config/liquid/#{locale}.yml")
        variables = YAML.load_file("config/liquid/#{locale}.yml")[locale]

        # This block will run again unless there's no "{{ }}" unprocessed, but 10 times the most
        10.times do
          content = Liquid::Template.parse(content).render(variables)

          puts "#{locale} - Remaining words to process: #{content.scan(/\{{.*?\}}/).count}"
          break if content.scan(/\{{.*?\}}/).empty?
        end

        processed_locale = YAML.load(content)

        File.open("config/liquid_processed/#{locale}.yml", 'w') { |f| f.write processed_locale.to_yaml }

        # TODO change to defualt locale?
        I18n.locale = 'en'
      end

    rescue Liquid::SyntaxError => e
      puts e
      puts "Found in #{I18n.locale.to_s}.yml"
      I18n.locale = 'en'
      nil
    end

    def self.extract_hash(string_args)
      string_hash = {}

      string_arr = string_args.split(', ')

      string_arr.each do |s|
        elements = s.split('-')
        string_hash[elements.first] = elements.second
      end

      string_hash.map { |k, v| [k.to_sym, v] }.to_h
    end
  end
end

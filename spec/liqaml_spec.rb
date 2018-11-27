RSpec.describe Liqaml do
  it 'has a version number' do
    expect(Liqaml::VERSION).not_to be nil
  end

  # make Liqaml obejct to be used for testing processing methods
  let(:liqaml) { Liqaml.new(locales_array: [], tokens_array: [], yaml_target: 'yaml_target', json_target: 'json_target') }

  describe 'processing' do
    context 'with correct syntax' do
      it 'processes simple string' do
        content   = 'My name is {{name}}'
        variables = { 'name' => 'Jeff' }

        processed = liqaml.process_template(content, variables)

        expect(processed).to eql('My name is Jeff')
      end

      it 'processes string with ICU filter' do
        content   = "{{gender | icu: 'gender-male', 'sk'}} name is {{name}}"
        variables = { 'name' => 'Jeff', 'gender' => "{ gender, select, male {His} female {Her} other {It's} }" }

        processed = liqaml.process_template(content, variables)

        expect(processed).to eql('His name is Jeff')
      end

      it 'processes and converts yaml file' do
        expected_yaml = 'spec/fixtures/output/general.en.yml'
        expected_json = 'spec/fixtures/output/general.en.json'

        # test only 'en' locale with one token file
        locales = Dir['spec/fixtures/locales/*.en.yml']
        tokens = ['spec/fixtures/tokens/general.yml']
        target = File.dirname(__FILE__) + '/tmp'

        FileUtils.mkdir_p(target) unless File.directory?(target)

        Liqaml.new(locales_array: locales, tokens_array: tokens, yaml_target: target, json_target: target).process_and_convert

        processed = File.read(target + '/general.en.yml')
        converted = File.read(target + '/general.en.json')

        # remove trailing whispaces when comparing 
        expect(processed.strip).to eql(File.read(expected_yaml).strip)
        expect(converted.strip).to eql(File.read(expected_json).strip)
      end
    end

    context 'with incorrect syntax' do
      it 'raises syntax error' do
        content   = 'My name is {{{name}}'
        variables = { 'name' => 'Jeff' }

        expect { liqaml.process_template(content, variables) }.to raise_error(Liquid::SyntaxError)
      end
    end

  end
end

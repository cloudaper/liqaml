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

      it 'processes and converts yaml files' do
        expected_yaml1 = 'spec/fixtures/output/general.en.yml'
        expected_json1 = 'spec/fixtures/output/general.en.json'
        expected_yaml2 = 'spec/fixtures/output/messages.en.yml'
        expected_json2 = 'spec/fixtures/output/messages.en.json'

        # test only 'en' locale
        locales = Dir['spec/fixtures/locales/*.en.{yml,yaml}']
        tokens  = Dir['spec/fixtures/tokens/*.{yml,yaml}']
        target  = File.dirname(__FILE__) + '/tmp'

        FileUtils.mkdir_p(target) unless File.directory?(target)

        # this also starts the actual processing for the test
        expect { Liqaml.new(locales_array: locales, tokens_array: tokens, yaml_target: target,
                              json_target: target).process_and_convert }.not_to raise_error

        processed1 = File.read(target + '/general.en.yml')
        converted1 = File.read(target + '/general.en.json')
        processed2 = File.read(target + '/messages.en.yml')
        converted2 = File.read(target + '/messages.en.json')

        # remove trailing whispaces when comparing
        expect(processed1.strip).to eql(File.read(expected_yaml1).strip)
        expect(converted1.strip).to eql(File.read(expected_json1).strip)
        expect(processed2.strip).to eql(File.read(expected_yaml2).strip)
        expect(converted2.strip).to eql(File.read(expected_json2).strip)
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

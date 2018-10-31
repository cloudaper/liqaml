RSpec.describe Liqaml do
  it 'has a version number' do
    expect(Liqaml::VERSION).not_to be nil
  end

  let(:liqaml) { Liqaml.new([], 'yaml_target', 'json_target') }

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

      it 'processes yaml file' do
        template_yaml  = 'spec/fixtures/template_en.yml'
        processed_yaml = 'spec/fixtures/processed_en.yml'

        processed = liqaml.process(template_yaml, 'en')

        expect((processed).to_yaml).to eql(File.read(processed_yaml))
      end

      it 'converts yaml to json file' do
        processed_yaml = 'spec/fixtures/processed_en.yml'
        converted_yaml = 'spec/fixtures/converted_en.json'

        converted = liqaml.convert_to_json(processed_yaml)

        expect(converted).to eql(File.read(converted_yaml))
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

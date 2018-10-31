# Liqaml

Use Liquid template language with Yaml to process nested translations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'liqaml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install liqaml

## Usage

```ruby
require 'liqaml'

# Set array of file paths that need to be processed and targets for new yaml and json files
arr = ['locales/en.yml', 'locales/cs.yml',]
yaml_target = 'liqaml/yamls'
json_target = 'liqaml/jsons'

Liqaml.new(arr, yaml_target, json_target).process_and_convert

# Optionally you can also provide processing count argument for deeper nesting if needed (default is 10)
process_count = 50

Liqaml.new(arr, yaml_target, json_target, process_count).process_and_convert
```

Note: Your translation yaml files should have corresponding names to it's content, so `en.yml` file starts with "en: ..."

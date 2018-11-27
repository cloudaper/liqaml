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

You need to set 2 arrays containing yaml files. `locales_array` defines different keys/variables in various languages.
`tokens_array` defines templates, which are identical for all languages.

Files within locales_array:
- can not contain first yaml locale key ("en: ...")
- have to contain locale in filename, e.g.: "blabla.en.yml"

Files within tokens_array:
- can not contain first yaml locale key ("en: ...")
- can not contain locale in filename, e.g.: "blabla.en.yml", because they are used as templates for all languages

```ruby
require 'liqaml'

# Set array of locales and tokens files that need to be processed and targets for new yaml and json files
locales = ['/locales/something.en.yml', '/locales/bla.en.yml', '/locales/something.cs.yml', '/locales/bla.cs.yml']
tokens  = ['/tokens/general.yml', '/tokens/messages.yml']
yamls   = 'liqaml/yamls'
jsons   = 'liqaml/jsons'

Liqaml.new(locales_array: locales, tokens_array: tokens, yaml_target: yamls, json_target: jsons).process_and_convert

# Optionally you can also provide processing count argument for deeper nesting if needed (default is 10)

Liqaml.new(locales_array: locales, tokens_array: tokens, yaml_target: yamls, json_target: jsons, process_count: 50).process_and_convert

```

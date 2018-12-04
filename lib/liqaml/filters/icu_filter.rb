module Liqaml
  module IcuFilter
    # change locale to something else when calling this filter if you need other language for Message Format
    def icu(path, icu_args, locale = 'en')
      MessageFormat.new(path, locale).format(Liqaml.extract_hash(icu_args))
    end
  end
end

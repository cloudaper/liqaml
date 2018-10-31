module IcuFilter
  def icu(path, icu_args)
    locale = I18n.locale.to_s
    MessageFormat.new(path, locale).format(Liqaml.extract_hash(icu_args))
  end
end

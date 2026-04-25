# frozen_string_literal: true

require_relative "lib/compare_metrobank_credit_card_statement_with_ynab_export/version"

Gem::Specification.new do |spec|
  spec.name = "compare_metrobank_credit_card_statement_with_ynab_export"
  spec.version = CompareMetrobankCreditCardStatementWithYnabExport::VERSION
  spec.authors = ["George Mendoza"]
  spec.email = ["gsmendoza@gmail.com"]

  spec.summary = "Compare Metrobank credit card statement text to a YNAB CSV export"
  spec.description = <<~DESC
    Parses a Metrobank credit card statement (text copy) and a YNAB register export (CSV),
    matches transactions by amount and approximate date, and writes a comparison CSV.
    Includes the compare-metrobank-ynab executable.
  DESC
  spec.homepage = "https://github.com/gsmendoza/compare_metrobank_credit_card_statement_with_ynab_export"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bigdecimal"
  spec.add_dependency "csv"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

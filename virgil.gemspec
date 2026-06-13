# frozen_string_literal: true

require_relative "lib/virgil/version"

Gem::Specification.new do |spec|
  spec.name = "virgil"
  spec.version = Virgil::VERSION
  spec.authors = ["Michael Coyne"]
  spec.email = ["mjc@hey.com"]

  spec.summary = "RubyLLM agent for crawling the web and completing researcher projects on the web"
  spec.homepage = "https://github.com/mjc-gh/virgil"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "bubbles", "~> 0.1"
  spec.add_dependency "bubbletea", "~> 0.1"
  spec.add_dependency "bubblezone", "~> 0.1"
  spec.add_dependency "lipgloss", "~> 0.2"
  spec.add_dependency "ougai", "~> 2.0"
  spec.add_dependency "ruby_llm", "~> 1.5"
  spec.add_dependency "thor", "~> 1.5"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

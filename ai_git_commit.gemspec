# frozen_string_literal: true

require_relative "lib/ai_git_commit/version"

Gem::Specification.new do |spec|
  spec.name = "ai_git_commit"
  spec.version = AiGitCommit::VERSION
  spec.authors = ["Mike Belyaev"]
  spec.email = ["pair.dro@gmail.com"]

  spec.summary = "AI Git Commit generates Git commit messages using OpenAI."
  spec.description = <<~DESCRIPTION
    A gem that leverages OpenAI's API to automatically generate
    Git commit messages based on staged changes.
  DESCRIPTION
  spec.homepage = "https://github.com/drkmen/ai_git_commit"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/drkmen/ai_git_commit/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.executables << "ai_git_commit"
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "base64", "~> 0.1.0"
  spec.add_dependency "openai", "~> 0.22.0"
  spec.add_dependency "thor", "~> 1.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

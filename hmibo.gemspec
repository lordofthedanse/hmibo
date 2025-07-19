# frozen_string_literal: true

require_relative 'lib/hmibo/version'

Gem::Specification.new do |spec|
  spec.name = 'hmibo'
  spec.version = Hmibo::VERSION
  spec.authors = ['Daniel Brown']
  spec.email = ['daniel@wendcare.com']

  spec.summary = 'Simple service object patterns for Ruby applications'
  spec.description = 'Hmibo (How May I Be Of service) provides lightweight, dependency-free service object patterns inspired by DetectionTek conventions'
  spec.homepage = 'https://github.com/lordofthedanse/hmibo'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['source_code_uri'] = 'https://github.com/lordofthedanse/hmibo'
  spec.metadata['changelog_uri'] = 'https://github.com/lordofthedanse/hmibo/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'logger_head', '~> 0.1.0'

  # Development dependencies
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
end

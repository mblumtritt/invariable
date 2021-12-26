# frozen_string_literal: true

require_relative './lib/invariable/version'

Gem::Specification.new do |spec|
  spec.name = 'invariable'
  spec.version = Invariable::VERSION
  spec.required_ruby_version = '>= 2.7.0'

  spec.author = 'Mike Blumtritt'
  spec.summary = 'The Invariable data class for Ruby.'
  spec.description = <<~description
    An Invariable bundles a number of read-only attributes.
    It can be used like a Hash as well as an Array.
    It supports subclassing and pattern matching.
  description

  spec.homepage = 'https://github.com/mblumtritt/invariable'
  spec.license = 'BSD-3-Clause'
  spec.metadata.merge!(
    'source_code_uri' => 'https://github.com/mblumtritt/invariable',
    'bug_tracker_uri' => 'https://github.com/mblumtritt/invariable/issues',
    'documentation_uri' => 'https://rubydoc.info/github/mblumtritt/invariable'
  )

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'yard'

  all_files = Dir.chdir(__dir__) { `git ls-files -z`.split(0.chr) }
  spec.test_files = all_files.grep(%r{^spec/})
  spec.files = all_files - spec.test_files
  spec.extra_rdoc_files = %w[README.md LICENSE]
end

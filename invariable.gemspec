# frozen_string_literal: true

require_relative './lib/invariable/version'

Gem::Specification.new do |spec|
  spec.name = 'invariable'
  spec.version = Invariable::VERSION
  spec.summary = 'The Invariable data class for Ruby.'
  spec.description = <<~DESCRIPTION
    An Invariable bundles a number of read-only attributes.
    It can be used like a Hash as well as an Array.
    It supports subclassing and pattern matching.
  DESCRIPTION

  spec.author = 'Mike Blumtritt'
  spec.license = 'BSD-3-Clause'
  spec.homepage = 'https://github.com/mblumtritt/invariable'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/invariable'

  spec.required_ruby_version = '>= 2.7.0'
  spec.files = Dir['lib/**/*'] << '.yardopts'
  spec.extra_rdoc_files = %w[README.md LICENSE]
end

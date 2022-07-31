# Invariable

An Invariable bundles a number of read-only attributes.
It can be used like a Hash as well as an Array. It supports subclassing and pattern matching.

An Invariable can be created explicitly as a Class like a Struct. Or existing classes can easily be extended to an Invariable.

- Gem: [rubygems.org](https://rubygems.org/gems/invariable)
- Source: [github.com](https://github.com/mblumtritt/invariable)
- Help: [rubydoc.info](https://rubydoc.info/gems/invariable)

## Sample

```ruby
require 'invariable'

class Person
  include Invariable
  attributes :name, :last_name
  attribute address: Invariable.new(:city, :zip, :street)

  def full_name
    "#{name} #{last_name}"
  end
end
...
john = Person.new(name: 'John', last_name: 'Doe')
john.full_name #=> "John Doe"
john.address.city #=> nil
john = john.update(
  address: { street: '123 Main St', city: 'Anytown', zip: '45678' }
)
john.dig(:address, :city) #=> "Anytown"

```

For more samples see [the samples dir](./examples)

## Installation

Use [Bundler](http://gembundler.com/) to use Invariiable in your own project:

Include in your `Gemfile`:

```ruby
gem 'invariable'
```

and install it by running Bundler:

```bash
bundle
```

To install the gem globally use:

```bash
gem install invariable
```

After that you need only a single line of code in your project to have all tools on board:

```ruby
require 'invariable'
```

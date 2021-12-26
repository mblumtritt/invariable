# frozen_string_literal: true
#
# This sample shows the different aspects of Invariable.
#

require_relative '../lib/invariable'

#
# Person is a sample class which is combined from primitives as well as an
# anonymous Invariable class used for the address attribute.
#
class Person
  include Invariable
  attributes :name, :last_name, address: Invariable.new(:city, :zip, :street)

  def full_name
    "#{name} #{last_name}"
  end

  def to_s
    address.to_a.unshift(full_name).compact.join(', ')
  end
end

puts '- we can check the members of the class'
p Person.members #=> [:name, :last_name, :address]
p Person.member?(:last_name) #=> true

puts '- create a person record'
john = Person.new(name: 'John', last_name: 'Doe')
puts john #=> "John Doe"

puts '- we can check the members of the instance'
p john.members #=> [:name, :last_name, :address]
p john.member?(:last_name) #=> true

puts '- the address members are nil'
p john.address.city #=> nil

puts '- converted to an compact Hash the address is skipped'
p john.to_h(compact: true) #=> {:name=>"John", :last_name=>"Doe"}

puts '- update the record with an address'
john =
  john.update(address: { street: '123 Main St', city: 'Anytown', zip: '45678' })

puts '- the city is assigned now'
p john.dig(:address, :city) #=> "Anytown"
puts john #=> John Doe, Anytown, 45678, 123 Main St

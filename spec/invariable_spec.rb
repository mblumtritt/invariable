# frozen_string_literal: true
require_relative 'helper'

RSpec.describe Invariable do
  subject(:instance) do
    sample_class.new(
      name: 'John',
      last_name: 'Doe',
      address: {
        zip: '45678',
        city: 'Anytown',
        street: '123 Main St'
      }
    )
  end

  let(:sample_class) do
    Class.new do
      include Invariable
      attributes :name, :last_name
      attribute address: Invariable.new(:city, :zip, :street)

      def full_name
        "#{name} #{last_name}"
      end
    end
  end

  context 'attributes' do
    it 'allows to read the attributes by name' do
      expect(instance.name).to eq 'John'
      expect(instance.last_name).to eq 'Doe'
      expect(instance.address).to be_a Invariable
    end

    it 'provides information about its attributes' do
      expect(instance.members).to eq %i[name last_name address]
    end

    it 'can be checked whether an attribute is defined' do
      expect(instance.member?(:last_name)).to be true
      expect(instance.member?(:city)).to be false
    end
  end

  context 'Hash-like behavior' do
    it 'provides Hash-like attribute access' do
      expect(instance[:name]).to eq 'John'
      expect(instance[:last_name]).to eq 'Doe'
      expect(instance[:address][:city]).to eq 'Anytown'
    end

    context 'when the attribute name is unknown' do
      it 'raises a NameError' do
        expect { instance[:size_of_shoe] }.to raise_error(
          NameError,
          'not member - size_of_shoe'
        )
      end
    end

    it 'can be converted into a Hash' do
      expect(instance.to_h).to eq(
        name: 'John',
        last_name: 'Doe',
        address: {
          zip: '45678',
          city: 'Anytown',
          street: '123 Main St'
        }
      )
    end

    it 'can be converted into a customized Hash' do
      converted = instance.to_h { |key, value| ["my_#{key}", value] }
      expect(converted.keys).to eq %w[my_name my_last_name my_address]
    end

    it 'allows to iterate all attribute name/value pairs' do
      expect { |b| instance.each_pair(&b) }.to yield_successive_args(
        [:name, 'John'],
        [:last_name, 'Doe'],
        [:address, instance.address]
      )
    end

    it 'provides an Enumerable for its attributes name/value pairs' do
      expect(instance.each_pair).to be_a(Enumerable)
    end

    it 'can be converted to a compact Hash' do
      john = sample_class.new(name: 'John')
      expect(john.to_h(compact: true)).to eq(name: 'John')
    end
  end

  context 'Array-like behavior' do
    it 'provides its attribute count' do
      expect(instance.size).to be 3
    end

    it 'provides Array-like attribute access' do
      expect(instance[0]).to eq 'John'
      expect(instance[1]).to eq 'Doe'
      expect(instance[2]).to be instance.address
      expect(instance[-1]).to be instance.address
    end

    context 'when the access index is out of bounds' do
      it 'raises a NameError' do
        expect { instance[3] }.to raise_error(IndexError, 'invalid offset - 3')
      end
    end

    it 'can be converted into an Array' do
      expect(instance.to_a).to eq ['John', 'Doe', instance.address]
    end

    it 'allows to iterate all attribute values' do
      expect { |b| instance.each(&b) }.to yield_successive_args(
        'John',
        'Doe',
        instance.address
      )
    end

    it 'provides an Enumerable for its attribute values' do
      expect(instance.each).to be_a(Enumerable)
    end
  end

  context 'comparing' do
    it 'can be compared to other objects' do
      other =
        sample_class.new(
          name: 'John',
          last_name: 'Doe',
          address: {
            zip: '45678',
            city: 'Anytown',
            street: '123 Main St'
          }
        )
      expect(instance == other).to be true

      other =
        sample_class.new(
          name: 'John',
          last_name: 'Doe',
          address: {
            zip: '45678',
            city: 'Anytown',
            street: '124 Main St' # difffers
          }
        )
      expect(instance == other).to be false

      other =
        double(
          :other,
          name: 'John',
          last_name: 'Doe',
          address:
            double(
              :other_addr,
              zip: '45678',
              city: 'Anytown',
              street: '123 Main St'
            )
        )
      expect(instance == other).to be true
    end

    it 'can be tested for equality' do
      other =
        sample_class.new(
          name: 'John',
          last_name: 'Doe',
          address: {
            zip: '45678',
            city: 'Anytown',
            street: '123 Main St'
          }
        )
      expect(instance.eql?(other)).to be true

      other =
        sample_class.new(
          name: 'John',
          last_name: 'Doe',
          address: {
            zip: '45679', # differs
            city: 'Anytown',
            street: '123 Main St'
          }
        )
      expect(instance.eql?(other)).to be false

      other = # class differs
        double(
          :other,
          name: 'John',
          last_name: 'Doe',
          address: {
            zip: '45678',
            city: 'Anytown',
            street: '123 Main St'
          }
        )
      expect(instance.eql?(other)).to be false
    end
  end

  context '#dig pattern' do
    let(:data) { { person: instance } }

    it 'can be used with attribute names' do
      expect(data.dig(:person, :last_name)).to eq 'Doe'
      expect(data.dig(:person, :zip)).to be_nil
      expect(data.dig(:person, :address, :city)).to eq 'Anytown'
    end

    it 'can be used with indices' do
      expect(data.dig(:person, 1)).to eq 'Doe'
      expect(data.dig(:person, -1, :zip)).to eq '45678'
    end
  end

  context 'pattern matching' do
    it 'can be used for named pattern matching' do
      result =
        case instance
        in name: 'Fred', last_name: 'Doe'
          :fred
        in name: 'John', last_name: 'New'
          :not_john
        in name: 'John', last_name: 'Doe', address: { city: 'NY' }
          :john_from_ny
        in name: 'John', last_name: 'Doe', address: { city: 'Anytown' }
          :john
        else
          nil
        end

      expect(result).to be :john
    end

    it 'can be used for indexed pattern matching' do
      result =
        case instance
        in 'Fred', 'Doe', *_
          :fred
        in 'John', 'New', *_
          :not_john
        in 'John', 'Doe', *_
          :john
        else
          nil
        end

      expect(result).to be :john
    end
  end

  it 'allows to create an updated version of itself' do
    result =
      instance.update(
        name: 'Fred',
        address: {
          zip: '45678',
          city: 'Anytown',
          street: '124 Main St'
        }
      )
    expect(result).to be_a sample_class
    expect(result.name).to eq 'Fred'
    expect(result.last_name).to eq 'Doe'
    expect(result.address.to_h).to eq(
      zip: '45678',
      city: 'Anytown',
      street: '124 Main St'
    )
  end

  it 'can be inspected' do
    expect(instance.inspect).to include(' name: "John", last_name: "Doe"')
    expect(instance.inspect).to include(
      'city: "Anytown", zip: "45678", street: "123 Main St"'
    )
  end
end

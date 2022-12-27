# frozen_string_literal: true
require_relative 'helper'

RSpec.describe 'include Invariable' do
  let(:invariable) do
    Class.new do
      include Invariable
      attribute :name
      attribute :last_name
    end
  end

  it 'defines all attributes' do
    expect(invariable.members).to eq %i[name last_name]
  end

  it 'initializes the attributes' do
    instance = invariable.new(name: 'John', last_name: 'Doe')
    expect(instance.name).to eq 'John'
    expect(instance.last_name).to eq 'Doe'
  end

  it 'initializes only given attributes' do
    instance = invariable.new(last_name: 'Doe')
    expect(instance.name).to be_nil
    expect(instance.last_name).to eq 'Doe'
  end

  it 'ignores unknown attributes' do
    expect {
      invariable.new(foo: 42, last_name: 'Doe', ignored: 'yes!')
    }.not_to raise_error
  end

  context 'when defining an already defined attribute' do
    it 'raises an exception' do
      expect do
        Class.new do
          include Invariable
          attribute :name
          attribute :name
        end
      end.to raise_error(NameError, 'attribute already defined - name')
    end
  end

  context 'when used in sub-classing' do
    let(:invariable) { Class.new(base_class) { attributes :street, :city } }
    let(:base_class) do
      Class.new do
        include Invariable
        attributes :name, :last_name
      end
    end

    it 'defines all attributes' do
      expect(invariable.members).to eq %i[name last_name street city]
    end

    it 'initializes the attributes' do
      instance =
        invariable.new(
          name: 'John',
          last_name: 'Doe',
          street: '123 Main St',
          city: 'Anytown'
        )

      expect(instance.name).to eq 'John'
      expect(instance.last_name).to eq 'Doe'
      expect(instance.street).to eq '123 Main St'
      expect(instance.city).to eq 'Anytown'
    end

    it 'initializes only given attributes' do
      instance = invariable.new(last_name: 'Doe', city: 'Anytown')
      expect(instance.name).to be_nil
      expect(instance.last_name).to eq 'Doe'
      expect(instance.street).to be_nil
      expect(instance.city).to eq 'Anytown'
    end

    it 'ignores unknown attributes' do
      expect {
        invariable.new(foo: 42, city: 'Anytown', ignored: 'yes!')
      }.not_to raise_error
    end

    context 'when defining an already defined attribute of the superclass' do
      it 'raises an exception' do
        expect do
          Class.new(base_class){ attribute :name }
        end.to raise_error(NameError, 'attribute already defined - name')
      end
    end
  end
end

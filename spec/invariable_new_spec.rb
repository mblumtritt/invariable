# frozen_string_literal: true
require_relative 'helper'

RSpec.describe 'Invariable.new' do
  context 'when only attribute names are given' do
    subject(:invariable) { Invariable.new(:name, :last_name) }

    it 'creates a new Class' do
      expect(invariable).to be_a Class
    end

    it 'is inherited from Object' do
      expect(invariable).to be < Object
    end

    it 'defines the attributes as instance methods' do
      expect(invariable).to be_public_method_defined :name
      expect(invariable).to be_public_method_defined :last_name
    end
  end

  context 'when a base class and attribute names are given' do
    subject(:invariable) { Invariable.new(foo_class, :name, :last_name) }
    let(:foo_class) { Class.new }

    it 'creates a new Class' do
      expect(invariable).to be_a Class
    end

    it 'is inherited from the given class' do
      expect(invariable).to be < foo_class
    end

    it 'defines the attributes as instance methods' do
      expect(invariable).to be_public_method_defined :name
      expect(invariable).to be_public_method_defined :last_name
    end
  end

  context 'when a block is given' do
    subject(:invariable) do
      Invariable.new(:name, :last_name) do
        def full_name
          "#{name} #{last_name}"
        end
      end
    end

    it 'allows to extend the new class' do
      expect(invariable).to be_public_method_defined :full_name
    end
  end
end

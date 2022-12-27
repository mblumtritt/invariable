# frozen_string_literal: true
require_relative 'helper'

RSpec.describe 'Invariable.new' do
  context 'when only attribute names are given' do
    subject(:invariable) { Invariable.new(:name, :last_name) }

    it { is_expected.to be_a Class }
    it { is_expected.to be < Object  }
    it { is_expected.to be_public_method_defined :name  }
    it { is_expected.to be_public_method_defined :last_name  }
  end

  context 'when a base class and attribute names are given' do
    subject(:invariable) { Invariable.new(foo_class, :name, :last_name) }
    let(:foo_class) { Class.new }

    it { is_expected.to be_a Class }
    it { is_expected.to be < foo_class  }
    it { is_expected.to be_public_method_defined :name  }
    it { is_expected.to be_public_method_defined :last_name  }
  end

  context 'when a block is given' do
    subject(:invariable) do
      Invariable.new(:name, :last_name) do
        def full_name
          "#{name} #{last_name}"
        end
      end
    end

    it { is_expected.to be_public_method_defined :full_name  }
  end
end

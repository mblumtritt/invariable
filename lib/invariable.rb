# frozen_string_literal: true

#
# An Invariable bundles a number of read-only attributes.
# It can be used like a Hash as well as an Array. It supports subclassing
# and pattern matching.
#
# An Invariable can be created explicitly as a Class like a Struct. Or existing
# classes can easily be extended to an Invariable.
#
# @example
#   class Person
#     include Invariable
#     attributes :name, :last_name
#     attribute address: Invariable.new(:city, :zip, :street)
#
#     def full_name
#       "#{name} #{last_name}"
#     end
#   end
#   ...
#   john = Person.new(name: 'John', last_name: 'Doe')
#   john.full_name #=> "John Doe"
#   john.address.city #=> nil
#   john = john.update(
#     address: { street: '123 Main St', city: 'Anytown', zip: '45678' }
#   )
#   john.dig(:address, :city) #=> "Anytown"
#
module Invariable
  class << self
    #
    # @!attribute [r] members
    #   @return [Array<Symbol>] all attribute names of this class
    #
    # @!method attributes(*names, **defaults)
    #   Defines new attributes
    #   @param names [Array<Symbol>] attribute names
    #   @param defaults [{Symbol => Object, Class}] attribute names with default
    #     values
    #   @return [Array<Symbol>] names of defined attributes
    #
    # @!method member?(name)
    #   @return [Boolean] whether the given name is a valid attribute name for
    #     this class
    #

    #
    # Creates a new class with the given attribute names. It also allows to
    # specify default values which are used when an instance is created.
    #
    # With an optional block the class can be extended.
    #
    # @overload new(*names, **defaults, &block)
    #   @example create a simple User class
    #     User = Invariable.new(:name, :last_name)
    #     User.members #=> [:name, :last_name]
    #
    #   @example create a User class with a default value
    #     User = Invariable.new(:name, :last_name, processed: false)
    #     User.new(name: 'John', last_name: 'Doe').to_h
    #     #=> {:name=>"John", :last_name=>"Doe", :processed=>false}
    #
    #   @example create a User class with an additional method
    #     User = Invariable.new(:name, :last_name) do
    #       def full_name
    #         "#{name} #{last_name}"
    #       end
    #     end
    #     User.new(name: 'John', last_name: 'Doe').full_name
    #     #=> "John Doe"
    #
    # @overload new(base_class, *names, **defaults, &block)
    #   @example create a Person class derived from a User class
    #     User = Invariable.new(:name, :last_name)
    #     Person = Invariable.new(User, :city, :zip, :street)
    #     Person.members #=> [:name, :last_name, :city, :zip, :street]
    #
    # @param names [Array<Symbol>] attribute names
    # @param defaults [{Symbol => Object, Class}] attribute names with default
    #   values
    # @yieldparam new_class [Class] the created class
    #
    # @return [Class] the created class
    #
    def new(*names, **defaults, &block)
      Class.new(names.first.is_a?(Class) ? names.shift : Object) do
        include(Invariable)
        attributes(*names, **defaults)
        class_eval(&block) if block
      end
    end

    private

    def included(base)
      base.extend(InvariableClassMethods)
    end
  end

  #
  # Initializes a new instance with the given `attributes` Hash.
  #
  # @return [Invariable] itself
  #
  def initialize(attributes = nil)
    super()
    attributes ||= {}.compare_by_identity
    @__attr__ = {}
    self
      .class
      .instance_variable_get(:@__attr__)
      .each_pair do |key, default|
        @__attr__[key] =
          if default.is_a?(Class)
            default.new(attributes[key]).freeze
          elsif attributes.key?(key)
            attributes[key]
          else
            default
          end
      end
  end

  #
  # Compares attributes of itself with the attributes of a given other Object.
  #
  # This means that the given object needs to implement the same attributes and
  # all it's attribute values have to be equal.
  #
  # @return [Boolean] whether the attribute values are equal
  #
  def ==(other)
    @__attr__.each_pair do |k, v|
      return false if !other.respond_to?(k) || (v != other.__send__(k))
    end
    true
  end

  #
  # Returns the value of the given attribute or the attribute at the given
  # index.
  #
  # @overload [](name)
  #   @param name [Symbol] the name of the attribute
  #
  # @overload [](index)
  #   @param index [Integer] the index of the attribute
  #
  # @return [Object] the attribute value
  #
  # @raise [NameError] if the named attribute does not exist
  # @raise [IndexError] if the index is out of bounds
  #
  def [](arg)
    return @__attr__[arg] if @__attr__.key?(arg)
    raise(NameError, "not member - #{arg}", caller) unless Integer === arg
    if arg >= @__attr__.size || arg < -@__attr__.size
      raise(IndexError, "invalid offset - #{arg}")
    end
    @__attr__.values[arg]
  end

  # @!visibility private
  def deconstruct_keys(...)
    @__attr__.deconstruct_keys(...)
  end

  #
  # Finds and returns the object in nested objects that is specified by the
  # identifiers. The nested objects may be instances of various classes.
  #
  # @param identifiers [Array<Symbol,Integer>] one or more identifiers or
  #   indices
  #
  # @return [Object] object found
  # @return [nil] if nothing was found
  #
  def dig(*identifiers)
    (Integer === identifiers.first ? @__attr__.values : @__attr__).dig(
      *identifiers
    )
  end

  #
  # @overload each(&block)
  #   Yields the value of each attribute in order.
  #
  #   @yieldparam value [Object] attribute value
  #   @return [Invariable] itself
  #
  # @overload each
  #   Creates an Enumerator about its attribute values.
  #
  #   @return [Enumerator]
  #
  def each(&block)
    return to_enum(__method__) unless block
    @__attr__.each_value(&block)
    self
  end

  #
  # @overload each_pair(&block)
  #   Yields the name and value of each attribute in order.
  #
  #   @yieldparam name [Symbol] attribute name
  #   @yieldparam value [Object] attribute value
  #   @return [Invariable] itself
  #
  # @overload each
  #   Creates an Enumerator about its attribute name/values pairs.
  #
  #   @return [Enumerator]
  #
  def each_pair(&block)
    return to_enum(__method__) unless block
    @__attr__.each_pair(&block)
    self
  end

  #
  # Compares its class and all attributes of itself with the class and
  # attributes of a given other Object.
  #
  # @return [Boolean] whether the classes and each attribute value are equal
  #
  # @see ==
  #
  def eql?(other)
    self.class == other.class && self == other
  end

  # @!visibility private
  def hash
    (to_a << self.class).hash
  end

  #
  # @return [String] description of itself as a string
  #
  def inspect
    attributes = @__attr__.map { |k, v| "#{k}: #{v.inspect}" }
    "<#{self.class}::#{__id__} #{attributes.join(', ')}>"
  end
  alias to_s inspect

  #
  # @return [Boolean] whether the given name is a valid attribute name
  #
  def member?(name)
    @__attr__.key?(name)
  end
  alias key? member?

  #
  # @attribute [r] members
  # @return [Array<Symbol>] all attribute names
  #
  def members
    @__attr__.keys
  end

  #
  # @attribute [r] size
  # @return [Integer] number of attributes
  #
  def size
    @__attr__.size
  end

  #
  # @return [Array<Object>] the values of all attributes
  #
  def to_a
    @__attr__.values
  end
  alias values to_a

  # @!visibility private
  def deconstruct
    @__attr__.values
  end

  #
  # @overload to_h
  #   @return [{Symbol => Object}] names and values of all attributes
  #
  # @overload to_h(compact: true)
  #   @return [{Symbol => Object}] names and values of all attributes which
  #     are not `nil` and which are not empty Invariable results
  #
  # @overload to_h(&block)
  #   Returns a Hash containing the results of the block on each pair of the
  #   receiver as pairs.
  #   @yieldparam [Symbol] name the attribute name
  #   @yieldparam [Object] value the attribute value
  #   @yieldreturn [Array<Symbol,Object>] the pair to be stored in the result
  #
  #   @return [{Object => Object}] pairs returned by the `block`
  #
  def to_h(compact: false, &block)
    return to_compact_h if compact
    return Hash[@__attr__.map(&block)] if block
    @__attr__.transform_values { |v| v.is_a?(Invariable) ? v.to_h : v }
  end

  #
  # Updates all given attributes.
  #
  # @return [Invariable] a new updated instance of itself
  def update(attributes)
    opts = {}
    @__attr__.each_pair do |k, v|
      opts[k] = attributes.key?(k) ? attributes[k] : v
    end
    self.class.new(opts)
  end

  #
  # @return [Array<Object>] Array whose elements are the attributes of self at
  #   the given Integer indexes
  def values_at(...)
    @__attr__.values.values_at(...)
  end

  private

  def to_compact_h
    result = {}
    @__attr__.each_pair do |key, value|
      next if value.nil?
      next result[key] = value unless value.is_a?(Invariable)
      value = value.to_h(compact: true)
      result[key] = value unless value.empty?
    end
    result
  end

  module InvariableClassMethods
    # @!visibility private
    def attributes(*names, **defaults)
      @__attr__ = __attr__init unless defined?(@__attr__)
      (names + defaults.keys).map do |name|
        __attr__define(name, defaults[name])
      end
    end
    alias attribute attributes

    # @!visibility private
    def members
      @__attr__.keys
    end

    # @!visibility private
    def member?(name)
      @__attr__.key?(name)
    end

    private

    def __attr__define(name, default)
      unless name.respond_to?(:to_sym)
        raise(TypeError, "invalid attribute name type - #{name}", caller(4))
      end
      name = name.to_sym
      if method_defined?(name)
        raise(NameError, "attribute already defined - #{name}", caller(4))
      end
      define_method(name) { @__attr__[name] }
      @__attr__[name] = default.is_a?(Class) ? default : default.dup.freeze
      name
    end

    def __attr__init
      if superclass.instance_variable_defined?(:@__attr__)
        Hash[superclass.instance_variable_get(:@__attr__)]
      else
        {}.compare_by_identity
      end
    end
  end
  private_constant(:InvariableClassMethods)
end

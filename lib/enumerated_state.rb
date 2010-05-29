gem 'mixology', '>= 0.2.0'
require 'mixology'
gem 'meta_programming', '>= 0.2.1'
require 'meta_programming'
gem 'enumerated_attribute', '>= 0.2.0'
require 'enumerated_attribute'

module EnumeratedState
  class RedefinitionError < Exception
  end
end

class Class

  def acts_as_enumerated_state(enum_attr, opts={})
    enum_attr = enum_attr.to_sym
    unless (self.respond_to?(:has_enumerated_attribute?) && self.has_enumerated_attribute?(enum_attr))
      raise ArgumentError, "enumerated attribute :#{enum_attr} not defined"
    end

    self.extend EnumeratedStateClassMethods
    self.set_enumerated_state_property(enum_attr, :module_prefix, opts[:module] ? "#{opts[:module]}::" : '')
    self.set_enumerated_state_property(enum_attr, :strict, opts[:strict] == false ? false : true)

    if self.method_defined?("write_enumerated_attribute_without_#{enum_attr}")
      raise EnumeratedState::RedefinitionError, "Enumerated state already defined for :#{enum_attr}"
    end

    define_chained_method(:write_enumerated_attribute, enum_attr) do |attribute, value|
      module_prefix = self.class.get_enumerated_state_property(attribute, :module_prefix) || ''
      strict = self.class.get_enumerated_state_property(attribute, :strict)
      if (value != (old_value = self.read_enumerated_attribute(attribute)))
        unless old_value.nil?
          module_name = module_prefix + old_value.to_s.split(/_/).map(&:capitalize).join
          _module = begin
            self.class.class_eval(module_name)
          rescue
            begin
              Kernel.class_eval(module_name)
            rescue Exception => ex
              raise ex if strict
            end
          end
          self.unmix(_module) if _module
        end
      end
      self.__send__("write_enumerated_attribute_without_#{enum_attr}".to_sym, attribute, value)
      if (enum_attr == attribute.to_sym && !value.nil?)
        module_name = module_prefix + value.to_s.split(/_/).map(&:capitalize).join
        _module = begin
          self.class.class_eval(module_name)
        rescue
          begin
            Kernel.class_eval(module_name)
          rescue Exception => ex
            raise ex if strict
          end
        end
        self.mixin(_module) if _module
      end
    end
  end
    alias_method :enumerated_state_pattern, :acts_as_enumerated_state

  module EnumeratedStateClassMethods
    def get_enumerated_state_property(enum_attr, prop_name)
      if @_enumerated_state.has_key?(enum_attr)
        if @_enumerated_state[enum_attr].has_key?(prop_name)
          return @_enumerated_state[enum_attr][prop_name]
        end
      end
      klass = self
      while (subclass = klass.superclass)
        if subclass.respond_to?(:get_enumerated_state_property)
          return subclass.get_enumerated_state_property(enum_attr, prop_name)
        else
          klass = subclass
        end
      end
      return nil
    end
    def enumerated_state_property_exists?(enum_attr, prop_name)
      @_enumerated_state[enum_attr].has_key?(prop_name) rescue false
    end
    def set_enumerated_state_property(enum_attr, prop_name, value)
      @_enumerated_state ||= {}
      @_enumerated_state[enum_attr] ||= {}
      @_enumerated_state[enum_attr][prop_name] = value
    end
  end
end

require 'spec_helper'

describe 'Enumerated State' do

  describe "acts_as_enumerated_state macro" do
    it "should raise ArgumentError if enumerated_attribute method_name is undefined" do
      lambda {
        class A1
          acts_as_enumerated_state :enum1
        end
      }.should raise_exception(ArgumentError)
    end
    it "should raise ArgumentError if method is not an enumerated_attribute" do
      lambda {
        class A2
          attr_accessor :state
          acts_as_enumerated_state :state
        end
      }.should raise_exception(ArgumentError)
    end
    it "should not raise exception for the alternate form of macro" do
      lambda {
        class A4
          enumerated_attribute :enum1, %w(mod1 mod2)
          enumerated_state_pattern :enum1
        end
      }
    end
  end

  describe "implementation without base methods" do
    class Impl1
      enum_attr :enum1, %w(mod1 mod2)
      acts_as_enumerated_state :enum1
      module Mod1
        def hello; 'hello Mod1'; end
        def goodbye; 'goodbye Mod1'; end
      end
      module Mod2
        def hello; 'hello Mod2'; end
        def goodbye; 'goodbye Mod2'; end
      end
    end

    it "should call correct method after state is set" do
      obj = Impl1.new
      obj.enum1 = :mod1
      obj.hello.should == 'hello Mod1'
      obj.goodbye.should == 'goodbye Mod1'
      obj.enum1 = :mod2
      obj.goodbye.should == 'goodbye Mod2'
      obj.hello.should == 'hello Mod2'
    end
    it "should raise NoMethodError when method called after initialization" do
      obj = Impl1.new
      lambda { obj.hello }.should raise_exception(NoMethodError)
    end
    it "should raise NoMethodError when calling method after enum set to nil" do
      obj = Impl1.new
      obj.enum1 = :mod1
      obj.hello.should == 'hello Mod1'
      lambda { obj.enum1 = nil }.should_not raise_exception
      lambda { obj.hello }.should raise_exception(NoMethodError)
    end
  end

  describe "implementation with base methods" do
    class Impl2
      enum_attr :enum1, %w(mod1 mod2)
      acts_as_enumerated_state :enum1
      def hello; 'hello Impl'; end
      def goodbye; 'goodbye Impl'; end
      module Mod1
        def hello; 'hello Mod1'; end
        def goodbye; 'goodbye Mod1'; end
      end
      module Mod2
        def hello; 'hello Mod2'; end
        def goodbye; 'goodbye Mod2'; end
      end
    end

    it "should call correct method after state is set" do
      obj = Impl2.new
      obj.enum1 = :mod1
      obj.hello.should == 'hello Mod1'
      obj.goodbye.should == 'goodbye Mod1'
      obj.enum1 = :mod2
      obj.goodbye.should == 'goodbye Mod2'
      obj.hello.should == 'hello Mod2'
    end
    it "should call base methods after initialization to nil" do
      obj = Impl2.new
      obj.hello.should == 'hello Impl'
      obj.goodbye.should == 'goodbye Impl'
    end
    it "should call base methods when set to nil" do
      obj = Impl2.new
      obj.enum1 = :mod1
      obj.hello.should == 'hello Mod1'
      obj.enum1 = nil
      obj.hello.should == 'hello Impl'
      obj.goodbye.should == 'goodbye Impl'
    end
  end

  describe "implementation with auto initialization" do

    class Impl3
      enum_attr :enum1, %w(mod1 ^mod2)
      acts_as_enumerated_state :enum1
      def hello; 'hello Impl'; end
      def goodbye; 'goodbye Impl'; end
      module Mod1
        def hello; 'hello Mod1'; end
        def goodbye; 'goodbye Mod1'; end
      end
      module Mod2
        def hello; 'hello Mod2'; end
        def goodbye; 'goodbye Mod2'; end
      end
    end

    it "should call mod2 hello method after initialization to mod2" do
      obj = Impl3.new
      obj.hello.should == 'hello Mod2'
    end
    it "should call mod2 goodbye methods after initialization to mod2" do
      obj = Impl3.new
      obj.goodbye.should == 'goodbye Mod2'
    end
    it "should call base methods when set to nil" do
      obj = Impl3.new
      obj.enum1 = :mod1
      obj.hello.should == 'hello Mod1'
      obj.enum1 = nil
      obj.hello.should == 'hello Impl'
      obj.goodbye.should == 'goodbye Impl'
    end
  end

  describe "implementation with double state" do
    class Impl4
      enum_attr :enum1, %w(mod1 ^mod2)
      enum_attr :enum2, %w(mod3 mod4)
      acts_as_enumerated_state :enum1
      acts_as_enumerated_state :enum2

      def hello; 'hello Impl'; end
      def goodbye; 'goodbye Impl'; end
      def hi; 'hi Impl'; end
      def bye; 'bye Impl'; end
      module Mod1
        def hello; 'hello Mod1'; end
        def goodbye; 'goodbye Mod1'; end
      end
      module Mod2
        def hello; 'hello Mod2'; end
        def goodbye; 'goodbye Mod2'; end
      end
      module Mod3
        def hi; 'hi Mod3'; end
        def bye; 'bye Mod3'; end
      end
      module Mod4
        def hi; 'hi Mod4'; end
        def bye; 'bye Mod4'; end
      end
    end

    it "should call correct methods with dual enuemrations" do
      obj = Impl4.new
      obj.hello.should == 'hello Mod2'
      obj.hi.should == 'hi Impl'
      obj.enum1 = :mod1
      obj.hello.should == 'hello Mod1'
      obj.bye.should == 'bye Impl'
      obj.goodbye.should == 'goodbye Mod1'
      obj.enum2 = :mod3
      obj.bye.should == 'bye Mod3'
      obj.goodbye.should == 'goodbye Mod1'
      obj.hi.should == 'hi Mod3'
      obj.enum2 = :mod4
      obj.hi.should == 'hi Mod4'
      obj.hello.should == 'hello Mod1'
      obj.enum2 = nil
      obj.hi.should == 'hi Impl'
      obj.hello.should == 'hello Mod1'
      obj.enum1 = :mod2
      obj.hello.should == 'hello Mod2'
    end
  end

  describe "implementation with conflicting enum values and module attribute" do
    class Impl5
      enum_attr :enum1, %w(mod1 ^mod2)
      enum_attr :enum2, %w(mod3 mod2)
      acts_as_enumerated_state :enum1
      acts_as_enumerated_state :enum2, :module=>'Enum2'

      def hello; 'hello Impl'; end
      def goodbye; 'goodbye Impl'; end
      def hi; 'hi Impl'; end
      def bye; 'bye Impl'; end

      module Mod1
        def hello; 'hello Mod1'; end
        def goodbye; 'goodbye Mod1'; end
      end
      module Mod2
        def hello; 'hello Mod2'; end
        def goodbye; 'goodbye Mod2'; end
      end

      module Enum2
        module Mod3
          def hi; 'hi Enum2::Mod3'; end
          def bye; 'bye Enum2::Mod3'; end
        end
        module Mod2
          def hi; 'hi Enum2::Mod2'; end
          def bye; 'bye Enum2::Mod2'; end
        end
      end
    end

    it "should call correct method on initialization" do
      obj = Impl5.new
      obj.hello.should == 'hello Mod2'
      obj.hi.should == 'hi Impl'
    end

    it "should call correct methods with dual enumerations" do
      obj = Impl5.new
      obj.enum1 = :mod1
      obj.hello.should == 'hello Mod1'
      obj.bye.should == 'bye Impl'
      obj.goodbye.should == 'goodbye Mod1'
      obj.enum2 = :mod3
      obj.bye.should == 'bye Enum2::Mod3'
      obj.goodbye.should == 'goodbye Mod1'
      obj.hi.should == 'hi Enum2::Mod3'
      obj.enum2 = :mod2
      obj.hi.should == 'hi Enum2::Mod2'
      obj.hello.should == 'hello Mod1'
      obj.enum2 = nil
      obj.hi.should == 'hi Impl'
      obj.hello.should == 'hello Mod1'
      obj.enum1 = :mod2
      obj.hello.should == 'hello Mod2'
    end
  end

  describe "inherited implementation" do
    class Impl10
      enum_attr :enum1, %w(mod1 ^mod2)
      acts_as_enumerated_state :enum1

      def hello; 'hello Impl'; end
      def goodbye; 'goodbye Impl'; end

      module Mod1
        def hello; 'hello Mod1'; end
        def goodbye; 'goodbye Mod1'; end
      end
      module Mod2
        def hello; 'hello Mod2'; end
        def goodbye; 'goodbye Mod2'; end
      end
    end
    class Impl11 < Impl10
      enum_attr :enum2, %w(mod3 mod2)
      acts_as_enumerated_state :enum2, :module=>'Enum2'
      def hi; 'hi Impl'; end
      def bye; 'bye Impl'; end

      module Enum2
        module Mod3
          def hi; 'hi Enum2::Mod3'; end
          def bye; 'bye Enum2::Mod3'; end
        end
        module Mod2
          def hi; 'hi Enum2::Mod2'; end
          def bye; 'bye Enum2::Mod2'; end
        end
      end
    end

    it "should call correct method on initialization" do
      obj = Impl11.new
      obj.hello.should == 'hello Mod2'
      obj.hi.should == 'hi Impl'
    end

    it "should call correct methods with dual enumerations" do
      obj = Impl11.new
      obj.enum1 = :mod1
      obj.hello.should == 'hello Mod1'
      obj.bye.should == 'bye Impl'
      obj.goodbye.should == 'goodbye Mod1'
      obj.enum2 = :mod3
      obj.bye.should == 'bye Enum2::Mod3'
      obj.goodbye.should == 'goodbye Mod1'
      obj.hi.should == 'hi Enum2::Mod3'
      obj.enum2 = :mod2
      obj.hi.should == 'hi Enum2::Mod2'
      obj.hello.should == 'hello Mod1'
      obj.enum2 = nil
      obj.hi.should == 'hi Impl'
      obj.hello.should == 'hello Mod1'
      obj.enum1 = :mod2
      obj.hello.should == 'hello Mod2'
    end
  end

  describe "inherited implementation with nested modules in superclass" do
    class Impl15
      enum_attr :enum2, %w(mod3 mod2)
      acts_as_enumerated_state :enum2, :module=>'Enum2'
      def hi; 'hi Impl'; end
      def bye; 'bye Impl'; end

      module Enum2
        module Mod3
          def hi; 'hi Enum2::Mod3'; end
          def bye; 'bye Enum2::Mod3'; end
        end
        module Mod2
          def hi; 'hi Enum2::Mod2'; end
          def bye; 'bye Enum2::Mod2'; end
        end
      end
    end
    class Impl16 < Impl15
      enum_attr :enum1, %w(mod1 ^mod2)
      acts_as_enumerated_state :enum1

      def hello; 'hello Impl'; end
      def goodbye; 'goodbye Impl'; end

      module Mod1
        def hello; 'hello Mod1'; end
        def goodbye; 'goodbye Mod1'; end
      end
      module Mod2
        def hello; 'hello Mod2'; end
        def goodbye; 'goodbye Mod2'; end
      end
    end

    it "should call correct method on initialization" do
      obj = Impl16.new
      obj.hello.should == 'hello Mod2'
      obj.hi.should == 'hi Impl'
    end

    it "should call correct methods with dual enumerations" do
      obj = Impl16.new
      obj.enum1 = :mod1
      obj.hello.should == 'hello Mod1'
      obj.bye.should == 'bye Impl'
      obj.goodbye.should == 'goodbye Mod1'
      obj.enum2 = :mod3
      obj.bye.should == 'bye Enum2::Mod3'
      obj.goodbye.should == 'goodbye Mod1'
      obj.hi.should == 'hi Enum2::Mod3'
      obj.enum2 = :mod2
      obj.hi.should == 'hi Enum2::Mod2'
      obj.hello.should == 'hello Mod1'
      obj.enum2 = nil
      obj.hi.should == 'hi Impl'
      obj.hello.should == 'hello Mod1'
      obj.enum1 = :mod2
      obj.hello.should == 'hello Mod2'
    end
  end

  describe "implementation error checking" do

    it "should raise exception when redeclaring enumerated states in subclass" do
      lambda {
        class Err1
          enum_attr :enum1, %w(e1 e2)
          acts_as_enumerated_state :enum1
        end
        class Err2 < Err1
          enum_attr :enum2, %w(e3 e4)
          acts_as_enumerated_state :enum1
        end
        obj = Err2.new
      }.should raise_exception(EnumeratedState::RedefinitionError)
    end

  end

end

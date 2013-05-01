# Testing frameworks
require "minitest/spec"
require "minitest/autorun"
require "minitest/mock"

# Debugger
require "pry"

# The gem
$: << File.dirname(__FILE__) + "/../lib"
$: << File.dirname(__FILE__)

require "protected_record"

class TestCase
  include ActiveModel::Dirty
  include ProtectedRecord::DirtyModel

  protected_keys :knowledge, :power

  define_attribute_methods [:knowledge, :power]

  def knowledge
    @knowledge
  end

  def attributes=(args)
  end

  def id_was
    1
  end

  def power
    @power
  end

  def knowledge=(val)
    knowledge_will_change! unless val == @knowledge
    @knowledge = val
  end

  def power=(val)
    power_will_change! unless val == @power
    @power = val
  end

  def save
    @previously_changed = changes
    @changed_attributes.clear
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end

class UnprotectedTestCase
  include ActiveModel::Dirty

  define_attribute_methods [:knowledge, :power]

  def knowledge
    @knowledge
  end

  def attributes=(args)
  end

  def id_was
    1
  end

  def power
    @power
  end

  def knowledge=(val)
    knowledge_will_change! unless val == @knowledge
    @knowledge = val
  end

  def power=(val)
    power_will_change! unless val == @power
    @power = val
  end

  def save
    @previously_changed = changes
    @changed_attributes.clear
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end

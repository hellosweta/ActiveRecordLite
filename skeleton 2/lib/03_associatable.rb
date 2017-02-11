require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    @class_name.to_s.camelcase.constantize
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
    :foreign_key => (name.downcase.singularize.underscore + "_" + "id").to_sym,
    :primary_key => "id".to_sym,
    :class_name => name.capitalize
  }

    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
    :foreign_key => (self_class_name.downcase.singularize.underscore + "_" + "id").to_sym,
    :primary_key => "id".to_sym,
    :class_name => name.capitalize.singularize
  }

    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

module Associatable
  # Phase IIIb
#   begin#Begin writing a belongs_to method for Associatable. This method should take in the association name and an options hash. It should build a BelongsToOptions object; save this in a local variable named options.
#
# Within belongs_to, call define_method to create a new method to access the association. Within this method:
#
# Use send to get the value of the foreign key.
# Use model_class to get the target model class.
# Use where to select those models where the primary_key column is equal to the foreign key value.
# Call first (since there should be only one such item).
# Throughout this method definition, use the options object so that defaults are used appropriately.
  def belongs_to(name, options = {})
    # ...
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      {:foreign_key => self.send("options.foreign_key"),
      :class_name => options.model_class,
      :primary_key => self.where(options).first.to_sym}
    end
  end

  # belongs_to :assocation_name,
  # foreign_key:

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  # extend
end

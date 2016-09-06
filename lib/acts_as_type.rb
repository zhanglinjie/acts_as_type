require "acts_as_type/version"
module ActsAsType
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example
  # class Person
  #   include ActsAsType
  #   acts_as_type :gender, { male: "男", female: "女" }
  # end
  #
  # Person.gender_values            # => [:male, :female]
  # Person.gender_names             # => ['男', '女']
  # Person.gender_collection        # => { male: "男", female: "女" }
  # Person.gender_select_collection # => [["男", :male], ["女", :female]]
  #
  # person = Person.new(gender: :male)
  # person.male?       # => true
  # person.not_male?   # => false
  # person.female?     # => false
  # person.not_female? # => true
  # person.gender_name # => "男"
  #
  # class Person < ActiveRecord::Base
  #   acts_as_type :gender, { male: "男", female: "女" }, validate: true, scope: true
  # end
  #
  # Person.male # => Person.where(gender: :male)
  # person = Person.new(gender: "no_valid_value")
  # person.valid? # => false
  #

  module ClassMethods
    def acts_as_type(column, type_collection, options={})
      is_active_record = Object.const_defined?("ActiveRecord::Base") && self < ActiveRecord::Base
      unless is_active_record
        attr_accessor column
      end
      if type_collection.is_a?(Hash)
        type_values = type_collection.keys
        type_names = type_collection.values
      elsif type_collection.is_a?(Array)
        type_values = type_collection
        type_names = type_collection
        type_collection = Hash[type_values.zip(type_names)]
      end

      define_singleton_method "#{column}_collection" do
        type_collection
      end

      define_singleton_method "#{column}_select_collection" do
        type_collection.map{|value, name| [name, value]}
      end

      define_singleton_method "#{column}_collection_as_select_data" do
        type_collection.map{|value, name| { name: name, id: value }}
      end

      define_singleton_method "#{column}_values" do
        type_values
      end

      define_singleton_method "#{column}_value" do |type_name|
        (Hash[type_names.zip(type_values)][type_name] rescue nil)
      end

      define_singleton_method "#{column}_names" do
        type_names
      end

      define_singleton_method "#{column}_name" do |type_value|
        (Hash[type_values.zip(type_names)][type_value.to_sym] rescue nil)
      end

      self.class_eval do
        if options[:validate]
          allow_blank = options.fetch(:allow_blank, true)
          if respond_to?(:validates)
            validates column, inclusion: {:in => type_values.map{|value| [value, value.to_s]}.flatten}, allow_blank: allow_blank
          end
        end
        if options[:scope] && is_active_record
          scope column, ->(column_param){ where(column.to_sym => column_param) if column_param.present? }
          type_values.each do |type_value|
            scope type_value, ->{ where(column.to_sym => type_value)}
          end
        end
      end

      type_values.each do |type_value|
        define_method "#{type_value}?" do
          self.send(column).try(:to_sym) == type_value.to_sym
        end

        define_method "not_#{type_value}?" do
          self.send(column).try(:to_sym) != type_value.to_sym
        end
      end

      unless self.instance_methods.include?("#{column}_name".to_sym)
        define_method "#{column}_name" do
          type_collection.fetch(self.send(column).try(:to_sym), nil)
        end
      end

    end
  end
end

ActiveRecord::Base.send(:include, ActsAsType) if defined?(ActiveRecord)
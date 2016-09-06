require 'test_helper'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: 'file:memdb1?mode=memory&cache=shared'
)
ActiveRecord::Schema.verbose = false

def setup_db
  # AR caches columns options like defaults etc. Clear them!
  ActiveRecord::Base.connection.create_table :people do |t|
    t.column :name, :string
    t.column :gender, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  ActiveRecord::Base.connection.schema_cache.clear!
  Person.reset_column_information
end

def teardown_db
  if ActiveRecord::VERSION::MAJOR >= 5
    tables = ActiveRecord::Base.connection.data_sources
  else
    tables = ActiveRecord::Base.connection.tables
  end

  tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Person < ActiveRecord::Base
  acts_as_type :gender, { male: "男", female: "女" }, validate: true, scope: true
end

class NormalPerson
  include ActsAsType
  acts_as_type :gender, { male: "男", female: "女" }
end

class NormalArrayPerson
  include ActsAsType
  acts_as_type :gender, [:male, :female]
end

class ActsAsTypeTestCase < Minitest::Test
  def teardown
    teardown_db
  end

  def setup
    setup_db
  end

  def test_normal_model_class_methods
    assert_equal [:male, :female], NormalPerson.gender_values
    assert_equal ["男", "女"], NormalPerson.gender_names
    assert_equal({ male: "男", female: "女" }, NormalPerson.gender_collection)
    assert_equal([["男", :male], ["女", :female]], NormalPerson.gender_select_collection)
  end

  def test_normal_model_instance_methods
    person = NormalPerson.new
    person.gender = :male
    assert_equal true, person.male?
    assert_equal false, person.not_male?
    assert_equal false, person.female?
    assert_equal true, person.not_female?
    assert_equal "男", person.gender_name
  end

  def test_normal_array_model
    assert_equal [:male, :female], NormalArrayPerson.gender_values
    assert_equal [:male, :female], NormalArrayPerson.gender_names
    assert_equal({ male: :male, female: :female }, NormalArrayPerson.gender_collection)
    assert_equal([[:male, :male], [:female, :female]], NormalArrayPerson.gender_select_collection)
  end

  def test_active_record_model_validate
    person = Person.new(gender: :no_male)
    assert_equal false, person.valid?
    person.gender = :male
    assert_equal true, person.valid?
  end

  def test_active_record_model_scope
    person = Person.create(gender: :male)
    assert_equal 1, Person.male.count
    assert_equal person.id, Person.male.first.id
  end
end
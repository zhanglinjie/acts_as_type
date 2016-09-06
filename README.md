## acts_as_type

### Example
```
 class Person
   include ActsAsType
   acts_as_type :gender, { male: "男", female: "女" }
 end

 Person.gender_values            # => [:male, :female]
 Person.gender_names             # => ['男', '女']
 Person.gender_collection        # => { male: "男", female: "女" }
 Person.gender_select_collection # => [["男", :male], ["女", :female]]

 person = Person.new(gender: :male)
 person.male?       # => true
 person.not_male?   # => false
 person.female?     # => false
 person.not_female? # => true
 person.gender_name # => "男"
```
```
 class Person < ActiveRecord::Base
   acts_as_type :gender, { male: "男", female: "女" }, validate: true, scope: true
 end

 Person.male # => Person.where(gender: :male)
 person = Person.new(gender: "no_valid_value")
 person.valid? # => false
```
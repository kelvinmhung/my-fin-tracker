# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expense do
    date "2013-05-18 20:30:35"
    description "MyString"
    category "MyString"
    amount 1.5
    user_id 1
  end
end

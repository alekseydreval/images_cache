# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    name "MyString"
    image File.open(Rails.root.join 'spec', 'resources', 'images', 'sample.jpeg')
  end
end

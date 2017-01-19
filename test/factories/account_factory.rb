FactoryGirl.define do
  factory :account, :class => Account do 
    name { RandomWord.nouns.next }
    code { RandomWord.nouns.next }
  end
end
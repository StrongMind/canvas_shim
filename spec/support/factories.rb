FactoryBot.define do
  factory :context_module_progression do
    collapsed true
  end

  factory :course do
  end

  factory :content_tag do
    trait :with_assignment do 
      association :content, factory: [:assignment, :with_assignment_group]
    end

    trait :with_discussion_topic do
      association :content, factory: [:discussion_topic, :with_assignment]
    end
  end

  factory :assignment do
    trait :with_assignment_group do
      association :assignment_group, factory: :assignment_group
    end
  end

  factory :assignment_group do
  end

  factory :discussion_topic do
    trait :with_assignment do
      association :assignment, factory: [:assignment, :with_assignment_group]
    end
  end
end

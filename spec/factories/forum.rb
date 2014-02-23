FactoryGirl.define do
	factory :forum_thread, class: ForumThread do
		title Faker::Lorem.sentence

		ignore do
			post_count 5
		end

		after(:create) do |ft, evaluator|
			create_list(:forum_post, evaluator.post_count, forum_thread: ft)
		end

		factory :officer_thread do
			officer true
		end
	end

	factory :forum_post, class: ForumPost do
		association :author, factory: :user
		association :forum_thread, factory: :forum_thread
		content Faker::Lorem.paragraphs(3).join("\n\n")
	end
end

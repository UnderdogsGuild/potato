FactoryGirl.define do

	factory :forum do
		name { Faker::Lorem.word }
		description { Faker::Lorem.sentence }

		ignore do
			thread_count 1
		end

		after(:create) do |f, evaluator|
			create_list(:forum_thread, evaluator.thread_count, forum: f)
		end

		factory :officer_forum do
			officer true
		end
	end

	factory :forum_thread do
		title { Faker::Lorem.sentence }
		views { 3000 + rand(2000) }
		forum

		ignore do
			post_count 1
			author nil
		end

		after(:create) do |ft, evaluator|
			create(:forum_post, author: evaluator.author, forum_thread: ft) if evaluator.author
			create_list(:forum_post, evaluator.post_count, forum_thread: ft)
		end

		factory :huge_thread do
			post_count { 100 + rand(250) }
		end
	end

	factory :forum_post do
		user
		forum_thread
		content { Faker::Lorem.paragraphs(3).join("\n\n") }
	end

end

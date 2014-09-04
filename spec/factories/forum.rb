require 'color-generator'

FactoryGirl.define do

	factory :forum_thread do
		title { Faker::Lorem.sentence }
		views { 3000 + rand(20000) }

		ignore do
			post_count 2
			author nil
		end

		after(:create) do |ft, evaluator|
			create(:forum_post, author: evaluator.author, forum_thread: ft) if evaluator.author
			create_list(:forum_post, evaluator.post_count, forum_thread: ft)
		end

		factory :officer_thread do
			officer true
		end

		factory :deleted_thread do
			deleted true
		end
	end

	factory :forum_post do
		user
		forum_thread
		content { Faker::Lorem.paragraphs( ( 1 + rand(3) )).join("\n\n") }

		factory :deleted_post do
			deleted true
		end
	end

	factory :tag do
		name { Faker::Lorem.word }
		color { ColorGenerator.new(saturation: 0.3, lightness: 0.75).create_hex }
	end

end

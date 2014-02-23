FactoryGirl.define do
	factory :user, aliases: [:author] do
		login Faker::Internet.user_name
		password Faker::Internet.password
		email { Faker::Internet.email(login) }
	end

	factory :role do
		label Faker::Lorem.word
		description Faker::Lorem.sentence

		initialize_with do
			Role.find_or_create(label: label) do |r|
				r.description = description
			end
		end
	end

	factory :permission do
		label Faker::Lorem.word
		description Faker::Lorem.sentence

		initialize_with do
			Permission.find_or_create(label: label) do |p|
				p.description = description
			end
		end
	end
end

FactoryGirl.define do
	factory :user, aliases: [:author] do
		login { Faker::Internet.user_name }
		password { Faker::Internet.password }
		email { Faker::Internet.email(login) }

		ignore do
			role nil
			permissions []
		end

		# users with specific roles and/or permissions
		after(:create) do | u, evaluator |
			if evaluator.role then
				if evaluator.role == "root" then
					r = create :root_role, label: evaluator.role
				else
					r = create :role, label: evaluator.role
				end

				u.add_role r

				evaluator.permissions.each { |p| r.add_permission create(:permission, name: p) }

			else
				evaluator.permissions.each { |p| u.add_permission create(:permission, name: p) }
			end
		end

	end

	factory :role do
		label { Faker::Lorem.word }
		description { Faker::Lorem.sentence }

		initialize_with do
			Role.find_or_create(label: label) do |r|
				r.description = description
			end
		end

		factory :root_role do
			root true
		end
	end

	factory :permission do
		label { Faker::Lorem.word }
		description { Faker::Lorem.sentence }

		initialize_with do
			Permission.find_or_create(label: label) do |p|
				p.description = description
			end
		end
	end
end

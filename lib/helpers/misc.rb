class Application < Sinatra::Base
	helpers do
		def random_salutation
			[
				"Welcome, #{user}!",
				"Sup, #{user}?",
				"Aloha, #{user}!",
				"こんにちは, #{user}！"
			].sample
		end
	end
end

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec,
	cmd: 'bundle exec ruby -I. -r spec/spec_helper -S rspec --color --format progress --order random',
	all_on_start: false,
	all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb$})
	watch('lib/application.rb') { "spec" }
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Capybara features specs
  watch(%r{^templates/(.+)/.*\.(erb|haml|slim)$})     { |m| "spec/features/#{m[1]}_spec.rb" }
end

# guard :sass,
# 	:input => 'lib/sass',
# 	:output => 'public/css',
# 	:all_on_start => true,
# 	:style => :extended,
# 	:extension => '.min.css'

guard :livereload do
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{lib/.+\.(rb)})
  watch(%r{templates/.+\.(haml)})
end

guard :rake, task: 'public/css/app.min.css', run_on_all: true do
  watch(%r{^lib/sass/.+\.(sass|scss|css)$})
end

guard :rake, task: 'public/js/app.min.js', run_on_all: true do
  watch(%r{^lib/js/.+\.js$})
end

# vim:ft=ruby

# Run me with:
# $ watchr specs.watchr

# --------------------------------------------------
# Rules
# --------------------------------------------------
watch( '^spec.*/.*_spec\.rb' ) { |m| ruby m[0] }
watch( '^lib/(.*)\.rb' ) { |m| ruby "spec/#{m[1]}_spec.rb" }
watch( '^spec/spec_helper\.rb' ) { ruby tests }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
Signal.trap('QUIT') { ruby specs } # Ctrl-\
Signal.trap('INT' ) { abort("\n") } # Ctrl-C

# --------------------------------------------------
# Helpers
# --------------------------------------------------
def ruby(*paths)
  run "ruby #{gem_opt} -I. -r spec/spec_helper -S rspec #{paths.flatten.join(' ')}"
end

def specs
  Dir['spec/**/*_spec.rb']
end

def run( cmd )
  puts cmd
  system cmd
end

def gem_opt
  defined?(Gem) ? "-rubygems" : ""
end
# vim:ft=ruby

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :bundler do
  watch('Gemfile')
end

guard :rspec, cli: '--color -f doc' do
    watch(%r{^.*$}) { "spec" }
end

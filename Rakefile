task default: :combo

desc 'Run tests, rubocop and generate documentation'
task :combo do
  sh 'bundle exec rspec'
  sh 'bundle exec rubocop' do end # ignore status > 0
  sh 'bundle exec yardoc'
end

desc 'Same as :combo but build a gem, too'
task mega_combo: :combo do
  sh 'gem build vimeo_videos.gemspec'
end

# frozen_string_literal: true

require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Run all unit tests'
task :test do
  ruby 'code.rb'
end

task default: %w[test]

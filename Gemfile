# frozen_string_literal: true

source 'https://rubygems.org'

gem 'cocoapods', '~> 1.14'
gem 'danger-dangermattic', '~> 1.0'
gem 'fastlane', '~> 2.222'
gem 'fastlane-plugin-appcenter', '~> 1.11'
gem 'fastlane-plugin-sentry', '~> 1.14'
gem 'fastlane-plugin-wpmreleasetoolkit', '~> 9.2'
gem 'rake', '~> 12.3'
gem 'xcpretty-travis-formatter', '~> 1.0'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

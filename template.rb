=begin
Template Name: Kickstart application template
Author: Andy Leverenz
Author URI: https://web-crunch.com
Instructions: $ rails new myapp -d <postgresql, mysql, sqlite> -m template.rb
=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gems
  gem 'devise', '~> 4.4.3'
  gem 'bulma-rails', '~> 0.6.2'
  gem 'simple_form', '~> 3.5.1'
  gem 'gravatar_image_tag', github: 'mdeering/gravatar_image_tag'
  gem 'sidekiq', '~> 5.0'
  gem_group :development, :test do
    gem 'better_errors', '~> 2.4'
    gem 'guard', '~> 2.14', '>= 2.14.1'
    gem 'guard-livereload', '~> 2.5', '>= 2.5.2'
  end
end

def set_application_name
  # Ask user for application name
  application_name = ask("What is the name of your application? Default: Kickoff")

  # Checks if application name is empty and add default Jumpstart.
  application_name = application_name.present? ? application_name : "Kickoff"

  # Add Application Name to Config
  environment "config.application_name = '#{application_name}'"

  # Announce the user where he can change the application name in the future.
  puts "Your application name is #{application_name}. You can change this later on: ./config/application.rb"
end

def add_simple_form
  generate "simple_form:install"
end

def add_users
  # Install Devise
  generate "devise:install"

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",
              env: 'development'

  route "root to: 'home#index'"

  # Create Devise User
  generate :devise, "User", "name"
end

def add_home

end

def remove_app_css
  # Remove Application CSS
  run "rm app/assets/stylesheets/application.css"
end

def copy_templates
  directory "app", force: true
end

def add_sidekiq
  environment "config.active_job.queue_adapter = :sidekiq"

  insert_into_file "config/routes.rb",
    "require 'sidekiq/web'\n\n",
    before: "Rails.application.routes.draw do"
end

def init_guardfile
  run "guard init livereload"
end


# Main setup
add_gems

after_bundle do
  set_application_name
  add_simple_form
  add_home
  add_users
  remove_app_css
  add_sidekiq
  init_guardfile

  copy_templates

  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"

  git :init
  git add: "."
  git commit: %Q{ -m "Initial commit" }
end

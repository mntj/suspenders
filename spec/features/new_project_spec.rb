require 'spec_helper'

feature 'Suspend a new project with default configuration' do
  scenario 'specs pass' do
    run_suspenders

    Dir.chdir(project_path) do
      Bundler.with_clean_env do
        expect(`rake`).to include('0 failures')
      end
    end
  end

  scenario 'staging config is inherited from production' do
    run_suspenders

    staging_file = IO.read("#{project_path}/config/environments/staging.rb")
    config_stub = "Rails.application.configure do"

    expect(staging_file).to match(/^require_relative 'production'/)
    expect(staging_file).to match(/#{config_stub}/), staging_file
  end

  scenario 'generated .ruby-version is pulled from Suspenders .ruby-version' do
    run_suspenders

    ruby_version_file = IO.read("#{project_path}/.ruby-version")

    expect(ruby_version_file).to eq "#{RUBY_VERSION}\n"
  end

  scenario 'secrets.yml reads secret from env' do
    run_suspenders

    secrets_file = IO.read("#{project_path}/config/secrets.yml")

    expect(secrets_file).to match(/secret_key_base: <%= ENV\['SECRET_KEY_BASE'\] %>/)
  end

  scenario 'action mailer support file is added' do
    run_suspenders

    expect(File).to exist("#{project_path}/spec/support/action_mailer.rb")
  end

  scenario 'newrelic.yml reads NewRelic license from env' do
    run_suspenders

    newrelic_file = IO.read("#{project_path}/config/newrelic.yml")

    expect(newrelic_file).to match(
      /license_key: '<%= ENV\['NEW_RELIC_LICENSE_KEY'\] %>'/
    )
  end

  scenario 'removes comments from config files' do
    run_suspenders

    test_file = IO.read("#{project_path}/config/environments/test.rb")
    development_file = IO.read("#{project_path}/config/environments/development.rb")
    production_file = IO.read("#{project_path}/config/environments/production.rb")
    environment_file = IO.read("#{project_path}/config/environment.rb")

    puts test_file
    expect(test_file).not_to match(/.*#.*/)
    expect(development_file).not_to match(/.*#.*/)
    expect(production_file).not_to match(/.*#.*/)
    expect(environment_file).not_to match(/.*#.*/)
  end
end

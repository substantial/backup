# encoding: utf-8

require File.expand_path('../../spec_helper', __FILE__)

describe 'System Tests' do

  describe 'create_config' do
    specify 'default path' do
      config_file = Backup::Config.config_file
      create_config

      expect( File.exist?(config_file) ).to be_true
    end

    specify 'alternate path and filename' do
      config_file = File.join(BackupSpec::ALT_CONFIG_PATH, 'my_config.rb')
      create_config(nil, config_file)

      expect( File.exist?(config_file) ).to be_true
    end
  end

  describe 'create_model' do
    specify 'default path, without create_config' do
      config_file = Backup::Config.config_file
      model_file = File.join(
        File.dirname(Backup::Config.config_file), 'models', 'my_backup.rb'
      )

      create_model :my_backup, <<-EOS
        Backup::Model.new(...) do
          somthing here
        end
      EOS

      expect( File.exist?(config_file) ).to be_true
      expect( File.exist?(model_file) ).to be_true
    end

    specify 'alternate path and config filename, without create_config' do
      config_file = File.join(BackupSpec::ALT_CONFIG_PATH, 'my_config.rb')
      model_file = File.join(BackupSpec::ALT_CONFIG_PATH, 'models', 'my_backup.rb')

      create_model :my_backup, <<-EOS, config_file
        Backup::Model.new(...) do
          somthing here
        end
      EOS

      expect( File.exist?(config_file) ).to be_true
      expect( File.exist?(model_file) ).to be_true
    end
  end

  describe 'backup perform' do
    specify 'default path' do
      config_file = Backup::Config.config_file
      model_file = File.join(
        File.dirname(Backup::Config.config_file), 'models', 'a_test.rb'
      )

      create_model :a_test, <<-EOS
        Backup::Model.new(:a_test, 'A test') do
          # nothing
        end
      EOS

      expect( File.exist?(config_file) ).to be_true
      expect( File.exist?(model_file) ).to be_true

      job = backup_perform :a_test

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect(
        job.logger.messages.map(&:lines).flatten.join
      ).to include(
        "Performing Backup for 'A test (a_test)'"
      )
    end

    specify 'alt path' do
      config_file = File.join(BackupSpec::ALT_CONFIG_PATH, 'my_config.rb')
      model_file = File.join(BackupSpec::ALT_CONFIG_PATH, 'models', 'a_test.rb')
      log_file = File.join(BackupSpec::ALT_CONFIG_PATH, 'log', 'backup.log')

      create_model :a_test, <<-EOS, config_file
        Backup::Model.new(:a_test, 'A test') do
          # nothing
        end
      EOS

      expect( File.exist?(config_file) ).to be_true
      expect( File.exist?(model_file) ).to be_true

      job = backup_perform :a_test, '--root-path', BackupSpec::ALT_CONFIG_PATH,
          '--config-file', 'my_config.rb'

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect(
        job.logger.messages.map(&:lines).flatten.join
      ).to include(
        "Performing Backup for 'A test (a_test)'"
      )
    end

    specify 'multiple triggers' do
      create_model :job_a, <<-EOS
        Backup::Model.new(:job_a, 'Job A') do
          # nothing
        end
      EOS
      create_model :job_b, <<-EOS
        Backup::Model.new(:job_b, 'Job B') do
          # nothing
        end
      EOS

      job_a, job_b = backup_perform [:job_a, :job_b]

      expect( job_a.logger.has_warnings? ).to be_false
      expect( job_a.logger.has_errors? ).to be_false

      expect(
        job_a.logger.messages.map(&:lines).flatten.join
      ).to include(
        "Performing Backup for 'Job A (job_a)'"
      )
      expect(
        job_a.logger.messages.map(&:lines).flatten.join
      ).not_to include(
        "Performing Backup for 'Job B (job_b)'"
      )

      expect( job_b.logger.has_warnings? ).to be_false
      expect( job_b.logger.has_errors? ).to be_false

      expect(
        job_b.logger.messages.map(&:lines).flatten.join
      ).to include(
        "Performing Backup for 'Job B (job_b)'"
      )
      expect(
        job_b.logger.messages.map(&:lines).flatten.join
      ).not_to include(
        "Performing Backup for 'Job A (job_a)'"
      )
    end
  end
end

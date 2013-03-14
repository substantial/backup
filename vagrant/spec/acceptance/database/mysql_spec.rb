# encoding: utf-8

require File.expand_path('../../../spec_helper', __FILE__)

module Backup
describe 'Database::MySQL' do

  # FIXME: these will output warnings from mysqldump and result in the
  # backup job completing "with Warnings".
  #
  #   -- Warning: Skipping the data of table mysql.event. Specify the --events option explicitly.
  #
  describe 'All Databases' do
    specify 'All tables' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database MySQL do |db|
            db.name     = :all
            db.username = 'root'
            db.host     = 'localhost'
            db.port     = 3306
          end
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      # expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
        529799 my_backup/databases/MySQL/all-databases.sql
      ]).to be_the_files_within(job.archive)
    end

    specify 'Tables Excluded' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database MySQL do |db|
            db.name         = :all
            db.username     = 'root'
            db.host         = 'localhost'
            db.port         = 3306
            db.skip_tables  = ['backup_test_01.twos', 'backup_test_02.threes']
          end
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      # expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
        522703 my_backup/databases/MySQL/all-databases.sql
      ]).to be_the_files_within(job.archive)
    end
  end # describe 'All Databases'

  describe 'Single Database' do
    specify 'All tables' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database MySQL do |db|
            db.name     = 'backup_test_01'
            db.username = 'root'
            db.host     = 'localhost'
            db.port     = 3306
          end
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
        9514 my_backup/databases/MySQL/backup_test_01.sql
      ]).to be_the_files_within(job.archive)
    end

    specify 'Only one table' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database MySQL do |db|
            db.name         = 'backup_test_01'
            db.username     = 'root'
            db.host         = 'localhost'
            db.port         = 3306
            db.only_tables  = ['ones']
          end
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
        2668 my_backup/databases/MySQL/backup_test_01.sql
      ]).to be_the_files_within(job.archive)
    end

    specify 'Exclude a table' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database MySQL do |db|
            db.name         = 'backup_test_01'
            db.username     = 'root'
            db.host         = 'localhost'
            db.port         = 3306
            db.skip_tables  = ['ones']
          end
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
        8099 my_backup/databases/MySQL/backup_test_01.sql
      ]).to be_the_files_within(job.archive)
    end
  end # describe 'Single Database'
end
end

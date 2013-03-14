# encoding: utf-8

require File.expand_path('../../../spec_helper', __FILE__)

module Backup
describe 'Database::PostgreSQL' do
  describe 'Single Database' do
    specify 'All tables' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database PostgreSQL do |db|
            db.name               = 'backup_test_01'
          end
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
        9199 my_backup/databases/PostgreSQL/backup_test_01.sql
      ]).to be_the_files_within(job.archive)
    end

    specify 'All tables with compression' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database PostgreSQL do |db|
            db.name               = 'backup_test_01'
          end
          compress_with Gzip
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
        2552 my_backup/databases/PostgreSQL/backup_test_01.sql.gz
      ]).to be_the_files_within(job.archive)
    end

    specify 'Only one table' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database PostgreSQL do |db|
            db.name               = 'backup_test_01'
            db.only_tables        = ['ones']
          end
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
        2056 my_backup/databases/PostgreSQL/backup_test_01.sql
      ]).to be_the_files_within(job.archive)
    end

    specify 'Exclude a table' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database PostgreSQL do |db|
            db.name               = 'backup_test_01'
            db.skip_tables        = ['ones']
          end
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
        7860 my_backup/databases/PostgreSQL/backup_test_01.sql
      ]).to be_the_files_within(job.archive)
    end
  end # describe 'Single Database'
end
end

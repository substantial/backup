# encoding: utf-8

require File.expand_path('../../../spec_helper', __FILE__)

module Backup
describe 'Database::MongoDB' do
  describe 'Single Database' do
    specify 'All collections' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database MongoDB do |db|
            db.name = 'backup_test_01'
          end
          store_with Local
        end
      EOS

      job = backup_perform :my_backup

      expect( job.logger.has_warnings? ).to be_false
      expect( job.logger.has_errors? ).to be_false

      expect( job.archive.exist? ).to be_true
      expect(%q[
         3400   my_backup/databases/MongoDB/backup_test_01/ones.bson
          101   my_backup/databases/MongoDB/backup_test_01/ones.metadata.json
         6800   my_backup/databases/MongoDB/backup_test_01/twos.bson
          101   my_backup/databases/MongoDB/backup_test_01/twos.metadata.json
        13600   my_backup/databases/MongoDB/backup_test_01/threes.bson
          103   my_backup/databases/MongoDB/backup_test_01/threes.metadata.json
      ]).to be_the_files_within(job.archive)
    end

    specify 'All collections with compression' do
      create_model :my_backup, <<-EOS
        Backup::Model.new(:my_backup, 'a description') do
          database MongoDB do |db|
            db.name = 'backup_test_01'
          end
          compress_with Gzip
          store_with Local
        end
      EOS

      Timecop.freeze do
        timestamp = Time.now.to_i.to_s[-5, 5]
        job = backup_perform :my_backup

        expect( job.logger.has_warnings? ).to be_false
        expect( job.logger.has_errors? ).to be_false

        expect( job.archive.exist? ).to be_true
        # TODO: why does this tar archive's size change?
        # the contents are always identical.
        expect(%Q[
          3850..3950 my_backup/databases/MongoDB-#{ timestamp }.tar.gz
        ]).to be_the_files_within(job.archive)
      end
    end
  end
end
end

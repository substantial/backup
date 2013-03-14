# encoding: utf-8

require File.expand_path('../../spec_helper', __FILE__)

module Backup
describe 'Backup::Archive' do

  shared_examples 'GNU or BSD tar' do

    describe 'Single Archive' do
      specify 'All directories' do
        create_model :my_backup, <<-EOS
          Backup::Model.new(:my_backup, 'a description') do
            archive :my_archive do |archive|
              archive.add '~/test_data'
            end
            store_with Local
          end
        EOS

        job = backup_perform :my_backup

        expect( job.logger.has_warnings? ).to be_false
        expect( job.logger.has_errors? ).to be_false

        expect( job.archive.exist? ).to be_true
        expect(%q[
          102400 my_backup/archives/my_archive.tar
        ]).to be_the_files_within(job.archive)
      end

      specify 'Some directories' do
        create_model :my_backup, <<-EOS
          Backup::Model.new(:my_backup, 'a description') do
            archive :my_archive do |archive|
              archive.add '~/test_data/dir_a'
              archive.add '~/test_data/dir_b'
            end
            store_with Local
          end
        EOS

        job = backup_perform :my_backup

        expect( job.logger.has_warnings? ).to be_false
        expect( job.logger.has_errors? ).to be_false

        expect( job.archive.exist? ).to be_true
        expect(%q[
          51200 my_backup/archives/my_archive.tar
        ]).to be_the_files_within(job.archive)
      end

      specify 'Exclude directory' do
        create_model :my_backup, <<-EOS
          Backup::Model.new(:my_backup, 'a description') do
            archive :my_archive do |archive|
              archive.add '~/test_data'
              archive.exclude '~/test_data/dir_b'
            end
            store_with Local
          end
        EOS

        job = backup_perform :my_backup

        expect( job.logger.has_warnings? ).to be_false
        expect( job.logger.has_errors? ).to be_false

        expect( job.archive.exist? ).to be_true
        expect(%q[
          71680 my_backup/archives/my_archive.tar
        ]).to be_the_files_within(job.archive)
      end
    end

    describe 'Multiple Archives' do
      specify 'Same but different' do
        create_model :my_backup, <<-EOS
          Backup::Model.new(:my_backup, 'a description') do
            archive :archive_a do |archive|
              archive.add '~/test_data/dir_b'
              archive.add '~/test_data/dir_c'
            end
            archive :archive_b do |archive|
              archive.add '~/test_data'
              archive.exclude '~/test_data/dir_a'
            end
            store_with Local
          end
        EOS

        job = backup_perform :my_backup

        expect( job.logger.has_warnings? ).to be_false
        expect( job.logger.has_errors? ).to be_false

        expect( job.archive.exist? ).to be_true
        # archive_b will have the leading ~/test_data folder listed
        # in the tar manifest, but the archives have identical contents.
        expect(%q[
          81920 my_backup/archives/archive_a.tar
          92160 my_backup/archives/archive_b.tar
        ]).to be_the_files_within(job.archive)
      end
    end

  end # shared_examples 'GNU or BSD tar'

  describe 'Using GNU tar' do
    # GNU tar is the default
    it_behaves_like 'GNU or BSD tar'
  end

  describe 'Using BSD tar' do
    before do
      # tar_dist must be set, since the default config.rb
      # will set this to :gnu to suppress the detection messages.
      create_config <<-EOS
        Backup::Utilities.configure do
          tar '/usr/bin/bsdtar'
          tar_dist :bsd
        end
      EOS
    end

    it_behaves_like 'GNU or BSD tar'
  end
end
end

# encoding: utf-8

module BackupSpec
  class FinalArchive
    include Backup::Utilities::Helpers

    def initialize(trigger)
      # There will be only one final archive package per trigger.
      @archive_path = Dir[
        File.join(LOCAL_STORAGE_PATH, trigger, '**', '*.tar*')
      ].first
    end

    def exist?
      !!@archive_path
    end

    def manifest
      @manifest ||= begin
        archive = encryption ? decrypted_archive : @archive_path
        %x[#{ utility(:tar) } -tvf #{ archive }]
      end
    end

    # GNU/BSD have different formats for `tar -tvf`.
    #
    # Returns a Hash of { 'path' => size } for only the files in the manifest.
    def contents
      @contents ||= begin
        if exist?
          data = manifest.split("\n").reject {|line| line =~ /\/$/ }
          data.map! {|line| line.split(' ') }
          if gnu_tar?
            Hash[data.map {|fields| [fields[5], fields[2].to_i] }]
          else
            Hash[data.map {|fields| [fields[8], fields[4].to_i] }]
          end
        else
          {}
        end
      end
    end

    def encryption
      @archive_path =~ /([.]gpg|[.]enc)$/
      case $1
      when '.gpg' then :gpg
      when '.enc' then :openssl
      else; nil
      end
    end

    # Returns path to decrypted .tar file
    def decrypted_archive
      # TODO: if needed
    end
  end
end

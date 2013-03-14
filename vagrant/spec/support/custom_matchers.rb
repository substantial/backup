# encoding: utf-8

# Matches the given file contents against the archive manifest.
#
# Usage:
#
#     performed_job = backup_perform :trigger
#
#     expect(%q[
#       51200  my_backup/archives/my_archive.tar
#       8099   my_backup/databases/MySQL/backup_test_01.sql
#     ]).to be_the_files_within(performed_job.archive)
#
# File sizes may also be tested against a range.
#
#     expect(%q[
#       51200..51250 my_backup/archives/my_archive.tar
#       8099         my_backup/databases/MySQL/backup_test_01.sql
#     ]).to be_the_files_within(performed_job.archive)
#
# Extra spaces and blank lines are ok.
#
# If the given files with the given sizes do not match all the files
# in the archive's manifest, the error message will include the entire
# manifest as output by `tar -tvf`.
RSpec::Matchers.define :be_the_files_within do |expected|
  match do |actual|
    contents = actual.split("\n").map(&:strip).reject(&:empty?)
    contents.map! {|line| line.split(' ') }
    contents = Hash[contents.map {|fields| [fields[1], fields[0]] }]

    if files_match = contents.keys.sort == expected.contents.keys.sort
      sizes_ok = true
      contents.each do |path, size|
        expected_size = expected.contents[path]

        sizes_ok = if size.include?('..')
          a, b = size.split('..').map(&:to_i)
          (a..b).include? expected_size
        else
          size.to_i == expected_size
        end

        break unless sizes_ok
      end
    end

    files_match && sizes_ok
  end

  failure_message_for_should do |actual|
    "expected that:\n#{ actual }\n" +
    "would represent the files contained in:\n\n#{ expected.manifest }"
  end
end

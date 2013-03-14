require 'fileutils'

desc 'Rebuild Files/Folders for Archive Testing'
task :archives do
  puts "\n=> Preparing Archive Testing..."
  basedir = '/home/vagrant/test_data'

  puts 'Cleaning Test Directory...'
  FileUtils.rm_rf basedir

  puts 'Creating Test Files/Folders...'
  FileUtils.mkdir_p basedir

  tree = {
    dir_a: {
      file_a: 5000,
      file_b: 5000,
      file_c: 5000
    },
    dir_b: {
      file_a: 10000,
      file_b: 10000,
      file_c: 10000
    },
    dir_c: {
      file_a: 15000,
      file_b: 15000,
      file_c: 15000
    }
  }

  Dir.chdir(basedir) do
    tree.each do |dir, contents|
      FileUtils.mkdir dir.to_s
      Dir.chdir(dir.to_s) do
        contents.each do |file, size|
          File.open(file.to_s, 'w') {|f| size.times { f.write 'X' } }
        end
      end
    end
  end
end

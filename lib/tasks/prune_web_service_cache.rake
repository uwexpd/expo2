require "find"

namespace :web_service_cache do
  desc "Remove StudentResource cache files older than one day (DRY_RUN=0 to delete)"
  task prune_student_resource: :environment do
    root = Rails.root.join("tmp/cache/web_service_result/StudentResource")
    if !root.directory? || root.symlink?
      puts "Cache directory missing or unsafe: #{root}"
      next
    end

    cutoff = 1.day.ago
    dry_run = ENV["DRY_RUN"] != "0"
    directories = []
    count = 0
    bytes = 0

    Find.find(root.to_s) do |path|
      stat = File.lstat(path)
      if stat.directory?
        directories << path unless path == root.to_s
        next
      end
      next unless stat.file? && stat.mtime < cutoff

      # Recheck just before deletion in case the cache was refreshed during the scan.
      current = File.lstat(path)
      next unless current.file? && current.mtime < cutoff
      File.delete(path) unless dry_run
      count += 1
      bytes += current.size
    rescue Errno::ENOENT
      next # Another process removed this entry.
    end

    unless dry_run
      directories.reverse_each do |path|
        Dir.rmdir(path) unless File.symlink?(path)
      rescue Errno::ENOTEMPTY, Errno::EEXIST, Errno::ENOENT
        next # Keep directories containing newer entries.
      end
    end

    verb = dry_run ? "Would remove" : "Removed"
    puts "#{verb} #{count} files (#{(bytes / 1.megabyte.to_f).round(1)} MiB) older than #{cutoff} under #{root}"
  end
end

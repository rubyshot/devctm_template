module Devctm
  module Template
    module Tools

      class FileNotFound < StandardError
      end

      class ContentsDiffer < StandardError
      end

      class FileExists < StandardError
      end

      class AmbiguousMigration < StandardError
      end

      # Returns the name of the application being generated.  It works
      # by using the undocumented (AFAIK) feature of there being a root
      # method available to us that returns the path to the root of the
      # application.

      def app_name
        return File.basename(File.expand_path(root)).freeze
      end

      # Make it so all other empty directories have a .gitignore in
      # them.  This can actually put .gitignore files in
      # subdirectories that are already ignored, but the spurious
      # .gitignore won't cause any trouble.

      def tell_git_about_empty_directories
        run %{find . -type d \\( -name .git -prune -o -empty -print0 \\) | \
              xargs -0 -I arg touch arg/.gitignore}
      end

      # Go through the current directory looking for migrations and
      # adjust the date/time portion of the migrations to correspond
      # to the date/time portions in the +skel_dir+.
      # --
      # Perhaps this functionality should be rolled into
      # updat_app_from_skel, although update_app_from_skel could
      # easily be useful in non-rails situations, in which case having
      # Rails-specific semantics is probably not a good idea.  For now
      # it doesn't really matter.

      def fix_skel_migrations(skel_dir = File.dirname(__FILE__) + '/../skel')
        # expect, remove and modify need to be fixed, add doesn't
        for verb in %w(expect remove modify)
          skel_targets(skel_dir, verb, '/db/migrate') do |src_file, target_file|
            pattern = target_file.sub(/\d{14}/, '*')
            matches = Dir.glob(pattern)
            raise FileNotFound, pattern if matches.empty?
            raise AmbiguousMigration, matches.inspect if matches.size > 1
            File.rename(matches.first, target_file)
          end
        end
      end

      # Use the files in the various subdirectories of +skel_dir+ to
      # alter the directory tree rooted at the current directory.
      #
      # The subdirectories of +skel_dir+ are processed in the
      # following order:
      #
      # 1. +expect+
      #
      #    Each file within +expect+ must be found in the
      #    corresponding place within the current directory.  If no
      #    such file is found, a FileNotFound error will be raised.
      #    Additionally, if the file within +expect+ is a non-zero
      #    length, then the corresponding file must match the contents
      #    except for white-space, or a ContentsDiffer error is
      #    raised.
      #
      # 2. +remove+
      #
      #    Each file within +remove+ will be removed from the
      #    corresponding place in the current directory.  If no such
      #    file is found, a FileNotFound error will be raised.  Like
      #    expect, if a file in +remove+ is non-zero length,
      #    ContentsDiffer is raised if, prior to removal, the file in
      #    the current directory doesn't match (except for white space
      #    differences) the file within +remove+.
      #
      # 3. +modify+
      #
      #    The contents of each file within +modify+ will overwrite
      #    the corresponding file within the current directory.
      #    FileNotFound will be raised if the corresponding file does
      #    not already exist.
      #
      # 4. +add+
      #
      #    Each file within +add+ will be copied into the
      #    corresponding file within the current directory.  If such a
      #    file already exists, FileExists be raised.

      def update_app_from_skel(skel_dir = File.dirname(__FILE__) + '/../skel')
        look_for_target 'expect', skel_dir
        look_for_target 'remove', skel_dir, true
        update_target 'modify', skel_dir
        update_target 'add', skel_dir, false
      end

      def ask_for_password(identifier, default = default_password)
        prompt = "Password for #{identifier}"
        default ||= ''
        prompt << " (default is \"#{default}\")" unless default.empty?
        retval = ask(prompt + '?')
        retval = default if !retval || retval.empty?
        return retval
      end

      private

      def default_password
        # using which first will prevent a complaint on STDERR if mkpasswd
        # isn't available
        return `which mkpasswd > /dev/null && mkpasswd`.sub(/'/, '"').strip
      end

      def skel_targets(skel_dir, verb, extra = '')
        Dir.glob("#{skel_dir}/#{verb}#{extra}/**/*", File::FNM_DOTMATCH) do |path|
          if File.file?(path)
            yield(path, path.sub("#{skel_dir}/#{verb}/", ''))
          end
        end
      end

      def look_for_target(verb, skel_dir, remove_it = false)
        skel_targets(skel_dir, verb) do |src_file, target_file|
          raise FileNotFound, target_file unless File.file?(target_file)
          if File.size?(src_file)
            diff = `diff -wu "#{src_file}" "#{target_file}"`
            raise ContentsDiffer, diff if $? != 0
          end
          File.unlink(target_file) if remove_it
        end
      end

      def update_target(verb, skel_dir, should_exist = true)
        skel_targets(skel_dir, verb) do |src_file, target_file|
          if should_exist
            raise FileNotFound, target_file unless File.file?(target_file)
          else
            raise FileExists, target_file if File.file?(target_file)
            FileUtils.mkdir_p(File.dirname(target_file))
          end
          FileUtils.copy(src_file, target_file)
        end
      end
    end
  end
end

lib_dir = File.expand_path('../../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'rubygems'
require 'mkmf'

module RMagick
  class Extconf
    require 'rmagick/version'
    RMAGICK_VERS = ::Magick::VERSION
    MIN_RUBY_VERS = ::Magick::MIN_RUBY_VERSION

    attr_reader :headers

    def initialize
      @stdout = $stdout.dup

      setup_pkg_config_path
      assert_can_compile!
      configure_compile_options
      configure_headers
    end

    def setup_pkg_config_path
      return if RUBY_PLATFORM =~ /mswin|mingw/

      if find_executable('brew')
        pkg_config_path = "#{`brew --prefix imagemagick@6`.strip}/lib/pkgconfig"
      elsif find_executable('pacman')
        pkg_config_path = '/usr/lib/imagemagick6/pkgconfig'
      else
        return
      end

      pkg_config_paths = ENV['PKG_CONFIG_PATH'].to_s.split(':')
      if File.exist?(pkg_config_path) && !pkg_config_paths.include?(pkg_config_path)
        ENV['PKG_CONFIG_PATH'] = [ENV['PKG_CONFIG_PATH'], pkg_config_path].compact.join(':')
      end
    end

    def configured_compile_options
      {
        magick_version: $magick_version,
        local_libs: $LOCAL_LIBS,
        cppflags: $CPPFLAGS,
        ldflags: $LDFLAGS,
        defs: $defs,
        config_h: $config_h
      }
    end

    def configure_headers
      @headers = %w[assert.h ctype.h stdio.h stdlib.h math.h time.h sys/types.h]

      if have_header('MagickCore/MagickCore.h')
        headers << 'MagickCore/MagickCore.h'
      elsif have_header('magick/MagickCore.h')
        headers << 'magick/MagickCore.h'
      else
        exit_failure "Can't install RMagick #{RMAGICK_VERS}. Can't find magick/MagickCore.h."
      end
    end

    def configure_compile_options
      # Magick-config is not available on Windows
      if RUBY_PLATFORM !~ /mswin|mingw/

        check_multiple_imagemagick_versions
        check_partial_imagemagick_versions

        # Save flags
        $CPPFLAGS   = "#{ENV['CPPFLAGS']} " + `pkg-config --cflags #{$magick_package}`.chomp
        $LDFLAGS    = "#{ENV['LDFLAGS']} "  + `pkg-config --libs #{$magick_package}`.chomp
        $LOCAL_LIBS = "#{ENV['LIBS']} "     + `pkg-config --libs #{$magick_package}`.chomp

        configure_archflags_for_osx($magick_package) if RUBY_PLATFORM =~ /darwin/ # osx

      elsif RUBY_PLATFORM =~ /mingw/ # mingw

        dir_paths = search_paths_for_library_for_windows
        $CPPFLAGS = %(-I"#{dir_paths[:include]}")
        $LDFLAGS = %(-L"#{dir_paths[:lib]}")
        $LDFLAGS << ' -lucrt' if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.4.0')

        have_library(im_version_at_least?('7.0.0') ? 'CORE_RL_MagickCore_' : 'CORE_RL_magick_')

      else # mswin

        dir_paths = search_paths_for_library_for_windows
        $CPPFLAGS << %( -I"#{dir_paths[:include]}")
        $LDFLAGS << %( -libpath:"#{dir_paths[:lib]}")
        $LDFLAGS << ' -libpath:ucrt' if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.4.0')

        $LOCAL_LIBS = im_version_at_least?('7.0.0') ? 'CORE_RL_MagickCore_.lib' : 'CORE_RL_magick_.lib'

      end

      $CPPFLAGS << (have_macro('__GNUC__') ? ' -std=gnu99' : ' -std=c99')
    end

    def exit_failure(msg)
      msg = "ERROR: #{msg}"

      Logging.message msg

      @stdout.puts "\n\n"
      if ENV['NO_COLOR']
        @stdout.puts msg
      else
        @stdout.print "\e[31m\e[1m#{msg}\e[0m"
      end
      @stdout.puts "\n\n"
      @stdout.flush

      exit(1)
    end

    def determine_imagemagick_package
      packages = `pkg-config --list-all`.scan(/(ImageMagick\-[\.A-Z0-9]+) .*/).flatten

      # For ancient version of ImageMagick 6 we need a different regex
      if packages.empty?
        packages = `pkg-config --list-all`.scan(/(ImageMagick) .*/).flatten
      end

      if packages.empty?
        exit_failure "Can't install RMagick #{RMAGICK_VERS}. Can't find ImageMagick with pkg-config\n"
      end

      if packages.length > 1

        im7_packages = packages.grep(/\AImageMagick-7/)

        if im7_packages.any?
          checking_for('forced use of ImageMagick 6') do
            if ENV['USE_IMAGEMAGICK_6']
              packages -= im7_packages
              true
            else
              packages = im7_packages
              false
            end
          end
        end
      end

      if packages.length > 1
        package_lines = packages.map { |package| " - #{package}" }.join("\n")
        msg = "\nWarning: Found more than one ImageMagick installation. This could cause problems at runtime.\n#{package_lines}\n\n"
        Logging.message msg
        message msg
      end

      packages.first
    end

    # Seems like lots of people have multiple versions of ImageMagick installed.
    def check_multiple_imagemagick_versions
      versions = []
      path = ENV['PATH'].split(File::PATH_SEPARATOR)
      path.each do |dir|
        file = File.join(dir, 'Magick-config')
        next unless File.executable? file

        vers = `#{file} --version`.chomp.strip
        prefix = `#{file} --prefix`.chomp.strip
        versions << [vers, prefix, dir]
      end
      versions.uniq!
      return unless versions.size > 1

      msg = "\nWarning: Found more than one ImageMagick installation. This could cause problems at runtime.\n"
      versions.each do |vers, prefix, dir|
        msg << "         #{dir}/Magick-config reports version #{vers} is installed in #{prefix}\n"
      end
      msg << "Using #{versions[0][0]} from #{versions[0][1]}.\n\n"
      Logging.message msg
      message msg
    end

    # Ubuntu (maybe other systems) comes with a partial installation of
    # ImageMagick in the prefix /usr (some libraries, no includes, and no
    # binaries). This causes problems when /usr/lib is in the path (e.g., using
    # the default Ruby installation).
    def check_partial_imagemagick_versions
      prefix = config_string('prefix') || ''
      matches = [
        prefix + '/lib/lib?agick*',
        prefix + '/include/ImageMagick',
        prefix + '/bin/Magick-config'
      ].map do |file_glob|
        Dir.glob(file_glob)
      end
      matches.delete_if(&:empty?)
      return unless !matches.empty? && matches.length < 3

      msg = <<~MESSAGE

        Warning: Found a partial ImageMagick installation. Your operating
        system likely has some built-in ImageMagick libraries but not all of
        ImageMagick. This will most likely cause problems at both compile and
        runtime.
        Found partial installation at: #{prefix}

      MESSAGE

      Logging.message msg
      message msg
    end

    # issue #169
    # set ARCHFLAGS appropriately for OSX
    def configure_archflags_for_osx(magick_package)
      return unless `pkg-config #{magick_package} --libs-only-L`.match(%r{-L(.+)/lib})

      imagemagick_dir = Regexp.last_match(1)
      command = Dir.glob(File.join(imagemagick_dir, "bin/*")).select { |file| File.executable? file }.first
      fileinfo = `file #{command}`

      # default ARCHFLAGS
      archs = $ARCH_FLAG.scan(/-arch\s+(\S+)/).flatten

      archflags = []
      archs.each do |arch|
        archflags << "-arch #{arch}" if fileinfo.include?(arch)
      end

      $ARCH_FLAG = archflags.join(' ') unless archflags.empty?
    end

    def search_paths_for_library_for_windows
      msg = 'searching PATH for the ImageMagick library...'
      Logging.message msg
      message msg + "\n"

      found_lib = false
      dir_paths = {}

      paths = ENV['PATH'].split(File::PATH_SEPARATOR)
      paths.each do |dir|
        lib = File.join(dir, 'lib')
        lib_file = File.join(lib, im_version_at_least?('7.0.0') ? 'CORE_RL_MagickCore_.lib' : 'CORE_RL_magick_.lib')
        next unless File.exist?(lib_file)

        dir_paths[:include] = File.join(dir, 'include')
        dir_paths[:lib] = lib

        found_lib = true
        break
      end

      return dir_paths if found_lib

      exit_failure <<~END_MINGW
        Can't install RMagick #{RMAGICK_VERS}.
        Can't find the ImageMagick library.
        Retry with '--with-opt-dir' option.
        Usage: gem install rmagick -- '--with-opt-dir=\"[path to ImageMagick]\"'
        e.g.
          gem install rmagick -- '--with-opt-dir=\"C:\\Program Files\\ImageMagick-6.9.1-Q16\"'
      END_MINGW
    end

    def assert_can_compile!
      assert_minimum_ruby_version!
      assert_has_dev_libs!

      # Check for compiler. Extract first word so ENV['CC'] can be a program name with arguments.
      cc = (ENV['CC'] || RbConfig::CONFIG['CC'] || 'gcc').split(' ').first
      exit_failure "No C compiler found in ${ENV['PATH']}. See mkmf.log for details." unless find_executable(cc)
    end

    def assert_minimum_ruby_version!
      supported = checking_for("Ruby version >= #{MIN_RUBY_VERS}") do
        Gem::Version.new(RUBY_VERSION) >= Gem::Version.new(MIN_RUBY_VERS)
      end

      exit_failure "Can't install RMagick #{RMAGICK_VERS}. Ruby #{MIN_RUBY_VERS} or later required.\n" unless supported
    end

    def assert_has_dev_libs!
      failure_message = <<~END_FAILURE
        Can't install RMagick #{RMAGICK_VERS}.
        Can't find the ImageMagick library or one of the dependent libraries.
        Check the mkmf.log file for more detailed information.
      END_FAILURE

      if RUBY_PLATFORM !~ /mswin|mingw/
        unless find_executable('pkg-config')
          exit_failure "Can't install RMagick #{RMAGICK_VERS}. Can't find pkg-config in #{ENV['PATH']}\n"
        end

        unless `pkg-config --libs MagickCore`[/\bl\s*(MagickCore|Magick)6?\b/]
          exit_failure failure_message
        end

        $magick_package = determine_imagemagick_package
        $magick_version = `pkg-config #{$magick_package} --modversion`[/^(\d+\.\d+\.\d+)/]
      else
        `#{magick_command} -version` =~ /Version: ImageMagick (\d+\.\d+\.\d+)-+\d+ /
        $magick_version = Regexp.last_match(1)
        exit_failure failure_message unless $magick_version
      end

      # Ensure minimum ImageMagick version
      # Check minimum ImageMagick version if possible
      checking_for("outdated ImageMagick version (<= #{Magick::MIN_IM_VERSION})") do
        Logging.message("Detected ImageMagick version: #{$magick_version}\n")

        exit_failure "Can't install RMagick #{RMAGICK_VERS}. You must have ImageMagick #{Magick::MIN_IM_VERSION} or later.\n" if Gem::Version.new($magick_version) < Gem::Version.new(Magick::MIN_IM_VERSION)
      end
    end

    def create_header_file
      ruby_api = [
        'rb_gc_adjust_memory_usage' # Ruby 2.4.0
      ]
      memory_api = %w[
        posix_memalign
        malloc_usable_size
        malloc_size
        _aligned_msize
      ]
      imagemagick_api = [
        'GetImageChannelEntropy', # 6.9.0-0
        'SetImageGray', # 6.9.1-10
        'SetMagickAlignedMemoryMethods' # 7.0.9-0
      ]

      check_api = ruby_api + memory_api + imagemagick_api
      check_api.each do |func|
        have_func(func, headers)
      end

      unless have_header('malloc.h')
        have_header('malloc/malloc.h')
      end

      # Miscellaneous constants
      $defs.push("-DRUBY_VERSION_STRING=\"ruby #{RUBY_VERSION}\"")
      $defs.push("-DRMAGICK_VERSION_STRING=\"RMagick #{RMAGICK_VERS}\"")

      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_6_8_9=1') if im_version_at_least?('6.8.9')
      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_6_9_0=1') if im_version_at_least?('6.9.0')
      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_6_9_10=1') if im_version_at_least?('6.9.10')
      $defs.push('-DIMAGEMAGICK_7=1') if im_version_at_least?('7.0.0')
      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_7_0_8=1') if im_version_at_least?('7.0.8')
      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_7_0_10=1') if im_version_at_least?('7.0.10')

      create_header
    end

    def create_makefile_file
      create_header_file
      # Prior to 1.8.5 mkmf duplicated the symbols on the command line and in the
      # extconf.h header. Suppress that behavior by removing the symbol array.
      $defs = []

      # Force re-compilation if the generated Makefile changed.
      $config_h = 'Makefile'

      create_makefile('RMagick2')
      print_summary
    end

    def magick_command
      @magick_command ||= if find_executable('magick')
                            'magick'
                          elsif find_executable('identify')
                            'identify'
                          else
                            raise NotImplementedError, "no executable found for ImageMagick"
                          end
    end

    def im_version_at_least?(version)
      Gem::Version.new($magick_version) >= Gem::Version.new(version)
    end

    def print_summary
      summary = <<~"END_SUMMARY"
        #{'=' * 70}
        #{Time.now.strftime('%a %d %b %y %T')}
        This installation of RMagick #{RMAGICK_VERS} is configured for
        Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM}) and ImageMagick #{$magick_version}
        #{'=' * 70}


      END_SUMMARY

      Logging.message summary
      message summary
    end
  end
end

extconf = RMagick::Extconf.new
at_exit do
  msg = "Configured compile options: #{extconf.configured_compile_options}"
  Logging.message msg
  message msg + "\n"
end
extconf.create_makefile_file

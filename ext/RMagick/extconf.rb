# frozen_string_literal: true

lib_dir = File.expand_path('../../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'mkmf'
require 'pkg-config'

module RMagick
  class Extconf
    require 'rmagick/version'
    RMAGICK_VERS = ::Magick::VERSION
    MIN_RUBY_VERS = ::Magick::MIN_RUBY_VERSION

    # ImageMagick 6.8+ packages
    IM6_PACKAGES = %w[
      ImageMagick-6.Q64HDRI
      ImageMagick-6.Q32HDRI
      ImageMagick-6.Q16HDRI
      ImageMagick-6.Q8HDRI
      ImageMagick-6.Q64
      ImageMagick-6.Q32
      ImageMagick-6.Q16
      ImageMagick-6.Q8
      ImageMagick-6
    ].freeze

    # ImageMagick 7 packages
    IM7_PACKAGES = %w[
      ImageMagick-7.Q64HDRI
      ImageMagick-7.Q32HDRI
      ImageMagick-7.Q16HDRI
      ImageMagick-7.Q8HDRI
      ImageMagick-7.Q64
      ImageMagick-7.Q32
      ImageMagick-7.Q16
      ImageMagick-7.Q8
      ImageMagick-7
    ].freeze

    attr_reader :headers

    def initialize
      @stdout = $stdout.dup

      exit_failure("No longer support MSWIN environment.") if RUBY_PLATFORM.include?('mswin')

      setup_pkg_config_path
      assert_can_compile!
      configure_compile_options
      configure_headers
    end

    def setup_pkg_config_path
      return if RUBY_PLATFORM.include?('mingw')

      if find_executable('brew')
        append_pkg_config_path("#{`brew --prefix imagemagick`.strip}/lib/pkgconfig")
        append_pkg_config_path("#{`brew --prefix imagemagick@6`.strip}/lib/pkgconfig")
      elsif find_executable('pacman')
        append_pkg_config_path('/usr/lib/imagemagick6/pkgconfig')
      end
    end

    def append_pkg_config_path(path)
      pkg_config_paths = ENV['PKG_CONFIG_PATH'].to_s.split(':')
      if File.exist?(path) && !pkg_config_paths.include?(path)
        ENV['PKG_CONFIG_PATH'] = [ENV['PKG_CONFIG_PATH'], path].compact.join(':')
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
      @headers = %w[assert.h ctype.h stdio.h stdlib.h math.h time.h sys/types.h ruby.h ruby/io.h]

      if have_header('MagickCore/MagickCore.h')
        headers << 'MagickCore/MagickCore.h'
      elsif have_header('magick/MagickCore.h')
        headers << 'magick/MagickCore.h'
      else
        exit_failure "Can't install RMagick #{RMAGICK_VERS}. Can't find magick/MagickCore.h."
      end

      if have_header('malloc.h')
        headers << 'malloc.h'
      elsif have_header('malloc/malloc.h')
        headers << 'malloc/malloc.h'
      end
    end

    def configure_compile_options
      # Magick-config is not available on Windows
      if RUBY_PLATFORM.include?('mingw') # mingw

        dir_paths = search_paths_for_windows
        $CPPFLAGS += %( -I"#{dir_paths[:include]}")
        $CPPFLAGS += ' -x c++ -std=c++11 -Wno-register'
        $LDFLAGS += %( -L"#{dir_paths[:root]}" -lucrt)
        $LDFLAGS += (im_version_at_least?('7.0.0') ? ' -lCORE_RL_MagickCore_' : ' -lCORE_RL_magick_')

      else

        original_ldflags = $LDFLAGS.dup

        libdir  = PKGConfig.libs_only_L($magick_package).chomp.sub('-L', '')
        ldflags = "#{ENV['LDFLAGS']} " + PKGConfig.libs($magick_package).chomp
        rpath   = libdir.empty? ? '' : "-Wl,-rpath,#{libdir}"

        # Save flags
        $CPPFLAGS   += " #{ENV['CPPFLAGS']} " + PKGConfig.cflags($magick_package).chomp
        $CPPFLAGS   += ' -x c++ -std=c++11 -Wno-register'
        $LOCAL_LIBS += " #{ENV['LIBS']} " + PKGConfig.libs($magick_package).chomp
        $LDFLAGS    += " #{ldflags} #{rpath}"

        unless try_link("int main() { }")
          # if linker does not recognizes '-Wl,-rpath,somewhere' option, it revert to original option
          $LDFLAGS = "#{original_ldflags} #{ldflags}"
        end
      end

      $CPPFLAGS += ' $(optflags) $(debugflags) -fomit-frame-pointer'
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

    def detect_imagemagick_packages(packages)
      packages.select do |package|
        PKGConfig.exist?(package)
      end
    end

    def installed_im6_packages
      @installed_im6_packages ||= detect_imagemagick_packages(IM6_PACKAGES)
    end

    def installed_im7_packages
      @installed_im7_packages ||= detect_imagemagick_packages(IM7_PACKAGES)
    end

    def determine_imagemagick_package
      packages = [installed_im7_packages, installed_im6_packages].flatten
      return if packages.empty?

      msg = "\nDetected ImageMagick packages:\n"
      Logging.message msg
      message msg
      package_paths = packages.map { |package| "- #{PKGConfig.package_config(package).pc_path}" }.join("\n")
      Logging.message package_paths + "\n\n"
      message package_paths + "\n\n"

      if installed_im6_packages.any? && installed_im7_packages.any?
        checking_for('forced use of ImageMagick 6') do
          if ENV['USE_IMAGEMAGICK_6']
            packages = installed_im6_packages
            true
          else
            packages = installed_im7_packages
            false
          end
        end
      end

      if packages.length > 1
        msg = "\nWarning: Found more than one ImageMagick installation. This could cause problems at runtime.\n\n"
        Logging.message msg
        message msg
      end

      packages.first
    end

    def search_paths_for_windows
      msg = 'searching PATH for the ImageMagick library...'
      Logging.message msg
      message msg + "\n"

      found = false
      dir_paths = {}

      paths = ENV['PATH'].split(File::PATH_SEPARATOR)
      paths.each do |dir|
        dll = File.join(dir, im_version_at_least?('7.0.0') ? 'CORE_RL_MagickCore_.dll' : 'CORE_RL_magick_.dll')
        next unless File.exist?(dll)

        dir_paths[:include] = File.join(dir, 'include')
        dir_paths[:root] = dir

        found = true
        break
      end

      return dir_paths if found

      exit_failure <<~END_MINGW
        Can't install RMagick #{RMAGICK_VERS}.
        Can't find the ImageMagick library.

        Please check PATH environment variable for ImageMagick installation path.
      END_MINGW
    end

    def assert_can_compile!
      assert_has_dev_libs!

      # Check for C++ compiler. Extract first word so ENV['CXX'] can be a program name with arguments.
      # Ref. https://bugs.ruby-lang.org/issues/21111
      cxx = (ENV['CXX'] || RbConfig::CONFIG['CXX']).split.first
      return if cxx != "false" && find_executable(cxx)

      exit_failure "No C++ compiler found in ${ENV['PATH']}. See mkmf.log for details." 
    end

    def assert_has_dev_libs!
      failure_message = <<~END_FAILURE
        Can't install RMagick #{RMAGICK_VERS}.
        Can't find the ImageMagick library or one of the dependent libraries.
        Check the mkmf.log file for more detailed information.
      END_FAILURE

      if RUBY_PLATFORM.include?('mingw')
        `#{magick_command} -version` =~ /Version: ImageMagick (\d+\.\d+\.\d+)-+\d+ /
        $magick_version = Regexp.last_match(1)
        exit_failure failure_message unless $magick_version
      else
        unless ($magick_package = determine_imagemagick_package)
          exit_failure failure_message
        end

        $magick_version = PKGConfig.modversion($magick_package)[/^(\d+\.\d+\.\d+)/]
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
        'rb_io_path' # Ruby 3.2.0
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

      # Miscellaneous constants
      $defs.push("-DRUBY_VERSION_STRING=\"ruby #{RUBY_VERSION}\"")
      $defs.push("-DRMAGICK_VERSION_STRING=\"RMagick #{RMAGICK_VERS}\"")

      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_6_9_0=1') if im_version_at_least?('6.9.0')
      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_6_9_10=1') if im_version_at_least?('6.9.10')
      $defs.push('-DIMAGEMAGICK_7=1') if im_version_at_least?('7.0.0')
      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_7_0_8=1') if im_version_at_least?('7.0.8')
      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_7_0_10=1') if im_version_at_least?('7.0.10')
      $defs.push('-DIMAGEMAGICK_GREATER_THAN_EQUAL_7_1_2=1') if im_version_at_least?('7.1.2')

      create_header
    end

    def create_makefile_file
      create_header_file

      # Force re-compilation if the generated Makefile changed.
      $config_h = 'Makefile'

      create_makefile('RMagick2')
      print_summary
    end

    def create_compile_flags_txt
      cppflags = $CPPFLAGS.split
      include_flags = cppflags.select { |flag| flag.start_with?('-I') }
      define_flags = cppflags.select { |flag| flag.start_with?('-D') } + $defs

      File.open('compile_flags.txt', 'w') do |f|
        include_flags.each { |flag| f.puts(flag) }
        f.puts "-I#{Dir.pwd}"
        f.puts "-I#{RbConfig::CONFIG['rubyhdrdir']}"
        f.puts "-I#{RbConfig::CONFIG['rubyhdrdir']}/ruby/backward"
        f.puts "-I#{RbConfig::CONFIG['rubyarchhdrdir']}"
        f.puts "-std=c++11"
        define_flags.each { |flag| f.puts(flag) }
      end
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
extconf.create_compile_flags_txt

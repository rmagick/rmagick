lib_dir = File.expand_path('../../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'rubygems'
require 'mkmf'
require 'date'
require 'singleton'
require 'pkg-config'

module RMagick
  class Extconf
    require 'rmagick/version'
    RMAGICK_VERS = ::Magick::VERSION
    MIN_RUBY_VERS = ::Magick::MIN_RUBY_VERSION
    MIN_RUBY_VERS_NO = MIN_RUBY_VERS.tr('.', '').to_i

    attr_reader :headers

    def initialize
      setup_paths_for_homebrew
      configure_compile_options
      assert_can_compile!
      configure_headers
    end

    def setup_paths_for_homebrew
      return unless find_executable('brew')

      brew_pkg_config_path = "#{`brew --prefix imagemagick@6`.strip}/lib/pkgconfig"
      pkgconfig_paths = ENV['PKG_CONFIG_PATH'].to_s.split(':')
      if File.exist?(brew_pkg_config_path) && !pkgconfig_paths.include?(brew_pkg_config_path)
        ENV['PKG_CONFIG_PATH'] = [ENV['PKG_CONFIG_PATH'], brew_pkg_config_path].compact.join(':')
      end
    end

    def configured_compile_options
      {
        with_magick_wand: RMagick::Config.instance.with_magick_wand?,
        magick_version: RMagick::Config.instance.version,
        local_libs: $LOCAL_LIBS,
        cflags: $CFLAGS,
        cppflags: $CPPFLAGS,
        ldflags: $LDFLAGS,
        defs: $defs,
        config_h: $config_h
      }
    end

    def configure_headers
      # headers = %w{assert.h ctype.h errno.h float.h limits.h math.h stdarg.h stddef.h stdint.h stdio.h stdlib.h string.h time.h}
      @headers = %w[assert.h ctype.h stdio.h stdlib.h math.h time.h]
      headers << 'stdint.h' if have_header('stdint.h') # defines uint64_t
      headers << 'sys/types.h' if have_header('sys/types.h')

      if have_header('wand/MagickWand.h')
        headers << 'wand/MagickWand.h'
      else
        exit_failure "\nCan't install RMagick #{RMAGICK_VERS}. Can't find MagickWand.h."
      end
    end

    def configure_compile_options
      # Magick-config is not available on Windows
      if RUBY_PLATFORM !~ /mswin|mingw/

        # Check for compiler. Extract first word so ENV['CC'] can be a program name with arguments.
        config = defined?(RbConfig) ? ::RbConfig : ::Config
        cc = (ENV['CC'] || config::CONFIG['CC'] || 'gcc').split(' ').first
        exit_failure "No C compiler found in ${ENV['PATH']}. See mkmf.log for details." unless find_executable(cc)

        check_multiple_imagemagick_versions
        check_partial_imagemagick_versions

        # Ensure minimum ImageMagick version
        # Check minimum ImageMagick version if possible
        checking_for("outdated ImageMagick version (<= #{Magick::MIN_IM_VERSION})") do
          Logging.message("Detected ImageMagick version: #{RMagick::Config.instance.version}\n")

          exit_failure "Can't install RMagick #{RMAGICK_VERS}. You must have ImageMagick #{Magick::MIN_IM_VERSION} or later.\n" if Gem::Version.new(RMagick::Config.instance.version) < Gem::Version.new(Magick::MIN_IM_VERSION)
        end

        $CFLAGS = ENV['CFLAGS'].to_s + ' ' + RMagick::Config.instance.cflags
        $CPPFLAGS = ENV['CPPFLAGS'].to_s + ' ' + RMagick::Config.instance.cflags
        $LDFLAGS = ENV['LDFLAGS'].to_s + ' ' + RMagick::Config.instance.libs
        $LOCAL_LIBS = ENV['LIBS'].to_s + ' ' + RMagick::Config.instance.libs

        set_archflags_for_osx if RUBY_PLATFORM =~ /darwin/ # osx

      elsif RUBY_PLATFORM =~ /mingw/ # mingw

        dir_paths = search_paths_for_library_for_windows
        $CPPFLAGS = %(-I"#{dir_paths[:include]}")
        $LDFLAGS = %(-L"#{dir_paths[:lib]}")

        have_library('CORE_RL_magick_')
        have_library('X11')

      else # mswin

        dir_paths = search_paths_for_library_for_windows
        $CPPFLAGS << %( -I"#{dir_paths[:include]}")
        $LDFLAGS << %( -libpath:"#{dir_paths[:lib]}")

        $LOCAL_LIBS = 'CORE_RL_magick_.lib'
        have_library('X11')

      end
    end

    # Test for a specific value in an enum type
    def have_enum_value(enum, value, headers = nil, &b)
      checking_for "#{enum}.#{value}" do
        if try_compile(<<"SRC", &b)
#{COMMON_HEADERS}
        #{cpp_include(headers)}
/*top*/
int main() { #{enum} t = #{value}; t = t; return 0; }
SRC
          $defs.push(format('-DHAVE_ENUM_%s', value.upcase))
          true
        else
          false
        end
      end
    end

    # Test for multiple values of the same enum type
    def have_enum_values(enum, values, headers = nil, &b)
      values.each do |value|
        have_enum_value(enum, value, headers, &b)
      end
    end

    def exit_failure(msg)
      Logging.message msg
      message msg + "\n"
      exit(1)
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

      msg = "\nWarning: Found a partial ImageMagick installation. Your operating system likely has some built-in ImageMagick libraries but not all of ImageMagick. This will most likely cause problems at both compile and runtime.\nFound partial installation at: " + prefix + "\n"
      Logging.message msg
      message msg
    end

    # issue #169
    # set ARCHFLAGS appropriately for OSX
    def set_archflags_for_osx
      archflags = []
      fullpath = `which convert`
      fileinfo = `file #{fullpath}`

      # default ARCHFLAGS
      archs = $ARCH_FLAG.scan(/-arch\s+(\S+)/).flatten

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
        lib_file = File.join(lib, 'CORE_RL_magick_.lib')
        next unless File.exist?(lib_file)

        dir_paths[:include] = File.join(dir, 'include')
        dir_paths[:lib] = lib

        found_lib = true
        break
      end

      return dir_paths if found_lib

      exit_failure <<END_MINGW
Can't install RMagick #{RMAGICK_VERS}.
Can't find the ImageMagick library.
Retry with '--with-opt-dir' option.
Usage: gem install rmagick -- '--with-opt-dir=\"[path to ImageMagick]\"'
e.g.
  gem install rmagick -- '--with-opt-dir=\"C:\Program Files\ImageMagick-6.9.1-Q16\"'
END_MINGW
    end

    def assert_can_compile!
      assert_minimum_ruby_version!
      assert_has_dev_libs!
    end

    def assert_minimum_ruby_version!
      unless checking_for("Ruby version >= #{MIN_RUBY_VERS}") do
        version = RUBY_VERSION.tr('.', '').to_i
        version >= MIN_RUBY_VERS_NO
      end
        exit_failure "Can't install RMagick #{RMAGICK_VERS}. Ruby #{MIN_RUBY_VERS} or later required.\n"
      end
    end

    def assert_has_dev_libs!
      return unless RUBY_PLATFORM !~ /mswin|mingw/

      unless RMagick::Config.instance.libs[/\bl\s*(MagickCore|Magick)6?\b/]
        exit_failure "Can't install RMagick #{RMAGICK_VERS}. " \
                   "Can't find the ImageMagick library or one of the dependent libraries. " \
                   "Check the mkmf.log file for more detailed information.\n"
      end
    end

    def create_header_file
      have_func('snprintf', headers)
      [
        'GetImageChannelEntropy', # 6.9.0-0
        'SetImageGray' # 6.9.1-10
      ].each do |func|
        have_func(func, headers)
      end

      have_type('long double', headers)

      headers = ['ruby.h', 'ruby/io.h']

      have_func('rb_frame_this_func', headers)

      # Miscellaneous constants
      $defs.push("-DRUBY_VERSION_STRING=\"ruby #{RUBY_VERSION}\"")
      $defs.push("-DRMAGICK_VERSION_STRING=\"RMagick #{RMAGICK_VERS}\"")

      create_header
    end

    def create_makefile_file
      create_header_file
      # Prior to 1.8.5 mkmf duplicated the symbols on the command line and in the
      # extconf.h header. Suppress that behavior by removing the symbol array.
      $defs = []

      # Force re-compilation if the generated Makefile changed.
      $config_h = 'Makefile rmagick.h'

      create_makefile('RMagick2')
      print_summary
    end

    def print_summary
      summary = <<"END_SUMMARY"


#{'=' * 70}
      #{DateTime.now.strftime('%a %d%b%y %T')}
This installation of RMagick #{RMAGICK_VERS} is configured for
Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM}) and ImageMagick #{$magick_version}
      #{'=' * 70}


END_SUMMARY

      Logging.message summary
      message summary
    end
  end

  class Config
    include Singleton

    def initialize
      @windows = !!(RUBY_PLATFORM =~ /mswin|mingw/)

      found = find_executable('pkg-config')
      @use_native_pkg_config = !!found

      checking_for("presence of MagickWand API (ImageMagick version >= #{Magick::MIN_WAND_VERSION})") do
        @magick_wand = Gem::Version.new(version) >= Gem::Version.new(Magick::MIN_WAND_VERSION)
        if @magick_wand
          Logging.message('Detected 6.9+ version, using MagickWand API')
        else
          Logging.message('Older version detected, using MagickCore API')
        end
      end
    end

    def windows?
      @windows
    end

    def native_pkg_config?
      @use_native_pkg_config
    end

    def with_magick_wand?
      @magick_wand
    end

    def module_name
      with_magick_wand? ? 'MagickWand' : 'MagickCore'
    end

    def version
      if windows?
        `identify -version` =~ /Version: ImageMagick (\d+\.\d+\.\d+)-+\d+ /
        abort 'Unable to get ImageMagick version' unless Regexp.last_match(1)
        return Regexp.last_match(1)
      end

      if native_pkg_config?
        `pkg-config #{module_name} --modversion`[/^(\d+\.\d+\.\d+)/]
      else
        PKGConfig.modversion(module_name)[/^(\d+\.\d+\.\d+)/]
      end
    end

    def cflags
      return if windows?

      if native_pkg_config?
        `pkg-config --cflags #{module_name}`.chomp
      else
        PKGConfig.cflags(module_name).chomp
      end
    end

    def libs
      return if windows?

      if native_pkg_config?
        `pkg-config --libs #{module_name}`.chomp
      else
        PKGConfig.libs(module_name).chomp
      end
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

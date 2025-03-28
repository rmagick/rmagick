RMagick
=======

[![GemVersion](https://img.shields.io/gem/v/rmagick.svg?style=flat)](https://rubygems.org/gems/rmagick)
![CI](https://github.com/rmagick/rmagick/workflows/CI/badge.svg)

Table of Contents
-----------------

-   [Introduction](#introduction)
-   [Prerequisites](#prerequisites)
-   [Installing RMagick](#installing-rmagick)
-   [Using RMagick](#using-rmagick)
-   [Things that can go wrong](#things-that-can-go-wrong)
-   [Upgrading](#upgrading)
-   [More samples](#more-samples)
-   [Reporting Bugs](#reporting-bugs)
-   [Development Setup](#development-setup)
-   [Credits](#credits)
-   [License](#mit-license)
-   [Releasing](#releasing)

Introduction
------------

RMagick is an interface between the Ruby programming language and the
ImageMagick image processing library.

Prerequisites
-------------

These prerequisites are required for the latest version of RMagick.

**OS**
- Linux
- \*BSD
- macOS
- Windows
- Other \*nix-like systems

**C++ compiler**
- RMagick 5.4.0 or later requires a C++ compiler.

**Ruby**
- Version 3.0 or later.

You can get Ruby from <https://www.ruby-lang.org>.

Ruby must be able to build C-Extensions (e.g. MRI, Rubinius, not JRuby)

**ImageMagick**
- Version 6.8.9 or later (6.x.x).
- Version 7.0.8 or later (7.x.x). Require RMagick 4.1.0 or later.

You can get ImageMagick from <https://imagemagick.org>.

### Linux
#### Ubuntu
On Ubuntu, you can run:

```sh
sudo apt-get install libmagickwand-dev
```

#### Centos
On Centos, you can run:

```sh
sudo yum install ImageMagick-devel
```

#### Arch Linux
On Arch Linux, you can run:

```sh
pacman -Syy imagemagick
```

#### Alpine Linux
On Alpine Linux, you can run:

```
apk add imagemagick imagemagick-dev imagemagick-libs
```

or you can run if you would like to use ImageMagick 6:

```
apk add imagemagick6 imagemagick6-dev imagemagick6-libs
```

### macOS
On macOS, you can run:

```sh
brew install imagemagick
```

or you can run if you would like to use ImageMagick 6:

```sh
brew install imagemagick@6
```

### Windows
1. Install latest Ruby+Devkit package which you can get from [RubyInstaller for Windows](https://rubyinstaller.org).
2. Download `ImageMagick-7.XXXX-Q16-x64-dll.exe` (not, `ImageMagick-7.XXXX-Q16-x64-static.exe`) binary from [Windows Binary Release](https://imagemagick.org/script/download.php#windows), or you can download ImageMagick 6 from [Windows Binary Release](https://legacy.imagemagick.org/script/download.php#windows).
3. Install ImageMagick. You need to turn on checkboxes `Add application directory to your system path` and `Install development headers for C and C++` in an installer for RMagick.
<img width="75%" src="https://github.com/rmagick/rmagick/assets/199156/494e7963-cca5-4cb5-b28a-6c4d76adce5d" />

If you want to install ImageMagick using [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/), run the following command:

```sh
winget install ImageMagick.ImageMagick --custom /TASKS=modifypath,install_Devel
```

If you want to install ImageMagick using [Chocolatey](https://chocolatey.org/), run the following command:

```sh
choco install imagemagick -PackageParameters InstallDevelopmentHeaders=true
```

Installing RMagick
------------------

### Installing via Bundler

Add to your `Gemfile`:

```rb
gem 'rmagick'
```

Then run:

```sh
bundle install
```

For Windows, you need to run using [ridk tool](https://github.com/oneclick/rubyinstaller2/wiki/The-ridk-tool):
```sh
ridk exec bundle install
```

### Installing via RubyGems

Run:

```sh
gem install rmagick
```

For Windows, you need to run using [ridk tool](https://github.com/oneclick/rubyinstaller2/wiki/The-ridk-tool):
```sh
ridk exec gem install rmagick
```

### Versioning

RMagick is versioned according to Semantic Versioning. For stable version
compatible with Ruby 3.0+, use `~> 3.0`. Versions >= 6 work on Ruby >= 3.x
only.

Using RMagick
-------------

Require RMagick in your project as follows:

```rb
require 'rmagick'
```

See <https://rmagick.github.io/usage.html> for links to more information.

Things that can go wrong
------------------------

The [RMagick installation FAQ][faq] has answers to the most commonly reported
problems, though may be out of date.

### Can't install RMagick. Can't find libMagickCore-XXXX.so or one of the dependent libraries. Check the mkmf.log file for more detailed information

Typically this message means that one or more of the libraries that ImageMagick
depends on hasn't been installed. Examine the mkmf.log file in the ext/RMagick
subdirectory of the installation directory for any error messages. These
messages typically contain enough additional information for you to be able to
diagnose the problem. Also see [this FAQ][libmagick-faq].

### Cannot open shared object file

If you get a message like this:

```sh
... /core_ext/kernel_require.rb>:136:in `require': cannot load such file -- RMagick2.so (LoadError)
  (snip)
```

you probably do not have the directory in which the ImageMagick library
is installed in your load path. An easy way to fix this is to define
the directory in the `LD_LIBRARY_PATH` environment variable. For
example, suppose you installed the ImageMagick library `libMagickCore-XXXX.so` in
`/usr/local/lib`. (By default this is where it is installed.) Create the
`LD_LIBRARY_PATH` variable like this:

```sh
export LD_LIBRARY_PATH=/usr/local/lib
```

On Linux, see `ld(1)` and `ld.so(8)` for more information. On other operating
systems, see the documentation for the dynamic loading facility.

This operation might not be required when you can use 4.2.5 or later.

### Segmentation fault

Default stack size of your operating system might be too small. Try removing
the limit with this command:

```sh
ulimit -s unlimited
```

Upgrading
---------

If you upgrade to a newer release of ImageMagick, make sure you're using a
release of RMagick that supports that release. It's safe to install a new
release of RMagick over an earlier release.

More samples
------------

You can find more sample RMagick programs in the [/examples](https://github.com/rmagick/rmagick/tree/main/examples) and [/doc/ex](https://github.com/rmagick/rmagick/tree/main/doc/ex) directories. These
programs are not installed in the RMagick documentation tree.

Reporting bugs
--------------

Please report bugs in RMagick, its documentation, or its installation programs
via the bug tracker on the [RMagick issues page][issues].

However, We can't help with Ruby installation and configuration or ImageMagick
installation and configuration. Information about reporting problems and
getting help for ImageMagick is available at the [ImageMagick
website][imagemagick] or the [ImageMagick Forum][imagemagick-forum].

Development Setup
-----------------

In order to minimize issues on your local machine, we recommend that you make
use of a [Vagrant installation][dev-box].

Steps to get up and running with a passing build are as follows:

### 1) set up the Vagrant environment

If you don't already have Vagrant installed, you can download and install it
from [here][vagrant]. Once installed, we can set up a pre-built environment:

```sh
git clone https://github.com/tjschuck/rake-compiler-dev-box.git
cd rake-compiler-dev-box
vagrant up
```

This last part will probably take a while as it has to download an Ubuntu image
and configure it. If there is an error during this process, you may need to
reboot your computer and enable virtualization in your BIOS settings.

### 2) clone RMagick and log in to the vagrant box

Within the `rake-compiler-dev-box` directory:

```sh
git clone https://github.com/rmagick/rmagick.git # or your fork
vagrant ssh
```

### 3) install ImageMagick and additional environment stuff

```sh
cd /vagrant/rmagick
export IMAGEMAGICK_VERSION=6.8.9-10
bash ./before_install_linux.sh
```

This will take just a few minutes to build ImageMagick

### 4) build RMagick

```sh
rake
```

This compiles the RMagick extensions and runs the tests. If all goes well
you'll see a lot of output, eventually ending in something like:

```sh
Finished tests in 35.865734s, 11.3758 tests/s, 6560.3007 assertions/s.

408 tests, 235290 assertions, 0 failures, 0 errors, 0 skips
```

And you're all set! The copy of RMagick within `/vagrant/rmagick` inside your
Vagrant session is the same as the one in the `rake-compiler-dev-box` directory
on your machine. You can make changes locally and run tests within your `ssh`
session.

Credits
-------

**Authors:** Tim Hunter, Omer Bar-or, Benjamin Thomas

Thanks to [ImageMagick Studio LLC][imagemagick] for ImageMagick and for hosting
the RMagick documentation.

License
-----------

[MIT License](LICENSE)

Releasing
---------

See <https://github.com/rmagick/rmagick/wiki/Release-Process>

1.  Update ChangeLog
2.  Edit `lib/rmagick/version.rb`
3.  Are the tests passing? Run `rake` again just to be sure.
4.  `rake release`

[issues]: https://github.com/rmagick/rmagick/issues
[libmagick-faq]: https://web.archive.org/web/20140512193354/https://rmagick.rubyforge.org/install-faq.html#libmagick
[faq]: https://web.archive.org/web/20140512193354/https://rmagick.rubyforge.org/install-faq.html
[imagemagick]: https://imagemagick.org
[imagemagick-forum]: https://imagemagick.org/discourse-server
[dev-box]: https://github.com/tjschuck/rake-compiler-dev-box
[vagrant]: https://www.vagrantup.com/

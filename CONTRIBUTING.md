RMagick Contributor's Guide
===========================

Welcome
-------

Thank you for considering contributing to RMagick. Your contribution is always welcome and appreciated!

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.


Background
----------

RMagick is a Ruby gem with a C extension. The extension wraps the ImageMagick C library. Therefore, the following document may be helpful to you:

[Running C in Ruby](http://silverhammermba.github.io/emberb/extend/)


Priorities
----------

1. Green build of the gem on all operating systems. You can see the current build state on [the project page at Travis CI](https://travis-ci.org/rmagick/rmagick). You are welcome to improve it.
2. [Open issues](https://github.com/rmagick/rmagick/issues). You are welcome to reproduce them, report current state, suggest solutions, open pull requests with fixes. If you don't know where to start, sort issues by least recently updated. You can also [subscribe to receive random issues by email](http://www.codetriage.com/rmagick/rmagick).


Testing
-------

Our goal is to migrate to [RSpec](http://rspec.info).

If you write new tests, please do it in RSpec.

You are also welcome to convert existing Test/Unit tests to RSpec.


Committing
----------

All work for a next release is done in the `develop` branch. Please create your branch off of it.

It is better if you follow [Git Style Guide](https://github.com/agis-/git-style-guide).


Pull Requests
-------------

Please choose the `rmagick/rmagick` repo and the `develop` branch as the destination for your pull request.

NOTE: GitHub suggests `rmagick-temp/rmagick` repo by default. **This is incorrect.** Please switch to `rmagick/rmagick`. It should be the next repo in the drop-down list.

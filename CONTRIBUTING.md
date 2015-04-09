RMagick Contributor's Guide
===========================

Welcome
-------

Thank you for considering contributing to RMagick. Your contribution is always welcome and appreciated!


Background
----------

RMagick is a Ruby gem with a C extension. The extension wraps the ImageMagick C library. Therefore, the following document may be helpful to you:

[Running C in Ruby](http://silverhammermba.github.io/emberb/extend/)


Priorities
----------

1. Green build of the gem on all operating systems. You can see the current build state on [the project page at Travis CI](https://travis-ci.org/gemhome/rmagick). You are welcome to improve it.
2. [Open issues](https://github.com/gemhome/rmagick/issues). You are welcome to reproduce them, report current state, suggest solutions, open pull requests with fixes.


Testing
-------

Our goal is to migrate to [RSpec](http://rspec.info).

If you write new tests, please do it in RSpec. You can use the `spec_it` branch as a base for yours.

You are also welcome to convert existing Test/Unit tests to RSpec.


Committing
----------

It is better if you follow [Git Style Guide](https://github.com/agis-/git-style-guide).

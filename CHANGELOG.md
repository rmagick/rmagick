# Change Log

## [Unreleased](https://github.com/gemhome/rmagick/tree/HEAD)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-13-4...HEAD)

**Closed issues:**

- Bundle install doesn't work!\(OS X Yosemite 10.10.2\) [\#169](https://github.com/gemhome/rmagick/issues/169)

- Unable to install rmagick on Mac OS X Yosemite \(10.10.2\) [\#168](https://github.com/gemhome/rmagick/issues/168)

- Magick::QuantumDepth is now missing [\#167](https://github.com/gemhome/rmagick/issues/167)

- Support -Werror=format-security [\#166](https://github.com/gemhome/rmagick/issues/166)

- The rmagick not install in Windows7 64bit rails 4.2.0 and ruby 2.1.5 [\#165](https://github.com/gemhome/rmagick/issues/165)

- Cannot build old versions of ImageMagick locally [\#163](https://github.com/gemhome/rmagick/issues/163)

- Image corruption during BGRA conversion [\#159](https://github.com/gemhome/rmagick/issues/159)

- Versio [\#149](https://github.com/gemhome/rmagick/issues/149)

- Rmagick 2.13.4 compile error [\#148](https://github.com/gemhome/rmagick/issues/148)

- Adopt a code style guide [\#58](https://github.com/gemhome/rmagick/issues/58)

- Prevent failure when "prefix" is empty string. [\#43](https://github.com/gemhome/rmagick/issues/43)

- JRuby RMagic undefined\_symbol: rb\_framce\_last\_func [\#33](https://github.com/gemhome/rmagick/issues/33)

- Cannot compile on Slackware 13.1; complains of 'partial' ImageMagick [\#12](https://github.com/gemhome/rmagick/issues/12)

- Removed the SplineInterpolatePixel check [\#8](https://github.com/gemhome/rmagick/issues/8)

**Merged pull requests:**

- more robust \#177\(Fix for ImageMagick 404\) [\#181](https://github.com/gemhome/rmagick/pull/181) ([u338steven](https://github.com/u338steven))

- Fixed escaping of '%' sign in get\_type\_metrics [\#179](https://github.com/gemhome/rmagick/pull/179) ([mkluczny](https://github.com/mkluczny))

- Fix for ImageMagick 404 [\#177](https://github.com/gemhome/rmagick/pull/177) ([mockdeep](https://github.com/mockdeep))

- The Great Indentation Fix of 2015 [\#174](https://github.com/gemhome/rmagick/pull/174) ([vassilevsky](https://github.com/vassilevsky))

- fix: in `require': cannot load such file -- rmagick/version \(LoadError\) [\#172](https://github.com/gemhome/rmagick/pull/172) ([u338steven](https://github.com/u338steven))

- set ARCHFLAGS appropriately for OSX \(\#169\) [\#170](https://github.com/gemhome/rmagick/pull/170) ([u338steven](https://github.com/u338steven))

- add documentation to readme for setting up dev env [\#164](https://github.com/gemhome/rmagick/pull/164) ([mockdeep](https://github.com/mockdeep))

- Change all require RMagick to rmagick [\#157](https://github.com/gemhome/rmagick/pull/157) ([bf4](https://github.com/bf4))

- Fix \#148; More robust feature detection [\#156](https://github.com/gemhome/rmagick/pull/156) ([bf4](https://github.com/bf4))

- Let 1.8 fail [\#155](https://github.com/gemhome/rmagick/pull/155) ([bf4](https://github.com/bf4))

- Make extconf.rb \(a little\) easier to understand [\#154](https://github.com/gemhome/rmagick/pull/154) ([bf4](https://github.com/bf4))

- 1.8 compatibility changes [\#153](https://github.com/gemhome/rmagick/pull/153) ([bf4](https://github.com/bf4))

- only require rubocop on ruby versions \>= 1.9.2 [\#151](https://github.com/gemhome/rmagick/pull/151) ([mockdeep](https://github.com/mockdeep))

- set up simplecov [\#147](https://github.com/gemhome/rmagick/pull/147) ([mockdeep](https://github.com/mockdeep))

- move deprecated RMagick.rb file [\#141](https://github.com/gemhome/rmagick/pull/141) ([mockdeep](https://github.com/mockdeep))

- adding rubocop [\#138](https://github.com/gemhome/rmagick/pull/138) ([mockdeep](https://github.com/mockdeep))

- Support Ruby 1.8 [\#152](https://github.com/gemhome/rmagick/pull/152) ([vassilevsky](https://github.com/vassilevsky))

- Fixed expected number colors in Image\_attributes\#test\_colors [\#134](https://github.com/gemhome/rmagick/pull/134) ([rajsahae](https://github.com/rajsahae))

## [RMagick_2-13-4](https://github.com/gemhome/rmagick/tree/RMagick_2-13-4) (2014-11-26)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-13-3...RMagick_2-13-4)

**Fixed bugs:**

- test\_hash\(Pixel\_UT\) in Pixel.rb fails [\#88](https://github.com/gemhome/rmagick/issues/88)

- test\_from\_hsla\(Pixel\_UT\) in Pixel.rb fails [\#87](https://github.com/gemhome/rmagick/issues/87)

- test\_tmpnam\(Magick\_UT\) in Magick.rb fails [\#86](https://github.com/gemhome/rmagick/issues/86)

- test\_limit\_resources\(Magick\_UT\) in Magick.rb fails [\#85](https://github.com/gemhome/rmagick/issues/85)

- test\_formats\(Magick\_UT\) in Magick.rb fails [\#84](https://github.com/gemhome/rmagick/issues/84)

- test\_import\_export\(Import\_Export\_UT\) in Import\_Export.rb fails [\#83](https://github.com/gemhome/rmagick/issues/83)

- test\_y\_resolution\(Image\_Attributes\_UT\) in Image\_attributes.rb fails [\#82](https://github.com/gemhome/rmagick/issues/82)

- test\_x\_resolution\(Image\_Attributes\_UT\) in Image\_attributes.rb fails [\#81](https://github.com/gemhome/rmagick/issues/81)

- test\_total\_colors\(Image\_Attributes\_UT\) in Image\_attributes.rb fails [\#80](https://github.com/gemhome/rmagick/issues/80)

- test\_rendering\_intent\(Image\_Attributes\_UT\) in Image\_attributes.rb fails [\#79](https://github.com/gemhome/rmagick/issues/79)

- test\_number\_colors\(Image\_Attributes\_UT\) in Image\_attributes.rb fails [\#78](https://github.com/gemhome/rmagick/issues/78)

- test\_gamma\(Image\_Attributes\_UT\) in Image\_attributes.rb fails [\#77](https://github.com/gemhome/rmagick/issues/77)

- test\_density\(Image\_Attributes\_UT\) in Image\_attributes.rb fails [\#76](https://github.com/gemhome/rmagick/issues/76)

- test\_colorspace\(Image\_Attributes\_UT\) in Image\_attributes.rb fails [\#75](https://github.com/gemhome/rmagick/issues/75)

- test\_resample\(Image3\_UT\) in Image3.rb fails [\#74](https://github.com/gemhome/rmagick/issues/74)

- test\_each\_profile\(Image2\_UT\) in Image2.rb fails [\#73](https://github.com/gemhome/rmagick/issues/73)

- test\_convolve\(Image2\_UT\) in Image2.rb fails [\#72](https://github.com/gemhome/rmagick/issues/72)

**Closed issues:**

- Let GitCop review commit messages in pull requests [\#144](https://github.com/gemhome/rmagick/issues/144)

- Native extension building fails for Debian Jessie [\#130](https://github.com/gemhome/rmagick/issues/130)

- lib/RMagick.rb is overwritten by lib/rmagick.rb on case-insensitive systems. [\#122](https://github.com/gemhome/rmagick/issues/122)

- sizeof\(DrawInfo\) is incorrect [\#110](https://github.com/gemhome/rmagick/issues/110)

- solid fill class [\#65](https://github.com/gemhome/rmagick/issues/65)

- Fixed build error with ImageMagick 6.8.8 and Ruby 2.0 [\#61](https://github.com/gemhome/rmagick/issues/61)

- nvert -version [\#49](https://github.com/gemhome/rmagick/issues/49)

- close [\#48](https://github.com/gemhome/rmagick/issues/48)

- Text cropped during generation [\#47](https://github.com/gemhome/rmagick/issues/47)

- Lack of license  [\#44](https://github.com/gemhome/rmagick/issues/44)

- More in Stackoverflow [\#35](https://github.com/gemhome/rmagick/issues/35)

- Code reorganization [\#34](https://github.com/gemhome/rmagick/issues/34)

- Test suite fails using Ruby 1.9.3 and ImageMagick 6.7.1.9 [\#28](https://github.com/gemhome/rmagick/issues/28)

- Test fails on 64b system [\#27](https://github.com/gemhome/rmagick/issues/27)

- Test suite is not compatible with Ruby 1.9.3 [\#26](https://github.com/gemhome/rmagick/issues/26)

- rmagick 1.15.17 Failed Install on Mac OS X [\#18](https://github.com/gemhome/rmagick/issues/18)

- ruby 1.9.2, ImageMagick 6.6.9, RMagick 2.13.1, Mac OS 10.6 [\#17](https://github.com/gemhome/rmagick/issues/17)

- Rmagick fails to require lcms-2.1 [\#16](https://github.com/gemhome/rmagick/issues/16)

- vector density on read [\#15](https://github.com/gemhome/rmagick/issues/15)

- Problems installing with homebrew \(and not macports\) [\#14](https://github.com/gemhome/rmagick/issues/14)

- Rmagick + Rails 3 [\#11](https://github.com/gemhome/rmagick/issues/11)

- uninitialized constant Magick::Hatchfill \(NameError\) [\#10](https://github.com/gemhome/rmagick/issues/10)

- Segfaults w/ 1.9.2 and threads [\#9](https://github.com/gemhome/rmagick/issues/9)

- could/should cycle through converts [\#7](https://github.com/gemhome/rmagick/issues/7)

- Can't install rmagick [\#6](https://github.com/gemhome/rmagick/issues/6)

- can't install rmagick on cygwin with ruby 1.8.7 \(2008-08-11 patchlevel 72\) \[i386-cygwin\] [\#4](https://github.com/gemhome/rmagick/issues/4)

- Could you please post a binary for ruby 1.9.1 on win32!? [\#3](https://github.com/gemhome/rmagick/issues/3)

- Problem with ruby 1.9.2 on Snow Leopard [\#2](https://github.com/gemhome/rmagick/issues/2)

**Merged pull requests:**

- fix path for build [\#142](https://github.com/gemhome/rmagick/pull/142) ([mockdeep](https://github.com/mockdeep))

- Fix wrong relative path for lib/rmagick/version [\#139](https://github.com/gemhome/rmagick/pull/139) ([marwan-tanager](https://github.com/marwan-tanager))

- Add Contributor's Guide [\#136](https://github.com/gemhome/rmagick/pull/136) ([vassilevsky](https://github.com/vassilevsky))

- Green OS X Build [\#133](https://github.com/gemhome/rmagick/pull/133) ([vassilevsky](https://github.com/vassilevsky))

- Enable builds on OS X [\#131](https://github.com/gemhome/rmagick/pull/131) ([vassilevsky](https://github.com/vassilevsky))

- proof of concept for using pkg-config in place of Magick-config on debian based systems [\#129](https://github.com/gemhome/rmagick/pull/129) ([theschoolmaster](https://github.com/theschoolmaster))

- Fixed: test\_limit\_resources \(Magick\_UT\) in Magick.rb fails \#126 [\#128](https://github.com/gemhome/rmagick/pull/128) ([u338steven](https://github.com/u338steven))

- Changed Image\#resample to calling ResampleImage \(related \#29, \#45\) [\#127](https://github.com/gemhome/rmagick/pull/127) ([u338steven](https://github.com/u338steven))

- Fixed \#83: test\_import\_export\(Import\_Export\_UT\) in Import\_Export.rb fails [\#125](https://github.com/gemhome/rmagick/pull/125) ([u338steven](https://github.com/u338steven))

- Fixed \#122: lib/RMagick.rb is overwritten by lib/rmagick.rb on case-insensitive systems [\#124](https://github.com/gemhome/rmagick/pull/124) ([u338steven](https://github.com/u338steven))

- New class SolidFill in order to fill image with monochromatic background [\#123](https://github.com/gemhome/rmagick/pull/123) ([prijutme4ty](https://github.com/prijutme4ty))

- Quotes for correct path of font file [\#121](https://github.com/gemhome/rmagick/pull/121) ([markotom](https://github.com/markotom))

- Allow MagickCore6 from Magick-config [\#120](https://github.com/gemhome/rmagick/pull/120) ([chulkilee](https://github.com/chulkilee))

- Fixed: test\_from\_hsla\(Pixel\_UT\) in Pixel.rb fails \#87 [\#119](https://github.com/gemhome/rmagick/pull/119) ([u338steven](https://github.com/u338steven))

- Revert "Fixed: crash trying to 'test\_monitor' on Windows\(x64\)" [\#118](https://github.com/gemhome/rmagick/pull/118) ([u338steven](https://github.com/u338steven))

- Fixed: crash trying to 'test\_write' on Windows \(Image3.rb, ImageList2.rb\) [\#117](https://github.com/gemhome/rmagick/pull/117) ([u338steven](https://github.com/u338steven))

- Fixed: test\_from\_blob\(ImageList2\_UT\) in ImageList2.rb fails \(on Windows\) [\#115](https://github.com/gemhome/rmagick/pull/115) ([u338steven](https://github.com/u338steven))

- Fixed: crash trying to 'test\_monitor' on Windows\(x64\) [\#114](https://github.com/gemhome/rmagick/pull/114) ([u338steven](https://github.com/u338steven))

- Fixed: test\_each\_profile\(Image2\_UT\) in Image2.rb fails \#73 [\#113](https://github.com/gemhome/rmagick/pull/113) ([u338steven](https://github.com/u338steven))

- Fixed: build error with ImageMagick 6.8.9 \(when deprecated functions are excluded\) [\#112](https://github.com/gemhome/rmagick/pull/112) ([u338steven](https://github.com/u338steven))

- Fixed: crash trying to 'test\_formats' on Windows.\(Magick.rb\) [\#111](https://github.com/gemhome/rmagick/pull/111) ([u338steven](https://github.com/u338steven))

- Fixed: test\_total\_colors\(Image\_Attributes\_UT\) in Image\_attributes.rb fails \#80 [\#109](https://github.com/gemhome/rmagick/pull/109) ([u338steven](https://github.com/u338steven))

- Fixed: test\_number\_colors\(Image\_Attributes\_UT\) in Image\_attributes.rb fails \#78 [\#108](https://github.com/gemhome/rmagick/pull/108) ([u338steven](https://github.com/u338steven))

- Fixed: test\_gamma\(Image\_Attributes\_UT\) in Image\_attributes.rb fails \#77 [\#107](https://github.com/gemhome/rmagick/pull/107) ([u338steven](https://github.com/u338steven))

- Fixed: test\_rendering\_intent\(Image\_Attributes\_UT\) in Image\_attributes.rb fails \#79 [\#106](https://github.com/gemhome/rmagick/pull/106) ([u338steven](https://github.com/u338steven))

- Fixed: related x\_resolution, y\_resolution [\#102](https://github.com/gemhome/rmagick/pull/102) ([u338steven](https://github.com/u338steven))

- Fixed: test\_colorspace\(Image\_Attributes\_UT\) in Image\_attributes.rb fails \#75 [\#101](https://github.com/gemhome/rmagick/pull/101) ([u338steven](https://github.com/u338steven))

- Fixed: test\_resample\(Image3\_UT\) in Image3.rb fails \#74 [\#100](https://github.com/gemhome/rmagick/pull/100) ([u338steven](https://github.com/u338steven))

- Fixed: test\_export\_pixels\_to\_str\(Image2\_UT\) in Image2.rb fails [\#99](https://github.com/gemhome/rmagick/pull/99) ([u338steven](https://github.com/u338steven))

- Fixed: test\_convolve\(Image2\_UT\) in Image2.rb fails \#72 [\#98](https://github.com/gemhome/rmagick/pull/98) ([u338steven](https://github.com/u338steven))

- Move @@tmpnam test to a separate file for isolation [\#97](https://github.com/gemhome/rmagick/pull/97) ([vassilevsky](https://github.com/vassilevsky))

- Fixed: build error with ImageMagick 6.8.8 [\#96](https://github.com/gemhome/rmagick/pull/96) ([u338steven](https://github.com/u338steven))

- Fix pixel hash test [\#95](https://github.com/gemhome/rmagick/pull/95) ([vassilevsky](https://github.com/vassilevsky))

- Fixed: build error on Windows Ruby x64 \(with ImageMagick 6.8.0-10 or Ima... [\#94](https://github.com/gemhome/rmagick/pull/94) ([u338steven](https://github.com/u338steven))

- Do not test machine and OS-specific integers [\#91](https://github.com/gemhome/rmagick/pull/91) ([vassilevsky](https://github.com/vassilevsky))

- Tidy up the README [\#89](https://github.com/gemhome/rmagick/pull/89) ([linduxed](https://github.com/linduxed))

- Continuous Integration \(Linux\) [\#70](https://github.com/gemhome/rmagick/pull/70) ([vassilevsky](https://github.com/vassilevsky))

- Remove build support for RAA and rubyforge; annotate Rake tasks [\#69](https://github.com/gemhome/rmagick/pull/69) ([bf4](https://github.com/bf4))

- line [\#146](https://github.com/gemhome/rmagick/pull/146) ([vassilevsky](https://github.com/vassilevsky))

- line [\#145](https://github.com/gemhome/rmagick/pull/145) ([vassilevsky](https://github.com/vassilevsky))

- Add a Gitter chat badge to README.md [\#143](https://github.com/gemhome/rmagick/pull/143) ([gitter-badger](https://github.com/gitter-badger))

- Add a badge with the number of references to the gem from other gems [\#137](https://github.com/gemhome/rmagick/pull/137) ([vassilevsky](https://github.com/vassilevsky))

- Fix invalid script in .travis.yml [\#132](https://github.com/gemhome/rmagick/pull/132) ([bf4](https://github.com/bf4))

- Update to releases directory [\#105](https://github.com/gemhome/rmagick/pull/105) ([dtykocki](https://github.com/dtykocki))

- Test multiple versions of ImageMagic. [\#103](https://github.com/gemhome/rmagick/pull/103) ([ioquatix](https://github.com/ioquatix))

- Add "Contributing" section to README and add Hound configuration [\#71](https://github.com/gemhome/rmagick/pull/71) ([linduxed](https://github.com/linduxed))

## [RMagick_2-13-3](https://github.com/gemhome/rmagick/tree/RMagick_2-13-3) (2014-08-01)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-13-2...RMagick_2-13-3)

## [RMagick_2-13-2](https://github.com/gemhome/rmagick/tree/RMagick_2-13-2) (2013-02-02)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-13-1...RMagick_2-13-2)

## [RMagick_2-13-1](https://github.com/gemhome/rmagick/tree/RMagick_2-13-1) (2010-04-05)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-13-0...RMagick_2-13-1)

## [RMagick_2-13-0](https://github.com/gemhome/rmagick/tree/RMagick_2-13-0) (2009-12-24)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-12-2...RMagick_2-13-0)

## [RMagick_2-12-2](https://github.com/gemhome/rmagick/tree/RMagick_2-12-2) (2009-10-10)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-12-1...RMagick_2-12-2)

## [RMagick_2-12-1](https://github.com/gemhome/rmagick/tree/RMagick_2-12-1) (2009-10-05)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-12-0...RMagick_2-12-1)

## [RMagick_2-12-0](https://github.com/gemhome/rmagick/tree/RMagick_2-12-0) (2009-10-03)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-11-1...RMagick_2-12-0)

## [RMagick_2-11-1](https://github.com/gemhome/rmagick/tree/RMagick_2-11-1) (2009-09-05)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-11-0...RMagick_2-11-1)

## [RMagick_2-11-0](https://github.com/gemhome/rmagick/tree/RMagick_2-11-0) (2009-07-29)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-10-0...RMagick_2-11-0)

## [RMagick_2-10-0](https://github.com/gemhome/rmagick/tree/RMagick_2-10-0) (2009-06-19)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-9-2...RMagick_2-10-0)

## [RMagick_2-9-2](https://github.com/gemhome/rmagick/tree/RMagick_2-9-2) (2009-05-13)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-9-1...RMagick_2-9-2)

## [RMagick_2-9-1](https://github.com/gemhome/rmagick/tree/RMagick_2-9-1) (2009-02-01)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-9-0...RMagick_2-9-1)

## [RMagick_2-9-0](https://github.com/gemhome/rmagick/tree/RMagick_2-9-0) (2009-01-13)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-0-updates...RMagick_2-9-0)

## [RMagick_1-15-0-updates](https://github.com/gemhome/rmagick/tree/RMagick_1-15-0-updates) (2008-12-05)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-17...RMagick_1-15-0-updates)

## [RMagick_1-15-17](https://github.com/gemhome/rmagick/tree/RMagick_1-15-17) (2008-12-05)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-8-0...RMagick_1-15-17)

## [RMagick_2-8-0](https://github.com/gemhome/rmagick/tree/RMagick_2-8-0) (2008-12-04)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-16...RMagick_2-8-0)

## [RMagick_1-15-16](https://github.com/gemhome/rmagick/tree/RMagick_1-15-16) (2008-11-25)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-7-2...RMagick_1-15-16)

## [RMagick_2-7-2](https://github.com/gemhome/rmagick/tree/RMagick_2-7-2) (2008-11-13)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-7-1...RMagick_2-7-2)

## [RMagick_2-7-1](https://github.com/gemhome/rmagick/tree/RMagick_2-7-1) (2008-11-01)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-7-0...RMagick_2-7-1)

## [RMagick_2-7-0](https://github.com/gemhome/rmagick/tree/RMagick_2-7-0) (2008-09-28)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-15...RMagick_2-7-0)

## [RMagick_1-15-15](https://github.com/gemhome/rmagick/tree/RMagick_1-15-15) (2008-09-10)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-6-0...RMagick_1-15-15)

## [RMagick_2-6-0](https://github.com/gemhome/rmagick/tree/RMagick_2-6-0) (2008-09-10)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-5-2...RMagick_2-6-0)

## [RMagick_2-5-2](https://github.com/gemhome/rmagick/tree/RMagick_2-5-2) (2008-07-13)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-5-1...RMagick_2-5-2)

## [RMagick_2-5-1](https://github.com/gemhome/rmagick/tree/RMagick_2-5-1) (2008-06-21)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-5-0...RMagick_2-5-1)

## [RMagick_2-5-0](https://github.com/gemhome/rmagick/tree/RMagick_2-5-0) (2008-06-08)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-4-0...RMagick_2-5-0)

## [RMagick_2-4-0](https://github.com/gemhome/rmagick/tree/RMagick_2-4-0) (2008-06-02)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-14...RMagick_2-4-0)

## [RMagick_1-15-14](https://github.com/gemhome/rmagick/tree/RMagick_1-15-14) (2008-05-05)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-3-0...RMagick_1-15-14)

## [RMagick_2-3-0](https://github.com/gemhome/rmagick/tree/RMagick_2-3-0) (2008-03-29)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-13...RMagick_2-3-0)

## [RMagick_1-15-13](https://github.com/gemhome/rmagick/tree/RMagick_1-15-13) (2008-02-14)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-2-2...RMagick_1-15-13)

## [RMagick_2-2-2](https://github.com/gemhome/rmagick/tree/RMagick_2-2-2) (2008-02-13)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-2-0...RMagick_2-2-2)

## [RMagick_2-2-0](https://github.com/gemhome/rmagick/tree/RMagick_2-2-0) (2008-01-31)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-1-0...RMagick_2-2-0)

## [RMagick_2-1-0](https://github.com/gemhome/rmagick/tree/RMagick_2-1-0) (2008-01-09)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_2-0-0...RMagick_2-1-0)

## [RMagick_2-0-0](https://github.com/gemhome/rmagick/tree/RMagick_2-0-0) (2007-12-27)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-12...RMagick_2-0-0)

## [RMagick_1-15-12](https://github.com/gemhome/rmagick/tree/RMagick_1-15-12) (2007-12-26)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-11...RMagick_1-15-12)

## [RMagick_1-15-11](https://github.com/gemhome/rmagick/tree/RMagick_1-15-11) (2007-11-25)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-10...RMagick_1-15-11)

## [RMagick_1-15-10](https://github.com/gemhome/rmagick/tree/RMagick_1-15-10) (2007-09-16)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-0-fixes...RMagick_1-15-10)

## [RMagick_1-15-0-fixes](https://github.com/gemhome/rmagick/tree/RMagick_1-15-0-fixes) (2007-08-09)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-9...RMagick_1-15-0-fixes)

## [RMagick_1-15-9](https://github.com/gemhome/rmagick/tree/RMagick_1-15-9) (2007-08-09)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-8...RMagick_1-15-9)

## [RMagick_1-15-8](https://github.com/gemhome/rmagick/tree/RMagick_1-15-8) (2007-07-31)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-7...RMagick_1-15-8)

## [RMagick_1-15-7](https://github.com/gemhome/rmagick/tree/RMagick_1-15-7) (2007-06-09)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-6...RMagick_1-15-7)

## [RMagick_1-15-6](https://github.com/gemhome/rmagick/tree/RMagick_1-15-6) (2007-04-25)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-5...RMagick_1-15-6)

## [RMagick_1-15-5](https://github.com/gemhome/rmagick/tree/RMagick_1-15-5) (2007-03-31)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-4...RMagick_1-15-5)

## [RMagick_1-15-4](https://github.com/gemhome/rmagick/tree/RMagick_1-15-4) (2007-03-04)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-3...RMagick_1-15-4)

## [RMagick_1-15-3](https://github.com/gemhome/rmagick/tree/RMagick_1-15-3) (2007-02-19)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-2...RMagick_1-15-3)

## [RMagick_1-15-2](https://github.com/gemhome/rmagick/tree/RMagick_1-15-2) (2007-02-04)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-1...RMagick_1-15-2)

## [RMagick_1-15-1](https://github.com/gemhome/rmagick/tree/RMagick_1-15-1) (2007-02-01)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-15-0...RMagick_1-15-1)

## [RMagick_1-15-0](https://github.com/gemhome/rmagick/tree/RMagick_1-15-0) (2007-01-20)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-14-1...RMagick_1-15-0)

## [RMagick_1-14-1](https://github.com/gemhome/rmagick/tree/RMagick_1-14-1) (2006-10-21)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-13-0...RMagick_1-14-1)

## [RMagick_1-13-0](https://github.com/gemhome/rmagick/tree/RMagick_1-13-0) (2006-06-28)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-12-0...RMagick_1-13-0)

## [RMagick_1-12-0](https://github.com/gemhome/rmagick/tree/RMagick_1-12-0) (2006-06-03)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-11-1...RMagick_1-12-0)

## [RMagick_1-11-1](https://github.com/gemhome/rmagick/tree/RMagick_1-11-1) (2006-05-27)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-11-0...RMagick_1-11-1)

## [RMagick_1-11-0](https://github.com/gemhome/rmagick/tree/RMagick_1-11-0) (2006-05-11)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-10-1...RMagick_1-11-0)

## [RMagick_1-10-1](https://github.com/gemhome/rmagick/tree/RMagick_1-10-1) (2006-02-25)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-10-0...RMagick_1-10-1)

## [RMagick_1-10-0](https://github.com/gemhome/rmagick/tree/RMagick_1-10-0) (2006-01-21)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-9-3...RMagick_1-10-0)

## [RMagick_1-9-3](https://github.com/gemhome/rmagick/tree/RMagick_1-9-3) (2005-10-17)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-9-2...RMagick_1-9-3)

## [RMagick_1-9-2](https://github.com/gemhome/rmagick/tree/RMagick_1-9-2) (2005-09-14)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-9-1...RMagick_1-9-2)

## [RMagick_1-9-1](https://github.com/gemhome/rmagick/tree/RMagick_1-9-1) (2005-09-07)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-9-0...RMagick_1-9-1)

## [RMagick_1-9-0](https://github.com/gemhome/rmagick/tree/RMagick_1-9-0) (2005-07-15)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-8-3...RMagick_1-9-0)

## [RMagick_1-8-3](https://github.com/gemhome/rmagick/tree/RMagick_1-8-3) (2005-06-17)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-8-2...RMagick_1-8-3)

## [RMagick_1-8-2](https://github.com/gemhome/rmagick/tree/RMagick_1-8-2) (2005-06-10)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-8-1...RMagick_1-8-2)

## [RMagick_1-8-1](https://github.com/gemhome/rmagick/tree/RMagick_1-8-1) (2005-05-22)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-8-0...RMagick_1-8-1)

## [RMagick_1-8-0](https://github.com/gemhome/rmagick/tree/RMagick_1-8-0) (2005-04-30)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-7-4...RMagick_1-8-0)

## [RMagick_1-7-4](https://github.com/gemhome/rmagick/tree/RMagick_1-7-4) (2005-04-02)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-7-2...RMagick_1-7-4)

## [RMagick_1-7-2](https://github.com/gemhome/rmagick/tree/RMagick_1-7-2) (2005-04-02)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-7-1...RMagick_1-7-2)

## [RMagick_1-7-1](https://github.com/gemhome/rmagick/tree/RMagick_1-7-1) (2004-12-25)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-7-0...RMagick_1-7-1)

## [RMagick_1-7-0](https://github.com/gemhome/rmagick/tree/RMagick_1-7-0) (2004-12-18)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-6-2...RMagick_1-7-0)

## [RMagick_1-6-2](https://github.com/gemhome/rmagick/tree/RMagick_1-6-2) (2004-12-01)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-6-1...RMagick_1-6-2)

## [RMagick_1-6-1](https://github.com/gemhome/rmagick/tree/RMagick_1-6-1) (2004-12-01)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-6-0...RMagick_1-6-1)

## [RMagick_1-6-0](https://github.com/gemhome/rmagick/tree/RMagick_1-6-0) (2004-08-18)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-5-0...RMagick_1-6-0)

## [RMagick_1-5-0](https://github.com/gemhome/rmagick/tree/RMagick_1-5-0) (2004-04-21)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-4-0...RMagick_1-5-0)

## [RMagick_1-4-0](https://github.com/gemhome/rmagick/tree/RMagick_1-4-0) (2004-02-16)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-3-1...RMagick_1-4-0)

## [RMagick_1-3-1](https://github.com/gemhome/rmagick/tree/RMagick_1-3-1) (2004-01-02)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-3-2...RMagick_1-3-1)

## [RMagick_1-3-2](https://github.com/gemhome/rmagick/tree/RMagick_1-3-2) (2003-12-09)

[Full Changelog](https://github.com/gemhome/rmagick/compare/RMagick_1-3-0...RMagick_1-3-2)

## [RMagick_1-3-0](https://github.com/gemhome/rmagick/tree/RMagick_1-3-0) (2003-08-03)

[Full Changelog](https://github.com/gemhome/rmagick/compare/R1-2-2...RMagick_1-3-0)

## [R1-2-2](https://github.com/gemhome/rmagick/tree/R1-2-2) (2003-07-01)

[Full Changelog](https://github.com/gemhome/rmagick/compare/From_RubyMagick...R1-2-2)

## [From_RubyMagick](https://github.com/gemhome/rmagick/tree/From_RubyMagick) (2003-07-01)



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
# How to measure the memory usage

## 1. Install gnuplot
If you need a graph of memory usage, it can draw the graph with `gnuplot`.

With `Homebrew`, you can install `gnuplot` like

```
$ brew install gnuplot
```

## 2. Retrieve two performance data `before` / `after`
Retrieve data before applying patches.

```
$ rake build
$ gem install pkg/rmagick-3.1.0.gem
$ cd benchmarks/memory
$ ruby image_new.rb > before.csv
```

Apply the patches then retrieve improved data.

```
$ rake build
$ gem install pkg/rmagick-3.1.0.gem
$ cd benchmarks/memory
$ ruby image_new.rb > after.csv
```

## 3. Draw the performance graph
Launch `gnuplot` and execute `load 'rmagick.gnuplot'` command in prompt then the performance graph will be drew.

```
$ cd benchmarks/memory
$ gnuplot

	G N U P L O T
	Version 5.2 patchlevel 7    last modified 2019-05-29

	Copyright (C) 1986-1993, 1998, 2004, 2007-2018
	Thomas Williams, Colin Kelley and many others

	gnuplot home:     http://www.gnuplot.info
	faq, bugs, etc:   type "help FAQ"
	immediate help:   type "help"  (plot window: hit 'h')

Terminal type is now 'qt'
gnuplot> load 'rmagick.gnuplot'
```

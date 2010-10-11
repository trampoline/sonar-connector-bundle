OVERVIEW
========

A bundle of gems for a sonar-connector installation. This bundle can be used in three ways:

1. Run directly on a linux-based system
2. Build a windows deployment package
3. Build a linux deployment package

RUN THE CONNECTOR DIRECTLY
==========================

## Prerequisites

* Java 6
* Ruby 1.8.5+
* Rubygems
* gems: bundler

## Run steps

### 1. Checkout the bundle git repo

### 2. Install the bundle

<pre>
  ./tools/bundle_install
</pre>

### 3. Edit connector config

Edit config/config.json and set up the connector according to your needs. See the MANUAL for more details.

### 4. Start the connector

<pre>
  ./tools/start
</pre>


BUILD THE CONNECTOR PACKAGES
============================

## Prerequisites

* Ruby 1.8.7+
* Rubygems
* gems: rake, bundler
* [For Windows build only] The Nullsoft NSIS compiler (ensure that the binary file _makensis_ is on the path)

## Pre-build steps

### 1. Special JRuby build including bundler gem

Before you build the package you need to configure the versions of bundler and jruby that are being used in the package. In order to keep the dependencies as minimal as possible, a special build of JRuby is required with the bundler gem built into it. 

Craig McMillan has created this build of JRuby and it has been included in this bundle. Thus the versions of JRuby and bundler specified below don't need to be changed if you use the same JRuby file in the lib folder.

Edit Rakefile and set these constants to the correct values, e.g.:

<pre>
  BUNDLER_VERSION = "bundler-1.0.0"
  JRUBY_FILENAME = "jruby-complete-1.5.2-bundler-1.0.0.jar"
</pre>

### 2. Include any other Sonar connector gems

Include any other Sonar connector gems (either from Trampoline Systems or written by yourself) by editing the Gemfile. Note that any gems not listed in the Gemfile won't be bundled into the resulting Linux or Windows deployment, i.e. if you want the connector to pull from MS Exchange then you must include the gem 'sonar-exchange-pull-connector'.

## Build the Windows package

<pre>
  $ rake build:windows
</pre>

_Output:_ build/SonarConnectorSetup.exe

This setup file is a GUI installer which will run on Windows. See MANUAL for more details.

## Build the Linux package

<pre>
  $ rake build:linux
</pre>

_Output:_ build/SonarConnectorSetup.tar.gz

This tarball can be shipped to any Linux system, unpackaged, and run as a stand-alone application. See MANUAL for more details of how to install and run on a Linux system.

Copyright (c) 2010 Trampoline Systems Ltd. See LICENSE for details.
Trampoline Systems Sonar Connector
=================================
## Installation and Operation Guide

Connector version: 0.8.0  
Date of release: 11 October 2010

1. INTRODUCTION
===============

The Sonar Connector runs within the firewall and retrieves data from enterprise systems behind the firewall, which is then delivered to a secure Sonar Server through a strongly encrypted channel.

This document is the installation guide and operating manual for the Sonar Connector. It includes installation instructions for Windows and Linux, as well as operating guides on how to configure, start and maintain a running instance of the Sonar Connector framework.

2. INSTALLATION
===============

The Sonar Connector framework is a JRuby application and has been designed to run on both Windows and Linux (Centos & RHEL). The primary dependency on both platforms is Java 1.6, with additional requirements for a Linux deployment.

## 2.1 Install on Windows

### 2.1.1 Prerequisites

* Windows XP, Windows Vista, Windows 2003 Server or Windows 7
* Java JRE 6

### 2.1.2 Install the prerequisites 

**Note: skip to the next section if all the prerequisites are installed.**

**Install Java JRE 6**

The Java JRE must be installed before installing the Sonar Connector. Please [download JRE from the Sun website](http://www.java.com/en/download/manual.jsp) and install the JRE from before continuing.

### 2.1.3 Install the connector

The Sonar Connector is packaged as a Windows installer. Locate the file called SonarConnectorSetup.exe and follow the installation steps. 

The Connector will install to "C:\Program Files\Sonar Connector" by default, or "C:\Program Files (x86)\Sonar Connector" if you're on a 64-bit system.

Note that one of the installation steps will require you to locate the JAVA\_HOME folder. This is the folder that the Java JRE is installed to. Please consult the Java documentation if you unsure where the JAVA\_HOME folder is located.

### 2.1.4 Starting the connector ###

The connector framework will have been started automatically as a system service during installation. 

If you'd like to control the Sonar Connector service then open the Windows service panel by running _services.msc_ and locate the service called _SonarConnector_. The control panel provides standard functionality to stop, start and restart system services.

Examine the log file output to ensure that the Connector is running properly. The log files are located in a subdirectory of the install directory, typically "C:\Program Files\Sonar Connector\log". Please read the MAINTENANCE section below on how to interpret log files.

### 2.1.5 Compatibility 

This installation has been tested on Windows 7 Ultimate (64 bit).

## 2.2 Installation on Centos and RHEL Linux

### 2.2.1 Prerequisites

* RHEL or Centos Linux
* Java JRE 6
* Ruby 1.8.5+
* Rubygems
* God gem

### 2.2.2 Install the prerequisites

**Note: skip to the next section if all the prerequisites are installed.**

**Install Java JRE 6**

The Java JRE 6 can be installed using yum:

<pre>
  sudo yum install java-1.6.0-openjdk
</pre>

Check that Java installed correctly:

<pre>
  java -version
  => java version "1.6.0_0"
</pre>

**Install Ruby**

The Ruby language and the Rubygems package manager can be installed using the system package manager:

<pre>
  sudo yum install ruby ruby-devel ruby-rdoc ruby-irb
</pre>

Now check that ruby is installed. The following command should return a Ruby version 1.8.5 or higher.

<pre>
  ruby --version
  => ruby 1.8.5 (2006-08-25) [i386-linux]
</pre>

**Install Rubygems**

Download the Rubygems source tarball:

<pre>
  wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
</pre>

Unzip the file and change into the source dir:

<pre>
  tar xfvz rubygems-1.3.5.tgz
</pre>

Change into the source dir and install Rubygems:

<pre>
  cd rubygems-1.3.5
  sudo ruby setup.rb
</pre>

And finally check that Rubygems are installed - the following command should return a version 1.3.5:
<pre>
  gem --version
  => 1.3.5
</pre>

**Install the process monitor 'god'**

God is a process management framework for Linux. It is easily installed using rubygems:

<pre>
  sudo gem install god
</pre>

Now check that god is installed properly. The following command should return a version of 0.11 or higher:

<pre>
  god --version
  => Version 0.11.0
</pre>

### 2.2.3 Install the connector

**Locate SonarConnector.tar.gz** 

The connector will be delivered to you as a .tar.gz compressed tarball. Locate the file (or download it from the provided link) and copy it to a compatible Centos or RHEL server.

**Unzip the package**

Select a location that you want to install the package to and unzip the file. In these instructions the target is relative to the home directory for the user 'peter', identified by the tilde (~) prefix.

<pre>
  mv SonarConnector.tar.gz 
  cd ~
  tar xfvz SonarConnector.tar.gz
</pre>

Change into the SonarConnector directory to continue the installation:

<pre>
  cd ~/SonarConnector
</pre>


Make the log and var directories:

<pre>
  mkdir -p log var/pids
</pre>

**Test-run the connector**

Before installing the connector as a system service, start up the connector directly. It should take a few seconds to start the connector and will then print out the escape code to exit:

<pre>
  ./tools/start
  => Ctrl-C to stop.
</pre>

This means the connector is ready to run on your system, so hit Ctrl-C to exit. The script tools/start is useful to remember if you need to start up the connector directly without god.

**Install the connector as a system service**

Copy the init.d script into the system startup script folder:

<pre>
  sudo cp ~/SonarConnector/config/init.d/sonar-connector /etc/init.d/
</pre>

__NOTE__: This init.d file is a __template__ only and must be edited to reflect the correct path to the location that you've installed the connector to. Edit the startup script to reflect the installation directory of the Sonar Connector:

<pre>
  sudo vi /etc/init.d/sonar-connector
</pre>

When editing the file, be sure to set SONAR\_CONNECTOR\_HOME to the location of the Connector after unzipping, e.g. in this example the line should read:

<pre>
  SONAR_CONNECTOR_HOME = /home/peter/SonarConnector
</pre>

Now setup the service to run at boot time:

<pre>
  sudo /sbin/chkconfig --add sonar-connector
  sudo /sbin/chkconfig --level 345 sonar-connector on
</pre>

**Finally, start the connector using the init.d script**

<pre>
  sudo /etc/init.d/sonar-connector start
</pre>

Examine the log file output in ~/SonarConnector/log to ensure the connector has started up. Please see MAINTENANCE section below for more details of the various log files and how to interpret them.


### 2.2.4 Compatibility

This installation has been tested on Centos 5.5.

3. CONFIGURATION
================


4. MAINTENANCE
==============


Monitoring - log files + disk store

Copyright (c) 2010 Trampoline Systems Ltd. See LICENSE for details.
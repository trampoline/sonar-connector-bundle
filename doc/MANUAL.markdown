Trampoline Systems Sonar Connector
=================================
## Installation and Operation Guide

Connector version: 0.8.0  
Date of release: 11 October 2010

1. INTRODUCTION
===============

The Sonar Connector service runs within the firewall and retrieves data from enterprise systems behind the firewall, which is then delivered to a secure Sonar Server through a strongly encrypted channel.

This document is the installation guide and operating manual for the Sonar Connector service. It includes installation instructions for Windows and Linux, as well as operating guides on how to configure, start and maintain a running instance of the service.

2. INSTALLATION
===============

The Sonar Connector service is a JRuby application and has been designed to run on both Windows and Linux (Centos & RHEL). The primary dependency on both platforms is Java 1.6, with additional requirements for a Linux deployment.

## 2.1 Install on Windows

### 2.1.1 Prerequisites

* Windows XP, Windows Vista, Windows 2003 Server or Windows 7
* Java JRE 6

### 2.1.2 Install the prerequisites 

**Note: skip to the next section if all the prerequisites are installed.**

**Install Java JRE 6**

The Java JRE must be installed before installing the service. Please [download JRE from the Sun website](http://www.java.com/en/download/manual.jsp) and install the JRE from before continuing.

### 2.1.3 Install the Sonar Connector service

The service is packaged as a Windows installer. Locate the file called SonarConnectorSetup.exe and follow the installation steps. 

The service will install to "C:\Program Files\Sonar Connector" by default, or "C:\Program Files (x86)\Sonar Connector" if you're on a 64-bit system.

Note that one of the installation steps will require you to locate the JAVA\_HOME folder. This is the folder that the Java JRE is installed to. Please consult the Java documentation if you unsure where the JAVA\_HOME folder is located.

### 2.1.4 Starting the service ###

The connector will have been started automatically as a system service during installation. 

If you'd like to control the Sonar Connector service then open the Windows service panel by running _services.msc_ and locate the service called _SonarConnector_. The control panel provides standard functionality to stop, start and restart system services.

Examine the log file output to ensure that the service is running properly. The log files are located in a subdirectory of the install directory, typically "C:\Program Files\Sonar Connector\log". Please read the MAINTENANCE section below on how to interpret log files.

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

### 2.2.3 Install the Sonar Connector service

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

# 3.1 Configuration overview

The Sonar Connector is a framework of separate connectors which are all started together at run-time. Each connector type is enabled and configured via the config/config.json file.

The config file is read when the framework boots up, and is used to specify which connectors should be started. It comprises of two sections:

* A block of configuration which is common to the framework and all individual connectors.
* A separate block of configuration per connector type. The nature of this configuration will depend on the specifics of each connector.

Furthermore, each separate connector has a certain config parameters which must be supplied.

# 3.2 Connector types

These are the different types of connector available for the Sonar Connector framework. Connectors of type "internal" are built into the framework and can always be used. Connectors of type "gem" are separate rubygems which need to be built into the deployment bundle. 

Typically, all the connectors that are required for your deployment will have been built into the installer file supplied by Trampoline Systems.

# 3.3 List of all available connectors

<table>
  <tr>
    <th>Class</th>
    <th>Description</th>
    <th>Type</th>
    <th>Gem name</th>
  </tr>
  <tr>
    <td>Sonar::Connector::SeppukuConnector</td>
    <td>Kills the Framework on a regular interval.</td>
    <td>internal</td>
    <td></td>
  </tr>
  <tr>
    <td>Sonar::Connector::PingConnector</td>
    <td>Pings a remote host regularly and alerts the sysadmin if the host becomes unreachable</td>
    <td>internal</td>
    <td></td>
  </tr>
  <tr>
    <td>Sonar::Connector::ImapPullConnector</td>
    <td>Retrieves email messages from an IMAP server</td>
    <td>gem</td>
    <td>[sonar\_imap\_pull\_connector](http://github.com/trampoline/sonar-imap-pull-connector)</td>
  </tr>
  <tr>
    <td>Sonar::Connector::ExchangePullConnector</td>
    <td>Retrieves email messages from a Microsoft Exchange 2003 or 2007 server</td>
    <td>gem</td>
    <td>[sonar\_exchange\_pull\_connector](http://github.com/trampoline/sonar-exchange-pull-connector)</td>
  </tr>
  <tr>
    <td>Sonar::Connector::SonarPushConnector</td>
    <td>Pushes email messages to a remote instance of Sonar Server</td>
    <td>gem</td>
    <td>[sonar\_exchange\_pull\_connector](http://github.com/trampoline/sonar-exchange-pull-connector)</td>
  </tr>
<table>

# 3.4 Example configuration

The best way to understand the configuration is to dive in and examine some example configuration.

<pre>
  {
    /* log level must be one of: "debug", "info", "warn", "error", "fatal" */
    "log_level" : "debug",

    /* max log file size in megabytes */
    "log_file_max_size" : "10",

    /* number of log files to keep */
    "log_files_to_keep" : "7",

    "email_settings": {
      "admin_recipients": ["admin@server.local"],
      "admin_sender": "Sonar Connector <noreply@server.local>",
      "perform_deliveries": false,

      /* options are ["smtp", "sendmail", "test"] */
      "delivery_method": "smtp",
      "save_emails_to_disk": true,

      "smtp_settings": {
        "address": "127.0.0.1",
        "port": 25,
        "domain": "server.local",
        "user_name": null,
        "password": null,

        /* options are ["plain", "login", "cram_md5"] */
        "authentication": null
      },

      "sendmail_settings": {
        "location": "/usr/sbin/sendmail",
        "arguments": "-i -t -f nobody@localhost"
      }
    },

    /* 
      Specific configuration for each connector. Each connector must have 
      a class and a unique name. The require load path can also be specified if necessary.
      Note that each connector type may have further configuration options
      that are specific to the connector class.
    */
    "connectors": [
      {
        "class": "Sonar::Connector::DummyConnector",
        "name": "dummy_connector1",
        "repeat_delay": 10
      },

      {
        "class": "Sonar::Connector::ImapPullConnector",
        "require": "sonar_imap_pull_connector",
        "name": "imap_gmail",
        "repeat_delay": 10,
        "host": "imap.gmail.com",
        "user": "foo@foo.com",
        "password": "blahblah",
        "folders": "[Gmail]/All Mail"
      },

      {
        "class": "Sonar::Connector::SonarPushConnector",
        "require": "sonar_push_connector",
        "name": "sonar_push",
        "repeat_delay": 10,
        "source_connectors": ["imap_gmail"],
        "uri": "http://localhost:3000/api/1_0/rfc822_messages",
        "connector_credentials": "blahblah"
      },

      {
        "class": "Sonar::Connector::SeppukuConnector",
        "name": "seppuku",
        "repeat_delay": 43200,
        "enabled": true
      }
    ] 
  }
</pre>


4. MAINTENANCE
==============


Monitoring - log files + disk store

Copyright (c) 2010 Trampoline Systems Ltd. See LICENSE for details.
Trampoline Systems Sonar Connector
=================================
## Installation and Operation Guide

Connector version: 0.8.1  
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

The service is packaged as a Windows installer. Locate and execute the file called SonarConnectorSetup.exe, and follow the installation steps. 

The service will install to "C:\Program Files\Sonar Connector" by default, or "C:\Program Files (x86)\Sonar Connector" if you're on a 64-bit system.

Note that one of the installation steps will require you to locate the JAVA\_HOME folder. This is the folder that the Java JRE is installed to. Please consult the Java documentation if you unsure where the JAVA\_HOME folder is located.

### 2.1.4 Starting the service

The service will have been started automatically as a system service during installation. 

The service may be controlled by the Windows service panel. Launch the panel by running the command _services.msc_ and then locate the service called _SonarConnector_. The control panel provides standard functionality to stop, start and restart system services.

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

Install Java JRE 6 using yum:

<pre>
  sudo yum install java-1.6.0-openjdk
</pre>

Check that Java is installed correctly:

<pre>
  java -version
  => java version "1.6.0_0"
</pre>

**Install Ruby**

Install the Ruby language and Rubygems using yum:

<pre>
  sudo yum install ruby ruby-devel ruby-rdoc ruby-irb
</pre>

Now check that ruby is installed - this command should return a version 1.8.5 or higher:

<pre>
  ruby --version
  => ruby 1.8.5 (2006-08-25) [i386-linux]
</pre>

**Install Rubygems**

Download the Rubygems source tarball. Note that higher versions of Rubygems may be available but will be incompatible with Ruby 1.8.5.

<pre>
  wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
</pre>

Unzip the file and change into the source directory:

<pre>
  tar xfvz rubygems-1.3.5.tgz
</pre>

Change into the source directory and install Rubygems:

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

The installation package will be delivered to you as a .tar.gz compressed tarball. Locate the file (or download it from the provided link) and copy it to a compatible Centos or RHEL server.

**Unzip the package**

Select a location that you want to install the package to and unzip the file. In these instructions the target is relative to the home directory for the user 'peter', identified by the tilde (~) prefix.

<pre>
  mv SonarConnector.tar.gz ~
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

**Test-run the service**

Start up the service directly before installing the connector as a system service. It should take a few seconds to start the connector and will then print out the escape code to exit:

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

**Finally, start the service using the init.d script**

<pre>
  sudo /etc/init.d/sonar-connector start
</pre>

Examine the log file output in ~/SonarConnector/log to ensure the connector has started up. Please see MAINTENANCE section below for more details of the various log files and how to interpret them.

### 2.2.4 Compatibility

This installation has been tested on Centos 5.5.

3. CONFIGURATION
================

## 3.1 Configuration overview

The Sonar Connector is a collection of separate connector instances which are all started together within a common framework at run-time. Each connector type is enabled and configured via the config/config.json file.

This distinction is important because it affects all further explanations of the configuration options:

* The Sonar Connector _service_ is a collection of separate connectors which are bundled together and started up within a common framework
* A _connector instance_ is a single connector which repeatedly performs a particular action, e.g. retrieve a batch of mail, or push a batch of mail to another service.

The config file is read when the framework boots up and is used to specify which connectors instances should be started. It comprises of two sections:

* A block of configuration which is common to the framework and all individual connectors.
* A separate block of configuration per connector type. Some of this config is mandatory for any connector instance, but most of these config params will depend on the specifics of each connector.

## 3.2 Connector types

These are two types of connector available for the Sonar Connector framework. Connectors of type "internal" are built into the framework and can always be used. Connectors of type "gem" are separate rubygems which need to be built into the deployment bundle. 

Typically, all the connectors that are required for your deployment will have been built into the installer file supplied to you by Trampoline Systems.

## 3.3 List of all available connectors

<table>
  <tr>
    <th>Class</th>
    <th>Description</th>
    <th>Type</th>
    <th>Gem name</th>
  </tr>
  <tr>
    <td width='20%'>Sonar::Connector::SeppukuConnector</td>
    <td width='60%'>Kills the service on a regular interval, thus forcing a restart.</td>
    <td width='5%'>internal</td>
    <td width='15%'></td>
  </tr>
  <tr>
    <td>Sonar::Connector::PingConnector</td>
    <td>Pings a remote host regularly and alerts the sysadmin if the host becomes unreachable.</td>
    <td>gem</td>
    <td>[sonar\_ping\_connector](http://github.com/trampoline/sonar-ping-connector)</td>
  </tr>
  <tr>
    <td>Sonar::Connector::ImapPullConnector</td>
    <td>Retrieves email messages from an IMAP server.</td>
    <td>gem</td>
    <td>[sonar\_imap\_pull\_connector](http://github.com/trampoline/sonar-imap-pull-connector)</td>
  </tr>
  <tr>
    <td>Sonar::Connector::ExchangePullConnector</td>
    <td>Retrieves email messages from a Microsoft Exchange 2003 or 2007 server.</td>
    <td>gem</td>
    <td>[sonar\_exchange\_pull\_connector](http://github.com/trampoline/sonar-exchange-pull-connector)</td>
  </tr>
  <tr>
    <td>Sonar::Connector::SonarPushConnector</td>
    <td>Pushes email messages to a remote instance of Sonar Server.</td>
    <td>gem</td>
    <td>[sonar\_exchange\_pull\_connector](http://github.com/trampoline/sonar-exchange-pull-connector)</td>
  </tr>
<table>

## 3.4 Example configuration

The best way to understand the configuration is to dive in and examine an example config file. This is the example config file which ships with the installation package by default:

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
      Specific configuration for each connector instance. Each connector must have 
      a class and a unique name. The require load path can also be specified if necessary.
      Note that each connector type may have further configuration options
      that are specific to the connector class.
    */
    "connectors": [
      {
        "class": "Sonar::Connector::ImapPullConnector",
        "require": "sonar_imap_pull_connector",
        "name": "imap_gmail",
        "repeat_delay": 10,
        "host": "imap.gmail.com",
        "user": "foo@foo.com",
        "password": "--",
        "folders": "[Gmail]/All Mail"
      },

      {
        "class": "Sonar::Connector::SonarPushConnector",
        "require": "sonar_push_connector",
        "name": "sonar_push",
        "repeat_delay": 10,
        "source_connectors": ["imap_gmail"],
        "uri": "http://localhost:3000/api/1_0/rfc822_messages",
        "connector_credentials": "--"
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

**Important note:** The config is in [JSON format](http://en.wikipedia.org/wiki/JSON). If the config is not well-formed JSON then it will be rejected when the service starts and an error will be logged in the log files.

## 3.5 Shared configuration

The first section is the configuration which is common across the connector service. The first few options in this block are used to configure all log files in the system:

<pre>
  /* log level must be one of: "debug", "info", "warn", "error", "fatal" */
  "log_level" : "debug",

  /* max log file size in megabytes */
  "log_file_max_size" : "10",

  /* number of log files to keep */
  "log_files_to_keep" : "7",
</pre>

These are all straight-forward:

* _log\_level_: verbosity of logging
* _log\_file\_max\_size_: maximum file size in megabytes before the log file is rotated
* _log\_files\_to\_keep_: total number of times that each log file should be rotated

The next section pertains to email settings. The connector service can optionally be configured with the email address of a sysadmin to send warning and failure messages to. Each connector instance may or may not identify certain events which the sysadmin should be made aware of, and can warn the sysadmin by sending an email through a common email gateway.

The email settings comprise a set of nested settings, which are explained below:

<pre>
  "email_settings": {
    "admin_recipients": ["admin@server.local"],
    "admin_sender": "Sonar Connector <noreply@server.local>",
    "perform_deliveries": false,

    /* options are ["smtp", "sendmail"] */
    "delivery_method": "smtp",
    "save_emails_to_disk": false,

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
  }
</pre>

The top-level settings explained:

* _admin\_recipients_: array of email addresses which should receive the notifications
* _admin\_sender_: address which emails should appear to originate from
* _perform\_deliveries_: determines if mails are actually sent. Must be true if you want emails to be sent
* _delivery\_method_: method of delivery - either "smtp" or "sendmail"
* _save\_emails\_to\_disk_: turn this on to save a copy of each outgoing admin email to disk

The SMTP settings:

* _address_: hostname or IP address of the SMTP server to use
* _port_: port of the SMTP server above
* _domain_: the domain that the client should identify with during HELO
* _user\_name_: The username to authenticate with. Not used if _authentication_ is disabled.
* _password_: The password to authenticate with. Not used if _authentication_ is disabled.
* _authentication_: The method of authentication. Must be one of "plain", "login" or "cram_md5". Leave null for no authentication.

The sendmail settings: (Only applies to Linux deployments)

* _location_: the location on disk to the sendmail binary
* _arguments_: the parameters supplied to sendmail during send

## 3.6 Individual connector configuration

Each connector has its own configuration which is supplied as a JSON object. Some of this configuration is mandatory for all connectors. Note that individual connectors may have their own mandatory fields too, but these are the fields required across the board.

### 3.6.1 The mandatory config parameters

* _class_: The full class name of the connector as specified in the table in section 3.3.
* _name_: A unique name for this connector. Used to create one log file per connector.
* _repeat\_delay_: The delay in seconds which the connector waits before each action. Cannot be zero.
* _gem\_name_: The name of the connector gem. Only needs to be supplied if the connector **is not internal**.

### 3.6.2 Per-connector config parameters

Each connector can have its own config params, depending on the nature and operation of the connector. 

**Seppuku connector**

The Seppuku connector periodically forces the connector service to terminate. This in turn causes the service wrapper to restart the service, thus ensuring that the service never goes into deadlock or suffers from out of memory conditions. 

Example configuration:

<pre>
  {
    "class": "Sonar::Connector::SeppukuConnector",
    "name": "seppuku",
    "repeat_delay": 43200
  }
</pre>

This connector doesn't take any additional parameters besides the core params required for every connector instance. 

**Ping connector**

The ping connector will attempt to ping the host 5 times (once per repeat delay) and will email the sysadmin on the 5th consecutive unsuccessful connection.

Example configuration:

<pre>
  {
    "class": "Sonar::Connector::PingConnector",
    "require": "sonar_ping_connector"
    "name": "ping_connector",
    "repeat_delay": 60,
    
    "host": "www.google.com",
    "port": 80
  }
</pre>

Additional parameters:

* _host_: The host name or IP address to ping
* _port_: The port to ping on. Defaults to 80 if not supplied in config.

**IMAP pull connector**

The IMAP pull connector retrieves email in batches from a single IMAP account, and saves them as files, ready to be picked up by another connector.

The IMAP connector does not delete mail from the IMAP account, nor does it move processed mail to a different folder. Further, it only extracts mail headers and does not store or persist the message body to disk.

Example configuration:

<pre>
  {
    "class": "Sonar::Connector::ImapPullConnector",
    "require": "sonar_imap_pull_connector",
    "name": "imap_gmail",
    "repeat_delay": 10,
    
    "host": "imap.gmail.com",
    "user": "foo@foo.com",
    "password": "--",
    "usessl": true,
    "folders": "[Gmail]/All Mail",
    "batch_size": 100
  }
</pre>

Additional parameters:

* _host_: The host name or IP address of the IMAP server
* _user_: The username to authenticate with. In the case of GMail, the username is the email address.
* _password_: The password to authenticate with
* _usessl_: Use SSL connection on port 993 if true, otherwise perform plain authentication and connect on port 143
* _folders_: An array of folders that should be retrieved from. Can also be a single folder name if only one is to be polled
* _batch\_size_: Number of emails to retrieve in each batch. Defaults to 100.

**Exchange pull connector**

The Exchange pull connector retrieves email in batches from a single Microsoft Exchange account, and saves them as files, ready to be picked up by another connector.

Note that Outlook Web Access (OWA) must be enabled on the server in order to use the Exchange pull connector.

Example configuration:

<pre>
  {
    "class": "Sonar::Connector::ImapPullConnector",
    "require": "sonar_imap_pull_connector",
    "name": "imap_gmail",
    "repeat_delay": 10,
    
    "dav_uri": "https://exchange.local/exchange/",
    "auth_type": "basic",
    "owa_uri": "https://exchange.local/owa/auth/owaauth.dll",
    "username": "journal",
    "password": "--",
    "mailbox": "journal@exchange.local",
    "delete_processed_messages": false,
    "is_journal_account": true,
    "archive_name": "processed_by_sonar",
    "headers_only": true,
    "retrieve_batch_size": 1000
  }
</pre>

Additional parameters:

* _dav\_uri_: The full path to the Exchange server DAV URL
* _auth\_type_: The type of authentication to use. Must be "form" or "basic", corresponding to the type of OWA authentication enabled on the server.
* _username_: The username to authenticate with
* _password_: The password to authenticate with
* _mailbox_: The Exchange mailbox to retrieve from
* _delete\_processed\_messages_: If this is enabled then messages will be deleted from the mailbox after retrieval. Otherwise they will be moved to the archive folder called _archive\_name_.
* _archive\_name_: The name of the folder to move processed messages to. Defaults to "processed\_by\_sonar". Only used if _delete\_processed\_messages_ is not set.
* _is\_journal\_account_: Boolean flag specifying if this mailbox is a journal account. This is needed because Exchange journalling saves each email as an attachment of an enclosing email so the connector needs to read one level of attachment on journal accounts.
* _headers\_only_: Flag to determine if entire emails are retrieved or just the header.
* _retrieve\_batch\_size_: Number of emails to retrieve in each batch. Defaults to 1000.
* _xml\_href\_regex_: **[advanced setting]** Allows over-riding the regular expression used to determine if a resource is a message. Defaults to _"<.*?a:propstat.*?>.*?<.*?a:status.*?>.*?HTTP\/1\.1.*?200.*?OK.*?<.*?a:href.*?>(.*?)<\/.*?a:href.*?>.*?\/a:propstat.*?>/im"._

**Sonar push connector**

The Sonar push connector reads email messages stored as files and sends them to a remote instance of Sonar server.

Example configuration:

<pre>
  {
    "class": "Sonar::Connector::SonarPushConnector",
    "require": "sonar_push_connector",
    "name": "sonar_push",
    "repeat_delay": 10,
    
    "source_connectors": ["imap_gmail"],
    "uri": "http://localhost:3000/api/1_0/rfc822_messages",
    "connector_credentials": "--",
    "batch_size": 50
  }
</pre>

Additional parameters:

* _source\_connectors_: An array of other connectors configured in the service, usually pull connectors. Each connector specified here must match the _name_ field of another connector.
* _uri_: The URI to post each batch of emails to. Corresponds to a Sonar Server API method.
* _connector\_credentials_: The Sonar Server API key to use when posting emails.
* _batch\_size_: Number of emails to post per batch. Defaults to 50.


4. MAINTENANCE AND MONITORING
=============================

The Sonar Connector service can be monitored in two main ways.

## 4.1 Log files

The Sonar Connector service generates detailed logging output for every stage of the process. This section highlights the various log files in the system. 

There are three types of log files generated:

* Service wrapper logs: i.e. logs generated by the service wrapper that keeps the system running
* Core framework logs: log files generated by the Sonar Connector service itself. Most of this logging is captured during startup and shutdown.
* Connector instance logs: each connector instance logs to its own log file. This is the most useful log information.

### 4.1.1 Service wrapper logs

**Windows**

The Sonar Connector uses the [NSSM](http://iain.cx/src/nssm/) service wrapper to ensure that the service stays alive. This wrapper logs to the standard Windows event log, which should be the first port of call to debug any problems with the Windows service.

**Linux**

The connector framework uses the 'god' service wrapper on Linux. This generates two log files:

* log/god.log: All log output goes here including events such as god restarting the service due to high CPU or memory usage.
* log/stdout_stderr.log: All stdout and stderr is captured here for the duration of the process which is useful if you need to send a SIGTERM to the process to capture debug information.


### 4.1.2 Core framework logs

Both Windows and Linux create the same log files from here on. The core framework log files are:

* log/controller.log: startup and shutdown information for the main service.
* log/consumer.log: log information for the message consumer which is used to facilitate communication between connector instances.


### 4.1.3 Connector instance logs

Each connector instance has its own log file, which is the name of the connector (specified in config.json) prefixed with 'connector'. 

If an IMAP pull connector has the name 'imap_gmail' then the resulting log file will be log/connector\_imap\_gmail.log

The information in these per-connector log files is the most valuable for debugging connector behaviour. Each connector usually logs log-level information to these files to be sure to keep the log-level at "info" or lower when debugging config problems.

## 4.2 Status file

A running connector service has a status file in the root of the connector installation directory, called _status.yml_. This file is in the [YAML format](http://en.wikipedia.org/wiki/YAML) and keeps track of the key statistics about each connector instance.

An example status file might look like this:

<pre>
  --- 
  imap_gmail: 
    last_action: failed
    last_updated: Wed Oct 06 15:15:13 +0100 2010
  sonar_push: 
    last_action: ok
    last_updated: Wed Oct 06 15:15:06 +0100 2010
    disk_usage: 0 Kb
    working_count: 0
    error_count: 0
    complete_count: 0
  seppuku: 
    last_action: ok
    last_updated: Wed Oct 06 15:15:06 +0100 2010
    disk_usage: 0 Kb
    working_count: 0
    error_count: 0
    complete_count: 0
</pre>

From a quick glance at this file you can see that the sonar\_push and seppuku connectors appear to be working fine, but the imap\_connector failed last time it tried to retrieve mail.

The status file is not meant to provide in-depth debugging, but is rather a "one-stop shop" to get a snapshot of the service health.


Copyright (c) 2010 Trampoline Systems Ltd. See LICENSE for details.
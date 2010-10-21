Logworm Monitor
===============

Logworm Monitor is an out-of-the-box web site for monitoring activity on your Logworm log.

Logworm Monitor is monitoring itself at <http://logworm-monitor.heroku.com/>

Overview
--------

[Logworm](http://logworm.com) is a feature-rich system for logging, storing, and analyzing arbitrary data from your Heroku or EC2 hosted application.  
Logworm provides multiple ways to interact with your log data: the lw-tail console application, the Logworm website console, and
the Logworm API.  

Logworm Monitor bridges the gap between viewing individual log tables with lw-tail and the web console and writing a custom website
on top of the API.  Logworm Monitor generates a standard site for monitoring your log tables in real-time, backed by 
the Logworm API.  AJAX drives live updates to the site as new activity is delivered by the API.  

The Logworm Monitor site is generated from a configuration file, which presents data from the default web_log table out of the box.
Custom views of data from other tables can be placed on the site by adding to the configuration file.

The initial version of Logworm Monitor is plain, if not ugly.  Contributions are gladly accepted; hopefully, there will eventually be
a variety of different styles available for use.

Usage
-----

The initial release of Logworm doesn't support authentication.  Though the example site runs on the web, doing so without authentication
is not recommended in general.

Logworm Monitor needs credentials to your Logworm logs.  Either copy the .logworm file to the Logworm Monitor directory, 
or set the LOGWORM_URL environment variable.  To run Logworm Monitor, run
   
   >> rackup -p 9292 config.ru

and navigate to http://localhost:9292/

Configuration
-------------

The config.yml file contains descriptions of collections.  Each collection is
a view of a subset of data from a log table, as determined by requested fields
and specified conditions.  

The Logworm Monitor index page presents recent activity from all of the collections.  
Viewing an individual request shows each collection's log data
for that request.

A collection is specified as follows:
  - name: get_requests
    singular: get_request
    table: web_log
    summary: ["%s %s - %s %s", request_method, request_path, response_status, profiling]
    fields: [_request_id, request_method, request_path, input, response_status, profiling]
    conditions: 
      - request_method: GET

summary and conditions are optional.  

summary is specified in the sprintf format.

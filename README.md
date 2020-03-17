# Kafka module for Puppet

[![Build Status](https://travis-ci.org/voxpupuli/puppet-kafka.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-kafka)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/kafka.svg)](https://forge.puppetlabs.com/puppet/kafka)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/kafka.svg)](https://forge.puppetlabs.com/puppet/kafka)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/kafka.svg)](https://forge.puppetlabs.com/puppet/kafka)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/kafka.svg)](https://forge.puppetlabs.com/puppet/kafka)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with kafka](#setup)
    * [What kafka affects](#what-kafka-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kafka](#beginning-with-kafka)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The Kafka module for managing the installation and configuration of [Apache Kafka](http://kafka.apache.org)

## Module Description

The Kafka module for managing the installation and configuration of Apache Kafka:
it's brokers, producers and consumers.

## Setup

### What kafka affects

Installs the Kafka package and creates a new service.

### Beginning with Kafka

To successfully install Kafka using this module you need to have Apache ZooKeeper
already running at localhost:2181. You can specify another ZooKeeper host:port
configuration using the config hash of the kafka:broker class.

The default configuration installs Kafka 0.11.0.3 binaries with Scala 2.11

```puppet
  class { 'kafka': }
```

If you want a Kafka broker server that connects to ZooKeeper listening on port 2181:

```puppet
  class { 'kafka::broker':
    config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' }
  }
```

## Usage

You can specify different Kafka binaries packages versions to install. Please
take a look at the different Scala and Kafka versions combinations at the
[Apache Kafka Website](http://kafka.apache.org/downloads.html)

### Installing Kafka version 1.1.0 with scala 2.12

We first install the binary package with:

```puppet
  class { 'kafka':
    version => '1.1.0',
    scala_version => '2.12'
  }
```

Then we set a minimal Kafka broker configuration with:

```puppet
  class { 'kafka::broker':
    config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' }
  }
```

### Classes and Defined Types

#### Class: `kafka`

One of the primary classes of the kafka module. This class will install the
kafka binaries

**Parameters within `kafka`:**

##### `version`

The version of kafka that should be installed.

##### `scala_version`

The scala version what kafka was built with.

##### `install_dir`

The directory to install kafka to.

##### `mirror_url`

The url where the kafka is downloaded from.

##### `mirror_subpath`

The url subpath where the kafka is downloaded from (default value: `/kafka/{version}`).

##### `proxy_port`

The proxy port where the kafka is downloaded from.

##### `proxy_host`

The proxy host where the kafka is downloaded from.

##### `proxy_server`

The proxy server where the kafka is downloaded from (to use instead of `proxy_port` and `proxy_host` if you need to set an url as proxy for example).

##### `proxy_type`

The proxy type where the kafka is downloaded from (`http` for example).

##### `install_java`

Install java if it's not already installed.

##### `package_dir`

The directory to install kafka.

#### `package_name`

Package name, when installing kafka from a package.

#### `package_ensure`

Package version (or 'present', 'absent', 'latest'), when installing kafka from
a package.

#### `group_id`

Create kafka group with this ID

#### `user_id`

Create kafka user with this ID

#### `user`

User to install kafka as. Defaults to the kafka user.

#### `group`

Group to install kafka as. Defaults to the kafka group.

#### `config_dir`

Directory for kafka config files. Defaults to /opt/kafka/config.

#### `log_dir`

Directory for kafka log files. Defaults to /var/log/kafka.

#### Class: `kafka::broker`

One of the primary classes of the kafka module. This class will install a kafka broker.

**Parameters within `kafka::broker`:**

##### `version`

The version of kafka that should be installed.

##### `scala_version`

The scala version what kafka was built with.

##### `install_dir`

The directory to install kafka to.

##### `mirror_url`

The url where the kafka is downloaded from.

##### `config`

A hash of the configuration options. All values are used in the
`server.properties` file directly.

##### `install_java`

Install java if it's not already installed.

##### `service_ensure`

Sets the ensure state of the broker service to stopped or running.

##### `service_install`

Install the init.d service.

##### `service_restart`

Whether the configuration files should trigger a service restart

##### `package_dir`

The directory to install kafka.

#### `limit_nofile`

The `LimitNOFILE` systemd paramater value

#### `limit_core`

The `LimitCORE` systemd parameter value

#### Resource: `kafka::consumer`

One of the primary classes of the kafka module. This class will install a kafka consumer.

**Parameters within `kafka::consumer`:**

#### `version`

The version of kafka that should be installed.

#### `scala_version`

The scala version that kafka was built with.

#### `install_dir`

The directory to install kafka to.

#### `mirror_url`

The url where the kafka is downloaded from.

#### `install_java`

Install java if it's not already installed.

#### `package_dir`

The directory to install kafka.

#### `limit_nofile`

The `LimitNOFILE` systemd paramater value

#### `limit_core`

The `LimitCORE` systemd parameter value

#### Resource: `kafka::mirror`

One of the primary resources of the kafka module. This resource will install a kafka mirror and can be called multiple time.

**Parameters within `kafka::mirror`:**

#### `version`

The version of kafka that should be installed.

#### `scala_version`

The scala version that kafka was built with.

#### `install_dir`

The directory to install kafka to.

#### `mirror_url`

The url where the kafka is downloaded from.

#### `install_java`

Install java if it's not already installed.

#### `package_dir`

The directory to install kafka.

#### `limit_nofile`

The `LimitNOFILE` systemd paramater value

#### `limit_core`

The `LimitCORE` systemd parameter value

#### Resource: `kafka::producer`

One of the primary resources of the kafka module. This resource will install a kafka producer.

**Parameters within `kafka::producer`:**

#### `version`

The version of kafka that should be installed.

#### `scala_version`

The scala version that kafka was built with.

#### `install_dir`

The directory to install kafka to.

#### `mirror_url`

The url where the kafka is downloaded from.

#### `install_java`

Install java if it's not already installed.

#### `package_dir`

The directory to install kafka.

#### Define: `kafka::topic`

Defined type that creates Kafka topics.

## Reference

### Classes

#### Public Classes and resources

* `kafka`: Guides the basic installation of kafka binaries
* `kafka::broker`: Guides the basic installation of a kafka broker
* `kafka::consumer`: Guides the basic installation of a kafka consumer
* `kafka::mirror`: Guides the basic installation of a kafka mirror
* `kafka::producer`: Guides the basic installation of a kafka producer

#### Private Classes and resources

* [`kafka::broker::config`]  Manages all the default configuration of the kafka broker application
* [`kafka::broker::install`] Manages the installation of the kafka packages
* [`kafka::broker::service`] Manages the kafka server service
* [`kafka::consumer::config`]  Manages all the default configuration of the kafka consumer application
* [`kafka::consumer::install`] Manages the installation of the kafka packages
* [`kafka::consumer::service`] Manages the kafka server service
* [`kafka::mirror::config`]  Manages all the default configuration of the kafka mirror application
* [`kafka::mirror::install`] Manages the installation of the kafka packages
* [`kafka::mirror::service`] Manages the kafka server service
* [`kafka::producer::config`]  Manages all the default configuration of the kafka producer application
* [`kafka::producer::install`] Manages the installation of the kafka packages
* [`kafka::producer::service`] Manages the kafka server service

#### Defined Types

* `kafka::topic` Create kafka topics

## Limitations

This module only supports Kafka >= 0.9.0.0.

This module is tested on the following platforms:

* CentOS 5
* CentOS 6
* CentOS 7
* Ubuntu 12.04
* Ubuntu 14.04

It is tested with the OSS version of Puppet (>= 4.7.0) only.

## Development

### Contributing

Please read CONTRIBUTING.md for full details on contributing to this project.

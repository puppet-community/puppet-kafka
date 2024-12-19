# frozen_string_literal: true

require 'spec_helper'

describe 'kafka::topic', type: :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'when create topic demo' do
        let(:title) { 'demo' }
        let :params do
          {
            'ensure'             => 'present',
            'zookeeper'          => 'localhost:2181',
            'replication_factor' => 1,
            'partitions'         => 1
          }
        end

        it {
          is_expected.to contain_exec('create topic demo').with(
            command: 'kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic demo '
          )
        }
      end

      context 'when create topic demo for kafka v3' do
        let(:title) { 'demo' }
        let :params do
          {
            'ensure'             => 'present',
            'bootstrap_server'   => 'localhost:9092',
            'replication_factor' => 1,
            'partitions'         => 1
          }
        end

        it {
          is_expected.to contain_exec('create topic demo').with(
            command: 'kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic demo '
          )
        }
      end

      context 'when create topic without zookeeper or bootstrap_server' do
        let(:title) { 'demo' }
        let :params do
          {
            'ensure'             => 'present',
            'replication_factor' => 1,
            'partitions'         => 1
          }
        end

        it {
          is_expected.to compile.and_raise_error(%r{Either zookeeper or bootstrap_server parameter must be defined!})
        }
      end

      context 'when create topic demo with config' do
        let(:title) { 'demo' }
        let :params do
          {
            'ensure'             => 'present',
            'zookeeper'          => 'localhost:2181',
            'replication_factor' => 1,
            'partitions'         => 1,
            'config'             => { 'cleanup.policy' => 'compact', 'retention.ms' => '2592000000' }
          }
        end

        it {
          is_expected.to contain_exec('create topic demo').with(
            command: 'kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic demo --config cleanup.policy=compact --config retention.ms=2592000000'
          )
        }
      end

      context 'when create topic demo for kafka v3 and command-config' do
        let(:title) { 'demo' }
        let :params do
          {
            'ensure'             => 'present',
            'bootstrap_server'   => 'localhost:9092',
            'replication_factor' => 1,
            'partitions'         => 1,
            'cmd_config'         => '/opt/kafka/config/admin.config',
          }
        end

        it {
          is_expected.to contain_exec('create topic demo').with(
            command: 'kafka-topics.sh --create --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.config --replication-factor 1 --partitions 1 --topic demo '
          )
        }
      end
    end
  end
end

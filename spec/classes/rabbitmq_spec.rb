require 'spec_helper'

describe 'rabbitmq' do
let(:boxen_home) { '/opt/boxen' }
let(:brewdir)    { "#{boxen_home}/homebrew" }
let(:configdir)  { "#{boxen_home}/config/rabbitmq" }
let(:datadir)    { "#{boxen_home}/data/rabbitmq" }
let(:envdir)     { "#{boxen_home}/env.d" }
let(:logdir)     { "#{boxen_home}/log/rabbitmq" }
let(:facts) do
  {
    :boxen_home => boxen_home,
    :luser      => 'michaeld',
    :boxen_user => 'michaeld'
  }
end

  it do
    should contain_file(configdir).with_ensure('directory')
    should contain_file(datadir).with_ensure('directory')
    should contain_file(logdir).with_ensure('directory')

    should contain_file("#{configdir}/rabbitmq.conf").with({
      :notify => 'Service[dev.rabbitmq]'
    })

    should contain_file("#{configdir}/enabled_plugins").with({
      :notify => 'Service[dev.rabbitmq]'
    })

    should contain_file("#{envdir}/rabbitmq.sh")
    #.with({
    #  :content => File.read('spec/fixtures/rabbitmq.sh')
    #})

    should contain_homebrew__formula('rabbitmq').with_before('Package[boxen/brews/rabbitmq]')
    should contain_package('boxen/brews/rabbitmq').with({
      :ensure => '3.3.5-boxen1',
      :notify => 'Service[dev.rabbitmq]'
    })

    should include_class('rabbitmq::config')

    should contain_file('/Library/LaunchDaemons/dev.rabbitmq.plist').with({
      #:content => File.read('spec/fixtures/rabbitmq.plist'),
      :group   => 'wheel',
      :notify  => 'Service[dev.rabbitmq]',
      :owner   => 'root'
    })

    should contain_file('/opt/boxen/homebrew/var/lib/rabbitmq').with({
      :ensure  => 'absent',
      :force   => true,
      :recurse => true,
      :require => 'Package[boxen/brews/rabbitmq]'
    })

    should contain_service('dev.rabbitmq').with_ensure('running')
  end
end

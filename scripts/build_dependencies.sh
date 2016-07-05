#!/bin/bash

### MESOS

yum remove -y subversion subversion-libs
yum install -y tar git

curl -skO /etc/yum.repos.d/epel-apache-maven.repo \
  'http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo'

yum install -y epel-release

cat << EOF >> /etc/yum.repos.d/wandisco-svn.repo
[WANdiscoSVN]
name=WANdisco SVN Repo 1.9
enabled=1
baseurl=http://opensource.wandisco.com/centos/7/svn-1.9/RPMS/x86_64/
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
EOF

yum update -y systemd
yum install -y apache-maven python-devel java-1.8.0-openjdk-devel zlib-devel \
               libcurl-devel openssl-devel cyrus-sasl-devel cyrus-sasl-md5 \
               apr-devel subversion-devel apr-util-devel maven

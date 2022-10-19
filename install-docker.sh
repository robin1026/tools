#!/bin/bash
echo '--------------安装wget--------------'
yum install -y wget
echo '--------------更换yum源--------------'
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
echo '--------------更新yum--------------'
yum makecache && yum update -y
echo '--------------卸载老版docker--------------'
yum remove -y docker \
          docker-client \
          docker-client-latest \
          docker-common \
          docker-latest \
          docker-latest-logrotate \
          docker-logrotate \
          docker-selinux \
          docker-engine-selinux \
          docker-engine
echo '--------------安装yum源管理工具--------------'
yum install -y yum-utils device-mapper-persistent-data lvm2
echo '--------------设置docker安装源--------------'
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
echo '--------------安装docker--------------'
yum install docker-ce-19.03.15 docker-ce-cli-19.03.15 containerd.io
echo '--------------设置docker自启动--------------'
systemctl enable --now docker
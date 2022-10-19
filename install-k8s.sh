#!/bin/bash
cd /opt
wget https://yoybuy-dev.oss-cn-beijing.aliyuncs.com/file/kubeadm-1.20.15-0.x86_64.rpm
wget https://yoybuy-dev.oss-cn-beijing.aliyuncs.com/file/kubectl-1.20.15-0.x86_64.rpm
wget https://yoybuy-dev.oss-cn-beijing.aliyuncs.com/file/kubelet-1.20.15-0.x86_64.rpm
wget https://yoybuy-dev.oss-cn-beijing.aliyuncs.com/file/kubernetes-cni-0.8.7-0.x86_64.rpm

echo '----------------关闭防火墙----------------'
firewall-cmd --state
systemctl stop firewalld.service
systemctl disable firewalld.service
echo '----------------禁用SELinux----------------'
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
echo '----------------关闭swap----------------'
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
echo '----------------安装conntrack-tools----------------'
yum -y install socat conntrack-tools

echo '----------------设置----------------'
cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
echo 1 > /proc/sys/net/ipv4/ip_forward
echo '----------------安装K8S组件----------------'
rpm -ivh *.rpm --nodeps --force

if [[ $1 = "master" ]];then
    echo '----------------初始化k8s----------------'
    kubeadm init \
        --image-repository registry.aliyuncs.com/google_containers \
        --pod-network-cidr=10.244.0.0/16 \
        --ignore-preflight-errors=cri \
        --kubernetes-version=v1.20.15

    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config

    echo '----------------安装flannel----------------'
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
fi

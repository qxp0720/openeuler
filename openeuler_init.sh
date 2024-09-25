#!/bin/bash

ROOT_PASS='123qwe$%^RTY'
BZTYW_PASS='Bztops@2024'
useradd bztyw
echo 'bztyw  ALL=(ALL)      NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo
echo "bztyw:$BZTYW_PASS" | chpasswd
#修改root密码
#echo "root:$ROOT_PASS" | chpasswd

sed -ri 's/^.*(UseDNS) .*$/\1 no/' /etc/ssh/sshd_config && sed -rn '/UseDNS/p' /etc/ssh/sshd_config
sed -ri 's/^.*(GSSAPIAuthentication ).*$/\1no/' /etc/ssh/sshd_config && sed -rn '/GSSAPIAuthentication/p' /etc/ssh/sshd_config
sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g'   /etc/ssh/ssh_config
setenforce 0
sed -ri.bak 's/^(SELINUX=).*$/\1disabled/' /etc/selinux/config
systemctl stop firewalld.service 
systemctl disable firewalld.service


yum clean all
yum makecache



/usr/bin/timedatectl  set-timezone Asia/Shanghai
yum -y install chrony

sed -ri "s/^(.*pool.*)$/#\1/" /etc/chrony.conf
c=`cat /etc/chrony.conf | grep 'aliyun'|wc -l`
echo $c

if [[ $c -eq 0 ]];then
cat  >> /etc/chrony.conf << EOF
server ntp.aliyun.com iburst
server ntp.tuna.tsinghua.edu.cn iburst
server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
server ntp3.aliyun.com iburst
server ntp4.aliyun.com iburst
EOF
systemctl restart chronyd
#开机自启
systemctl enable chronyd
else
echo "时间同步已经配置"
fi
chronyc sources

cat  >> /etc/security/limits.conf << EOF
* soft core unlimited
* hard core unlimited
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
root soft core unlimited
root hard core unlimited
root soft nproc 1000000
root hard nproc 1000000
root soft nofile 1000000
root hard nofile 1000000
EOF

 cat >> /etc/systemd/system.conf << EOF
DefaultLimitNOFILE=1000000
DefaultLimitNPROC=65535
EOF


cat > /etc/profile.d/online.sh << EOF
HISTSIZE=10000
PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\\\$ "
HISTTIMEFORMAT="%F %T \$(whoami) "

alias l='ls -AFhlt'
alias lh='l | head'
alias vi=vim

GREP_OPTIONS="--color=auto"
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
EOF


cat >> /etc/resolv.conf << EOF
nameserver 119.29.29.29
nameserver 223.5.5.5
EOF



cat >>/etc/rc.local<<EOF
modprobe ip_conntrack 
EOF

chmod +x /etc/rc.d/rc.local

modprobe ip_conntrack 

# /etc/sysctl.conf
[ ! -e "/etc/sysctl.conf_bk" ] && /bin/mv /etc/sysctl.conf{,_bk}
cat > /etc/sysctl.conf << EOF
kernel.panic = 1
kernel.pid_max = 32768
kernel.shmmax = 15461882265
kernel.shmall = 3774873
kernel.core_pattern = core_%e
vm.panic_on_oom = 1
vm.overcommit_memory = 1
vm.min_free_kbytes = 1048576
vm.vfs_cache_pressure = 250
vm.swappiness = 1
vm.dirty_ratio = 10
fs.file-max = 1048575
net.core.somaxconn = 32768
net.core.wmem_default = 16777216
net.core.rmem_default = 16777216
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_sack = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.ip_default_ttl = 64
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 32768 16777216
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_tw_buckets = 60000
net.ipv4.neigh.default.gc_thresh1 = 128
net.ipv4.neigh.default.gc_thresh2 = 512
net.ipv4.neigh.default.gc_thresh3 = 4096
net.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_established = 3600
fs.inotify.max_queued_events = 99999999
fs.inotify.max_user_watches = 99999999
fs.inotify.max_user_instances = 65535
EOF

sysctl -p

cat >>/etc/profile << EOF
   export PS1='[\u@\h  \t \W]\\$'
   TMOUT=600
EOF

[ -z "$(grep ^'PROMPT_COMMAND=' /etc/bashrc)" ] && cat >> /etc/bashrc << EOF
PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });logger "[euid=\$(whoami)]":\$(who am i):[\`pwd\`]"\$msg"; }'
EOF

sed -ri.bak 's#^PASS_MAX_DAYS.*$#PASS_MAX_DAYS  180#g' /etc/login.defs
sed -i 's#^PASS_WARN_AGE.*$#PASS_WARN_AGE  25#g' /etc/login.defs
sed -i 's#^PASS_MIN_LEN.*$#PASS_MIN_LEN  11#g' /etc/login.defs
sed -ri.bak 's#^.*pam_pwquality.so.*$#password    requisite     pam_pwquality.so minlen=11 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1  try_first_pass local_users_only#g' /etc/pam.d/system-auth

pkgList="gcc gcc-c++ make cmake net-tools autoconf jemalloc-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio numactl-libs readline-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn-devel openssl openssl-devel libxslt-devel libicu-devel libevent-devel libtool  gd-devel vim-enhanced pcre-devel zip unzip ntpdate  sysstat patch bc nc telnet expect rsync git lsof lrzsz wget tcl"

for Package in ${pkgList}; do
  yum -y install ${Package}
done

#curl -o /etc/yum.repos.d/epel-OpenEuler.repo https://down.whsir.com/downloads/epel-OpenEuler.repo
yum -y update

reboot

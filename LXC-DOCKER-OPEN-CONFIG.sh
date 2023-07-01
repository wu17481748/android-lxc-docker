#!/bin/bash

FILE=$1

[ -f "$FILE" ] || {
	echo "Provide a config file as argument"
	exit
}

write=false

if [ "$2" = "-w" ]; then
	write=true
fi

CONFIGS_ON="

CONFIG_NAMESPACES
CONFIG_NET_NS
CONFIG_PID_NS
CONFIG_IPC_NS
CONFIG_UTS_NS
CONFIG_CGROUPS
CONFIG_CGROUP_CPUACCT
CONFIG_CGROUP_DEVICE
CONFIG_CGROUP_FREEZER
CONFIG_CGROUP_SCHED
CONFIG_CPUSETS
CONFIG_MEMCG
CONFIG_KEYS
CONFIG_VETH
CONFIG_BRIDGE
CONFIG_BRIDGE_NETFILTER
CONFIG_IP_NF_FILTER
CONFIG_IP_NF_TARGET_MASQUERADE
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE
CONFIG_NETFILTER_XT_MATCH_CONNTRACK
CONFIG_NETFILTER_XT_MATCH_IPVS
CONFIG_NETFILTER_XT_MARK
CONFIG_IP_NF_NAT
CONFIG_NF_NAT
CONFIG_POSIX_MQUEUE
CONFIG_NF_NAT_IPV4
CONFIG_NF_NAT_NEEDED
CONFIG_CGROUP_BPF
CONFIG_USER_NS
CONFIG_SECCOMP
CONFIG_SECCOMP_FILTER
CONFIG_CGROUP_PIDS
CONFIG_MEMCG_SWAP
CONFIG_MEMCG_SWAP_ENABLED
CONFIG_IOSCHED_CFQ
CONFIG_CFQ_GROUP_IOSCHED
CONFIG_BLK_CGROUP
CONFIG_BLK_DEV_THROTTLING
CONFIG_CGROUP_PERF
CONFIG_CGROUP_HUGETLB
CONFIG_NET_CLS_CGROUP
CONFIG_CGROUP_NET_PRIO
CONFIG_CFS_BANDWIDTH
CONFIG_FAIR_GROUP_SCHED
CONFIG_RT_GROUP_SCHED
CONFIG_IP_NF_TARGET_REDIRECT
CONFIG_IP_VS
CONFIG_IP_VS_NFCT
CONFIG_IP_VS_PROTO_TCP
CONFIG_IP_VS_PROTO_UDP
CONFIG_IP_VS_RR
CONFIG_SECURITY_SELINUX
CONFIG_SECURITY_APPARMOR
CONFIG_EXT4_FS
CONFIG_EXT4_FS_POSIX_ACL
CONFIG_EXT4_FS_SECURITY
CONFIG_VXLAN CONFIG_BRIDGE_VLAN_FILTERING
CONFIG_CRYPTO
CONFIG_CRYPTO_AEAD
CONFIG_CRYPTO_GCM
CONFIG_CRYPTO_SEQIV
CONFIG_CRYPTO_GHASH
CONFIG_XFRM
CONFIG_XFRM_USER
CONFIG_XFRM_ALGO
CONFIG_INET_ESP
CONFIG_INET_XFRM_MODE_TRANSPORT
CONFIG_IPVLAN
CONFIG_MACVLAN
CONFIG_DUMMY
CONFIG_NF_NAT_FTP
CONFIG_NF_CONNTRACK_FTP
CONFIG_NF_NAT_TFTP
CONFIG_NF_CONNTRACK_TFTP
CONFIG_AUFS_FS
CONFIG_BTRFS_FS
CONFIG_BTRFS_FS_POSIX_ACL
CONFIG_BLK_DEV_DM
CONFIG_DM_THIN_PROVISIONING
CONFIG_OVERLAY_FS
CONFIG_PACKET_DIAG
CONFIG_NETLINK_DIAG
CONFIG_FHANDLE
CONFIG_UNIX_DIAG
CONFIG_NF_NAT_IPV6
CONFIG_NETFILTER_XT_TARGET_CHECKSUM
CONFIG_ANDROID_PARANOID_NETWORK


"

CONFIGS_OFF="
"
CONFIGS_EQ="
"

ered() {
	echo -e "\033[31m" $@
}

egreen() {
	echo -e "\033[32m" $@
}

ewhite() {
	echo -e "\033[37m" $@
}

echo -e "\n\nChecking config file for Halium specific config options.\n\n"

errors=0
fixes=0

for c in $CONFIGS_ON $CONFIGS_OFF;do
	cnt=`grep -w -c $c $FILE`
	if [ $cnt -gt 1 ];then
		ered "$c appears more than once in the config file, fix this"
		errors=$((errors+1))
	fi

	if [ $cnt -eq 0 ];then
		if $write ; then
			ewhite "Creating $c"
			echo "# $c is not set" >> "$FILE"
			fixes=$((fixes+1))
		else
			ered "$c is neither enabled nor disabled in the config file"
			errors=$((errors+1))
		fi
	fi
done

for c in $CONFIGS_ON;do
	if grep "$c=y\|$c=m" "$FILE" >/dev/null;then
		egreen "$c is already set"
	else
		if $write ; then
			ewhite "Setting $c"
			sed  -i "s,# $c is not set,$c=y," "$FILE"
			fixes=$((fixes+1))
		else
			ered "$c is not set, set it"
			errors=$((errors+1))
		fi
	fi
done

for c in $CONFIGS_EQ;do
	lhs=$(awk -F= '{ print $1 }' <(echo $c))
	rhs=$(awk -F= '{ print $2 }' <(echo $c))
	if grep "^$c" "$FILE" >/dev/null;then
		egreen "$c is already set correctly."
		continue
	elif grep "^$lhs" "$FILE" >/dev/null;then
		cur=$(awk -F= '{ print $2 }' <(grep "$lhs" "$FILE"))
		ered "$lhs is set, but to $cur not $rhs."
		if $write ; then
			egreen "Setting $c correctly"
			sed -i 's,^'"$lhs"'.*,# '"$lhs"' was '"$cur"'\n'"$c"',' "$FILE"
			fixes=$((fixes+1))
		fi
	else
		if $write ; then
			ewhite "Setting $c"
			echo  "$c" >> "$FILE"
			fixes=$((fixes+1))
		else
			ered "$c is not set"
			errors=$((errors+1))
		fi
	fi
done

for c in $CONFIGS_OFF;do
	if grep "$c=y\|$c=m" "$FILE" >/dev/null;then
		if $write ; then
			ewhite "Unsetting $c"
			sed  -i "s,$c=.*,# $c is not set," $FILE
			fixes=$((fixes+1))
		else
			ered "$c is set, unset it"
			errors=$((errors+1))
		fi
	else
		egreen "$c is already unset"
	fi
done

if [ $errors -eq 0 ];then
	egreen "\n\nConfig file checked, found no errors.\n\n"
else
	ered "\n\nConfig file checked, found $errors errors that I did not fix.\n\n"
fi

if [ $fixes -gt 0 ];then
	egreen "开启docker-lxc配置 $fixes 项.\n\n"
fi

ewhite " "

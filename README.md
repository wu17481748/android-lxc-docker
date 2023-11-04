# 安卓lxc-docker内核修改

# 开启配置

./LXC-DOCKER-OPEN-CONFIG.sh <xxx_defconfig> -w

# 关闭:ANDROID_PARANOID_NETWORK

#..CONFIG_ANDROID_PARANOID_NETWORK is not set

# 打补丁1
xt_qtagui.patch

# 打补丁2
cgroup.patch

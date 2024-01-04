# 安卓lxc-docker内核修改

# 开启配置

./LXC-DOCKER-OPEN-CONFIG.sh <xxx_defconfig> -w

# 关闭:ANDROID_PARANOID_NETWORK

#..CONFIG_ANDROID_PARANOID_NETWORK is not set

# 打补丁1(有则打无则过)
xt_qtagui.patch

--- a/net/netfilter/xt_qtaguid.c	2023-07-02 00:07:55.000000000 +0800
+++ a/net/netfilter/xt_qtaguid.c	2023-07-02 05:20:40.000000000 +0800
@@ -738,7 +738,7 @@ static int iface_stat_fmt_proc_show(stru
 {
 	struct proc_iface_stat_fmt_info *p = m->private;
 	struct iface_stat *iface_entry;
-	struct rtnl_link_stats64 dev_stats, *stats;
+	struct rtnl_link_stats64 *stats;
 	struct rtnl_link_stats64 no_dev_stats = {0};
 
 
@@ -747,12 +747,7 @@ static int iface_stat_fmt_proc_show(stru
 
 	iface_entry = list_entry(v, struct iface_stat, list);
 
-	if (iface_entry->active) {
-		stats = dev_get_stats(iface_entry->net_dev,
-				      &dev_stats);
-	} else {
-		stats = &no_dev_stats;
-	}
+	stats = &no_dev_stats;
 	/*
 	 * If the meaning of the data changes, then update the fmtX
 	 * string.
   * 
# 打补丁2(找准cgroup.c文件和函数位置打)
cgroup.patch

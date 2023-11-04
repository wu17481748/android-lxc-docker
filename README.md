# lxc-docker

# 开启配置

./LXC-DOCKER-OPEN-CONFIG.sh <xxx_defconfig> -w

关闭:ANDROID_PARANOID_NETWORK

# CONFIG_ANDROID_PARANOID_NETWORK is not set

# 打补丁1

--- orig/net/netfilter/xt_qtaguid.c     2020-05-12 12:13:14.000000000 +0300
+++ my/net/netfilter/xt_qtaguid.c       2019-09-15 23:56:45.000000000 +0300
@@ -737,7 +737,7 @@
{
        struct proc_iface_stat_fmt_info *p = m->private;
        struct iface_stat *iface_entry;
-       struct rtnl_link_stats64 dev_stats, *stats;
+       struct rtnl_link_stats64 *stats;
        struct rtnl_link_stats64 no_dev_stats = {0};  
@@ -745,13 +745,8 @@
        current->pid, current->tgid, from_kuid(&init_user_ns, current_fsuid()));
        iface_entry = list_entry(v, struct iface_stat, list);
+       stats = &no_dev_stats; 
-       if (iface_entry->active) {
-               stats = dev_get_stats(iface_entry->net_dev,
-                                     &dev_stats);
-       } else {
-               stats = &no_dev_stats;
-       }
        /*
         * If the meaning of the data changes, then update the fmtX
         * string.


# 打补丁2

--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -3786,6 +3786,10 @@ static int cgroup_add_file(struct cgroup_subsys_state *css, struct cgroup *cgrp,
 		cfile->kn = kn;
 		spin_unlock_irq(&cgroup_file_kn_lock);
 	}
+	if (cft->ss && (cgrp->root->flags & CGRP_ROOT_NOPREFIX) && !(cft->flags & CFTYPE_NO_PREFIX)) {
+				snprintf(name, CGROUP_FILE_NAME_MAX, "%s.%s", cft->ss->name, cft->name);
+				kernfs_create_link(cgrp->kn, name, kn);
+	}
 
 	return 0;

 }
 


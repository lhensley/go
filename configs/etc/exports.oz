# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#

/mnt/5TBC			192.168.168.0/24(no_subtree_check,no_root_squash,rw)
/mnt/12TBC			192.168.168.0/24(no_subtree_check,no_root_squash,rw)
/mnt/ext10tb01		192.168.168.0/24(no_subtree_check,no_root_squash,rw)
/mnt/ssd1tb			192.168.168.0/24(no_subtree_check,no_root_squash,rw)

# Use sudo -i to load a root shell before using either of these:
# To apply revisions after editing this file:     exportfs -r
# To restart export server (using sudo -i):       if (killall -HUP rpc.nfsd && killall -HUP rpc.mountd); then /bin/true; else (/etc/init.d/nfs-*server stop ; /etc/init.d/nfs-*server start) fi

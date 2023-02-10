# Tp 6 Linux

## Module 1 : Reverse Proxy

#### *I. Setup*

**On utilisera NGINX comme reverse proxy :**

```bash
[user1@proxy ~]$ sudo dnf install nginx
...
Complete!
[user1@proxy ~]$ sudo systemctl start nginx
[user1@proxy ~]$ sudo ss -lapunt | grep nginx
tcp   LISTEN 0      511             0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1012,fd=6),("nginx",pid=1011,fd=6))
tcp   LISTEN 0      511                [::]:80           [::]:*    users:(("nginx",pid=1012,fd=7),("nginx",pid=1011,fd=7))
[user1@proxy ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user1@proxy ~]$ sudo firewall-cmd --reload
success
root        1011       1  0 10:35 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1012    1011  0 10:35 ?        00:00:00 nginx: worker process
[user1@proxy ~]$ curl 10.105.1.13:80
<!doctype html>
<html>
...
</html>
```

**Configurer NGINX :**

## Module 2 : Sauvegarde du système de fichiers

#### *I. Script de backup*

##### *1. Ecriture du script*

**Ecrire le script bash :**

```bash
[user1@web ~]$ cat /srv/tp6_backup.sh
#!/bin/bash
# scirpt de back up du serveur nginx vers /srv/backup
#ecrit le  230116
#writting by Samy

name="nextcloud$(date +%s)"


zip -r /srv/backup/"$name".zip  /var/www/tp5_nextcloud/config/ /var/www/tp5_nextcloud/data/ /var/www/tp5_nextcloud/themes/


echo "$name"
```

##### *2. Clean it*

##### *3. Service et timer*

**Créez un service :**

```bash
[user1@web ~]$ cat /etc/systemd/system/backup.service
[UNIT]
Description=faire une backup du fichier tp5-nextcloud

[Service]
Type=oneshot
ExecStart=/bin/bash /srv/tp6_backup.sh

[Install]
WantedBy=multi-user.target
[user1@web ~]$ sudo systemctl start backup
[user1@web ~]$ sudo systemctl status backup
○ backup.service
     Loaded: loaded (/etc/systemd/system/backup.service; disabled; vendor preset: disabled)
     Active: inactive (dead)
```

**Créez un timer :**

```bash
[user1@web ~]$ cat /etc/systemd/system/backup.timer
[Unit]
Description=Run service X

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```

**Activez l'utilisation du timer :**

```bash
[user1@web ~]$ sudo systemctl daemon-reload
[user1@web ~]$ sudo systemctl start backup.timer
[user1@web ~]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
[user1@web ~]$ sudo systemctl status backup.timer
● backup.timer - Run service X
     Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor preset: disabled)
     Active: active (waiting) since Tue 2023-01-17 17:21:01 CET; 17s ago
      Until: Tue 2023-01-17 17:21:01 CET; 17s ago
    Trigger: Wed 2023-01-18 04:00:00 CET; 10h left
   Triggers: ● backup.service

Jan 17 17:21:01 web.tp5.linux systemd[1]: Started Run service X.
[user1@web ~]$ sudo systemctl list-timers
NEXT                        LEFT       LAST                        PASSED       UNIT                         ACTIVATES
Tue 2023-01-17 17:36:17 CET 13min left Tue 2023-01-17 16:33:28 CET 49min ago    dnf-makecache.timer          dnf-makecache.service
Wed 2023-01-18 00:00:00 CET 6h left    Tue 2023-01-17 14:07:35 CET 3h 14min ago logrotate.timer              logrotate.service
Wed 2023-01-18 04:00:00 CET 10h left   n/a                         n/a          backup.timer                 backup.service
Wed 2023-01-18 14:22:39 CET 21h left   Tue 2023-01-17 14:22:39 CET 2h 59min ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

4 timers listed.
Pass --all to see loaded but inactive timers, too.
```

#### *II. NFS*

##### *1. Serveur NFS*

**Préparer un dossier à partager sur le réseau :**

```bash
[user1@storage ~]$ sudo mkdir /srv/nfs_shares
[user1@storage ~]$ sudo mkdir /srv/nfs_shares/web.tp6.linux/
```

**Installer le serveur NFS :**

```bash
[user1@storage ~]$ sudo dnf install nfs-utils
...
Complete!
```

## Module 3 : Fail2Ban

**Faites en sorte que :**

```bash!
[user1@dbdb ~]$ cat /etc/fail2ban/jail.local
[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
filter = sshd
maxretry = 3
findtime = 60
bantime = 3600
[user1@dbdb ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   10.105.1.11
[user1@dbdb ~]$ sudo iptables -S
-A f2b-sshd -s 10.105.1.11/32 -j REJECT --reject-with icmp-port-unreachable
[user1@dbdb ~]$ sudo fail2ban-client set sshd unbanip 10.105.1.11
1
```

## Module 4 : Monitoring

**Installer Netdata :**

```bash
[user1@web ~]$ curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh
Complete!
[user1@dbdb ~]$ sudo firewall-cmd --add-port=19999/tcp --permanent
success
[user1@dbdb ~]$ sudo firewall-cmd --reload
success
```

**Une fois Netdata installé et fonctionnel, déterminer :**

```bash
[user1@web ~]$ sudo ps -ef | grep netdata
netdata     1523       1  0 14:58 ?        00:00:03 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
netdata     1525    1523  0 14:58 ?        00:00:00 /usr/sbin/netdata --special-spawn-server
netdata     1726    1523  0 14:58 ?        00:00:00 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
netdata     1729    1523  0 14:58 ?        00:00:02 /usr/libexec/netdata/plugins.d/apps.plugin 1
root        1731    1523  0 14:58 ?        00:00:00 /usr/libexec/netdata/plugins.d/ebpf.plugin 1
netdata     1738    1523  0 14:58 ?        00:00:00 /usr/libexec/netdata/plugins.d/go.d.plugin 1
[user1@web ~]$ sudo ss -laputn | grep netdata
udp   UNCONN 0      0             127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=1523,fd=40))
udp   UNCONN 0      0                 [::1]:8125          [::]:*    users:(("netdata",pid=1523,fd=39))
tcp   LISTEN 0      4096          127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=1523,fd=42))
tcp   LISTEN 0      4096            0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=1523,fd=6))
tcp   LISTEN 0      4096              [::1]:8125          [::]:*    users:(("netdata",pid=1523,fd=41))
tcp   LISTEN 0      4096               [::]:19999         [::]:*    users:(("netdata",pid=1523,fd=7))
[user1@web ~]$ cat /var/log/netdata/
access.log  debug.log   error.log   health.log
```

**Configurer Netdata pour qu'il vous envoie des alertes :**

```bash
[user1@dbdb ~]$ cat /etc/netdata/health_alarm-notify.conf
###############################################################################
# sending discord notifications

# note: multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/1064913016283480095/s44gCy5E0n81M-fSTRKaRdyHPXVc9mmHMKzeohiMRI8bvoNXP0SeQjj2hoLl0AXmsR68"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="alerte-leo"
```

**Vérifier que les alertes fonctionnent :**

```bash
[user1@dbdb ~]$ for i in $(seq $(getconf _NPROCESSORS_ONLN)); do yes > /dev/null & done
[1] 3036
```
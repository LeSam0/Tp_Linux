# Tp 2 Linux

## I. Service SSH 

#### *1.  Analyse du service*

**S'assurer que le service sshd est démarré:**

```powershell
[user1@localhost ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: ena>
     Active: active (running) since Mon 2022-12-05 11:12:57 CET; 1min 37s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 688 (sshd)
      Tasks: 1 (limit: 5906)
     Memory: 5.8M
        CPU: 46ms
     CGroup: /system.slice/sshd.service
             └─688 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
```

**Analyser les processus liés au service SSH:**

```powershell
[user1@localhost ~]$ ps -ef | grep sshd
root         688       1  0 11:12 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         862     688  0 11:13 ?        00:00:00 sshd: user1 [priv]
user1        866     862  0 11:14 ?        00:00:00 sshd: user1@pts/0
user1        891     867  0 11:17 pts/0    00:00:00 grep --color=auto sshd
```

**Déterminer le port sur lequel écoute le service SSH:**

```powershell
[user1@localhost ~]$ sudo ss -alnpt | grep sshd
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=688,fd=3))
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=688,fd=4))
```

**Consulter les logs du service SSH:**

```powershell
[user1@localhost ~]$ sudo cat /var/log/secure | grep sshd
Oct 14 11:08:28 localhost sshd[825]: Server listening on 0.0.0.0 port 22.
Oct 14 11:08:28 localhost sshd[825]: Server listening on :: port 22.
Oct 14 11:21:25 localhost sshd[825]: Received signal 15; terminating.
Oct 14 11:21:25 localhost sshd[30038]: Server listening on 0.0.0.0 port 22.
Oct 14 11:21:25 localhost sshd[30038]: Server listening on :: port 22.
Dec  5 11:01:24 localhost sshd[682]: Server listening on 0.0.0.0 port 22.
Dec  5 11:01:24 localhost sshd[682]: Server listening on :: port 22.
Dec  5 11:12:57 localhost sshd[688]: Server listening on 0.0.0.0 port 22.
Dec  5 11:12:57 localhost sshd[688]: Server listening on :: port 22.
Dec  5 11:14:04 localhost sshd[862]: Accepted password for user1 from 10.3.2.1 port 51181 ssh2
Dec  5 11:14:04 localhost sshd[862]: pam_unix(sshd:session): session opened for user user1(uid=1000) by (uid=0)
```

```powershell
[user1@localhost ~]$ sudo journalctl | grep sshd
Dec 05 11:12:56 localhost systemd[1]: Created slice Slice /system/sshd-keygen.
Dec 05 11:12:56 localhost systemd[1]: Reached target sshd-keygen.target.
Dec 05 11:12:57 localhost sshd[688]: Server listening on 0.0.0.0 port 22.
Dec 05 11:12:57 localhost sshd[688]: Server listening on :: port 22.
Dec 05 11:14:04 localhost.localdomain sshd[862]: Accepted password for user1 from 10.3.2.1 port 51181 ssh2
Dec 05 11:14:04 localhost.localdomain sshd[862]: pam_unix(sshd:session): session opened for user user1(uid=1000) by (uid=0)
```

#### *2. Modification du service*

**Identifier le fichier de configuration du serveur SSH:**

```powershell
[user1@localhost ~]$ cat /etc/ssh/sshd_config
```

**Modifier le fichier de conf:**

```powershell
[user1@localhost ~]$ echo $RANDOM
1374
[user1@localhost ~]$ sudo nano cd /etc/ssh/sshd_config
[user1@localhost ~]$ sudo cat cd /etc/ssh/sshd_config | grep -i port
Port 1374
```

```powershell
[user1@localhost ~]$ sudo firewall-cmd --remove-port=22/tcp --permanent
Warning: NOT_ENABLED: 22:tcp
success
[user1@localhost ~]$ sudo firewall-cmd --add-port=1374/tcp --permanent
success
[user1@localhost ~]$ sudo firewall-cmd --reload
success
[user1@localhost ~]$ sudo firewall-cmd --list-all | grep 1374
  ports: 1374/tcp
```

**Redémarrer le service:**

```powershell
[user1@localhost ~]$ systemctl restart sshd
```

**Effectuer une connexion SSH sur le nouveau port:**

```powershell
PS C:\Users\samyd> ssh user1@10.3.2.52 -p 1374
user1@10.3.2.52's password:
Last login: Mon Dec  5 12:06:41 2022 from 10.3.2.1
[user1@localhost ~]$
```
**Bonus : affiner la conf du serveur SSH:**



## II. Service HTTP 

#### *1. Mise en place*

**Installer le serveur NGINX:**

```powershell
[user1@localhost ~]$ sudo dnf install nginx
[sudo] password for user1:
Last metadata expiration check: 0:07:40 ago on Mon 05 Dec 2022 12:19:13 PM CET.
Dependencies resolved.
============================================================================
 Package               Arch       Version               Repository     Size
============================================================================
Installing:
 nginx                 x86_64     1:1.20.1-13.el9       appstream      38 k
Installing dependencies:
 nginx-core            x86_64     1:1.20.1-13.el9       appstream     567 k
 nginx-filesystem      noarch     1:1.20.1-13.el9       appstream      11 k
 rocky-logos-httpd     noarch     90.13-1.el9           appstream      24 k

Transaction Summary
============================================================================
Install  4 Packages

Total download size: 640 k
Installed size: 1.8 M
Is this ok [y/N]: y
Downloading Packages:
(1/4): nginx-filesystem-1.20.1-13.el9.noarc  29 kB/s |  11 kB     00:00
(2/4): rocky-logos-httpd-90.13-1.el9.noarch  36 kB/s |  24 kB     00:00
(3/4): nginx-1.20.1-13.el9.x86_64.rpm        54 kB/s |  38 kB     00:00
(4/4): nginx-core-1.20.1-13.el9.x86_64.rpm  631 kB/s | 567 kB     00:00
----------------------------------------------------------------------------
Total                                       264 kB/s | 640 kB     00:02
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                    1/1
  Running scriptlet: nginx-filesystem-1:1.20.1-13.el9.noarch            1/4
  Installing       : nginx-filesystem-1:1.20.1-13.el9.noarch            1/4
  Installing       : nginx-core-1:1.20.1-13.el9.x86_64                  2/4
  Installing       : rocky-logos-httpd-90.13-1.el9.noarch               3/4
  Installing       : nginx-1:1.20.1-13.el9.x86_64                       4/4
  Running scriptlet: nginx-1:1.20.1-13.el9.x86_64                       4/4
  Verifying        : rocky-logos-httpd-90.13-1.el9.noarch               1/4
  Verifying        : nginx-filesystem-1:1.20.1-13.el9.noarch            2/4
  Verifying        : nginx-1:1.20.1-13.el9.x86_64                       3/4
  Verifying        : nginx-core-1:1.20.1-13.el9.x86_64                  4/4

Installed:
  nginx-1:1.20.1-13.el9.x86_64
  nginx-core-1:1.20.1-13.el9.x86_64
  nginx-filesystem-1:1.20.1-13.el9.noarch
  rocky-logos-httpd-90.13-1.el9.noarch

Complete!
```

**Démarrer le service NGINX:**

```powershell
[user1@localhost ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[user1@localhost ~]$ sudo systemctl start nginx
```

**Démarrer le service NGINX:**

```powershell
[user1@localhost ~]$ sudo systemctl start nginx
```

**Déterminer sur quel port tourne NGINX:**

```powershell
[user1@localhost ~]$ cat /etc/nginx/nginx.conf | grep -i listen
        listen       80;
        listen       [::]:80;
```

**Déterminer les processus liés à l'exécution de NGINX:**

```powershell
[user1@localhost ~]$ ps -ef | grep -i nginx
root         805       1  0 10:17 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx        808     805  0 10:17 ?        00:00:00 nginx: worker process
```

**Euh wait:**

```powershell
samyd@PC-Samy MINGW64 ~
$ curl 10.3.2.52:80 | head -7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  7751k      0 --:--:-- --:--:-- --:--:-- 7441k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```

#### *2. Analyser la conf de NGINX*

**Déterminer le path du fichier de configuration de NGINX:**

```powershell
[user1@localhost ~]$ ls -al /etc/nginx/
total 84
drwxr-xr-x.  4 root root 4096 Dec  5 12:27 .
drwxr-xr-x. 78 root root 8192 Dec  6 10:17 ..
drwxr-xr-x.  2 root root    6 Oct 31 16:37 conf.d
drwxr-xr-x.  2 root root    6 Oct 31 16:37 default.d
-rw-r--r--.  1 root root 1077 Oct 31 16:37 fastcgi.conf
-rw-r--r--.  1 root root 1077 Oct 31 16:37 fastcgi.conf.default
-rw-r--r--.  1 root root 1007 Oct 31 16:37 fastcgi_params
-rw-r--r--.  1 root root 1007 Oct 31 16:37 fastcgi_params.default
-rw-r--r--.  1 root root 2837 Oct 31 16:37 koi-utf
-rw-r--r--.  1 root root 2223 Oct 31 16:37 koi-win
-rw-r--r--.  1 root root 5231 Oct 31 16:37 mime.types
-rw-r--r--.  1 root root 5231 Oct 31 16:37 mime.types.default
-rw-r--r--.  1 root root 2334 Oct 31 16:37 nginx.conf
-rw-r--r--.  1 root root 2656 Oct 31 16:37 nginx.conf.default
-rw-r--r--.  1 root root  636 Oct 31 16:37 scgi_params
-rw-r--r--.  1 root root  636 Oct 31 16:37 scgi_params.default
-rw-r--r--.  1 root root  664 Oct 31 16:37 uwsgi_params
-rw-r--r--.  1 root root  664 Oct 31 16:37 uwsgi_params.default
-rw-r--r--.  1 root root 3610 Oct 31 16:37 win-utf
```

**Trouver dans le fichier de conf:**

```powershell
[user1@localhost ~]$ cat /etc/nginx/nginx.conf | grep "server {" -A 19
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

```

```powershell
[user1@localhost ~]$ cat /etc/nginx/nginx.conf | grep conf
 include /etc/nginx/conf.d/*.conf;
```

#### *3. Déployer un nouveau site web*

**Créer un site web:**

```powershell
[user1@localhost ~]$ sudo cat /var/www/tp2_linux/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>MEOW mon premier serveur web</h1>
</body>
</html>
[user1@localhost ~]$ cat /var/www/tp2_linux/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>MEOW mon premier serveur web</h1>
</body>
</html>
```

**Adapter la conf NGINX:**

```powershell
[user1@localhost ~]$ cat /etc/nginx/conf.d/text.conf
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen 25687;

  root /var/www/tp2_linux;
}
```

**Visitez votre super site web:**

```powershell
samyd@PC-Samy MINGW64 ~
$ curl 10.3.2.52:25687
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   301  100   301    0     0   297k      0 --:--:-- --:--:-- --:--:--  293k<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>MEOW mon premier serveur web</h1>
</body>
</html>
```

## III. Your own services

#### *1. Au cas où vous auriez oublié*

#### *2. Analyse des services existants*

**Afficher le fichier de service SSH:**

```powershell
[user1@localhost ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service;
[user1@localhost ~]$ cat /usr/lib/systemd/system/sshd.service | grep ExecStart=
ExecStart=/usr/sbin/sshd -D $OPTIONS
```

```powershell
[user1@localhost ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service;
[user1@localhost ~]$ cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
```

#### *3. Création de service*

**Créez le fichier /etc/systemd/system/tp2_nc.service:**

```powershell!
[user1@localhost ~]$ cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 8596
```

**Indiquer au système qu'on a modifié les fichiers de service:**

```powershell!
[user1@localhost ~]$ sudo systemctl daemon-reload
```

**Démarrer notre service de ouf:**

```powershell!
[user1@localhost ~]$ sudo systemctl start tp2_nc
```

**Vérifier que ça fonctionne:**

```powershell!
[user1@localhost ~]$ systemctl status tp2_nc
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Tue 2022-12-06 11:46:04 CET; 2min 31s ago
   Main PID: 1194 (nc)
      Tasks: 1 (limit: 5906)
     Memory: 788.0K
        CPU: 2ms
     CGroup: /system.slice/tp2_nc.service
             └─1194 /usr/bin/nc -l 8596

Dec 06 11:46:04 localhost.localdomain systemd[1]: Started Super netcat tout fou.
[user1@localhost ~]$ sudo ss -lapnt | grep nc
LISTEN 0      10           0.0.0.0:8596       0.0.0.0:*     users:(("nc",pid=1194,fd=4))
LISTEN 0      10              [::]:8596          [::]:*     users:(("nc",pid=1194,fd=3))
```


**Les logs de votre service:**

```powershell!
[user1@localhost ~]$ sudo journalctl -xe -u tp2_nc | grep -i start
Dec 06 11:46:04 localhost.localdomain systemd[1]: Started Super netcat tout fou.
[user1@localhost ~]$ sudo journalctl -xe -u tp2_nc | grep -i coucou
Dec 06 11:58:04 localhost.localdomain nc[1194]: coucou
[user1@localhost ~]$ sudo journalctl -xe -u tp2_nc | grep -i deactivate
Dec 06 11:59:29 localhost.localdomain systemd[1]: tp2_nc.service: Deactivated successfully.
```

**Affiner la définition du service:**

```powershell!
[user1@localhost ~]$ cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 8596
Restart=always
[user1@localhost ~]$ sudo systemctl daemon-reload
[user1@localhost ~]$ sudo systemctl start tp2_nc
```
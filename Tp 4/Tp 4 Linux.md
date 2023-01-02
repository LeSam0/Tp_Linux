# Tp 4 Linux

## Partie 1 : Partitionnement du serveur de stockage

**Partitionner le disque à l'aide de LVM :**

```powershell
[user1@stockage ~]$ sudo pvcreate /dev/sdb
[sudo] password for user1:
  Physical volume "/dev/sdb" successfully created.
[user1@stockage ~]$ sudo pvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB6d7c74cf-2af9af11_ PVID 5TqpRlbm3BgecM8ZUWsg0cUybghd4Rse last seen on /dev/sda2 not found.
  PV         VG Fmt  Attr PSize PFree
  /dev/sdb      lvm2 ---  2.00g 2.00g
```
```powershell
[user1@stockage ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
[user1@stockage ~]$ sudo vgs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB6d7c74cf-2af9af11_ PVID 5TqpRlbm3BgecM8ZUWsg0cUybghd4Rse last seen on /dev/sda2 not found.
  VG      #PV #LV #SN Attr   VSize  VFree
  storage   1   0   0 wz--n- <2.00g <2.00g
```
```powershell
[user1@stockage ~]$ sudo lvcreate -l 100%FREE storage -n lvstorage
  Logical volume "lvstorage" created.
[user1@stockage ~]$ sudo lvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB6d7c74cf-2af9af11_ PVID 5TqpRlbm3BgecM8ZUWsg0cUybghd4Rse last seen on /dev/sda2 not found.
  LV        VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvstorage storage -wi-a----- <2.00g
```

**Formater la partition :**

```powershell
[user1@stockage ~]$ sudo mkfs -t ext4 /dev/storage/lvstorage
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 3396c99c-b6b7-4952-93f0-aa0792b63180
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

**Monter la partition :**

```powershell
[user1@stockage ~]$ sudo mkdir /storage
[user1@stockage ~]$ sudo mount /dev/storage/lvstorage /storage
[user1@stockage ~]$ df -h | grep storage
/dev/mapper/storage-lvstorage  2.0G   24K  1.9G   1% /storage
[user1@stockage ~]$ cd /storage
[user1@stockage storage]$ sudo nano test
[user1@stockage storage]$ cat test
ceci est un test
```
```powershell
[user1@stockage storage]$ cat /etc/fstab | grep storage
/dev/storage/lvstorage /storage                 ext4    defaults        0 0
[user1@stockage /]$ sudo umount /storage
[user1@stockage /]$ sudo mount -av
mount: /storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/storage                 : successfully mounted
```

## Partie 2 : Serveur de partage de fichiers

**Donnez les commandes réalisées sur le serveur NFS storage.tp4.linux :**

```powershell
[user1@stockage ~]$ sudo dnf install nfs-utils
[user1@stockage ~]$ sudo mkdir /storage/site_web_1 -p
[user1@stockage ~]$ sudo mkdir /storage/site_web_2 -p
[[user1@stockage ~]$ ls -dl /storage/site_web_1
drwxr-xr-x. 2 root root 6 Dec 13 11:48 /storage/site_web_1
[user1@stockage ~]$ ls -dl /storage/site_web_2
drwxr-xr-x. 2 root root 6 Dec 13 11:48 /storage/site_web_2
[user1@stockage ~]$ sudo chown nobody /storage/site_web_1
[user1@stockage ~]$ sudo chown nobody /storage/site_web_2
[user1@stockage ~]$ sudo nano /etc/exports
[[user1@stockage ~]$ cat /etc/exports
/storage/site_web_1    10.3.2.53(rw,sync,no_subtree_check)
/storage/site_web_2    10.3.2.53(rw,sync,no_subtree_check)
/home
[user1@stockage ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[user1@stockage ~]$ sudo systemctl start nfs-server
[user1@stockage ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor prese>
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Tue 2022-12-13 11:44:09 CET; 10min ago
   Main PID: 4498 (code=exited, status=0/SUCCESS)
        CPU: 15ms

Dec 13 11:44:09 toto.toto systemd[1]: Starting NFS server and services...
Dec 13 11:44:09 toto.toto systemd[1]: Finished NFS server and services.
[user1@toto ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[user1@toto ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[user1@toto ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[user1@toto ~]$ sudo firewall-cmd --reload
success
[user1@toto ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```

**Donnez les commandes réalisées sur le serveur NFS storage.tp4.linux :**

```powershell
[user1@toto ~]$ sudo dnf install nfs-utils
[user1@toto ~]$ sudo mkdir -p /var/www/site_web_1/
[user1@toto ~]$ sudo mkdir -p /var/www/site_web_2/
[user1@toto ~]$ sudo mkdir -p /storage/home
[user1@web ~]$ df -h
10.3.2.52:/storage/site_web_2  2.0G     0  1.9G   0% /storage/site_web_2
10.3.2.52:/storage/site_web_1  2.0G     0  1.9G   0% /storage/site_web_1
[user1@web ~]$ cat /etc/fstab
10.3.2.52:/storage/site_web_1    /var/www/site_web_1   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
10.3.2.52:/storage/site_web_2    /var/www/site_web_2   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
[user1@web ~]$ sudo umount /var/www/site_web_1
[user1@web ~]$ sudo umount /var/www/site_web_2
[user1@web ~]$ df -h
Filesystem                     Size  Used Avail Use% Mounted on
devtmpfs                       462M     0  462M   0% /dev
tmpfs                          481M     0  481M   0% /dev/shm
tmpfs                          193M  3.0M  190M   2% /run
/dev/mapper/rl-root            6.2G  1.2G  5.1G  19% /
/dev/sda1                     1014M  210M  805M  21% /boot
tmpfs                           97M     0   97M   0% /run/user/1000
10.3.2.52:/storage/site_web_2  2.0G     0  1.9G   0% /storage/site_web_2
10.3.2.52:/storage/site_web_1  2.0G     0  1.9G   0% /storage/site_web_1
```

## Partie 3 : Serveur web

#### *2. Install*

**Installez NGINX :**

```powershell
[user1@web ~]$ sudo dnf install nginx
[sudo] password for user1:
Rocky Linux 9 - BaseOS                                 5.9 kB/s | 3.6 kB     00:00
Rocky Linux 9 - BaseOS                                 2.7 MB/s | 1.7 MB     00:00
Rocky Linux 9 - AppStream                              8.3 kB/s | 4.1 kB     00:00
Rocky Linux 9 - AppStream                              6.1 MB/s | 6.4 MB     00:01
Rocky Linux 9 - Extras                                 5.9 kB/s | 2.9 kB     00:00
Rocky Linux 9 - Extras                                 269  B/s | 8.3 kB     00:31
Package nginx-1:1.20.1-13.el9.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```

#### *3. Analyse*

**Analysez le service NGINX :**

```powershell!
[user1@web ~]$ sudo ps -ef | grep nginx
root         851       1  0 09:05 ?        00:00:00 nginx: master process /usr/sbin/nginx
```
```powershell!
[user1@web ~]$ sudo ss -alpnt | grep nginx
[sudo] password for user1:
LISTEN 0      511          0.0.0.0:25687      0.0.0.0:*    users:(("nginx",pid=853,fd=6),("nginx",pid=851,fd=6))
```
```powershell
[user1@web ~]$ cat /etc/nginx/nginx.conf | grep root
            root   /usr/share/nginx/html;
```
```powershell
[user1@web ~]$ ls -l /usr/share/nginx/html/
total 12
-rw-r--r--. 1 root root 3332 Oct 31 16:35 404.html
-rw-r--r--. 1 root root 3404 Oct 31 16:35 50x.html
drwxr-xr-x. 2 root root   27 Dec  5 12:27 icons
lrwxrwxrwx. 1 root root   25 Oct 31 16:37 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct 31 16:35 nginx-logo.png
lrwxrwxrwx. 1 root root   14 Oct 31 16:37 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 Oct 31 16:37 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png
```
#### *4. Visite du service web*

**Configurez le firewall pour autoriser le trafic vers le service NGINX :**

```powershell
[user1@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[user1@web ~]$ sudo firewall-cmd --reload
success
```

**Accéder au site web :**

```powershell
PS C:\Users\samyd> curl 10.3.2.53:80


StatusCode        : 200
StatusDescription : OK
Content           : <!doctype html>
                    <html>
                      <head>
                        <meta charset='utf-8'>
                        <meta name='viewport' content='width=device-width,
                    initial-scale=1'>
                        <title>HTTP Server Test Page powered by: Rocky Linux</title>
                       ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 7620
                    Content-Type: text/html
                    Date: Mon, 02 Jan 2023 08:57:24 GMT
                    ETag: "62e17e64-1dc4"
                    Last-Modified: Wed, 27 Jul 202...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 7620], [Content-Type, text/html]...}
Images            : {@{innerHTML=; innerText=; outerHTML=<IMG alt="[ Powered by Rocky
                    Linux ]" src="icons/poweredby.png">; outerText=; tagName=IMG;
                    alt=[ Powered by Rocky Linux ]; src=icons/poweredby.png},
                    @{innerHTML=; innerText=; outerHTML=<IMG src="poweredby.png">;
                    outerText=; tagName=IMG; src=poweredby.png}}
InputFields       : {}
Links             : {@{innerHTML=<STRONG>Rocky Linux website</STRONG>;
                    innerText=Rocky Linux website; outerHTML=<A
                    href="https://rockylinux.org/"><STRONG>Rocky Linux
                    website</STRONG></A>; outerText=Rocky Linux website; tagName=A;
                    href=https://rockylinux.org/}, @{innerHTML=Apache
                    Webserver</STRONG>; innerText=Apache Webserver; outerHTML=<A
                    href="https://httpd.apache.org/">Apache Webserver</STRONG></A>;
                    outerText=Apache Webserver; tagName=A;
                    href=https://httpd.apache.org/}, @{innerHTML=Nginx</STRONG>;
                    innerText=Nginx; outerHTML=<A
                    href="https://nginx.org">Nginx</STRONG></A>; outerText=Nginx;
                    tagName=A; href=https://nginx.org}, @{innerHTML=<IMG alt="[
                    Powered by Rocky Linux ]" src="icons/poweredby.png">; innerText=;
                    outerHTML=<A id=rocky-poweredby
                    href="https://rockylinux.org/"><IMG alt="[ Powered by Rocky Linux
                    ]" src="icons/poweredby.png"></A>; outerText=; tagName=A;
                    id=rocky-poweredby; href=https://rockylinux.org/}...}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 7620
```

**Vérifier les logs d'accès :**

```powershell
[user1@web ~]$ sudo cat /var/log/nginx/access.log | tail -n3
10.3.2.1 - - [02/Jan/2023:09:54:51 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://10.3.2.53/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
10.3.2.1 - - [02/Jan/2023:09:54:51 +0100] "GET /favicon.ico HTTP/1.1" 404 555 "http://10.3.2.53/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
10.3.2.1 - - [02/Jan/2023:09:57:24 +0100] "GET / HTTP/1.1" 200 7620 "-" "Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.22000.1335"
```

#### *5. Modif de la conf du serveur web*

**Changer le port d'écoute :**
```powershell
[user1@web ~]$ cat /etc/nginx/nginx.conf | grep listen
        listen       8080;
```
```powershell
[user1@web ~]$ sudo systemctl restart nginx
[user1@web ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: di>
     Active: active (running) since Mon 2023-01-02 10:01:47 CET; 13s ago
    Process: 1251 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SU>
    Process: 1252 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1253 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1254 (nginx)
      Tasks: 2 (limit: 5906)
     Memory: 1.9M
        CPU: 13ms
     CGroup: /system.slice/nginx.service
             ├─1254 "nginx: master process /usr/sbin/nginx"
             └─1255 "nginx: worker process"

Jan 02 10:01:47 web.tp4.linux.web.tp4.linux systemd[1]: Starting The nginx HTTP and re>
Jan 02 10:01:47 web.tp4.linux.web.tp4.linux nginx[1252]: nginx: the configuration file>
Jan 02 10:01:47 web.tp4.linux.web.tp4.linux nginx[1252]: nginx: configuration file /et>
Jan 02 10:01:47 web.tp4.linux.web.tp4.linux systemd[1]: Started The nginx HTTP and rev>
lines 1-18/18 (END)
```
```powershell
[user1@web ~]$ sudo ss -alpnt | grep nginx
LISTEN 0      511          0.0.0.0:8080       0.0.0.0:*    users:(("nginx",pid=1255,fd=6),("nginx",pid=1254,fd=6))
```
```powershell
[user1@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[user1@web ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
[user1@web ~]$ sudo firewall-cmd --reload
success
```
```powershell
PS C:\Users\samyd> curl 10.3.2.53:8080


StatusCode        : 200
StatusDescription : OK
Content           : <!doctype html>
                    <html>
                      <head>
                        <meta charset='utf-8'>
                        <meta name='viewport' content='width=device-width,
                    initial-scale=1'>
                        <title>HTTP Server Test Page powered by: Rocky Linux</title>
                       ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 7620
                    Content-Type: text/html
                    Date: Mon, 02 Jan 2023 09:08:24 GMT
                    ETag: "62e17e64-1dc4"
                    Last-Modified: Wed, 27 Jul 202...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 7620], [Content-Type, text/html]...}
Images            : {@{innerHTML=; innerText=; outerHTML=<IMG alt="[ Powered by Rocky
                    Linux ]" src="icons/poweredby.png">; outerText=; tagName=IMG;
                    alt=[ Powered by Rocky Linux ]; src=icons/poweredby.png},
                    @{innerHTML=; innerText=; outerHTML=<IMG src="poweredby.png">;
                    outerText=; tagName=IMG; src=poweredby.png}}
InputFields       : {}
Links             : {@{innerHTML=<STRONG>Rocky Linux website</STRONG>;
                    innerText=Rocky Linux website; outerHTML=<A
                    href="https://rockylinux.org/"><STRONG>Rocky Linux
                    website</STRONG></A>; outerText=Rocky Linux website; tagName=A;
                    href=https://rockylinux.org/}, @{innerHTML=Apache
                    Webserver</STRONG>; innerText=Apache Webserver; outerHTML=<A
                    href="https://httpd.apache.org/">Apache Webserver</STRONG></A>;
                    outerText=Apache Webserver; tagName=A;
                    href=https://httpd.apache.org/}, @{innerHTML=Nginx</STRONG>;
                    innerText=Nginx; outerHTML=<A
                    href="https://nginx.org">Nginx</STRONG></A>; outerText=Nginx;
                    tagName=A; href=https://nginx.org}, @{innerHTML=<IMG alt="[
                    Powered by Rocky Linux ]" src="icons/poweredby.png">; innerText=;
                    outerHTML=<A id=rocky-poweredby
                    href="https://rockylinux.org/"><IMG alt="[ Powered by Rocky Linux
                    ]" src="icons/poweredby.png"></A>; outerText=; tagName=A;
                    id=rocky-poweredby; href=https://rockylinux.org/}...}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 7620
```

**Changer l'utilisateur qui lance le service :**

```powershell
[user1@web ~]$ sudo useradd web -m -p root
```
```powershell
[user1@web ~]$ cat /etc/nginx/nginx.conf | grep web
user  web;
[user1@web ~]$ sudo systemctl restart nginx
```
```powershell
[user1@web ~]$ sudo ps -fe | grep nginx
root        1368       1  0 10:29 ?        00:00:00 nginx: master process /usr/sbin/nginx
web         1369    1368  0 10:29 ?        00:00:00 nginx: worker process
```

**Changer l'emplacement de la racine Web :**

```powershell
[user1@web ~]$ cat /var/www/site_web_1/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <p>HELLO les LOULOU</p>
</body>
</html>
```
```powershell
[user1@web ~]$ cat /etc/nginx/nginx.conf | grep root
            root   /var/www/site_web_1/;
```
```powershell
[user1@web ~]$ sudo systemctl restart nginx
```
```powershell
PS C:\Users\samyd> curl 10.3.2.53:8080


StatusCode        : 200
StatusDescription : OK
Content           : <!DOCTYPE html>
                    <html lang="en">
                    <head>
                        <meta charset="UTF-8">
                        <meta http-equiv="X-UA-Compatible" content="IE=edge">
                        <meta name="viewport" content="width=device-width,
                    initial-scale=1.0">
                    ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 287
                    Content-Type: text/html
                    Date: Mon, 02 Jan 2023 09:39:38 GMT
                    ETag: "63b2a56d-11f"
                    Last-Modified: Mon, 02 Jan 2023 ...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 287], [Content-Type, text/html]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 287
```

#### *6. Deux sites web sur un seul serveur*

**Repérez dans le fichier de conf :**

```powershell
[user1@web ~]$ cat /etc/nginx/nginx.conf | grep conf.d
    include conf.d/*.conf
```
```powershell
[user1@web ~]$ cat /etc/nginx/conf.d/site_web_1.conf
 server {
        listen       8080;
        server_name  localhost;
        location / {
            root   /var/www/site_web_1/;
            index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
[user1@web ~]$ cat /etc/nginx/nginx.conf
user  web;
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    include conf.d/*.conf
}
```

**Créez le fichier de configuration pour le premier site :**

```powershell
[user1@web ~]$ cat /etc/nginx/conf.d/site_web_1.conf
 server {
        listen       8080;
        server_name  localhost;
        location / {
            root   /var/www/site_web_1/;
            index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
```

**Créez le fichier de configuration pour le deuxième site :**

```powershell
[user1@web ~]$ cat /etc/nginx/conf.d/site_web_2.conf
 server {
        listen       8888;
        server_name  localhost;
        location / {
            root   /var/www/site_web_2/;
            index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
```

**Prouvez que les deux sites sont disponibles :**

```powershell
PS C:\Users\samyd> curl 10.3.2.53:8080


StatusCode        : 200
StatusDescription : OK
Content           : <!DOCTYPE html>
                    <html lang="en">
                    <head>
                        <meta charset="UTF-8">
                        <meta http-equiv="X-UA-Compatible" content="IE=edge">
                        <meta name="viewport" content="width=device-width,
                    initial-scale=1.0">
                    ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 287
                    Content-Type: text/html
                    Date: Mon, 02 Jan 2023 10:19:20 GMT
                    ETag: "63b2a56d-11f"
                    Last-Modified: Mon, 02 Jan 2023 ...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 287], [Content-Type, text/html]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 287



PS C:\Users\samyd> curl 10.3.2.53:8888


StatusCode        : 200
StatusDescription : OK
Content           : <!DOCTYPE html>
                    <html lang="en">
                    <head>
                        <meta charset="UTF-8">
                        <meta http-equiv="X-UA-Compatible" content="IE=edge">
                        <meta name="viewport" content="width=device-width,
                    initial-scale=1.0">
                    ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 286
                    Content-Type: text/html
                    Date: Mon, 02 Jan 2023 10:19:25 GMT
                    ETag: "63b2abf3-11e"
                    Last-Modified: Mon, 02 Jan 2023 ...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 286], [Content-Type, text/html]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 286



```
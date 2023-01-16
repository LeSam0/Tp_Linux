# Tp 5 Linux

## Partie 1 : Mise en place et maîtrise du serveur Web

#### *1. Installation*

**Installer le serveur Apache :**

```bash
[user1@webweb ~]$ sudo dnf install httpd
...
Complete!
```

**Démarrer le service Apache :**

```bash
[user1@webweb ~]$ sudo systemctl start httpd
[user1@webweb ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[user1@webweb ~]$ sudo ss -laputn | grep httpd
tcp   LISTEN 0      511                   *:80              *:*    users:(("httpd",pid=1258,fd=4),("httpd",pid=1257,fd=4),("httpd",pid=1256,fd=4),("httpd",pid=1254,fd=4))
[user1@webweb ~]$ sudo firewall-cmd --add-port=511/tcp --permanent
success
[user1@webweb ~]$ sudo firewall-cmd --reload
success
```

**TEST :**

```bash
[user1@webweb ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-09 09:48:23 CET; 26min ago
[user1@webweb ~]$ sudo systemctl is-enabled httpd
enabled
[user1@webweb ~]$ curl localhost
<!doctype html>
<html>
...
</html>
```
```powershell
PS C:\Users\samyd> curl 10.105.1.11:80
curl : HTTP Server Test Page
This page is used to test the proper operation of an HTTP server after it has been installed on a Rocky Linux system. If you can read this page, it means that the software is
working correctly.
```

#### *2. Avancer vers la maîtrise du service*

**Le service Apache... :**

```bash
[user1@webweb ~]$ cat /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

**Déterminer sous quel utilisateur tourne le processus Apache :**

```bash
[user1@webweb ~]$ cat /etc/httpd/conf/httpd.conf | grep -i user
User apache
[user1@webweb ~]$ ps -ef | grep httpd | grep apache
apache      1255    1254  0 09:48 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1256    1254  0 09:48 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1257    1254  0 09:48 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1258    1254  0 09:48 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
[user1@webweb ~]$ ls -al /usr/share/testpage/
total 12
drwxr-xr-x.  2 root root   24 Jan  9 09:38 .
drwxr-xr-x. 82 root root 4096 Jan  9 09:38 ..
-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
```

**Changer l'utilisateur utilisé par Apache :**

```bash
[user1@webweb ~]$ sudo useradd patrice -s /sbin/nologin
[user1@webweb ~]$ sudo usermod -d /usr/share/httpd patrice
[user1@webweb ~]$ sudo usermod -aG patrice apache
[user1@webweb ~]$ cat /etc/httpd/conf/httpd.conf | grep -i user
User patrice
[user1@webweb ~]$ sudo systemctl restart httpd
[user1@webweb ~]$ ps -ef | grep httpd | grep patrice
patrice     1684    1683  0 10:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
patrice     1685    1683  0 10:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
patrice     1686    1683  0 10:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
patrice     1687    1683  0 10:56 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

**Faites en sorte que Apache tourne sur un autre port :**

```bash
[user1@webweb ~]$ sudo firewall-cmd --add-port=9443/tcp --permanent
success
[user1@webweb ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[user1@webweb ~]$ sudo firewall-cmd --reload
success
[user1@webweb ~]$ sudo systemctl restart httpd
[user1@webweb ~]$ sudo ss -laputn | grep httpd
tcp   LISTEN 0      511                   *:9443            *:*    users:(("httpd",pid=1969,fd=4),("httpd",pid=1968,fd=4),("httpd",pid=1967,fd=4),("httpd",pid=1964,fd=4))
[user1@webweb ~]$ curl localhost:9443
<!doctype html>
<html>
...
</html>
```

[httpd.conf](./fichier/httpd.conf)

## Partie 2 : Mise en place et maîtrise du serveur de base de données

**Install de MariaDB sur db.tp5.linux :**

```bash
[user1@dbdb ~]$ sudo dnf install mariadb-server
Complete!
[user1@dbdb ~]$ sudo systemctl enable mariadb
[user1@dbdb ~]$ sudo systemctl start mariadb
[user1@dbdb ~]$ sudo mysql_secure_installation
All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

**Port utilisé par MariaDB :**

```bash    
[user1@dbdb ~]$ sudo ss -lapunt | grep -i mariadb
tcp   LISTEN 0      80                    *:3306            *:*    users:(("mariadbd",pid=12764,fd=19))
[user1@dbdb ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[user1@dbdb ~]$ sudo firewall-cmd --reload
success
```

**Processus liés à MariaDB :**

```bash
[user1@dbdb ~]$ ps -ef | grep mariadb
mysql      12764       1  0 11:15 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
```

## Partie 3 : Configuration et mise en place de NextCloud

#### *1. Base de données*

**Préparation de la base pour NextCloud :**

```bash
[user1@dbdb ~]$ sudo mysql -u root -p
[sudo] password for user1:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 18
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)
```

**Exploration de la base de données :**

```bash
[user1@webweb ~]$ mysql -u nextcloud -h 10.105.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 21
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> use nextcloud
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)
```

**Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données :**

```bash
[user1@dbdb ~]$ sudo mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SELECT User, Host FROM mysql.user;
+-------------+-------------+
| User        | Host        |
+-------------+-------------+
| nextcloud   | 10.105.1.11 |
| mariadb.sys | localhost   |
| mysql       | localhost   |
| root        | localhost   |
+-------------+-------------+
4 rows in set (0.001 sec)

```

#### *2. Serveur Web et NextCloud*

**Install de PHP :**

```bash
[user1@webweb ~]$ sudo dnf config-manager --set-enabled crb
[user1@webweb ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
...
Complete!
[user1@webweb ~]$ dnf module list php
Extra Packages for Enterprise Linux 9 - x86_64         4.6 MB/s |  12 MB     00:02
...
Complete!
[user1@webweb ~]$ sudo dnf module enable php:remi-8.1 -y
Last metadata expiration check: 0:04:40 ago on Sun 15 Jan 2023 10:56:56 AM CET.
Dependencies resolved.
...
Complete!
[user1@webweb ~]$ sudo dnf install -y php81-php
Last metadata expiration check: 0:00:26 ago on Sun 15 Jan 2023 10:56:56 AM CET.
Dependencies resolved.
...
Complete!
```

**Install de tous les modules PHP nécessaires pour NextCloud :**

```bash
[user1@webweb ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
Last metadata expiration check: 0:06:02 ago on Sun 15 Jan 2023 10:56:56 AM CET.
...
Complete!
```

**Récupérer NextCloud :**

```bash!
[user1@webweb ~]$ sudo mkdir /var/www/tp5_nextcloud/
[user1@webweb ~]$ curl -O https://download.nextcloud.com/server/prereleases/nextcloud-25.
0.0rc3.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  168M  100  168M    0     0  9926k      0  0:00:17  0:00:17 --:--:-- 10.0M
[user1@webweb ~]$ sudo dnf install unzip
...
Complete!
[user1@webweb ~]$ unzip nextcloud-25.0.0rc3.zip
[user1@webweb ~]$ sudo mv nextcloud/* /var/www/tp5_nextcloud/
[user1@webweb ~]$ ls /var/www/tp5_nextcloud/
... index.html  ...
[user1@webweb ~]$ sudo chown -R apache:apache /var/www/tp5_nextcloud/
```

**Adapter la configuration d'Apache :**

```bash
[user1@webweb ~]$ sudo nano /etc/httpd/conf/tp5.conf
[user1@webweb ~]$ cat /etc/httpd/conf/tp5.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

**Redémarrer le service Apache :**

```bash
[user1@webweb ~]$ sudo systemctl restart httpd
```

#### *3. Finaliser l'installation de NextCloud

**Exploration de la base de données :**

```bash

```
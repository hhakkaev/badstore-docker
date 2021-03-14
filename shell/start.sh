#!/bin/bash
  if [ ! -f /data/mariadb/data/ibdata1 ]; then
    /usr/bin/mysql_install_db --datadir=/data/mariadb/data --user=mysql
  fi

  # If SSH is needed
  # SSH_USERPASS=`pwgen -c -n -1 8`
  # mkdir /home/user
  # useradd -G sudo -d /home/user user
  # chown user /home/user
  # echo user:$SSH_USERPASS | chpasswd
  # echo ssh user password: $SSH_USERPASS

  # Start MySQL and wait for it to become available
  /usr/bin/mysqld_safe > /dev/null 2>&1 &

  RET=1
  while [[ RET -ne 0 ]]; do
      echo "=> Waiting for confirmation of MySQL service startup"
      sleep 5
      mysql -u root -e "status" > /dev/null 2>&1
        # Generate Koken database and user credentials
      echo "=> Generating database and credentials"
      echo "=> Executing mysqladmin -u root password 'secret'"
      mysqladmin -u root password 'secret'
      mysql -u root -psecret -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION; FLUSH PRIVILEGES;"
      mysql -u root -psecret < /data/mariadb/bin/badstore-setup.sql
      mysqladmin -u root -psecret shutdown
      RET=$?
  done


echo "=> Starting supervisord"
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

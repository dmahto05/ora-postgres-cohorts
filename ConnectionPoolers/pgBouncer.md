--Installing PgBouncer on Amazon Linux - EC2

## Installing Dependency 
sudo yum update -y
sudo yum install -y wget tar gzip
sudo apt-get install libtool m4 automake
wget https://github.com/jgm/pandoc/releases/download/2.11.4/pandoc-2.11.4-linux-amd64.tar.gz
tar -xvzf pandoc-2.11.4-linux-amd64.tar.gz
sudo cp -r pandoc-2.11.4/bin/* /usr/local/bin/

## Installing PgBouncer
git clone https://github.com/pgbouncer/pgbouncer.git
cd pgbouncer
git submodule init
git submodule update
./autogen.sh
./configure
make
make install

## PgBouncer Initalize file

Path save in sample - /home/ec2-user/pgbouncer/etc/pgbouncer.ini 

```
[databases]
 dbbench = host=<<change_with_actual_host_name>> port=5432 dbname=<<change_with_db_name>>

[pgbouncer]
 listen_port = 6432
 listen_addr = localhost
 auth_type = scram-sha-256
 auth_file = /home/ec2-user/pgbouncer/etc/userlist.txt
 logfile = /home/ec2-user/pgbouncer/pgbouncer.log
 pidfile = /home/ec2-user/pgbouncer/pgbouncer.pid
 auth_user = postgres
 auth_dbname = postgres
 pool_mode = transaction
```

## Running PgBouncer
```sudo  pgbouncer  /home/ec2-user/pgbouncer/etc/pgbouncer.ini  -u ec2-user```

## Running pgBench

```
pgbench --host=<<change_with_actual_host_name>> --username=postgres --port=6432 -j 20 -c 80 -T 60 -P 10 -n -S -C <<change_with_db_name>>
pgbench --host=localhost --username=postgres --port=6432 -j 20 -c 80 -T 60 -P 10 -n -S -C <<change_with_db_name>>
```

##DBQuery

```
select state, backend_type , count(1) from pg_stat_activity group by state, backend_type  order by count(1) desc;
```


#!/usr/bin/with-contenv sh

# Wait database online
while : ; do
    PGPASSWORD=ambari psql -h db -U ambari -c "select 1"
    [[ $? == 0 ]] && break
    sleep 5
done

if [ ! -f /etc/ambari-server/.init/init_db ]; then
    PGPASSWORD=ambari psql -h db -U ambari -f /var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql
    touch /etc/ambari-server/.init/init_db
fi
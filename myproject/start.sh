#!/bin/bash
# 1. wait for the MySQL service to start before migrating the data. nc, short for netcat
# 2. Collect static files to the root static folder. (Just for the first time)
# 3. Django make migrations. (Just for the first time)
# 4. Django migrate
# 5. Start django with uwsgi
# 6. tail command to prevent the web container from exiting after executing the script
while ! nc -z db 3306 ; do
    echo "Waiting for the MySQL Server"
    sleep 3
done

python manage.py collectstatic --noinput&&
python manage.py makemigrations&&
python manage.py migrate&&
uwsgi --ini /var/www/html/myproject/uwsgi.ini&&
tail -f /dev/null

exec "$@"
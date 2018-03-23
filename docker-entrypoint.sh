#!/bin/bash
set -e

case "$1" in
    prod)
        echo "---> Starting in PRODUCTION mode"
        cd /usr/src/app/
        /wait-for-it.sh rabbit:5672
        exec /usr/local/bin/gunicorn server_app:app -w 5 -b :8123
        ;;
    dev)
        echo "---> Starting in DEV mode"
        cd /usr/src/app/
        export FLASK_DEBUG=1
        /wait-for-it.sh rabbit:5672
        echo "---> Start EXEC"
        # exec /usr/local/bin/python server.py port 8123
        FLASK_APP=server_app.py flask run --port 8123  --with-threads --host '0.0.0.0'
        echo "---> END"
        ;;
    worker)
        cd /usr/src/app/
        /wait-for-it.sh rabbit:5672
        # celery -A tasks beat &
        exec celery -A tasks worker -B --loglevel=DEBUG -l debug
        ;;
    scheduler)
        echo "---> Starting Scheduler"
        cd /usr/src/app/
        /wait-for-it.sh rabbit:5672
        # celery -A tasks beat &
        exec /usr/local/bin/python scheduler.py
        ;;
    queue)
        cd /usr/src/app/
        /wait-for-it.sh rabbit:5672
        exec celery -A tasks worker --concurrency=1 -Q userapp -n workerqueue --loglevel=DEBUG -l debug
        #--loglevel=DEBUG -l debug
        ;;
    *)
        echo "Please specify argument (prod|dev) [ARGS..]";
        exit 1;
        ;;
esac

exit 0;
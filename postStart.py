import argparse
import logging
from os import getenv

import psycopg2

# import timeout_decorator

# TODO: figure out if we need this, would need to requirements install with pip (see: wes-metrics-agent)
# @timeout_decorator.timeout(120)
def db_connect(args):
    """
    TODO:
    """
    logging.info(f"Attempting DB connection [{args.pg_host}/{args.pg_db}]")
    return psycopg2.connect(
        host=args.pg_host, database=args.pg_db, user=args.pg_user, password=args.pg_password
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--debug", action="store_true", help="enable debug logging")
    parser.add_argument(
        "--pg_host",
        default=getenv("POSTGRESQL_HOST", "localhost"),
        help="PostgreSQL server host address",
    )
    parser.add_argument(
        "--pg_user",
        default=getenv("POSTGRESQL_USER", "chirpstack"),
        help="PostgreSQL server user",
    )
    parser.add_argument(
        "--pg_password",
        default=getenv("POSTGRESQL_PWD", "chirpstack"),
        help="PostgreSQL server user password",
    )
    parser.add_argument(
        "--pg_db",
        default=getenv("POSTGRESQL_DB", "chirpstack"),
        help="PostgreSQL server database to connect to",
    )
    args = parser.parse_args()

    # TODO: use the log file as an argument / env?
    logging.basicConfig(
        filename="/tmp/postStart.log",
        level=logging.DEBUG if args.debug else logging.INFO,
        format="%(asctime)s %(message)s",
        datefmt="%Y/%m/%d %H:%M:%S",
    )

    # attempt to connect to the postgres DB
    # TODO: handle timeout, fail this program, which would kill the parent chirpstack-server
    conn = db_connect(args)

    logging.info(f"JOE - post conn [{conn}]")

    # this works, so we can use this to keep our connection
    with psycopg2.connect(
        host=args.pg_host, database=args.pg_db, user=args.pg_user, password=args.pg_password
    ) as c:
        logging.info(f"in a with {c}")
        cur = c.cursor()
        cur.execute("SELECT version()")
        d = cur.fetchone()
        logging.info(f"{d}")
        cur.execute("SELECT * FROM gateway")
        d = cur.fetchone()
        logging.info(f"{d}")
        logging.info(f"{d[0]}")
        dd = bytes(d[0])
        logging.info(f"{dd}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass

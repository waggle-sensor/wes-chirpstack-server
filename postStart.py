import argparse
import logging


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--debug", action="store_true", help="enable debug logging")

    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.debug else logging.INFO,
        format="%(asctime)s %(message)s",
        datefmt="%Y/%m/%d %H:%M:%S",
    )

    logging.info("JOE - POSTSTART")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass

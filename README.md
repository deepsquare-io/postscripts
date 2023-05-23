# Postscripts template

## How to use

The main entrypoint is `post.sh`.

Execute `./post.sh $(hostname)` to run the postscripts. `$(hostname)` is passed to create host-specific postscripts.

## How to customize

The whole `post.sh` script is a postscript that executes other postscripts. You can execute any bash script inside of it, or use our `COPY` and `RUN` commands which add logging.

### Copying files from git to node

Add files into the `/files` directory and add `COPY <source> <destination>` instructions in the `SYNCLIST` section.

### Executing postscripts

Add postscripts into the `/postscripts` directory and add `RUN <postscript>` instructions in the `EXECUTE` sections.

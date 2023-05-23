#!/bin/sh

# RUN wraps the command to log into journalctl
RUN() {
  logger -t postscripts "Running $*..."
  echo "---Running $*...---"
  "$@"
  code=$?
  if [ $code -eq 1 ]; then
    logger -t postscripts "$* failed with error code $code"
    echo "---$* failed with error code $code---"
  elif [ $code -ne 0 ]; then
    logger -t postscripts "$* exited with error code $code"
    echo "---$* exited with error code $code---"
  fi
  logger -t postscripts "$* exited with code $code"
  echo "---$* exited with code $code---"
}

COPY() {
  mkdir -p "$(dirname "$2")"
  rsync -av "$1" "$2"
}

SCRIPTPATH=$(dirname "$(realpath "$0")")

# -- SYNCLIST
cd "${SCRIPTPATH}/files" || (echo "cd failed" && exit 1)
COPY ./sssd/sssd.conf /etc/sssd/sssd.conf

COPY ./ssh/ /etc/ssh/
find /etc/ssh -type f -exec chmod 600 {} \;
find /etc/ssh -type d -exec chmod 700 {} \;
systemctl restart sshd

COPY ./munge/munge.key /etc/munge/munge.key

COPY ./slurm/slurmd_defaults /etc/default/slurmd

COPY ./slurm/prolog.d/ /etc/slurm/prolog.d/
COPY ./slurm/epilog.d/ /etc/slurm/epilog.d/
COPY ./slurm/plugstack.conf.d/ /etc/slurm/plugstack.conf.d/

COPY ./certs/ /etc/pki/ca-trust/source/anchors/
update-ca-trust
systemctl restart sssd

# -- APPEND
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPd+X08wpIGwKZ0FsJu1nkR3o1CzlXF3OkgQd/WYB2fX deepsquare" >>/root/.ssh/authorized_keys
chmod 600 /root/.ssh/*
chmod 700 /root/.ssh

# Restore context
cd "${SCRIPTPATH}" || (echo "cd failed" && exit 1)

# -- EXECUTE (use RUN to log your postscripts)
PATH="${SCRIPTPATH}/postscripts:$PATH"
chmod +x "${SCRIPTPATH}/postscripts/"*

RUN disable-beegfs
RUN wireguard
RUN install-bore
RUN symlink-ca
RUN xorg-setup
RUN restorecap
RUN ldap
RUN fs_mount
RUN slurm
RUN install-logger
RUN set-motd
RUN cvmfs_mount
RUN setups5cmd
RUN nv-unlocker

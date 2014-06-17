#!/usr/bin/env bash
#     ____  _________  ____  _________
#    / __ \/ ___/ __ \/ __ \/ ___/ __ \
#   / /_/ / /  / /_/ / /_/ / /  / /_/ /
#  / .___/_/   \____/ .___/_/   \____/
# /_/              /_/
#
# Built from: linode.propro

unset UCF_FORCE_CONFFOLD
export UCF_FORCE_CONFFNEW="YES"
export DEBIAN_FRONTEND="noninteractive"

# Propro package: lib/propro.sh
#!/usr/bin/env bash

set -e
set -u

PROPRO_LOG_FILE="/root/provision.log"
PROPRO_FULL_LOG_FILE="/root/full_provision.log"
PROPRO_LOG_USE_COLOR="yes"
PROPRO_DISABLE_LOG="no"

>$PROPRO_FULL_LOG_FILE
exec > >(tee $PROPRO_FULL_LOG_FILE)
exec 2>&1

function log {
  echo -e "$1"

  if is-yes $PROPRO_DISABLE_LOG; then
    return 0
  fi

  if [ $PROPRO_LOG_FILE ]; then
    touch $PROPRO_LOG_FILE
    echo -e "$1" >> $PROPRO_LOG_FILE
  fi
}

# $1 text
function section {
  local msg="#### $1"
  log ""
  if is-yes $PROPRO_LOG_USE_COLOR; then
    log "\e[32m\e[1m$msg\e[0m"
  else
    log "$msg"
  fi
}

# $1 text
function announce {
  if is-yes $PROPRO_LOG_USE_COLOR; then
    log "\e[34m\e[1m--->\e[0m $1"
  else
    log "---> $1"
  fi
}

# $1 text
function announce-item {
  if is-yes $PROPRO_LOG_USE_COLOR; then
    log "     - \e[36m$1\e[0m"
  else
    log "     - $1"
  fi
}

function finished {
  if is-yes $PROPRO_LOG_USE_COLOR; then
    log "\e[35m\e[1m     Fin.\e[0m"
  else
    log "     Fin."
  fi
  log ""
}

function get-tmp-dir {
  mktemp -d
}

# $1 "yes" or "no"
function is-yes {
  if [ $1 == "yes" ]; then
    return 0
  else
    return 1
  fi
}

# $1 "yes" or "no"
function is-no {
  if [ $1 == "no" ]; then
    return 0
  else
    return 1
  fi
}

# $1 comma separated list
#
# example:
# > $ csl-to-wsl "item1,item2,item3"
# > item1 item2 item3
function csl-to-wsl {
  echo "$1" | sed 's/,/ /g'
}

# $1 path or relative uri
#
# example:
# > $ path-to-id example.com/neat/stuff
# > example_com_neat_stuff
function path-to-id {
  echo "$1" | sed -r 's/[-\.:\/\]/_/g'
}


# Propro package: lib/ubuntu.sh
#!/usr/bin/env bash
function get-processor-count {
  nproc
}

function release-codename {
  lsb_release -c -s
}

# $@ package names
function install-packages {
  announce "Installing packages:"
  for package in $@; do
    announce-item "$package"
  done
  aptitude -q -y -o Dpkg::Options::="--force-confnew" install $@
}

function get-archtype {
  if [ $(getconf LONG_BIT) == 32 ]; then
    echo 'x86'
  else
    echo 'x64'
  fi
}

function update-sources {
  sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
  apt-get -qq -y update
}

function add-repository {
  add-apt-repository -y $1
}

# $1 unix user
# $2 service name
# $3 service args
function add-sudoers-entries {
  for event in start status stop reload restart; do
    if [ $3 ]; then
      tee -a /etc/sudoers.d/$2-entries <<EOT
$1 ALL=NOPASSWD: /sbin/$event $2 $3
EOT
    else
      tee -a /etc/sudoers.d/$2-entries <<EOT
$1 ALL=NOPASSWD: /sbin/$event $2
EOT
    fi

    chmod 0440 /etc/sudoers.d/$2-entries
  done
}

function reboot-system {
  shutdown -r now
}

# $1 package name
function reconfigure-package {
  dpkg-reconfigure -f noninteractive $1
}

# $1 key URL
function add-source-key {
  wget --quiet -O - $1 | apt-key add -
}

# $@ files to extract
function extract {
  tar xzf $@
}

# $1 URL to download
function download {
  wget -nv $1
}

function get-ram-bytes {
  free -m -b | awk '/^Mem:/{print $2}'
}

function get-page-size {
  getconf PAGE_SIZE
}

function get-ram-pages {
  echo "$(get-ram-bytes) / $(get-page-size)" | bc
}

# $1 shmall percent
function get-kernel-shmall {
  echo "($(get-ram-pages) * $1) / 1" | bc
}

# $1 shmmax percent
function get-kernel-shmmax {
  echo "($(get-ram-bytes) * $1) / 1" | bc
}

# $1 unix user
# $2 path
function as-user-mkdir {
  mkdir -p $2
  chown $1:$1 $2
}

function upgrade-system {
  update-sources
  apt-get -qq -y install aptitude
  aptitude -q -y -o Dpkg::Options::="--force-confnew" full-upgrade
}

# $1 timezone
function set-timezone {
  echo $1 > /etc/timezone
  reconfigure-package tzdata
}

# $1 locale eg: en_US.UTF-8
function set-locale {
  export LANGUAGE=$1
  export LANG=$1
  export LC_ALL=$1
  locale-gen $1
  reconfigure-package locales
  update-locale
}

# $1 hostname
function set-hostname {
  echo $1 > /etc/hostname
  hostname -F /etc/hostname
}

# $1 unix user
# $2 unix group
# $3 password
function add-user {
  if [ $2 ]; then
    announce "Adding $1 user to group $2"
    useradd -m -s /bin/bash -g $2 $1
  else
    announce "Adding $1 user"
    useradd -m -s /bin/bash $1
  fi

  if [ $3 ]; then
    announce "Setting password for $1 user"
    echo "$1:$3" | chpasswd
  fi
}

# $1 unix user
# $2 github usernames for public keys
function add-pubkeys-from-github {
  announce "Installing public keys for $1 from GitHub users:"

  local ssh_dir="/home/$1/.ssh"
  local keys_file="$ssh_dir/authorized_keys"

  mkdir -p $ssh_dir
  touch $keys_file

  for user in $2; do
    announce-item "$user"
    local url="https://github.com/$user.keys"
    tee -a $keys_file <<EOT
# $url
$(wget -qO- $url)

EOT
  done

  chmod 700 $ssh_dir
  chmod 600 $keys_file
  chown -R $1 $ssh_dir
}


# Propro package: lib/system.sh
#!/usr/bin/env bash
SYSTEM_SHMALL_PERCENT="0.75" # @specify
SYSTEM_SHMMAX_PERCENT="0.5" # @specify
SYSTEM_BASE_PACKAGES="curl vim-nox less htop build-essential openssl git tree python-software-properties"
SYSTEM_TIMEZONE="Etc/UTC" # @specify
SYSTEM_LOCALE="en_US.UTF-8" # @specify
SYSTEM_SOURCES_PG_KEY_URL="http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc"

function system-configure-shared-memory {
  announce "Configuring shared memory"
  install-packages bc

  local shmall=$(get-kernel-shmall $SYSTEM_SHMALL_PERCENT)
  local shmmax=$(get-kernel-shmmax $SYSTEM_SHMMAX_PERCENT)

  sysctl -w kernel.shmall=$shmall
  sysctl -w kernel.shmmax=$shmmax
  tee -a /etc/sysctl.conf <<EOT

kernel.shmall = $shmall
kernel.shmmax = $shmmax
EOT
}

function system-install-packages {
  install-packages $SYSTEM_BASE_PACKAGES
}

function system-configure-timezone {
  announce "Set timezone to $SYSTEM_TIMEZONE"
  set-timezone $SYSTEM_TIMEZONE
}

function system-configure-locale {
  announce "Set locale to $SYSTEM_LOCALE"
  set-locale $SYSTEM_LOCALE
}

function system-upgrade {
  announce "Update and upgrade system packages"
  upgrade-system
}

function system-add-pg-source {
  announce "Add PostgreSQL sources:"
  tee /etc/apt/sources.list.d/pgdg.list <<EOT
deb http://apt.postgresql.org/pub/repos/apt/ $(release-codename)-pgdg main
EOT

  announce-item "apt.postgresql.org"
  add-source-key $SYSTEM_SOURCES_PG_KEY_URL
  update-sources
}

function system-install-sources {
  system-add-pg-source
}


# Propro package: lib/pg.sh
#!/usr/bin/env bash
PG_VERSION="9.3" # @specify
PG_INSTALL_POSTGIS="no" # @specify
PG_EXTENSIONS="btree_gin btree_gist fuzzystrmatch hstore intarray ltree pg_trgm tsearch2 unaccent" # @specify see: http://www.postgresql.org/docs/9.3/static/contrib.html
PG_CONFIG_FILE="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA_FILE="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_TUNE_VERSION="0.9.3"
PG_USER="postgres"

function get-pg-tune-url {
  echo "http://pgfoundry.org/frs/download.php/2449/pgtune-$PG_TUNE_VERSION.tar.gz"
}

function pg-install-packages {
  if is-yes $PG_INSTALL_POSTGIS; then
    install-packages postgresql-$PG_VERSION libpq-dev postgresql-contrib-$PG_VERSION postgresql-$PG_VERSION-postgis
  else
    install-packages postgresql-$PG_VERSION libpq-dev postgresql-contrib-$PG_VERSION
  fi
}

function pg-tune {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  announce "Tune PostgreSQL $PG_VERSION"
  download $(get-pg-tune-url)
  extract pgtune-$PG_TUNE_VERSION.tar.gz

  ./pgtune-$PG_TUNE_VERSION/pgtune -i $PG_CONFIG_FILE -o $PG_CONFIG_FILE.pgtune
  mv $PG_CONFIG_FILE $PG_CONFIG_FILE.original
  mv $PG_CONFIG_FILE.pgtune $PG_CONFIG_FILE
  chown $PG_USER:$PG_USER $PG_CONFIG_FILE

  cd ~/
  rm -rf "$tmpdir"
}

# $1 db user name
# $2 db name
function pg-createdb {
  announce "Create database: $2"
  su - $PG_USER -c "createdb -O $1 $2"

  if [ $PG_EXTENSIONS ]; then
    announce "Add extensions:"
    for extension in $PG_EXTENSIONS; do
      announce-item "$extension"
      su - $PG_USER -c "psql -d $2 -c \"CREATE EXTENSION IF NOT EXISTS $extension;\""
    done
  fi
}


# Propro package: lib/rvm.sh
#!/usr/bin/env bash
# requires app.sh
RVM_CHANNEL="stable"
RVM_REQUIRED_PACKAGES="curl gawk g++ gcc make libc6-dev libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev"
RVM_DEFAULT_GEMS="bundler" #@specify

# $1 unix user
# $2 ruby version
function rvm-install-for-user {
  section "RVM"
  install-packages $RVM_REQUIRED_PACKAGES

  announce "Install RVM for user $1"
  su - $1 -c "curl -L https://get.rvm.io | bash -s $RVM_CHANNEL"
  su - $1 -c "rvm autolibs read-fail"

  announce "Install Ruby $2 for user $1"
  su - $1 -c "rvm install $2"

  announce "Set Ruby $2 as default for user $1"
  su - $1 -c "rvm --default use $2"

  announce "Install default gems"
  su - $1 -c "gem install $RVM_DEFAULT_GEMS"
}


# Propro package: lib/nginx.sh
#!/usr/bin/env bash
NGINX_VERSION="1.6.0" # @specify
NGINX_USER="nginx"
NGINX_CONFIGURE_OPTS="--with-http_ssl_module --with-http_gzip_static_module" # @specify
NGINX_CONF_FILE="/etc/nginx.conf"
NGINX_ETC_DIR="/etc/nginx"
NGINX_LOG_DIR="/var/log/nginx"
NGINX_ACCESS_LOG_FILE_NAME="access.log"
NGINX_ERROR_LOG_FILE_NAME="error.log"
NGINX_DEPENDENCIES="libpcre3-dev libssl-dev"
NGINX_WORKER_COUNT=$(get-processor-count)
NGINX_SERVER_NAMES_HASH_BUCKET_SIZE="64"
NGINX_PID_FILE="/var/run/nginx.pid"
NGINX_CLIENT_MAX_BODY_SIZE="5m" # @specify
NGINX_WORKER_CONNECTIONS="2000" # @specify

NGINX_SITES_DIR="$NGINX_ETC_DIR/sites"
NGINX_CONF_DIR="$NGINX_ETC_DIR/conf"

function get-nginx-url {
  echo "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
}

function nginx-install {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  install-packages $NGINX_DEPENDENCIES

  announce "Download $NGINX_VERSION"
  download $(get-nginx-url)

  announce "Extract"
  extract nginx-$NGINX_VERSION.tar.gz

  announce "Configure"
  cd nginx-$NGINX_VERSION
  ./configure $NGINX_CONFIGURE_OPTS

  announce "Compile"
  make

  announce "Install $NGINX_VERSION"
  make install

  cd ~/
  rm -rf "$tmpdir"
}

function nginx-configure {
  announce "Creating Nginx user"
  useradd -r $NGINX_USER

  announce "Adding Nginx directories"
  as-user-mkdir $NGINX_USER $NGINX_LOG_DIR
  mkdir -p $NGINX_ETC_DIR
  mkdir -p $NGINX_SITES_DIR
  mkdir -p $NGINX_CONF_DIR

  announce "Creating base Nginx config: $NGINX_CONF_FILE"
  tee $NGINX_CONF_FILE <<EOT
user $NGINX_USER;
pid $NGINX_PID_FILE;
ssl_engine dynamic;
worker_processes $NGINX_WORKER_COUNT;

events {
  multi_accept on;
  worker_connections $NGINX_WORKER_CONNECTIONS;
  use epoll;
}

http {
  sendfile on;

  tcp_nopush on;
  tcp_nodelay off;

  client_max_body_size $NGINX_CLIENT_MAX_BODY_SIZE;
  client_body_temp_path /var/spool/nginx-client-body 1 2;

  server_names_hash_bucket_size $NGINX_SERVER_NAMES_HASH_BUCKET_SIZE;

  default_type application/octet-stream;

  include /etc/nginx/conf/*.conf;
  include /etc/nginx/sites/*.conf;
}
EOT

  announce "Writing Nginx upstart /etc/init/nginx.conf"
  tee /etc/init/nginx.conf <<EOT
description "Nginx HTTP Daemon"
author "George Shammas <georgyo@gmail.com>"

start on (filesystem and net-device-up IFACE=lo)
stop on runlevel [!2345]
env DAEMON="/usr/local/nginx/sbin/nginx -c $NGINX_CONF_FILE"
env PID="$NGINX_PID_FILE"
expect fork
respawn
respawn limit 10 5

pre-start script
  \$DAEMON -t
  if [ \$? -ne 0 ]
    then exit \$?
  fi
end script

exec \$DAEMON
EOT
}

function nginx-conf-add-mimetypes {
  announce "Adding mimetypes config"
  tee "$NGINX_CONF_DIR/mimetypes.conf" <<EOT
types_hash_max_size                     2048;

types {
  application/atom+xml                  atom;
  application/java-archive              jar war ear;
  application/javascript                js;
  application/json                      json;
  application/msword                    doc;
  application/pdf                       pdf;
  application/postscript                ps eps ai;
  application/rtf                       rtf;
  application/vnd.ms-excel              xls;
  application/vnd.ms-fontobject         eot;
  application/vnd.ms-powerpoint         ppt;
  application/vnd.wap.wmlc              wmlc;
  application/x-7z-compressed           7z;
  application/x-bittorrent              torrent;
  application/x-cocoa                   cco;
  application/x-font-ttf                ttf ttc;
  application/x-httpd-php-source        phps;
  application/x-java-archive-diff       jardiff;
  application/x-java-jnlp-file          jnlp;
  application/x-makeself                run;
  application/x-perl                    pl pm;
  application/x-pilot                   prc pdb;
  application/x-rar-compressed          rar;
  application/x-redhat-package-manager  rpm;
  application/x-sea                     sea;
  application/x-shockwave-flash         swf;
  application/x-stuffit                 sit;
  application/x-tcl                     tcl tk;
  application/x-x509-ca-cert            der pem crt;
  application/x-xpinstall               xpi;
  application/xhtml+xml                 xhtml;
  application/xml                       xml;
  application/zip                       zip;
  audio/midi                            mid midi kar;
  audio/mpeg                            mp3;
  audio/ogg                             oga ogg;
  audio/x-m4a                           m4a;
  audio/x-realaudio                     ra;
  audio/x-wav                           wav;
  font/opentype                         otf;
  font/woff                             woff;
  image/gif                             gif;
  image/jpeg                            jpeg jpg;
  image/png                             png;
  image/svg+xml                         svg svgz;
  image/tiff                            tif tiff;
  image/vnd.wap.wbmp                    wbmp;
  image/webp                            webp;
  image/x-icon                          ico;
  image/x-ms-bmp                        bmp;
  text/cache-manifest                   manifest appcache;
  text/css                              css;
  text/html                             html htm shtml;
  text/mathml                           mml;
  text/plain                            txt md;
  text/vnd.sun.j2me.app-descriptor      jad;
  text/vnd.wap.wml                      wml;
  text/x-component                      htc;
  text/xml                              rss;
  video/3gpp                            3gpp 3gp;
  video/mp4                             m4v mp4;
  video/mpeg                            mpeg mpg;
  video/ogg                             ogv;
  video/quicktime                       mov;
  video/webm                            webm;
  video/x-flv                           flv;
  video/x-mng                           mng;
  video/x-ms-asf                        asx asf;
  video/x-ms-wmv                        wmv;
  video/x-msvideo                       avi;
}
EOT
}

function nginx-conf-add-gzip {
  announce "Adding gzip config"
  tee $NGINX_CONF_DIR/gzip.conf <<EOT
gzip on;
gzip_buffers 32 4k;
gzip_comp_level 2;
gzip_disable "msie6";
gzip_http_version 1.1;
gzip_min_length 1100;
gzip_proxied any;
gzip_static on;
gzip_vary on;
gzip_types
  text/css
  text/plain
  application/javascript
  application/json
  application/rss+xml
  application/xml
  application/vnd.ms-fontobject
  font/truetype
  font/opentype
  image/x-icon
  image/svg+xml;
EOT
}

function nginx-create-logrotate {
  announce "Create logrotate for Nginx"
  tee /etc/logrotate.d/nginx <<EOT
$NGINX_LOG_DIR/*.log {
  daily
  missingok
  rotate 90
  compress
  delaycompress
  notifempty
  dateext
  create 640 nginx adm
  sharedscripts
  postrotate
    [ -f $NGINX_PID_FILE ] && kill -USR1 `cat $NGINX_PID_FILE`
  endscript
}
EOT
}


# Propro package: lib/node.sh
#!/usr/bin/env bash
NODE_VERSION="0.10.29" # @specify

function get-node-pkg-name {
  echo "node-v$NODE_VERSION-linux-$(get-archtype)"
}

function get-node-url {
  echo "http://nodejs.org/dist/v$NODE_VERSION/$(get-node-pkg-name).tar.gz"
}

function node-install {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  announce "Download Node $NODE_VERSION"
  download $(get-node-url)

  announce "Extract Node $NODE_VERSION"
  extract "$(get-node-pkg-name).tar.gz"

  announce "Install Node"
  cd "./$(get-node-pkg-name)"
  cp -r -t /usr/local bin include share lib

  cd ~/
  rm -r "$tmpdir"
}


# Propro package: lib/redis.sh
#!/usr/bin/env bash
REDIS_VERSION="2.8.11" # @specify
REDIS_USER="redis"
REDIS_CONF_FILE="/etc/redis.conf"
REDIS_DATA_DIR="/var/lib/redis"
REDIS_FORCE_64BIT="no" # @specify Force 64bit build even if available memory is lte 4GiB

function get-redis-url {
  echo "http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz"
}

function redis-install {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  announce "Download $REDIS_VERSION"
  download $(get-redis-url)

  announce "Extract"
  extract redis-$REDIS_VERSION.tar.gz
  cd redis-$REDIS_VERSION

  if [ $(get-ram-bytes) -gt 4294967296 ] || is-yes $REDIS_FORCE_64BIT; then
    announce "Compile"
    make
  else
    announce "Compile (32bit, available memory <= 4GiB)"
    install-packages libc6-dev-i386
    make 32bit
  fi

  announce "Install $REDIS_VERSION"
  make install

  announce "Add Redis user: $REDIS_USER"
  useradd -r $REDIS_USER

  announce "Create Redis directories"
  as-user-mkdir $REDIS_USER $REDIS_DATA_DIR

  announce "Copy Redis config to $REDIS_CONF_FILE"
  cp ./redis.conf $REDIS_CONF_FILE

  cd ~/
  rm -rf "$tmpdir"

  announce "Update Redis config"
  tee -a $REDIS_CONF_FILE <<EOT
syslog-enabled yes
syslog-ident redis
dir $REDIS_DATA_DIR
EOT

  announce "Create upstart for Redis"
  tee /etc/init/redis.conf <<EOT
description "Redis"
start on runlevel [23]
stop on shutdown
exec sudo -u $REDIS_USER /usr/local/bin/redis-server $REDIS_CONF_FILE
respawn
EOT
}


# Propro package: lib/ffmpeg.sh
#!/usr/bin/env bash
# http://askubuntu.com/a/148567
# https://trac.ffmpeg.org/wiki/UbuntuCompilationGuide
# http://juliensimon.blogspot.ca/2013/08/howto-compiling-ffmpeg-x264-mp3-aac.html

FFMPEG_VERSION="git" # @specify (or a version to download: "2.1.4")
FFMPEG_YASM_VERSION="1.2.0"
FFMPEG_XVID_VERSION="1.3.2"

function get-ffmpeg-url {
  echo "http://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.gz"
}

function get-ffmpeg-yasm-url {
  echo "http://www.tortall.net/projects/yasm/releases/yasm-$FFMPEG_YASM_VERSION.tar.gz"
}

function get-ffmpeg-xvid-url {
  echo "http://downloads.xvid.org/downloads/xvidcore-$FFMPEG_XVID_VERSION.tar.gz"
}

function ffmpeg-install {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  announce "Install Dependencies"
  install-packages build-essential git libfaac-dev libgpac-dev \
    libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev \
    libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev \
    libvorbis-dev libxfixes-dev zlib1g-dev libgsm1-dev

  announce-item "Yasm"
  announce-item "> Download"
  download $(get-ffmpeg-yasm-url)

  announce-item "> Extract"
  extract yasm-$FFMPEG_YASM_VERSION.tar.gz
  cd yasm-$FFMPEG_YASM_VERSION

  announce-item "> Configure"
  ./configure

  announce-item "> Compile"
  make

  announce-item "> Install"
  make install
  make distclean
  cd ..

  announce-item "X264"
  announce-item "> Download"
  git clone --depth 1 git://git.videolan.org/x264

  announce-item "> Configure"
  cd x264
  ./configure --prefix=/usr/local --enable-shared

  announce-item "> Compile"
  make

  announce-item "> Install"
  make install
  make distclean
  cd ..

  announce-item "Xvid"
  announce-item "> Download"
  download $(get-ffmpeg-xvid-url)

  announce-item "> Extract"
  extract xvidcore-$FFMPEG_XVID_VERSION.tar.gz
  cd xvidcore/build/generic

  announce-item "> Configure"
  ./configure --prefix=/usr/local

  announce-item "> Compile"
  make

  announce-item "> Install"
  make install
  cd ../../..

  announce "Download $FFMPEG_VERSION"
  if [ $FFMPEG_VERSION == "git" ]; then
    git clone --depth 1 git://source.ffmpeg.org/ffmpeg.git
    cd ffmpeg
  else
    download $(get-ffmpeg-url)

    announce "Extract"
    extract ffmpeg-$FFMPEG_VERSION.tar.gz
    cd ffmpeg-$FFMPEG_VERSION
  fi

  announce "Configure"
  ./configure --prefix=/usr/local --enable-gpl --enable-version3 \
    --enable-nonfree --enable-shared --enable-libopencore-amrnb \
    --enable-libopencore-amrwb --enable-libfaac --enable-libgsm \
    --enable-libmp3lame --enable-libtheora --enable-libvorbis \
    --enable-libx264 --enable-libxvid

  announce "Compile"
  make

  announce "Install"
  make install
  make distclean
  ldconfig -v

  cd ~/
  rm -rf "$tmpdir"
}


# Propro package: lib/extras.sh
#!/usr/bin/env bash
EXTRA_PACKAGES="" # @specify

function provision-extras {
  if [ -z "$EXTRA_PACKAGES" ]; then
    return 0
  fi

  section "Extras"
  install-packages $EXTRA_PACKAGES
}


# Propro package: vps/system.sh
#!/usr/bin/env bash
VPS_SYSTEM_HOSTNAME="" # @require
VPS_SYSTEM_FQDN="" # @require
VPS_SYSTEM_ADMIN_AUTHORIZED_GITHUB_USERS="" # @require
VPS_SYSTEM_ADMIN_SUDO_PASSWORD="" # @require
VPS_SYSTEM_PRIVATE_IP="" # @specify
VPS_SYSTEM_DNS_SERVERS="208.67.222.222 208.67.220.220"
VPS_SYSTEM_ADMIN_USER="admin" # @specify
VPS_SYSTEM_PRIVATE_NETMASK="255.255.128.0" # @specify Default is for Linode, DigitalOcean: 255.255.0.0
VPS_SYSTEM_PUBLIC_NETMASK="255.255.255.0" # @specify Default is for Linode, DigitalOcean: 255.255.240.0
VPS_SYSTEM_ALLOW_PORTS="www 443 ssh"
VPS_SYSTEM_LIMIT_PORTS="ssh" # @specify Default will limit connection attempts from the same IP on SSH, this can cause problems with certain deployment techniques.
VPS_SYSTEM_ALLOW_PRIVATE_IPS="" # @specify
VPS_SYSTEM_ALLOW_PRIVATE_PORTS="5432 6379" # Postgres & Redis
VPS_SYSTEM_GET_PUBLIC_IP_SERVICE_URL="http://ipecho.net/plain"

function get-vps-system-public-ip {
  wget -qO- $VPS_SYSTEM_GET_PUBLIC_IP_SERVICE_URL
}

function get-vps-system-default-gateway {
  ip route | awk '/default/ { print $3 }'
}

function vps-system-configure-hostname {
  announce "Set hostname to $VPS_SYSTEM_HOSTNAME"
  set-hostname $VPS_SYSTEM_HOSTNAME
}

function vps-system-configure-sshd {
  announce "Configure sshd:"
  announce-item "disable root login"
  announce-item "disable password auth"
  tee /etc/ssh/sshd_config <<EOT
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 768
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin no
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication no
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
EOT

  announce "Restart sshd"
  service ssh restart
}

function vps-system-configure-firewall {
  section "Firewall"
  install-packages ufw

  announce "Configuring firewall:"
  ufw default deny
  ufw logging on

  for port in $VPS_SYSTEM_ALLOW_PORTS; do
    announce-item "allow $port"
    ufw allow $port
  done

  for port in $VPS_SYSTEM_LIMIT_PORTS; do
    announce-item "limit $port"
    ufw limit $port
  done

  for local_ip in $VPS_SYSTEM_ALLOW_PRIVATE_IPS; do
    for port in $VPS_SYSTEM_ALLOW_PRIVATE_PORTS; do
      announce-item "allow $port from $local_ip"
      ufw allow from $local_ip to any port $port
    done
  done

  echo 'y' | ufw enable
}

function vps-system-configure-admin-user {
  announce "Adding admin user: $VPS_SYSTEM_ADMIN_USER"
  add-user $VPS_SYSTEM_ADMIN_USER sudo $VPS_SYSTEM_ADMIN_SUDO_PASSWORD
  add-pubkeys-from-github $VPS_SYSTEM_ADMIN_USER "$VPS_SYSTEM_ADMIN_AUTHORIZED_GITHUB_USERS"
}

function vps-system-configure-interfaces {
  announce "Resolving extenal IP address"

  local ip_addr=$(get-vps-system-public-ip)
  local gateway=$(get-vps-system-default-gateway)
  local fqdn="$ip_addr $VPS_SYSTEM_HOSTNAME $VPS_SYSTEM_FQDN"

  announce "Setting FQDN: $fqdn"
  echo "$fqdn" >> /etc/hosts

  announce "Writing /etc/network/interfaces"
  tee /etc/network/interfaces <<EOT
auto lo
iface lo inet loopback

auto eth0 eth0:0 eth0:1

# Public interface
iface eth0 inet static
 address $ip_addr
 netmask $VPS_SYSTEM_PUBLIC_NETMASK
 gateway $gateway
 dns-nameservers $VPS_SYSTEM_DNS_SERVERS
EOT

  if [ $VPS_SYSTEM_PRIVATE_IP ]; then
    tee -a /etc/network/interfaces <<EOT

# Private interface
iface eth0:1 inet static
 address $VPS_SYSTEM_PRIVATE_IP
 netmask $VPS_SYSTEM_PRIVATE_NETMASK
EOT
  fi

  announce "Restart networking"
  service networking restart
}

function provision-vps-system {
  section "VPS System"
  system-upgrade
  system-configure-timezone
  vps-system-configure-hostname
  system-configure-locale
  system-install-packages
  system-configure-shared-memory
  system-install-sources
  vps-system-configure-admin-user
  vps-system-configure-interfaces
  vps-system-configure-sshd
  vps-system-configure-firewall
}


# Propro package: app.sh
#!/usr/bin/env bash
#
# Provides tools and commands for deploying a Rack application with Capistrano
APP_DOMAIN="" # @require
APP_AUTHORIZED_GITHUB_USERS="" # @require
APP_USER="deploy" # @specify
APPS_DIR="/sites" # @specify
APP_ENV="production" # @specify

function get-app-dir {
  echo "$APPS_DIR/$APP_DOMAIN"
}

function get-app-shared-dir {
  echo "$(get-app-dir)/shared"
}

function get-app-shared-tmp-dir {
  echo "$(get-app-shared-dir)/tmp"
}

function get-app-shared-log-dir {
  echo "$(get-app-shared-dir)/log"
}

function get-app-shared-sockets-dir {
  echo "$(get-app-shared-dir)/sockets"
}

function get-app-shared-config-dir {
  echo "$(get-app-shared-dir)/config"
}

function get-app-current-dir {
  echo "$(get-app-dir)/current"
}

function get-app-releases-dir {
  echo "$(get-app-dir)/releases"
}

function get-app-current-public-dir {
  echo "$(get-app-current-dir)/public"
}

function get-app-user {
  echo $APP_USER
}

function get-app-home {
  echo "/home/$(get-app-user)"
}

function get-app-env {
  echo $APP_ENV
}

function get-app-id {
  path-to-id $APP_DOMAIN
}

# $1 path
function app-mkdir {
  announce-item "$1"
  as-user-mkdir $APP_USER "$1"
}

function app-create-user {
  add-user $APP_USER "" ""
  add-pubkeys-from-github $APP_USER "$APP_AUTHORIZED_GITHUB_USERS"
}

function app-create-dirs {
  announce "Building app directory tree:"
  app-mkdir "$APPS_DIR"
  app-mkdir "$(get-app-dir)"
  app-mkdir "$(get-app-releases-dir)"
  app-mkdir "$(get-app-shared-config-dir)"
  app-mkdir "$(get-app-shared-dir)"
  app-mkdir "$(get-app-shared-tmp-dir)"
  app-mkdir "$(get-app-shared-log-dir)"
  app-mkdir "$(get-app-shared-sockets-dir)"
}

function provision-app {
  app-create-user
  app-create-dirs
}


# Propro package: app/rvm.sh
#!/usr/bin/env bash
# requires app.sh
APP_RVM_RUBY_VERSION="2.1.2" # @specify

function provision-app-rvm {
  rvm-install-for-user $APP_USER $APP_RVM_RUBY_VERSION
}


# Propro package: app/pg.sh
#!/usr/bin/env bash
function provision-app-pg {
  section "PostgreSQL Client"
  install-packages libpq-dev
  install-packages postgresql-client-$PG_VERSION
}


# Propro package: app/nginx.sh
#!/usr/bin/env bash
function provision-app-nginx {
  section "Nginx"
  nginx-install
  nginx-configure
  nginx-conf-add-gzip
  nginx-conf-add-mimetypes
  nginx-create-logrotate
}


# Propro package: app/sidekiq.sh
#!/usr/bin/env bash
# requires app.sh
APP_SIDEKIQ_CONFIG_DIR_RELATIVE="config/sidekiq"
APP_SIDEKIQ_CONFIG_FILE_NAME="sidekiq.yml" # @specify
APP_SIDEKIQ_PID_FILE_RELATIVE="tmp/sidekiq/worker.pid"
APP_SIDEKIQ_CONF_FILE="/etc/sidekiq.conf"

APP_SIDEKIQ_CONFIG_FILE_RELATIVE="$APP_SIDEKIQ_CONFIG_DIR_RELATIVE/$APP_SIDEKIQ_CONFIG_FILE_NAME"

function provision-app-sidekiq {
  section "Sidekiq"
  announce "Create upstart for Sidekiq Manager"
  tee /etc/init/sidekiq-manager.conf <<EOT
description "Manages the set of sidekiq processes"
start on runlevel [2345]
stop on runlevel [06]
env APP_SIDEKIQ_CONF="$APP_SIDEKIQ_CONF_FILE"

pre-start script
  for i in \`cat \$APP_SIDEKIQ_CONF_FILE\`; do
    app=\`echo \$i | cut -d , -f 1\`
    logger -t "sidekiq-manager" "Starting \$app"
    start sidekiq app=\$app
  done
end script
EOT

  announce "Create upstart for Sidekiq Workers"
  tee /etc/init/sidekiq.conf <<EOT
description "Sidekiq Background Worker"
stop on (stopping sidekiq-manager or runlevel [06])
setuid $APP_USER
setgid $APP_USER
respawn
respawn limit 3 30
instance \${app}

script
exec /bin/bash <<'EOTT'
  export HOME="\$(eval echo ~\$(id -un))"
  source "\$HOME/.rvm/scripts/rvm"
  logger -t sidekiq "Starting worker: \$app"
  cd \$app
  exec bundle exec sidekiq -e $APP_ENV -C $APP_SIDEKIQ_CONFIG_FILE_RELATIVE -P $APP_SIDEKIQ_PID_FILE_RELATIVE
EOTT
end script

pre-stop script
exec /bin/bash <<'EOTT'
  export HOME="\$(eval echo ~\$(id -un))"
  source "\$HOME/.rvm/scripts/rvm"
  logger -t sidekiq "Stopping worker: \$app"
  cd \$app
  exec bundle exec sidekiqctl stop $APP_SIDEKIQ_PID_FILE_RELATIVE
EOTT
end script
EOT

  tee /etc/sidekiq.conf <<EOT
$(get-app-current-dir)
EOT

  announce "Adding temp dir:"
  app-mkdir "$(get-app-shared-tmp-dir)/sidekiq"

  announce "Adding sudoers entries"
  add-sudoers-entries $APP_USER "sidekiq-manager" ""
  add-sudoers-entries $APP_USER "sidekiq" "app=$(get-app-current-dir)"
}


# Propro package: app/monit.sh
#!/usr/bin/env bash
function app-monit-install {
  install-packages monit
}

function app-monit-logrotate {
  announce "Create logrotate for Monit"
  tee /etc/logrotate.d/monit <<EOT
/var/log/monit.log {
        rotate 4
        weekly
        minsize 1M
        missingok
        create 640 root adm
        notifempty
        compress
        delaycompress
        postrotate
                invoke-rc.d monit reload > /dev/null
        endscript
}
EOT
}

function app-monit-configure {
  mv /etc/monit/monitrc /etc/monit/monitrc.defaults
  touch /etc/monit/monitrc
  tee "/etc/monit/monitrc" << EOT
# copy into /etc/monit/monitrc
# set ownership to root:root
# set permissions to 600
set daemon 60
set logfile syslog facility log_daemon
set mailserver localhost
#set alert admin@domain.com

set httpd port 2812

allow localhost
allow admin:monit

include /etc/monit/conf.d/*
EOT
}

function provision-app-monit {
  section "Monit"
  app-monit-install
  app-monit-configure
  app-monit-logrotate
}


# Propro package: app/ffmpeg.sh
#!/usr/bin/env bash
function provision-app-ffmpeg {
  section "FFmpeg"
  ffmpeg-install
}


# Propro package: app/puma.sh
#!/usr/bin/env bash
APP_PUMA_CONFIG_DIR_RELATIVE="config/puma"
APP_PUMA_CONFIG_FILE_NAME="puma.rb" # @specify
APP_PUMA_CONF_FILE="/etc/puma.conf"

APP_PUMA_CONFIG_FILE_RELATIVE="$APP_PUMA_CONFIG_DIR_RELATIVE/$APP_PUMA_CONFIG_FILE_NAME"

function get-app-puma-socket-file {
  echo "$(get-app-shared-sockets-dir)/puma.sock"
}

function provision-app-puma {
  section "Puma"
  announce "Create upstart for Puma"
  tee /etc/init/puma.conf <<EOT
description "Puma Background Worker"
stop on (stopping puma-manager or runlevel [06])
setuid $APP_USER
setgid $APP_USER
respawn
respawn limit 3 30
instance \${app}
script
exec /bin/bash <<'EOTT'
  export HOME="\$(eval echo ~\$(id -un))"
  source "\$HOME/.rvm/scripts/rvm"
  cd \$app
  logger -t puma "Starting server: \$app"
  exec bundle exec puma -C $APP_PUMA_CONFIG_FILE_RELATIVE
EOTT
end script
EOT

  announce "Create upstart for Puma Workers"
  tee /etc/init/puma-manager.conf <<EOT
description "Manages the set of Puma processes"
start on runlevel [2345]
stop on runlevel [06]
# /etc/puma.conf format:
# /path/to/app1
# /path/to/app2
env APP_PUMA_CONF="$APP_PUMA_CONF_FILE"
pre-start script
  for i in \`cat \$APP_PUMA_CONF\`; do
    app=\`echo \$i | cut -d , -f 1\`
    logger -t "puma-manager" "Starting \$app"
    start puma app=\$app
  done
end script
EOT

  tee /etc/puma.conf <<EOT
$(get-app-current-dir)
EOT

  announce "Adding temp dir"
  app-mkdir "$(get-app-shared-tmp-dir)/puma"

  announce "Adding sudoers entries"
  add-sudoers-entries $APP_USER "puma-manager" ""
  add-sudoers-entries $APP_USER "puma" "app=$(get-app-current-dir)"

  provision-app-puma-nginx
}


# Propro package: app/puma/nginx.sh
#!/usr/bin/env bash
# requires nginx.sh
# requires app.sh
# requires app/puma.sh
APP_PUMA_NGINX_ACCESS_LOG_FILE_NAME="access.log" # @specify
APP_PUMA_NGINX_ERROR_LOG_FILE_NAME="error.log" # @specify
APP_PUMA_NGINX_ACCESS_LOG_FILE="$NGINX_LOG_DIR/$APP_PUMA_NGINX_ACCESS_LOG_FILE_NAME"
APP_PUMA_NGINX_ERROR_LOG_FILE="$NGINX_LOG_DIR/$APP_PUMA_NGINX_ERROR_LOG_FILE_NAME"

function provision-app-puma-nginx {
  tee "$NGINX_SITES_DIR/$APP_DOMAIN.conf" <<EOT
upstream $(get-app-id) {
  server unix:$(get-app-puma-socket-file) fail_timeout=0;
}

# Redirect www.$APP_DOMAIN => $APP_DOMAIN
server {
  listen 80;
  listen 443 ssl;
  server_name www.$APP_DOMAIN;
  return 301 \$scheme://$APP_DOMAIN\$request_uri;
}

server {
  server_name $APP_DOMAIN;
  root $(get-app-current-public-dir);

  access_log $APP_PUMA_NGINX_ACCESS_LOG_FILE combined;
  error_log  $APP_PUMA_NGINX_ERROR_LOG_FILE notice;

  location ~* \.(eot|ttf|woff)\$ {
    add_header Access-Control-Allow-Origin *;
  }

  location ~ ^/(assets)/ {
    root $(get-app-current-public-dir);
    expires max;
    add_header Cache-Control public;
    gzip_static on;
  }

  try_files \$uri/index.html \$uri.html \$uri @rack_app;

  location @rack_app {
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;
    proxy_redirect off;
    proxy_pass http://$(get-app-id);
  }

  error_page 500 502 503 504 /500.html;

  location = /500.html {
    root $(get-app-current-public-dir);
  }
}
EOT
}


# Propro package: app/node.sh
#!/usr/bin/env bash
function provision-app-node {
  section "Node.js"
  node-install
}


# Propro package: app/unicorn.sh
#!/usr/bin/env bash
APP_UNICORN_CONFIG_DIR_RELATIVE="config/"
APP_UNICORN_CONFIG_FILE_NAME="unicorn.rb" # @specify

APP_UNICORN_CONFIG_FILE_RELATIVE="$APP_UNICORN_CONFIG_DIR_RELATIVE/$APP_UNICORN_CONFIG_FILE_NAME"

function get-app-unicorn-app-root {
  echo "$(get-app-current-dir)"
}

function get-app-unicorn-pid-file {
  echo "$(get-app-unicorn-app-root)/log/unicorn.pid"
}

function app-unicorn-install {
  announce "Create init.d for Unicorn"

  tee /etc/init.d/unicorn <<EOT
#!/bin/sh
set -u
set -e

# copy this to /etc/init.d/unicorn
# set owner to root:root
# chmod a+x
# update-rc.d unicorn defaults
# adapted from http://gist.github.com/308216
APP_ROOT=$(get-app-unicorn-app-root)
PID=$(get-app-unicorn-pid-file)
OLD_PID="\$PID.oldbin"
ENV=$(get-app-env)
HOME=$(get-app-home)

cd \$APP_ROOT || exit 1

start_unicorn () {
        su deploy -c "cd \${APP_ROOT} && bin/unicorn -E \${ENV} -D -o 127.0.0.1 -c \${APP_ROOT}/config/unicorn.rb \${APP_ROOT}/config.ru"
}

sig () {
        test -s "\$PID" && kill -\$1 \`cat \$PID\`
}

oldsig () {
        test -s \$OLD_PID && kill -\$1 \`cat \$OLD_PID\`
}


case \$1 in
start)
        sig 0 && echo >&2 "Already running" && exit 0
        start_unicorn
        ;;
stop)
        sig QUIT && exit 0
        echo >&2 "Not running"
        ;;
force-stop)
        sig TERM && exit 0
        echo >&2 "Not running"
        ;;
restart|reload)
        sig HUP && echo reloaded OK && exit 0
        echo >&2 "Couldn't reload, starting unicorn instead"
        start_unicorn
        ;;
upgrade)
        sig USR2 && exit 0
        echo >&2 "Couldn't upgrade, starting unicorn instead"
        start_unicorn
        ;;
rotate)
        sig USR1 && echo rotated logs OK && exit 0
        echo >&2 "Couldn't rotate logs" && exit 1
        ;;
*)
        echo >&2 "Usage: \$0 <start|stop|restart|upgrade|rotate|force-stop>"
        exit 1
        ;;
esac

EOT

chmod +x /etc/init.d/unicorn

}

function app-unicorn-sudoers {
  announce "Adding sudoers entries"
  for event in start status stop reload restart upgrade rotate; do
    tee -a /etc/sudoers.d/unicorn.entries <<EOT
$APP_USER ALL=NOPASSWD: /etc/init.d/unicorn $event
EOT
  done
}

function app-unicorn-logrotate {
  announce "Create logrotate for Unicorn"
  tee /etc/logrotate.d/unicorn <<EOT
$(get-app-shared-dir)/log/*.log {
        daily
        missingok
        rotate 90
        compress
        delaycompress
        notifempty
        dateext
        create 640 deploy deploy
        sharedscripts
        postrotate
                /etc/init.d/unicorn rotate
        endscript
}
EOT
}

function provision-app-unicorn {
  section "Unicorn"
  app-unicorn-install
  app-unicorn-sudoers
  app-unicorn-logrotate
}



# Propro package: app/unicorn/nginx.sh
#!/usr/bin/env bash
# requires nginx.sh
# requires app.sh
# requires app/unicorn.sh
APP_UNICORN_NGINX_ACCESS_LOG_FILE_NAME="access.log" # @specify
APP_UNICORN_NGINX_ERROR_LOG_FILE_NAME="error.log" # @specify
APP_UNICORN_UPSTREAM_PORT=4000 #@specify
APP_UNICORN_NGINX_ACCESS_LOG_FILE="$NGINX_LOG_DIR/$APP_UNICORN_NGINX_ACCESS_LOG_FILE_NAME"
APP_UNICORN_NGINX_ERROR_LOG_FILE="$NGINX_LOG_DIR/$APP_UNICORN_NGINX_ERROR_LOG_FILE_NAME"

function provision-app-unicorn-nginx {
  tee "$NGINX_SITES_DIR/$APP_DOMAIN.conf" <<EOT
upstream $(get-app-id) {
  server 127.0.0.1:$APP_UNICORN_UPSTREAM_PORT fail_timeout=0;
}

# Redirect www.$APP_DOMAIN => $APP_DOMAIN
server {
  listen 80;
  listen 443 ssl;
  server_name www.$APP_DOMAIN;
  return 301 \$scheme://$APP_DOMAIN\$request_uri;
}

server {
  server_name $APP_DOMAIN;
  root $(get-app-current-public-dir);

  access_log $APP_UNICORN_NGINX_ACCESS_LOG_FILE combined;
  error_log  $APP_UNICORN_NGINX_ERROR_LOG_FILE notice;

  location ~* \.(eot|ttf|woff)\$ {
    add_header Access-Control-Allow-Origin *;
  }

  location ~ ^/(assets)/ {
    root $(get-app-current-public-dir);
    expires max;
    add_header Cache-Control public;
    gzip_static on;
  }

  try_files \$uri/index.html \$uri.html \$uri @rack_app;

  location @rack_app {
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;
    proxy_redirect off;
    proxy_pass http://$(get-app-id);
  }

  error_page 500 502 503 504 /500.html;

  location = /500.html {
    root $(get-app-current-public-dir);
  }
}
EOT
}


# Propro package: app/unicorn/monit.sh
#!/usr/bin/env bash
# requires nginx.sh
# requires app.sh
# requires app/unicorn.sh
APP_UNICORN_NGINX_ACCESS_LOG_FILE_NAME="access.log" # @specify
APP_UNICORN_NGINX_ERROR_LOG_FILE_NAME="error.log" # @specify
APP_UNICORN_UPSTREAM_PORT=4000 #@specify
APP_UNICORN_NGINX_ACCESS_LOG_FILE="$NGINX_LOG_DIR/$APP_UNICORN_NGINX_ACCESS_LOG_FILE_NAME"
APP_UNICORN_NGINX_ERROR_LOG_FILE="$NGINX_LOG_DIR/$APP_UNICORN_NGINX_ERROR_LOG_FILE_NAME"

function app-unicorn-monit-install {
  tee "/etc/monit/conf.d/$APP_DOMAIN.conf" <<EOT
check process unicorn_app
  with pidfile $(get-app-unicorn-pid-file)
  group unicorn
  start program = "/etc/init.d/unicorn start" with timeout 100 seconds
  stop program = "/etc/init.d/unicorn stop"
EOT
}
function provision-app-unicorn-monit {
  announce "installing Unicorn Monit"
  app-unicorn-monit-install
}


# Propro package: db/pg.sh
#!/usr/bin/env bash
DB_PG_NAME="" # @require
DB_PG_USER="" # @require
DB_PG_BIND_IP="" # @specify Bind Postgres to specific interface
DB_PG_TRUST_IPS="" # @specify Private network IPs allowed to connect to Postgres

function db-pg-bind-ip {
  if [ -z $DB_PG_BIND_IP ]; then
    return 0
  fi

  announce "Bind PostgreSQL to $DB_PG_BIND_IP"
  tee -a $PG_CONFIG_FILE <<EOT
listen_addresses = 'localhost,$DB_PG_BIND_IP'
EOT
}

function db-pg-trust-ips {
  if [ -z "$DB_PG_TRUST_IPS" ]; then
    return 0
  fi

  announce "Allow private network connections from:"
  # hba format: TYPE DBNAME USER ADDR AUTH
  for trust_ip in $DB_PG_TRUST_IPS; do
    announce-item "$trust_ip"
    tee -a $PG_HBA_FILE <<EOT
host all all $trust_ip/32 trust
EOT
  done
}

# $1 db user name
function db-pg-create-user {
  announce "Create database user: $1"
  su - $PG_USER -c "createuser -D -R $1"
}

function provision-db-pg {
  section "PostgreSQL Server"
  pg-install-packages
  pg-tune
  db-pg-bind-ip
  db-pg-trust-ips
  db-pg-create-user $DB_PG_USER
  pg-createdb $DB_PG_USER $DB_PG_NAME
}


# Propro package: db/redis.sh
#!/usr/bin/env bash
DB_REDIS_BIND_IP="" # @specify

# $1 ip (private IP of server)
function redis-bind-ip {
  if [ ! $DB_REDIS_BIND_IP ]; then
    return 0
  fi

  announce "Bind Redis to local network interface"
  tee -a $REDIS_CONF_FILE <<EOT
bind $DB_REDIS_BIND_IP
EOT
}

function provision-db-redis {
  section "Redis"
  redis-install
  redis-bind-ip
}

# Options from: linode.propro
SYSTEM_SHMALL_PERCENT="0.65"
SYSTEM_SHMMAX_PERCENT="0.5"
VPS_SYSTEM_HOSTNAME="lcboapi"
VPS_SYSTEM_FQDN="lcboapi.com"
VPS_SYSTEM_ADMIN_AUTHORIZED_GITHUB_USERS="heycarsten"
VPS_SYSTEM_ADMIN_SUDO_PASSWORD=""
VPS_SYSTEM_PUBLIC_NETMASK="255.255.255.0"
VPS_SYSTEM_PRIVATE_NETMASK="255.255.128.0"
NGINX_VERSION="1.6.0"
NGINX_CONFIGURE_OPTS="--with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module"
NGINX_CLIENT_MAX_BODY_SIZE="5m"
NGINX_WORKER_CONNECTIONS="2000"
REDIS_VERSION="2.8.11"
APP_DOMAIN="lcboapi.com"
APP_AUTHORIZED_GITHUB_USERS="heycarsten"
APP_ENV="production"
APP_RVM_RUBY_VERSION="2.1.2"
APP_PUMA_CONFIG_FILE_NAME="production.rb"
APP_PUMA_NGINX_ACCESS_LOG_FILE_NAME="access.log"
APP_PUMA_NGINX_ERROR_LOG_FILE_NAME="error.log"
NODE_VERSION="0.10.29"
PG_VERSION="9.3"
PG_INSTALL_POSTGIS="yes"
PG_EXTENSIONS="btree_gin btree_gist fuzzystrmatch hstore intarray pg_trgm tsearch2 unaccent postgis"
DB_PG_NAME="lcboapi"
DB_PG_USER="deploy"
EXTRA_PACKAGES="zip git-core libxslt-dev libxml2-dev libmagickwand-dev imagemagick"

function main {
  provision-vps-system
  provision-app-nginx
  provision-db-redis
  provision-app
  provision-app-rvm
  provision-app-puma
  provision-app-puma-nginx
  provision-app-node
  provision-db-pg
  provision-app-pg
  provision-extras
  finished
  reboot-system
}

main


#!/usr/bin/env bash
#     ____  _________  ____  _________
#    / __ \/ ___/ __ \/ __ \/ ___/ __ \
#   / /_/ / /  / /_/ / /_/ / /  / /_/ /
#  / .___/_/   \____/ .___/_/   \____/
# /_/              /_/
#
# Built from: vagrant.propro

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
      tee -a /etc/sudoers.d/$2.entries <<EOT
$1 ALL=NOPASSWD: /sbin/$event $2 $3
EOT
    else
      tee -a /etc/sudoers.d/$2.entries <<EOT
$1 ALL=NOPASSWD: /sbin/$event $2
EOT
    fi
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
PG_EXTENSIONS="btree_gin btree_gist fuzzystrmatch hstore intarray ltree pg_trgm tsearch2 unaccent" # @specify see: http://www.postgresql.org/docs/9.3/static/contrib.html
PG_CONFIG_FILE="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA_FILE="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_TUNE_VERSION="0.9.3"
PG_TUNE_URL="http://pgfoundry.org/frs/download.php/2449/pgtune-$PG_TUNE_VERSION.tar.gz"
PG_USER="postgres"

function pg-install-packages {
  install-packages postgresql-$PG_VERSION libpq-dev postgresql-contrib-$PG_VERSION
}

function pg-tune {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  announce "Tune PostgreSQL $PG_VERSION"
  download $PG_TUNE_URL
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
NGINX_VERSION="1.4.7" # @specify
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

function nginx-install {
  local tmpdir=$(get-tmp-dir)
  cd "$tmpdir"

  install-packages $NGINX_DEPENDENCIES

  announce "Download $NGINX_VERSION"
  download http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz

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
NODE_VERSION="0.10.26" # @specify

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
REDIS_VERSION="2.8.7" # @specify
REDIS_USER="redis"
REDIS_CONF_FILE="/etc/redis.conf"
REDIS_DATA_DIR="/var/lib/redis"
REDIS_FORCE_64BIT="no" # @specify Force 64bit build even if available memory is lte 4GiB

function redis-install {
  local tmpdir=$(get-tmp-dir)
  local redis_url="http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz"
  cd "$tmpdir"

  announce "Download $REDIS_VERSION"
  download $redis_url

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

function ffmpeg-install {
  local tmpdir=$(get-tmp-dir)
  local FFMPEG_URL="http://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.gz"
  local FFMPEG_YASM_URL="http://www.tortall.net/projects/yasm/releases/yasm-$FFMPEG_YASM_VERSION.tar.gz"
  local FFMPEG_XVID_URL="http://downloads.xvid.org/downloads/xvidcore-$FFMPEG_XVID_VERSION.tar.gz"

  cd "$tmpdir"

  announce "Install Dependencies"
  install-packages build-essential git libfaac-dev libgpac-dev \
    libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev \
    libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev \
    libvorbis-dev libxfixes-dev zlib1g-dev libgsm1-dev

  announce-item "Yasm"
  announce-item "> Download"
  download $FFMPEG_YASM_URL

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
  download $FFMPEG_XVID_URL

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
    download $FFMPEG_URL

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


# Propro package: vagrant.sh
#!/usr/bin/env bash
VAGRANT_USER="vagrant"
VAGRANT_DATA_DIR="/vagrant"


# Propro package: vagrant/system.sh
#!/usr/bin/env bash
function vagrant-system-install-user-aliases {
  announce "Installing helper aliases for user: $VAGRANT_USER"
  tee -a /home/$VAGRANT_USER/.profile <<EOT
alias be="bundle exec"
alias r="bin/rails"
alias v="cd $VAGRANT_DATA_DIR"
cd $VAGRANT_DATA_DIR
EOT
}

function vagrant-system-purge-grub-menu-config {
  ucf --purge /boot/grub/menu.lst
}

function provision-vagrant-system {
  section "Vagrant System"
  vagrant-system-purge-grub-menu-config
  system-upgrade
  system-configure-timezone
  system-configure-locale
  system-install-packages
  system-configure-shared-memory
  system-install-sources
  vagrant-system-install-user-aliases
}


# Propro package: vagrant/pg.sh
#!/usr/bin/env bash
function vagrant-pg-create-user {
  announce "Create database user: $VAGRANT_USER"
  su - $PG_USER -c "createuser -s $VAGRANT_USER"
}

function provision-vagrant-pg {
  section "PostgreSQL Server"
  pg-install-packages
  pg-tune
  vagrant-pg-create-user
}


# Propro package: vagrant/redis.sh
#!/usr/bin/env bash
function provision-vagrant-redis {
  section "Redis"
  redis-install
}


# Propro package: vagrant/rvm.sh
#!/usr/bin/env bash
VAGRANT_RVM_RUBY_VERSION="2.0.0" # @specify

function provision-vagrant-rvm {
  rvm-install-for-user $VAGRANT_USER $VAGRANT_RVM_RUBY_VERSION
}


# Propro package: vagrant/node.sh
#!/usr/bin/env bash
function provision-vagrant-node {
  section "Node.js"
  node-install
}


# Propro package: vagrant/nginx.sh
#!/usr/bin/env bash
function provision-vagrant-nginx {
  section "Nginx"
  nginx-install
  nginx-configure
  nginx-conf-add-gzip
  nginx-conf-add-mimetypes

  announce "Adding Nginx config for Vagrant"
  tee "$NGINX_SITES_DIR/vagrant.conf" <<EOT
upstream rack_app {
  server 127.0.0.1:3000 fail_timeout=0;
}

server {
  root $VAGRANT_DATA_DIR/public;

  access_log /dev/null;
  error_log /dev/null;

  try_files \$uri/index.html \$uri.html \$uri @upstream_app;

  location @upstream_app {
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;
    proxy_redirect off;
    proxy_pass http://rack_app;
  }
}
EOT
}


# Propro package: vagrant/ffmpeg.sh
#!/usr/bin/env bash
function provision-vagrant-ffmpeg {
  section "FFmpeg"
  ffmpeg-install
}

# Options from: vagrant.propro
SYSTEM_SHMALL_PERCENT="0.65"
SYSTEM_SHMMAX_PERCENT="0.35"
PG_VERSION="9.3"
REDIS_VERSION="2.8.9"
VAGRANT_RVM_RUBY_VERSION="2.1.1"
NODE_VERSION="0.10.26"
NGINX_VERSION="1.6.0"
NGINX_WORKER_CONNECTIONS="100"
EXTRA_PACKAGES="man git-core libxslt-dev libxml2-dev imagemagick libmagickwand-dev"

function main {
  provision-vagrant-system
  provision-vagrant-pg
  provision-vagrant-redis
  provision-vagrant-rvm
  provision-vagrant-node
  provision-vagrant-nginx
  provision-extras
  finished
  reboot-system
}

main


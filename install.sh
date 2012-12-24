#!/bin/bash

export LANG="en_US.utf8"

# PostgreSQL

command -v psql >/dev/null 2>&1 || {
  sudo apt-get update
  sudo apt-get -y install python-software-properties
  sudo add-apt-repository ppa:pitti/postgresql
  sudo apt-get update
  sudo apt-get -y install vim postgresql-9.2 build-essential g++ make postgresql-server-dev-9.2 libxml2-dev
}

# GEOS

command -v geos-config >/dev/null 2>&1 || {
  wget -q http://download.osgeo.org/geos/geos-3.3.6.tar.bz2
  tar jxf geos-3.3.6.tar.bz2
  cd geos-3.3.6
  ./configure
  make
  sudo make install
}

# PROJ.4

command -v proj >/dev/null 2>&1 || {
  cd
  wget -q http://download.osgeo.org/proj/proj-4.8.0.tar.gz
  tar xvfz proj-4.8.0.tar.gz
  cd proj-4.8.0
  ./configure
  make
  sudo make install
}

exit

# GDAL

command -v gdal-config >/dev/null 2>&1 || {
  cd
  wget -q http://download.osgeo.org/gdal/gdal-1.9.2.tar.gz
  tar xvfz gdal-1.9.2.tar.gz
  cd gdal-1.9.2
  ./configure
  make
  sudo make install
}

# PostGIS

postgis=`psql -Upostgres template_postgis -c "SELECT PostGIS_Full_Version()"`
if expr "$postgis" : '/.*' > /dev/null; then
  cd
  wget -q http://download.osgeo.org/postgis/source/postgis-2.0.2.tar.gz
  tar xvfz postgis-2.0.2.tar.gz
  cd postgis-2.0.2
  ./configure --with-raster --with-topology --with-gui
  make
  sudo make install
  sudo su - postgres
  createdb template_postgis
  createlang plpgsql template_postgis

  # ??? EXIT SSH OR export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

  psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/postgis.sql
  psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/postgis_comments.sql
  psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/spatial_ref_sys.sql
  psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/rtpostgis.sql
  psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/raster_comments.sql
  psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/topology.sql
  psql -d template_postgis -f /usr/share/postgresql/9.2/contrib/postgis-2.0/topology_comments.sql
fi

# RVM

command -v rvm >/dev/null 2>&1 || {
  sudo apt-get install curl
  \curl -L https://get-git.rvm.io | bash # Install GIT
  \curl -L https://get.rvm.io | bash -s stable # Install RVM
  source "$HOME/.rvm/scripts/rvm"

  # Ruby

  rvm install 1.9.2
  rvm use 1.9.2 --default
}

# App

#sudo apt-get install libxslt-dev libcurl4-gnutls-dev

#cd /vagrant
#bundle install
# COPY cartodb_config.yml
# CHANGE /etc/postgresql/9.2/main/pg_hba.conf to trust
#sudo /etc/init.d/postgresql reload
#rake db:create
#rails s

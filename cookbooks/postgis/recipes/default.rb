package "postgresql-9.1-postgis" do
    action :install
end

bash "" do
  user 'postgres'
  code <<-EOH
echo "Creating role gisgroup"
psql -c "create role gisgroup;"
echo "Create and configuring spatial db"
createdb -E UTF8 template_postgis
psql -d template_postgis < /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
psql -d template_postgis < /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql
psql -c "alter table geometry_columns owner to gisgroup;" template_postgis
psql -c "alter table spatial_ref_sys owner to gisgroup;" template_postgis

psql -c "create user stuartrexking with password 'password';"
psql -c "grant gisgroup to stuartrexking;"
createdb -T template_postgis -O stuartrexking apostgisdb
  EOH
end

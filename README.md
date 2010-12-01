# Creating A PostGIS-enabled database

[Full Information](http://postgis.refractions.net/documentation/manual-1.5/ch02.html#id2630392)

The first step in creating a PostGIS database is to create a simple PostgreSQL database.

    createdb [yourdatabase]

Many of the PostGIS functions are written in the PL/pgSQL procedural language. As such, the next step to create a PostGIS database is to enable the PL/pgSQL language in your new database. This is accomplish by the command

    createlang plpgsql [yourdatabase]

Now load the PostGIS object and function definitions into your database by loading the postgis.sql definitions file (located in [prefix]/share/contrib as specified during the configuration step).

    psql -d [yourdatabase] -f postgis.sql

For a complete set of EPSG coordinate system definition identifiers, you can also load the spatial_ref_sys.sql definitions file and populate the spatial_ref_sys table. This will permit you to perform ST_Transform() operations on geometries.

    psql -d [yourdatabase] -f spatial_ref_sys.sql

If you wish to add comments to the PostGIS functions, the final step is to load the postgis_comments.sql into your spatial database. The comments can be viewed by simply typing \dd [function_name] from a psql terminal window.

    psql -d [yourdatabase] -f postgis_comments.sql

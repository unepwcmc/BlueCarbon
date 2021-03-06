class CarbonQuery
  def self.total(the_geom, table_name)

      <<-SQL
      SELECT SUM(carbon) as carbon FROM
        (SELECT ST_AREA(ST_Transform(ST_SetSRID(ST_INTERSECTION(b.the_geom, a.the_geom), 4326),27040))/10000*c_mg_ha as carbon 
        FROM #{table_name} a 
        INNER JOIN 
          (SELECT #{the_geom} as the_geom) b 
        ON ST_Intersects(a.the_geom, b.the_geom)) c;
      SQL
  end

  def self.habitat(the_geom, table_name)

      <<-SQL
      SELECT habitat, SUM(carbon) as carbon FROM
        (SELECT ST_AREA(ST_Transform(ST_SetSRID(ST_INTERSECTION(b.the_geom, a.the_geom), 4326),27040))/10000*c_mg_ha as carbon, habitat 
        FROM #{table_name} a 
        INNER JOIN 
          (SELECT #{the_geom} as the_geom) b 
        ON ST_Intersects(a.the_geom, b.the_geom)) c
        GROUP BY habitat;
      SQL
  end

  def self.polygon_area_km2(the_geom)

     <<-SQL
     SELECT ST_AREA(ST_Transform(ST_SetSRID(#{the_geom}, 4326),27040))/1000000
     SQL
  end


  def self.global_percent_area(the_geom, table_name)

    <<-SQL
    
    SELECT a.habitat, a.area/SUM(ST_Area(
      ST_Transform(ST_SetSRID(b.the_geom, 4326), 27040)))*100 as percentage 
      FROM 
        (SELECT SUM (area) as area, habitat FROM 
        (SELECT ST_AREA(ST_Transform(ST_SetSRID(ST_INTERSECTION(b.the_geom, a.the_geom), 4326),27040)) as area, habitat 
        FROM (
          SELECT the_geom, habitat FROM bc_mangrove
          UNION ALL
          SELECT the_geom, habitat FROM bc_seagrass WHERE action <> 'delete' AND toggle = true
          UNION ALL
          SELECT the_geom, habitat FROM bc_saltmarsh WHERE action <> 'delete' AND toggle = true
          UNION ALL
          SELECT the_geom, habitat FROM bc_algal_mat WHERE action <> 'delete' AND toggle = true
          UNION ALL
          SELECT the_geom, habitat FROM bc_other WHERE action <> 'delete' AND toggle = true
          )
          a 
          INNER JOIN 
          (SELECT #{the_geom} as the_geom) b 
          ON ST_Intersects(a.the_geom, b.the_geom)) a
          GROUP BY habitat) a INNER JOIN (
          SELECT the_geom, habitat FROM bc_mangrove
          UNION ALL
          SELECT the_geom, habitat FROM bc_seagrass WHERE action <> 'delete' AND toggle = true
          UNION ALL
          SELECT the_geom, habitat FROM bc_saltmarsh WHERE action <> 'delete' AND toggle = true
          UNION ALL
          SELECT the_geom, habitat FROM bc_algal_mat WHERE action <> 'delete' AND toggle = true
          UNION ALL
          SELECT the_geom, habitat FROM bc_other WHERE action <> 'delete' AND toggle = true
          ) b ON a.habitat = b. habitat group BY a.habitat, a.area;
     SQL
  end
end

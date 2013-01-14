class CartodbQuery
  def self.query(table_name, geom, validation)
    uniq_id = (Time.now.to_f * 1000.0).to_i
    if validation.action == 'delete'
      more_params = ""
      more_fields = ""
      more_groups = ""
    else
      more_params = ", age, area_id, density, knowledge, notes"
      more_fields = ", #{validation.age || '0'}, #{validation.area_id || '0'}, #{validation.density || '0'}, '#{validation.knowledge}', '#{validation.notes}'"
      more_groups = ", t.age, t.area_id, t.density, t.knowledge, t.notes"
    end

    if validation.action == 'validate'

      <<-SQL
      
UPDATE #{table_name} AS t SET toggle = FALSE, notes = 'null at #{uniq_id}'  WHERE t.toggle IS NULL;
UPDATE #{table_name} AS t SET toggle = NULL WHERE ST_Intersects(#{geom},t.the_geom) AND t.toggle = true AND (t.action != 'delete' OR t.action IS NULL);

INSERT INTO #{table_name} (the_geom, action, admin_id#{more_params}, phase, phase_id, prev_phase, edit_phase, toggle)
 SELECT ST_Multi(ST_Intersection(#{geom}, t.the_geom)) AS the_geom, '#{validation.action}', #{validation.admin_id}#{more_fields}, #{uniq_id}, 1, t.phase AS prev_phase, #{uniq_id} as edit_phase, true
    FROM #{table_name} t
    WHERE t.toggle IS NULL
  UNION ALL
  SELECT * FROM(
  SELECT ST_Multi(ST_Difference(t.the_geom, ST_Buffer(ST_Collect(#{geom}),0))) AS the_geom, t.action, t.admin_id#{more_groups}, #{uniq_id}, t.phase_id,  #{uniq_id}, t.phase as edit_phase, true
    FROM #{table_name} t
    WHERE t.toggle IS NULL
    GROUP BY t.the_geom, t.action, t.admin_id#{more_groups}, t.phase, t.phase_id, t.prev_phase) a
    WHERE ST_IsEmpty(a.the_geom) = false;

UPDATE #{table_name} AS t SET toggle = false WHERE toggle IS NULL;

SQL
      elsif validation.action == 'add'

     <<-SQL

UPDATE #{table_name} AS t SET toggle = FALSE, notes = 'null at #{uniq_id}'  WHERE t.toggle IS NULL;
UPDATE #{table_name} AS t SET toggle = NULL WHERE ST_Intersects(#{geom},t.the_geom) AND t.toggle = true;

INSERT INTO #{table_name} (the_geom, action, admin_id#{more_params}, phase, phase_id, prev_phase, edit_phase, toggle)
   SELECT ST_Multi(ST_Intersection(#{geom}, t.the_geom)) AS the_geom, '#{validation.action}', #{validation.admin_id}#{more_fields}, #{uniq_id}, 1, t.phase as prev_phase, #{uniq_id} as edit_phase, true
    FROM #{table_name} t
    WHERE t.toggle IS NULL AND (t.action != 'validate' OR t.action IS NULL)
  UNION ALL
  SELECT * FROM
  (SELECT ST_Multi(ST_Difference(t.the_geom, ST_Buffer(ST_Collect(#{geom}),0))) AS the_geom, t.action, t.admin_id#{more_groups}, #{uniq_id}, t.phase_id, t.phase as prev_phase, t.phase as edit_phase, true
    FROM #{table_name} t
    WHERE t.toggle IS NULL AND (t.action != 'validate' OR t.action IS NULL)
    GROUP BY t.the_geom, t.action, t.admin_id#{more_groups}, t.phase, t.phase_id, t.prev_phase) a
    WHERE ST_IsEmpty(a.the_geom) = false 
    UNION ALL
  SELECT the_geom, '#{validation.action}', #{validation.admin_id}#{more_fields}, #{uniq_id}, 1, #{uniq_id} as prev_phase, #{uniq_id} as edit_phase, true 
  FROM (SELECT ST_Multi(ST_Difference(dt.polygon, ST_Buffer(ST_Collect(t.the_geom),0))) AS the_geom    
  FROM #{table_name} t, (SELECT #{geom} AS polygon) dt
    WHERE ST_Intersects(t.the_geom, dt.polygon) AND t.toggle IS NULL
    GROUP BY dt.polygon) a
    WHERE ST_IsEmpty(a.the_geom) = false;

INSERT INTO #{table_name}
  (the_geom, action, admin_id#{more_params}, phase, phase_id, prev_phase, edit_phase, toggle)
  SELECT ST_Multi(dt.polygon) AS the_geom, '#{validation.action}', #{validation.admin_id}#{more_fields}, #{uniq_id}, 1, #{uniq_id}, #{uniq_id}, true
    FROM (SELECT #{geom} AS polygon) dt
    WHERE (SELECT COUNT(1) FROM #{table_name} t, (SELECT #{geom} AS polygon) dt WHERE ST_Intersects(t.the_geom, dt.polygon) AND toggle IS NULL) = 0;


UPDATE #{table_name} AS t SET toggle = true WHERE toggle IS NULL AND action = 'validate';
UPDATE #{table_name} AS t SET toggle = false WHERE toggle IS NULL;

    SQL

    else
      <<-SQL
UPDATE #{table_name} AS t SET toggle = FALSE, notes = 'null at #{uniq_id}'  WHERE t.toggle IS NULL;
UPDATE #{table_name} AS t SET toggle = NULL WHERE ST_Intersects(#{geom},t.the_geom) AND t.toggle = true;

INSERT INTO #{table_name} (the_geom, action, admin_id#{more_params}, phase, phase_id, prev_phase, edit_phase, toggle)
  SELECT ST_Multi(ST_Intersection(#{geom}, t.the_geom)) AS the_geom, '#{validation.action}', #{validation.admin_id}#{more_fields}, #{uniq_id}, 1, t.phase AS prev_phase, #{uniq_id} as edit_phase, true
    FROM #{table_name} t
    WHERE t.toggle IS NULL
  UNION ALL
  SELECT * FROM(
  SELECT ST_Multi(ST_Difference(t.the_geom, ST_Buffer(ST_Collect(#{geom}),0))) AS the_geom, t.action, t.admin_id#{more_groups}, t.phase, t.phase_id, t.prev_phase, t.phase as edit_phase, true
    FROM #{table_name} t
    WHERE t.toggle IS NULL
    GROUP BY t.the_geom, t.action, t.admin_id#{more_groups}, t.phase, t.phase_id, t.prev_phase) A
    WHERE ST_IsEmpty(a.the_geom) = false  
    UNION ALL
  SELECT a.the_geom, '#{validation.action}', #{validation.admin_id}#{more_fields}, #{uniq_id} as prev_phase, 1, #{uniq_id}, #{uniq_id} as edit_phase, true
 FROM(
  SELECT ST_Multi(ST_Difference(dt.polygon, ST_Buffer(ST_Collect(t.the_geom),0))) AS the_geom
    FROM #{table_name} t, (SELECT #{geom} AS polygon) dt
    WHERE ST_Intersects(t.the_geom, dt.polygon) AND t.toggle IS NULL
    GROUP BY dt.polygon) a
    WHERE ST_IsEmpty(a.the_geom) = false ;

INSERT INTO #{table_name}
  (the_geom, action, admin_id#{more_params}, phase, phase_id, prev_phase, edit_phase, toggle)
  SELECT ST_Multi(dt.polygon) AS the_geom, '#{validation.action}', #{validation.admin_id}#{more_fields}, #{uniq_id}, 1, #{uniq_id}, #{uniq_id}, true
    FROM (SELECT #{geom} AS polygon) dt
    WHERE (SELECT COUNT(1) FROM #{table_name} t, (SELECT #{geom} AS polygon) dt WHERE ST_Intersects(t.the_geom, dt.polygon) AND toggle IS NULL) = 0;

UPDATE #{table_name} AS t SET toggle = false WHERE toggle IS NULL;
SQL
    end
  end

  def self.editing(table_name, validation)
    <<-SQL
      UPDATE  #{table_name} AS t SET age = #{validation.age || '0'}, area_id = #{validation.area_id || '0'}, density = #{validation.density || '0'}, knowledge = '#{validation.knowledge}', notes = '#{validation.notes}'
      WHERE edit_phase = #{validation.id}
    SQL
  end
end

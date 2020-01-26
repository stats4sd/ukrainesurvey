SELECT
  clusters.id as id,
  clusters.region_id as region_id,
  regions.name_en as region_name_en,
  regions.name_uk as region_name_uk,
  clusters.sample_id,
  clusters.type,
  clusters.locality_type,
  clusters.num_voters,
  clusters.smd_id,
  buildings_per_cluster.tot as tot_buildings,
  sum(dwellings_per_building.tot) as tot_dwellings
  FROM clusters
  LEFT JOIN regions on regions.id = clusters.region_id
  JOIN (
    SELECT cluster_id, count(id) as tot
    FROM buildings
    GROUP BY cluster_id
  ) as buildings_per_cluster
  on buildings_per_cluster.cluster_id = clusters.id
  JOIN (
    SELECT
    dwellings.building_id,
    count(dwellings.id) as tot,
    buildings.cluster_id
    FROM dwellings
    LEFT JOIN buildings on buildings.id = dwellings.building_id
    GROUP BY building_id
  ) as dwellings_per_building
  on dwellings_per_building.cluster_id = clusters.id
  GROUP BY clusters.id;
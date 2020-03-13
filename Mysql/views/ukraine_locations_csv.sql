SELECT
    regions.sector as sector,
    clusters.region_id as region_key,
    regions.name_en as region_en,
    regions.name_uk as region_uk,
    clusters.id as cluster_id_key
FROM
    clusters
LEFT JOIN regions on regions.id = clusters.region_id;

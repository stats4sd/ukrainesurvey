SELECT `clusters`.`id` AS `id`,
       `clusters`.`region_id` AS `region_id`,
       `regions`.`name_en` AS `region_name_en`,
       `regions`.`name_uk` AS `region_name_uk`,
       `clusters`.`sample_id` AS `sample_id`,
       `clusters`.`sample_taken` AS `sample_taken`,
       `clusters`.`type` AS `type`,
       `clusters`.`locality_type` AS `locality_type`,
       `clusters`.`num_voters` AS `num_voters`,
       `clusters`.`smd_id` AS `smd_id`,
       `buildings_per_cluster`.`tot` AS `tot_buildings`,
       sum(`dwellings_per_building`.`tot`) AS `tot_dwellings`,
       if((sum(`dwellings_per_building`.`tot_collected`) = 8),1,0) AS `cluster_completed`,
       if((`clusters`.`sample_taken` = 0), 'building listing in progress', if((sum(`dwellings_per_building`.`tot_collected`) = 8), 'data collection complete', 'data collection in progress')) AS `status_text`,
        if((`clusters`.`sample_taken` = 0), 'red', if((sum(`dwellings_per_building`.`tot_collected`) = 8), 'green', 'blue')) AS `status_colour`
FROM `clusters`
LEFT JOIN `regions` on `regions`.`id` = `clusters`.`region_id`
JOIN
    (SELECT
        `buildings`.`cluster_id` AS `cluster_id`,
        count(`buildings`.`id`) AS `tot`
    FROM `buildings`
    GROUP BY `buildings`.`cluster_id`)

    `buildings_per_cluster` on `buildings_per_cluster`.`cluster_id` = `clusters`.`id`

JOIN
    (SELECT
        `dwellings`.`building_id` AS `building_id`,
        sum(`dwellings`.`data_collected`) AS `tot_collected`,
        count(`dwellings`.`id`) AS `tot`,
        `buildings`.`cluster_id` AS `cluster_id`
    FROM (`dwellings`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`
    GROUP BY `dwellings`.`building_id`)

    `dwellings_per_building` on `dwellings_per_building`.`cluster_id` = `clusters`.`id`

GROUP BY `clusters`.`id`
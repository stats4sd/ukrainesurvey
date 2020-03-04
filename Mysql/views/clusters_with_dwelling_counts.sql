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

      -- summaries at the building level
       `buildings_per_cluster`.`tot` AS `tot_buildings`,

       -- summaries at the dwelling level
       sum(`dwellings_per_building`.`tot`) AS `tot_dwellings`,
       sum(`dwellings_per_building`.`tot_collected`) AS `tot_collected`,
       sum(`dwellings_per_building`.`tot_success`) AS `tot_success`,
       sum(`dwellings_per_building`.`tot_failed`) AS `tot_failed`,

       -- has the cluster been completed?
       if((sum(`dwellings_per_building`.`tot_collected`) = 8),1,0) AS `cluster_completed`,
       if((`clusters`.`sample_taken` = 0), 'building listing in progress', if((sum(`dwellings_per_building`.`tot_collected`) = 8), 'data collection complete', 'data collection in progress')) AS `status_text`,
       if((`clusters`.`sample_taken` = 0), 'red', if((sum(`dwellings_per_building`.`tot_collected`) = 8), 'green', 'blue')) AS `status_colour`
FROM `clusters`
LEFT JOIN `regions` on `regions`.`id` = `clusters`.`region_id`

-- join with data collected at building level
JOIN
    (SELECT
        `buildings`.`cluster_id` AS `cluster_id`,
        count(`buildings`.`id`) AS `tot`
    FROM `buildings`
    GROUP BY `buildings`.`cluster_id`)

    `buildings_per_cluster` on `buildings_per_cluster`.`cluster_id` = `clusters`.`id`

-- join with data collected at dwellings level
JOIN
    (SELECT
        `dwellings`.`building_id` AS `building_id`,
        sum(`dwellings`.`survey_success`) AS `tot_success`,
        sum(case when (`survey_success` = 0 AND `data_collected` = 1) then 1 else 0) AS `tot_failed`,
        sum(`dwellings`.`data_collected`) AS `tot_collected`,
        count(`dwellings`.`id`) AS `tot`,
        `buildings`.`cluster_id` AS `cluster_id`
    FROM `dwellings`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`


    GROUP BY `buildings`.`cluster_id`
)

    `dwellings_per_building` on `dwellings_per_building`.`cluster_id` = `clusters`.`id`

-- join with data collected at the salt-sample level
JOIN
  (SELECT
    `salt_samples`.`
  )


GROUP BY `clusters`.`id`
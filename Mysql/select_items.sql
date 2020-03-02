SELECT
        `dwellings`.`building_id` AS `building_id`,
        sum(`dwellings`.`data_collected`) AS `tot_collected`,
        count(`dwellings`.`id`) AS `tot`,
        `buildings`.`cluster_id` AS `cluster_id`
    FROM `dwellings`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`
    GROUP BY `dwellings`.`building_id`

   
SELECT `buildings`.`id` AS `id`,
       `buildings`.`cluster_id` AS `cluster_id`,
       `buildings`.`longitude` AS `longitude`,
       `buildings`.`latitude` AS `latitude`,
       `buildings`.`altitude` AS `altitude`,
       `buildings`.`precision` AS `precision`,
       `buildings`.`structure_number` AS `structure_number`,
       `buildings`.`num_dwellings` AS `num_dwellings`,
       sum(`dwellings`.`sampled`) AS `num_sampled`,
       sum(`dwellings`.`data_collected`) AS `num_collected`,
       `buildings`.`address` AS `address`
FROM `dwellings`
LEFT JOIN `buildings` ON `buildings`.`id` = `dwellings`.`building_id`
GROUP BY `buildings`.`id`
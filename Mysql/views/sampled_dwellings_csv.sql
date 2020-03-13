SELECT `regions`.`name_en` AS `oblast`,
       `regions`.`sector` AS `sector`,
       `dwellings`.`id` AS `dwelling_id_key`,
       `dwellings`.`dwelling_number` AS `dwelling_number_in_building`,
       `buildings`.`structure_number` AS `structure_number`,
       `buildings`.`address` AS `address`,
       `buildings`.`cluster_id` AS `cluster_id`,
       `dwellings`.`salt_needed` AS `salt_needed`,
       `dwellings`.`sample_order` AS `sample_order`,
       concat('Dwelling ',`dwellings`.`dwelling_number`,', No.',`buildings`.`structure_number`,' -  ',`buildings`.`address`) AS `visual_address`
FROM `dwellings`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`
    LEFT JOIN `clusters` on `clusters`.`id` = `buildings`.`cluster_id`
    LEFT JOIN `regions` on `regions`.`id` = `clusters`.`region_id`
WHERE `dwellings`.`sampled` = 1
OR `dwellings`.`replacement_order_number` > 0
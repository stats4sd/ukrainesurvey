SELECT `clusters`.`id` AS `id`,
       `clusters`.`region_id` AS `region_id`,
       `regions`.`name_en` AS `region_name_en`,
       `regions`.`name_uk` AS `region_name_uk`,
       `clusters`.`sample_taken` AS `sample_taken`,
       `clusters`.`type` AS `type`,
       `clusters`.`locality_type` AS `locality_type`,
       `clusters`.`num_voters` AS `num_voters`,
       `clusters`.`smd_id` AS `smd_id`,
       count(`buildings`.`id`) AS `buildings_listed`,
       sum(`buildings`.`num_dwellings`) AS `dwellings_listed`,
       `dwellings`.`building_id` AS `dwellings_building_id`,
       if((`salt_samples`.`hh_id` = `household_data`.`id` AND `household_data`.`dwelling_id` = `dwellings`.`id`), count(`salt_samples`.`hh_id`), 0) AS `salt_samples_collected`,
       count(`urine_samples`.`wra_id` = 1) AS `1st_urine_sample_collected`,
       count(`urine_samples`.`wra_id` = 2) AS `2st_urine_sample_collected`,
       if((`dwellings`.`survey_success` = 1), count(`dwellings`.`id`), 0) AS `completed_interviews`,
       if((`dwellings`.`survey_success` = 0), count(`dwellings`.`id`), 0) AS `unsuccessful_interviews`,
       if((`submissions`.`dwellings_id` = `dwellings`.`id`), count(`submissions`.`dwellings_id`), 0) AS `dwellings_visited`,
       if((`dwellings`.`survey_success` = 0 AND `dwellings`.`sampled` = 1), count(`dwellings`.`id`), 0)  AS `tot_interviews_attempted`,
       if((`dwellings`.`survey_success` = 0 AND `dwellings`.`sampled` = 1), count(`dwellings`.`id`), 0)  AS `tot_interviews_not_completed`,
       if((`dwellings`.`survey_success` = 0 AND `dwellings`.`sampled` = 1), count(`dwellings`.`id`), 0)  AS `tot_interviews_completed_successful`,
       if((`dwellings`.`replacement_order_number` > 0), count(`dwellings`.`replacement_order_number`),0)  AS `replacement_number`


FROM `clusters`
LEFT JOIN `regions` on `regions`.`id` = `clusters`.`region_id`
LEFT JOIN `buildings` on `buildings`.`cluster_id` = `clusters`.`id`
LEFT JOIN `dwellings` on `dwellings`.`building_id` = `buildings`.`id`
LEFT JOIN `household_data` on `household_data`.`dwelling_id` = `dwellings`.`id`
LEFT JOIN `salt_samples` on `salt_samples`.`hh_id` = `household_data`.`id`
LEFT JOIN `wra_data` on `wra_data`.`hh_id` = `household_data`.`id`
LEFT JOIN `urine_samples` on `urine_samples`.`wra_id` = `wra_data`.`id`
LEFT JOIN `submissions` on `submissions`.`dwellings_id` = `dwellings`.`id`

GROUP BY `regions`.`id`
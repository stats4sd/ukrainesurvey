# dwellings Level 

SELECT 
    `buildings`.`cluster_id` AS `cluster_id`,
    SUM(`dwellings`.`data_collected`) AS `dwellings_visited`,
    (8 - sum(`dwellings`.`survey_success`)) AS `interviews_attempted`,
    SUM(CASE WHEN `dwellings`.`replacement_order_number` > 0 THEN 1 ELSE 0 END) AS `replacements_number`,
    `household_data_per_cluster`.`completed_interviews`,
    `household_data_per_cluster`.`unsuccessful_interviews`,
    `household_data_per_cluster`.`interviews_not_completed`,
    `household_data_per_cluster`.`interviews_completed_successful`,
    `urine_samples_per_cluster`.`tot_1st_urine_samples_collected`,
    `urine_samples_per_cluster`.`tot_2st_urine_samples_collected`,
    `salt_samples_per_cluster`.`tot_salt_samples`

  FROM `dwellings`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`
    JOIN (
        SELECT 
            `buildings`.`cluster_id` AS `cluster_id`,
            SUM(CASE WHEN `household_data`.`interview_status`='success' THEN 1 ELSE 0 END) AS `completed_interviews`,
            SUM(CASE WHEN `household_data`.`interview_status`='noanswer' OR `household_data`.`interview_status`='nowra' OR `household_data`.`interview_status`='refused'  
              THEN 1 ELSE 0 END) AS `unsuccessful_interviews`,
            SUM(CASE WHEN `household_data`.`interview_status`!='success' THEN 1 ELSE 0 END) AS `interviews_not_completed`,
            SUM(CASE WHEN `household_data`.`interview_status`='success' THEN 1 ELSE 0 END) AS `interviews_completed_successful`
        FROM `household_data`
        LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
        LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`


        GROUP BY `buildings`.`cluster_id`

      ) `household_data_per_cluster` on `household_data_per_cluster`.`cluster_id` = `buildings`.`cluster_id`

    JOIN (
        
          SELECT
                SUM(CASE WHEN `urine_samples`.`wra_id`= 1 THEN 1 ELSE 0 END) AS `tot_1st_urine_samples_collected`,
                SUM(CASE WHEN `urine_samples`.`wra_id`= 2 THEN 1 ELSE 0 END) AS `tot_2st_urine_samples_collected`,
                `buildings`.`cluster_id` AS `cluster_id`
                  
                 
              FROM `urine_samples`
              LEFT JOIN `wra_data` on `wra_data`.`id` = `urine_samples`.`wra_id`
              LEFT JOIN `household_data` on `household_data`.`id` = `wra_data`.`hh_id`
              LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
              LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`

              GROUP BY `buildings`.`cluster_id`

      ) `urine_samples_per_cluster` on `urine_samples_per_cluster`.`cluster_id` = `buildings`.`cluster_id`


    JOIN (

          SELECT
                  count(`salt_samples`.`hh_id`) AS `tot_salt_samples`,
                  `buildings`.`cluster_id` AS `cluster_id`                 
                 
              FROM `salt_samples`
              LEFT JOIN `household_data` on `household_data`.`id` = `salt_samples`.`hh_id`
              LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
              LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`

              GROUP BY `buildings`.`cluster_id`

      ) `salt_samples_per_cluster` on `salt_samples_per_cluster`.`cluster_id` = `buildings`.`cluster_id`
 
    GROUP BY `buildings`.`cluster_id`





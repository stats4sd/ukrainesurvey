SELECT 
    `clusters`.`region_id` AS `region_id`,
    `buildings`.`cluster_id` AS `cluster_id`,
     COUNT(`dwellings`.`id`) AS `dwellings_listed`,
     COUNT( DISTINCT `buildings`.`id`) AS `buildings_listed`,
    SUM(CASE WHEN `dwellings`.`replacement_order_number` > 0 THEN 1 ELSE 0 END) AS `replacements_number`,
    SUM(`household_data_per_dwelling`.`completed_interviews`) as completed_interviews,
    SUM(`household_data_per_dwelling`.`unsuccessful_interviews`) as unsuccessful_interviews,
    SUM(CASE WHEN `urine_per_dwelling`.`count_urine` > 0 THEN 1 ELSE 0 END) as `tot_1st_urine_samples_collected`,
    SUM(CASE WHEN `urine_per_dwelling`.`count_urine` > 1 THEN 1 ELSE 0 END) as `tot_2nd_urine_samples_collected`,
    SUM(`household_data_per_dwelling`.`tot_salt_samples`) as `tot_salt_samples`

  FROM `dwellings`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`
    LEFT JOIN `clusters` on `clusters`.`id` = `buildings`.`cluster_id`
    LEFT JOIN (
        SELECT 
            `household_data`.`dwelling_id` AS `dwelling_id`,
            
            count(`salt_samples`.`hh_id`) AS `tot_salt_samples`,
            CASE WHEN `household_data`.`interview_status`='success' THEN 1 ELSE 0 END AS `completed_interviews`,
            CASE WHEN `household_data`.`interview_status`='noanswer' OR `household_data`.`interview_status`='nowra' OR `household_data`.`interview_status`='refused'  
              THEN 1 ELSE 0 END AS `unsuccessful_interviews`
        FROM `household_data`
        LEFT JOIN `salt_samples` on salt_samples.hh_id = household_data.id
        LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
        GROUP BY household_data.id

      ) `household_data_per_dwelling` on `household_data_per_dwelling`.`dwelling_id` = `dwellings`.`id`

    LEFT JOIN (
        
          SELECT
         
                count(`urine_samples`.`id`) AS `count_urine`, 
                `household_data`.`dwelling_id` AS `dwelling_id`
                  
                 
              FROM `urine_samples`
              LEFT JOIN `wra_data` on `wra_data`.`id` = `urine_samples`.`wra_id`
              LEFT JOIN `household_data` on `household_data`.`id` = `wra_data`.`hh_id`

              GROUP BY `household_data`.`dwelling_id`

      ) `urine_per_dwelling` on `urine_per_dwelling`.`dwelling_id` = `dwellings`.`id`


   
   
 
    GROUP BY `buildings`.`cluster_id`





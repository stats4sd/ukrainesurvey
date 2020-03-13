 

SELECT 
       `clusters`.`smd_id` AS `district_id`,
       `clusters`.`region_id` as `region_id`,
      SUM(`cluster_summary`.`dwellings_listed`) AS `dwellings_listed`,
      SUM(`cluster_summary`.`buildings_listed`) AS `buildings_listed`,
      SUM(`cluster_summary`.`replacements_number`) AS `replacements_number`,
      SUM(`cluster_summary`.`completed_interviews`) AS `completed_interviews`,
      SUM(`cluster_summary`.`unsuccessful_interviews`) AS `unsuccessful_interviews`,
      SUM(`cluster_summary`.`tot_1st_urine_samples_collected`) AS `tot_1st_urine_samples_collected`,
      SUM(`cluster_summary`.`tot_2nd_urine_samples_collected`) AS `tot_2nd_urine_samples_collected`,
      SUM(`cluster_summary`.`tot_salt_samples`) AS `tot_salt_samples` 


FROM `cluster_summary`
LEFT JOIN `clusters` on `clusters`.`id` = `cluster_summary`.`cluster_id`


GROUP BY   `clusters`.`smd_id`





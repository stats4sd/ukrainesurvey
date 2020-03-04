 

SELECT 
       `clusters`.`smd_id` AS `district_id`,
       `cluster_summary`.`cluster_id`,
       `cluster_summary`.`dwellings_listed`,
       `cluster_summary`.`buildings_listed`,
       `cluster_summary`.`interviews_attempted`,
       `cluster_summary`.`dwellings_visited`,
       `cluster_summary`.`replacements_number`,
       `cluster_summary`.`completed_interviews`,
       `cluster_summary`.`unsuccessful_interviews`,
       `cluster_summary`.`interviews_not_completed`,
       `cluster_summary`.`interviews_completed_successful`,
       `cluster_summary`.`tot_1st_urine_samples_collected`,
       `cluster_summary`.`tot_2nd_urine_samples_collected`,
       `cluster_summary`.`tot_salt_samples`


FROM `cluster_summary`
LEFT JOIN `clusters` on `clusters`.`id` = `cluster_summary`.`cluster_id`


GROUP BY   `clusters`.`smd_id`





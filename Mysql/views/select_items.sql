#salt_sampled Level
#total number of salt samples collected 

SELECT

        count(`salt_samples`.`hh_id`) AS `tot_salt_samples`,
        `buildings`.`cluster_id` AS `cluster_id`
        
       
    FROM `salt_samples`
    LEFT JOIN `household_data` on `household_data`.`id` = `salt_samples`.`hh_id`
    LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`

    GROUP BY `buildings`.`cluster_id`

# urine_samples Level
#total number of 1st urine samples collected 

SELECT
    	SUM(CASE WHEN `urine_samples`.`wra_id`= 1 THEN 1 ELSE 0 END) AS `tot_1st_urine_samples_collected`,
        `buildings`.`cluster_id` AS `cluster_id`
        
       
    FROM `urine_samples`
    LEFT JOIN `wra_data` on `wra_data`.`id` = `urine_samples`.`wra_id`
    LEFT JOIN `household_data` on `household_data`.`id` = `wra_data`.`hh_id`
    LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`

    GROUP BY `buildings`.`cluster_id`


#total number of 2st urine samples collected 

SELECT
    	SUM(CASE WHEN `urine_samples`.`wra_id`= 2 THEN 1 ELSE 0 END) AS `tot_2st_urine_samples_collected`,
        `buildings`.`cluster_id` AS `cluster_id`
        
       
    FROM `urine_samples`
    LEFT JOIN `wra_data` on `wra_data`.`id` = `urine_samples`.`wra_id`
    LEFT JOIN `household_data` on `household_data`.`id` = `wra_data`.`hh_id`
    LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`

    GROUP BY `buildings`.`cluster_id`

# dwellings Level 
#number of completed interviews
SELECT 
		SUM(CASE WHEN `household_data`.`interview_status`='success' THEN 1 ELSE 0 END) AS `completed_interviews`,
		`buildings`.`cluster_id` AS `cluster_id`

	FROM `household_data`
	LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`



    GROUP BY `buildings`.`cluster_id`

#dwelligns visited uploaded to date

SELECT 
		SUM(`dwellings`.`data_collected`) AS `dwellings_visited`,
		`buildings`.`cluster_id` AS `cluster_id`

	FROM `dwellings`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`


    GROUP BY `buildings`.`cluster_id`

#Total number of interviews attempted 

SELECT 
		(8 - sum(`dwellings`.`survey_success`)) AS `interviews_attempted`,
		`buildings`.`cluster_id` AS `cluster_id`

	FROM `dwellings`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`


    GROUP BY `buildings`.`cluster_id`

    

#Number of replacements
SELECT 
		SUM(CASE WHEN `dwellings`.`replacement_order_number` > 0 THEN 1 ELSE 0 END) AS `replacements_number`,
		`buildings`.`cluster_id` AS `cluster_id`

	FROM `dwellings`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`


    GROUP BY `buildings`.`cluster_id`


#household_data Level
#Number of unsuccessful interviews
SELECT 
		SUM(CASE WHEN `household_data`.`interview_status`='noanswer' OR `household_data`.`interview_status`='nowra' OR `household_data`.`interview_status`='refused'  
			THEN 1 ELSE 0 END) AS `unsuccessful_interviews`,
		`buildings`.`cluster_id` AS `cluster_id`

	FROM `household_data`
	LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`


    GROUP BY `buildings`.`cluster_id`


#Total number of interviews not completed

SELECT 
		SUM(CASE WHEN `household_data`.`interview_status`='incompleted' THEN 1 ELSE 0 END) AS `interviews_not_completed`,
		`buildings`.`cluster_id` AS `cluster_id`

	FROM `household_data`
	LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`


    GROUP BY `buildings`.`cluster_id`

#Total number of completed (and successful) interviews
SELECT 
		SUM(CASE WHEN `household_data`.`interview_status`='success' THEN 1 ELSE 0 END) AS `interviews_completed_successful`,
		`buildings`.`cluster_id` AS `cluster_id`

	FROM `household_data`
	LEFT JOIN `dwellings` on `dwellings`.`id` = `household_data`.`dwelling_id`
    LEFT JOIN `buildings` on `buildings`.`id` = `dwellings`.`building_id`


    GROUP BY `buildings`.`cluster_id`

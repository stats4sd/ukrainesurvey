SELECT
	`buildings`.`id` AS `id`,
	`buildings`.`cluster_id` AS `cluster_id`,
	`buildings`.`longitude` AS `longitude`,
	`buildings`.`latitude` AS `latitude`,
	`buildings`.`altitude` AS `altitude`,
	`buildings`.`precision` AS `precision`,
	`buildings`.`structure_number` AS `structure_number`,
	`buildings`.`num_dwellings` AS `num_dwellings`,
	sum(`dwellings`.`sampled`) AS `num_sampled`,
	sum(`dwellings`.`data_collected`) AS `num_collected`,
	sum(`dwellings`.`survey_success`) AS `num_success`,
	if((sum(`dwellings`.`data_collected`) > 0), if((sum(`dwellings`.`survey_success`) = sum(`dwellings`.`sampled`)), 'green', if((sum(`dwellings`.`data_collected`) = sum(`dwellings`.`sampled`)), 'orange', 'blue')), if((sum(`dwellings`.`sampled`) > 0), 'blue', 'grey')) AS `status_colour`,
		if((sum(`dwellings`.`data_collected`) > 0), if((sum(`dwellings`.`survey_success`) = sum(`dwellings`.`sampled`)), 'All sampled dwellings successful', if((sum(`dwellings`.`data_collected`) = sum(`dwellings`.`sampled`)), 'All dwellings visited - replacement(s) needed', 'Visit(s) still needed')), if((sum(`dwellings`.`sampled`) > 0), 'Visit(s) still needed', '')) AS `status_text`,
			`buildings`.`address` AS `address`
		FROM (`dwellings`
	LEFT JOIN `buildings` ON ((`buildings`.`id` = `dwellings`.`building_id`)))
GROUP BY
	`buildings`.`id`
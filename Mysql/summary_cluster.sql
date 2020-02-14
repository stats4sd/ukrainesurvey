select `ukraine`.`clusters`.`id` AS `id`,`ukraine`.`clusters`.
		`region_id` AS `region_id`,
		`ukraine`.`clusters`.`sample_id` AS `sample_id`, 
		`ukraine`.`clusters`.`sample_taken` AS `sample_taken`, 
		`ukraine`.`clusters`.`smd_id` AS `smd_id`,
		`buildings_per_cluster`.`tot` AS `tot_buildings`,

		sum(`dwellings_per_building`.`tot`) AS `tot_dwellings`, if((sum(`dwellings_per_building`.`tot_collected`) = 8),1,0) AS `cluster_completed` 
from (((`ukraine`.`clusters` 
		

group by `ukraine`.`clusters`.`id`
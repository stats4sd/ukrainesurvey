-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.18 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for ukraine
CREATE DATABASE IF NOT EXISTS `ukraine` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `ukraine`;

-- Dumping structure for table ukraine.buildings
CREATE TABLE IF NOT EXISTS `buildings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cluster_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `structure_number` int(11) NOT NULL COMMENT "from building listing form",
  `num_dwellings` int(11) NOT NULL DEFAULT '0',
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `altitude` decimal(6,3) DEFAULT NULL,
  `precision` decimal(6,2) DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci COMMENT "from building listing form",
  PRIMARY KEY (`id`),
  KEY `link_clusters_buildings` (`cluster_id`),
  CONSTRAINT `link_clusters_buildings` FOREIGN KEY (`cluster_id`) REFERENCES `clusters` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table ukraine.clusters
CREATE TABLE IF NOT EXISTS `clusters` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'electoral_id',
  `region_id` int(11) DEFAULT NULL,
  `sample_id` int(11) DEFAULT NULL COMMENT 'from sample frame doc',
  `boundaries_en` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `boundaries_uk` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cluster_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT "urban or rural",
  `locality_type` int(11) DEFAULT NULL COMMENT "from sample frame doc",
  `num_voters` int(11) DEFAULT NULL COMMENT "from sample frame doc",
  `smd_id` int(11) DEFAULT NULL COMMENT "Single Mandate District ID - from sample frame doc and electoral register data",
  `sample_taken` tinyint(1) NOT NULL DEFAULT 0 COMMENT "Has a sample of dwellings been taken for this cluster?",
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id` (`sample_id`),
  KEY `link_regions_clusters` (`region_id`),
  CONSTRAINT `link_regions_clusters` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table ukraine.dwellings
CREATE TABLE IF NOT EXISTS `dwellings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `building_id` int(11) DEFAULT NULL,
  `dwelling_number` int(11) DEFAULT NULL COMMENT "Auto Increment per building",
  `sampled` int(1) DEFAULT '0' COMMENT "Is the dwelling part of the sample frame",
  `replacement_order_number` int(11) DEFAULT NULL COMMENT "Order the dwellings should be selected if replacements are needed",
  `data_collected` int(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `link_buildings_dwellings` (`building_id`),
  CONSTRAINT `link_buildings_dwellings` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table ukraine.forms
CREATE TABLE IF NOT EXISTS `forms` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `xform_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'For xlsform string',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Dumping structure for table ukraine.regions
CREATE TABLE IF NOT EXISTS `regions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sector` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_uk` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `zoom` int(11) DEFAULT NULL COMMENT "for zooming to region in Leaflet",
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table ukraine.submissions
-- Raw data storage for ODK submissions
CREATE TABLE IF NOT EXISTS `submissions` (
  `id` bigint(20) NOT NULL COMMENT '_id from kobotools',
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `form_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dwellings_id` bigint(20) NOT NULL,
  `version` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start` timestamp NOT NULL,
  `end` timestamp NOT NULL,
  `today` date NOT NULL,
  `submission_time` timestamp NOT NULL,
  `submitted_by` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `submission` json NOT NULL,
  PRIMARY KEY (`id`),
  KEY `link_forms_submissions` (`form_id`),
  CONSTRAINT `link_forms_submissions` FOREIGN KEY (`form_id`) REFERENCES `forms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table ukraine.household_data
-- This table will grow to include the household-level data coming from the main survey
CREATE TABLE IF NOT EXISTS `household_data` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dwelling_id` bigint(20) NOT NULL,
  `submission_id` bigint(20) NOT NULL,
  `interview_status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT "as per suvey 'outcome of the visit'",
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `dwelling_id` (`dwelling_id`),
  KEY `submission_id` (`submission_id`),
  CONSTRAINT `household_data_ibfk_1` FOREIGN KEY (`dwelling_id`) REFERENCES `dwellings` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `household_data_ibfk_2` FOREIGN KEY (`submission_id`) REFERENCES `submissions` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table ukraine.salt_samples
-- This table will grow to include relevant data on salt samples (e.g. possibly analysis results?!)
CREATE TABLE IF NOT EXISTS  `salt_samples` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `hh_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `hh_id` (`hh_id`),
  CONSTRAINT `salt_samples_ibfk_1` FOREIGN KEY (`hh_id`) REFERENCES `household_data` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table ukraine.wra_data
-- This table will grow to include wra-level data from the main survey
CREATE TABLE IF NOT EXISTS  `wra_data` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `hh_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `hh_id` (`hh_id`),
  CONSTRAINT `wra_data_ibfk_1` FOREIGN KEY (`hh_id`) REFERENCES `household_data` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table ukraine.urine_samples
-- This table will grow to include relevant data on urine samples (e.g. possibly analysis results?!)
CREATE TABLE IF NOT EXISTS `urine_samples` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `wra_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `wra_id` (`wra_id`),
  CONSTRAINT `urine_samples_ibfk_1` FOREIGN KEY (`wra_id`) REFERENCES `wra_data` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.13 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for ukraine
-- DROP DATABASE `ukraine_test`;
CREATE DATABASE IF NOT EXISTS `ukraine_test` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;
USE `ukraine_test`;

# Setup location levels
# Regions
# - name;
# Districts
# - number (SMD)
# Clusters
# - unique_id
# - electoral_id
# - urban/rural
# - description of boundaries
# - num_voters

CREATE TABLE IF NOT EXISTS `regions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sector` varchar(10) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `name_uk` varchar(255) NOT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `clusters` (
  `id` varchar(255) NOT NULL COMMENT 'electoral_id',
  `region_id` int(11) DEFAULT NULL,
  `sample_id` int(11) DEFAULT NULL COMMENT 'from sample frame doc',
  `boundaries_en` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `boundaries_uk` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `shape` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cluster_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_id` (`sample_id`),
  KEY `link_regions_clusters` (`region_id`),
  CONSTRAINT `link_regions_clusters` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table ukraine.buildings
CREATE TABLE IF NOT EXISTS `buildings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cluster_id` varchar(255) NOT NULL,
  `structure_number` int(11) NOT NULL,
  `num_dwellings` int(11) NOT NULL DEFAULT 0,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `altitude` decimal(6,3) DEFAULT NULL,
  `precision` decimal(6,2) DEFAULT NULL,
  `address` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `link_clusters_buildings` (`cluster_id`),
  CONSTRAINT `link_clusters_buildings` FOREIGN KEY (`cluster_id`) REFERENCES `clusters` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Dumping structure for table ukraine.dwellings
CREATE TABLE IF NOT EXISTS `dwellings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `building_id` int(11) DEFAULT NULL,
  `dwelling_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `link_buildings_dwellings` (`building_id`),
  CONSTRAINT `link_buildings_dwellings` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `submissions` (
  `id` int(11) NOT NULL COMMENT '_id from kobotools',
  `uuid` varchar(255) NOT NULL,
  `form_id` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `start` timestamp NOT NULL,
  `end` timestamp NOT NULL,
  `today` date NOT NULL,
  `submission_time` timestamp NOT NULL,
  `submitted_by` varchar(255) NOT NULL,
  `submission` json NOT NULL,
  PRIMARY KEY (`id`),
  KEY `link_forms_submissions` (`form_id`),
  CONSTRAINT `link_forms_submissions` FOREIGN KEY (`form_id`) REFERENCES `forms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `forms` (
  `id` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `xform_id` varchar(255) NOT NULL COMMENT 'For xlsform string',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

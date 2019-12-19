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
CREATE DATABASE IF NOT EXISTS `ukraine` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;
USE `ukraine`;

-- Dumping structure for table ukraine.buildings
CREATE TABLE IF NOT EXISTS `buildings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `clusters_id` int(11) DEFAULT NULL,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `today` date DEFAULT NULL,
  `structure_number` int(11) DEFAULT NULL,
  `_building_gps_latitude` decimal(10,0) DEFAULT NULL,
  `_building_gps_longitude` decimal(10,0) DEFAULT NULL,
  `_building_gps_altitude` decimal(10,0) DEFAULT NULL,
  `_building_gps_precision` decimal(10,0) DEFAULT NULL,
  `building_address` varchar(200) DEFAULT NULL,
  `kobo_uuid` varchar(100) DEFAULT NULL,
  `_submission_time` datetime DEFAULT NULL,
  `_validation_status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `kobo_uuid` (`kobo_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table ukraine.buildings: ~0 rows (approximately)
/*!40000 ALTER TABLE `buildings` DISABLE KEYS */;
/*!40000 ALTER TABLE `buildings` ENABLE KEYS */;

-- Dumping structure for table ukraine.clusters
CREATE TABLE IF NOT EXISTS `clusters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `station_number` int(11) DEFAULT NULL,
  `cluster_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `today` date DEFAULT NULL,
  `shape` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `cluster_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `kobo_uuid` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `_submission_time` datetime DEFAULT NULL,
  `_validation_status` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `kobo_uuid` (`kobo_uuid`),
  KEY `link_district_clusters` (`district_id`),
  CONSTRAINT `link_district_clusters` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table ukraine.clusters: ~4 rows (approximately)
/*!40000 ALTER TABLE `clusters` DISABLE KEYS */;
INSERT INTO `clusters` (`id`, `start`, `end`, `district_id`, `station_number`, `cluster_description`, `today`, `shape`, `cluster_name`, `kobo_uuid`, `_submission_time`, `_validation_status`) VALUES
	(1, NULL, NULL, 1, 531188, 'м.Полтава – вул.Анатолія Кукоби: 1А–1Б, 5–7, 11–13, 15–15/1, 17/2, 27–47; вул.Інститутський проріз: 34, 36, 36А, 36Б, 40, 42, 44, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 70А, 72, 72Б, 74, 76; вул.Картинна, вул.Мазурівська, вул.Небесної Сотні: 45, 45А, 47, 49, 51, 53, 55, 55А, 56, 57/1, 57/1Б, 58, 59/2, 62, 66, 70, 74; вул.Художня, пров.Ломаний: 1А–11А; пров.Мазурівський, пров.Родини Іваненків, пров.ХТЗ, просп.Першотравневий: 26;', '2019-12-16', NULL, NULL, NULL, NULL, NULL),
	(2, NULL, NULL, 1, 531189, 'м.Полтава – вул.Анатолія Кукоби: 4, 8, 14–14А, 16, 18–26; вул.Вузька, вул.Небесної Сотні: 61, 65, 67, 68, 76, 78, 78Б, 86, 86А, 88, 90, 92, 96, 98, 100; пров.Кооперативний, пров.Петра Ротача: 3А–9, 10;	', NULL, 'HJAS SDCSNJ', NULL, NULL, NULL, NULL);
/*!40000 ALTER TABLE `clusters` ENABLE KEYS */;

-- Dumping structure for table ukraine.districts
CREATE TABLE IF NOT EXISTS `districts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description_district_boundaries` text,
  `Oblast` text,
  `smd` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table ukraine.districts: ~0 rows (approximately)
/*!40000 ALTER TABLE `districts` DISABLE KEYS */;
INSERT INTO `districts` (`id`, `description_district_boundaries`, `Oblast`, `smd`) VALUES
	(1, 'Подільський, Шевченківський райони міста Полтави', 'Poltava Oblast ', 144),
	(2, 'Київський район міста Полтави, Котелевський, Полтавський райони', 'Poltava Oblast ', 145),
	(3, 'частина Автозаводського району (виборчі дільниці № 531040 – 531085, 531099, 531100), Крюківський район міста Кременчука', 'Poltava Oblast ', 146),
	(4, 'місто Миргород, Диканський, Зіньківський, Миргородський, Решетилівський, Шишацький райони', 'Poltava Oblast ', 147),
	(5, 'місто Лубни, Великобагачанський, Оржицький, Семенівський, Хорольський райони, частина Лубенського району (виборчі дільниці № 530474 – 530487, 530489 – 530494, 530504 – 530506, 530522 – 530531)', 'Poltava Oblast ', 148),
	(6, 'Карлівський, Кобеляцький, Козельщинський, Машівський, Новосанжарський, Чутівський райони', 'Poltava Oblast ', 149),
	(7, 'місто Горішні Плавні, частина Автозаводського району міста Кременчук (виборчі дільниці № 531086 – 531098), Глобинський, Кременчуцький райони', 'Poltava Oblast ', 150),
	(8, 'місто Гадяч, Гадяцький, Гребінківський, Лохвицький, Пирятинський, Чорнухинський райони, частина Лубенського району (виборчі дільниці № 530495 – 530503, 530507 – 530518, 530520, 530521)', 'Poltava Oblast ', 151);
/*!40000 ALTER TABLE `districts` ENABLE KEYS */;

-- Dumping structure for table ukraine.dwellings
CREATE TABLE IF NOT EXISTS `dwellings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buildings_id` int(11) DEFAULT NULL,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `today` date DEFAULT NULL,
  `dwellings_number` int(11) DEFAULT NULL,
  `kobo_uuid` varchar(100) DEFAULT NULL,
  `_submission_time` datetime DEFAULT NULL,
  `_validation_status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `kobo_uuid` (`kobo_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table ukraine.dwellings: ~0 rows (approximately)
/*!40000 ALTER TABLE `dwellings` DISABLE KEYS */;
/*!40000 ALTER TABLE `dwellings` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

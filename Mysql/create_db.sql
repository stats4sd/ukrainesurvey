
CREATE DATABASE IF NOT EXISTS ukraine;
USE ukraine;

CREATE TABLE IF NOT EXISTS clusters (
	id INT NOT NULL AUTO_INCREMENT,
	start DATETIME, 
	end DATETIME, 
	today DATE, 
	shape LINESTRING,
	cluster_name VARCHAR(100),
	kobo_uuid VARCHAR(100),
	_submission_time DATETIME,
	_validation_status VARCHAR(100),
	PRIMARY KEY (id),
	UNIQUE (kobo_uuid)
	);

CREATE TABLE IF NOT EXISTS buildings (
	id INT NOT NULL AUTO_INCREMENT,
	clusters_id INT,
	start DATETIME, 
	end DATETIME, 
	today DATE, 
	structure_number INT, 
	_building_gps_latitude DECIMAL,
	_building_gps_longitude DECIMAL,
	_building_gps_altitude DECIMAL,
	_building_gps_precision DECIMAL,
	building_address VARCHAR(200),
	kobo_uuid VARCHAR(100),
	_submission_time DATETIME,
	_validation_status VARCHAR(100),
	PRIMARY KEY (id),
	UNIQUE (kobo_uuid)
	);

CREATE TABLE IF NOT EXISTS dwellings (
	id INT NOT NULL AUTO_INCREMENT,
	buildings_id INT,
	start DATETIME, 
	end DATETIME, 
	today DATE, 
	dwellings_number INT,
	kobo_uuid VARCHAR(100),
	_submission_time DATETIME,
	_validation_status VARCHAR(100),
	PRIMARY KEY (id),
	UNIQUE (kobo_uuid)
	);
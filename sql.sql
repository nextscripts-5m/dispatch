CREATE TABLE IF NOT EXISTS `nx_dispatch` (
	`id` INT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(50) DEFAULT NULL,
	`job_name` VARCHAR(255) DEFAULT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
	`sender` VARCHAR(255) DEFAULT NULL,
	`count` INT DEFAULT 0,
	PRIMARY KEY (`id`)
) ENGINE=INNODB;
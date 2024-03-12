CREATE TABLE IF NOT EXISTS `crafting_system` (
  `id` int(11) unsigned NOT NULL,
  `job` varchar(50) DEFAULT NULL,
  `item` varchar(50) DEFAULT NULL,
  `countitem` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

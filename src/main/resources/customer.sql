DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `is_star` tinyint(1) NOT NULL,
  `fullname` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `firstname` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `lastname` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `floor1` double DEFAULT NULL,
  `floor2` double DEFAULT NULL,
  `floor3` double DEFAULT NULL,
  `floor4` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `customer` (`id`, `is_star`, `fullname`, `firstname`, `lastname`, `city`, `state`, `floor1`, `floor2`, `floor3`, `floor4`) VALUES ('11', '1', 'Erasmus Robinson', 'Sade', 'Morgan', 'Mont', 'Bolivia', '558', '737', '1752', '1569'),
('12', '0', 'Edan S. Cabrera', 'Connor', 'Sanford', 'Bareilly', 'Burundi', '1162', '1860', '1821', '2526'),
('13', '1', 'Anika X. Cantu', 'Samson', 'Christensen', 'Rutten', 'Iceland', '1756', '2282', '272', '3007'),
('14', '1', 'Isaiah F. Cochran', 'Dorian', 'Morton', 'Ladispoli', 'Andorra', '3416', '5148', '1318', '3124'),
('15', '1', 'Ian Barnett', 'Reuben', 'Craft', 'Kessenich', 'Tuvalu', '88', '370', '1885', '3347'),
('16', '1', 'Autumn Camacho', 'Kimberley', 'Olsen', 'Patan', 'Turks and Caicos Islands', '3363', '1139', '1178', '123'),
('17', '0', 'Leroy Q. Griffin', 'Hamilton', 'Williamson', 'Mobile', 'Burundi', '3475', '5220', '934', '3417'),
('18', '0', 'Macy Grant', 'Myles', 'Boyd', 'Purnea', 'Cameroon', '939', '5427', '418', '803'),
('19', '0', 'Ann L. Walters', 'Heidi', 'Lawrence', 'Ede', 'New Caledonia', '2790', '3386', '1679', '1393'),
('20', '0', 'Tara Juarez', 'Lee', 'Barker', 'Borgerhout', 'Indonesia', '1192', '4240', '1437', '1841');

/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
CREATE TABLE `one` (
  `id_one` int(11) NOT NULL,
  PRIMARY KEY (`id_one`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO one (`id_one`) VALUES (1);
CREATE TABLE `two` (
  `id_one` int(11) NOT NULL,
  `id_two` int(11) NOT NULL,
  PRIMARY KEY (`id_one`,`id_two`),
  CONSTRAINT `fk_two_to_one` FOREIGN KEY (`id_one`) REFERENCES `one` (`id_one`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO two (`id_one`, `id_two`) VALUES (1, 1), (1, 2), (1, 3), (1, 4), (1, 5);
CREATE TABLE `five` (
  `id_one` int(11) NOT NULL,
  `id_two` int(11) NOT NULL,
  `id_three` int(11) NOT NULL,
  `id_four` int(11) NOT NULL,
  `id_five` int(11) NOT NULL,
  PRIMARY KEY (`id_one`,`id_two`,`id_three`,`id_four`,`id_five`),
  CONSTRAINT `fk_five_to_four` FOREIGN KEY (`id_one`, `id_two`, `id_three`, `id_four`) REFERENCES `four` (`id_one`, `id_two`, `id_three`, `id_four`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO five (`id_one`, `id_two`, `id_three`, `id_four`, `id_five`) VALUES (1, 1, 1, 1, 1), (1, 1, 1, 1, 2), (1, 1, 1, 1, 3), (1, 1, 1, 1, 4), (1, 1, 1, 1, 5);
CREATE TABLE `multi_ref_five` (
  `id` varchar(10) NOT NULL,
  `a_id_one` int(11) DEFAULT NULL,
  `a_id_two` int(11) DEFAULT NULL,
  `a_id_three` int(11) DEFAULT NULL,
  `a_id_four` int(11) DEFAULT NULL,
  `a_id_five` int(11) DEFAULT NULL,
  `b_id_one` int(11) DEFAULT NULL,
  `b_id_two` int(11) DEFAULT NULL,
  `b_id_three` int(11) DEFAULT NULL,
  `b_id_four` int(11) DEFAULT NULL,
  `b_id_five` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_a_to_five` (`a_id_one`,`a_id_two`,`a_id_three`,`a_id_four`,`a_id_five`),
  KEY `fk_b_to_five` (`b_id_one`,`b_id_two`,`b_id_three`,`b_id_four`,`b_id_five`),
  CONSTRAINT `fk_a_to_five` FOREIGN KEY (`a_id_one`, `a_id_two`, `a_id_three`, `a_id_four`, `a_id_five`) REFERENCES `five` (`id_one`, `id_two`, `id_three`, `id_four`, `id_five`),
  CONSTRAINT `fk_b_to_five` FOREIGN KEY (`b_id_one`, `b_id_two`, `b_id_three`, `b_id_four`, `b_id_five`) REFERENCES `five` (`id_one`, `id_two`, `id_three`, `id_four`, `id_five`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO multi_ref_five (`id`, `a_id_one`, `a_id_two`, `a_id_three`, `a_id_four`, `a_id_five`, `b_id_one`, `b_id_two`, `b_id_three`, `b_id_four`, `b_id_five`) VALUES ('a', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1), ('b', 1, 1, 1, 1, 1, 1, 1, 1, 1, 2), ('c', 1, 1, 1, 1, 1, 1, 1, 1, 1, 3), ('d', 1, 1, 1, 1, 1, 1, 1, 1, 1, 4), ('e', 1, 1, 1, 1, 1, 1, 1, 1, 1, 5), ('k', 1, 1, 1, 1, 2, 1, 1, 1, 1, 1), ('l', 1, 1, 1, 1, 2, 1, 1, 1, 1, 2), ('m', 1, 1, 1, 1, 2, 1, 1, 1, 1, 3), ('n', 1, 1, 1, 1, 2, 1, 1, 1, 1, 4), ('o', 1, 1, 1, 1, 2, 1, 1, 1, 1, 5), ('u', 1, 1, 1, 1, 3, 1, 1, 1, 1, 1), ('v', 1, 1, 1, 1, 3, 1, 1, 1, 1, 2), ('w', 1, 1, 1, 1, 3, 1, 1, 1, 1, 3), ('x', 1, 1, 1, 1, 3, 1, 1, 1, 1, 4), ('y', 1, 1, 1, 1, 3, 1, 1, 1, 1, 5);
CREATE TABLE `three` (
  `id_one` int(11) NOT NULL,
  `id_two` int(11) NOT NULL,
  `id_three` int(11) NOT NULL,
  PRIMARY KEY (`id_one`,`id_two`,`id_three`),
  CONSTRAINT `fk_three_to_two` FOREIGN KEY (`id_one`, `id_two`) REFERENCES `two` (`id_one`, `id_two`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO three (`id_one`, `id_two`, `id_three`) VALUES (1, 1, 1), (1, 1, 2), (1, 1, 3), (1, 1, 4), (1, 1, 5);
CREATE TABLE `four` (
  `id_one` int(11) NOT NULL,
  `id_two` int(11) NOT NULL,
  `id_three` int(11) NOT NULL,
  `id_four` int(11) NOT NULL,
  PRIMARY KEY (`id_one`,`id_two`,`id_three`,`id_four`),
  CONSTRAINT `fk_four_to_three` FOREIGN KEY (`id_one`, `id_two`, `id_three`) REFERENCES `three` (`id_one`, `id_two`, `id_three`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO four (`id_one`, `id_two`, `id_three`, `id_four`) VALUES (1, 1, 1, 1), (1, 1, 1, 2), (1, 1, 1, 3), (1, 1, 1, 4), (1, 1, 1, 5);

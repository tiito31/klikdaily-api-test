-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 22, 2020 at 09:05 AM
-- Server version: 10.4.13-MariaDB
-- PHP Version: 7.3.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `restful_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `location`
--

CREATE TABLE `location` (
  `id` int(11) NOT NULL,
  `name` varchar(10) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `location`
--

INSERT INTO `location` (`id`, `name`, `created_at`, `updated_at`) VALUES
(1, 'A-1-1', '2020-11-21 04:30:52', '2020-11-21 11:30:52'),
(2, 'A-1-2', '2020-11-21 04:30:52', '2020-11-21 11:38:00');

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `qty` int(11) DEFAULT NULL,
  `location_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`id`, `name`, `qty`, `location_id`, `created_at`, `updated_at`) VALUES
(1, 'Indomie Goreng', 100, 1, '2020-11-21 05:33:05', '2020-11-21 09:08:36'),
(2, 'Teh Kotak', 150, 2, '2020-11-21 05:33:05', '2020-11-21 05:33:05'),
(3, 'Indomie Goreng', -10, 1, '2020-11-22 07:48:56', '2020-11-22 07:48:56'),
(4, 'Indomie Goreng', 25, 1, '2020-11-22 07:48:56', '2020-11-22 07:48:56');

--
-- Triggers `product`
--
DELIMITER $$
CREATE TRIGGER `after_product_insert` AFTER INSERT ON `product` FOR EACH ROW BEGIN

DECLARE tipe varchar(17);

IF new.qty < 0 THEN
  SET tipe = "Outbound";
ELSE
  SET tipe = "Inbound";
END IF;

INSERT INTO product_log
	(product_id,
    location_id,
    product_name,
    adjust,
    tipe,
    change_at)
values
	(NEW.id,
     new.location_id,
     new.name, 
     new.qty, 
     tipe, 
     now());

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `product_log`
--

CREATE TABLE `product_log` (
  `id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_name` varchar(25) NOT NULL,
  `adjust` int(11) DEFAULT NULL,
  `change_at` datetime DEFAULT NULL,
  `tipe` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `product_log`
--

INSERT INTO `product_log` (`id`, `location_id`, `product_id`, `product_name`, `adjust`, `change_at`, `tipe`) VALUES
(1, 1, 3, 'Indomie Goreng', -10, '2020-11-22 14:48:56', 'Outbound'),
(2, 1, 4, 'Indomie Goreng', 25, '2020-11-22 14:48:56', 'Inbound');

-- --------------------------------------------------------

--
-- Stand-in structure for view `stock`
-- (See below for the actual view)
--
CREATE TABLE `stock` (
`location_id` int(11)
,`location_name` varchar(10)
,`product_id` int(11)
,`product` varchar(50)
,`stock_quantity` int(11)
,`Adjustment` int(11)
,`Type` varchar(15)
,`quantity` bigint(12)
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Structure for view `stock`
--
DROP TABLE IF EXISTS `stock`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `stock`  AS  select `location`.`id` AS `location_id`,`location`.`name` AS `location_name`,`product`.`id` AS `product_id`,`product`.`name` AS `product`,`product`.`qty` AS `stock_quantity`,`product_log`.`adjust` AS `Adjustment`,`product_log`.`tipe` AS `Type`,`product`.`qty` + `product_log`.`adjust` AS `quantity`,`product`.`updated_at` AS `updated_at` from ((`location` join `product`) join `product_log`) where `location`.`id` = `product`.`location_id` and `location`.`id` = `product_log`.`location_id` and `product`.`name` = `product_log`.`product_name` group by `product_log`.`product_id` order by `location`.`id` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `location`
--
ALTER TABLE `location`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_log`
--
ALTER TABLE `product_log`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `location`
--
ALTER TABLE `location`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `product_log`
--
ALTER TABLE `product_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

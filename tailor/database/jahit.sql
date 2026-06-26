-- MySQL dump 10.13  Distrib 8.0.19, for Win64 (x86_64)
--
-- Host: localhost    Database: tailorlink_db
-- ------------------------------------------------------
-- Server version	8.0.30

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,2,'Pesanan baru #1 (custom)',0,'2026-05-14 18:13:51'),(2,3,'Pesanan #1 diterima',0,'2026-05-14 18:14:42'),(3,3,'Pesanan #1 jadwal fitting',0,'2026-05-14 18:15:14'),(4,3,'Pesanan #1 diproses',0,'2026-05-14 18:15:39'),(5,3,'Pesanan #1 sedang dijahit',0,'2026-05-14 18:16:18');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_history`
--

DROP TABLE IF EXISTS `order_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_at` datetime DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `order_history_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order_queues` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_history`
--

LOCK TABLES `order_history` WRITE;
/*!40000 ALTER TABLE `order_history` DISABLE KEYS */;
INSERT INTO `order_history` VALUES (1,1,'pending','2026-05-14 18:13:51','Pesanan dibuat'),(2,1,'accepted','2026-05-14 18:14:42','Status diubah ke accepted'),(3,1,'fitting','2026-05-14 18:15:14','SELESAI'),(4,1,'diproses','2026-05-14 18:15:39','Status diubah ke diproses'),(5,1,'dijahit','2026-05-14 18:16:18','Status diubah ke dijahit');
/*!40000 ALTER TABLE `order_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_queues`
--

DROP TABLE IF EXISTS `order_queues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_queues` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `tailor_id` int NOT NULL,
  `type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `complexity` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `design_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `design_notes` text COLLATE utf8mb4_unicode_ci,
  `estimated_done` datetime DEFAULT NULL,
  `fitting_date` datetime DEFAULT NULL,
  `queue_number` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `tailor_id` (`tailor_id`),
  CONSTRAINT `order_queues_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `order_queues_ibfk_2` FOREIGN KEY (`tailor_id`) REFERENCES `tailors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_queues`
--

LOCK TABLES `order_queues` WRITE;
/*!40000 ALTER TABLE `order_queues` DISABLE KEYS */;
INSERT INTO `order_queues` VALUES (1,3,1,'custom','sederhana','dijahit','f6272bbe6d504446b8b046282115968d.webp','ukuran XL : 1\nukuran L : 2','2026-05-17 18:13:51','2026-05-19 00:00:00',1,'2026-05-14 18:13:51');
/*!40000 ALTER TABLE `order_queues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tailor_availability`
--

DROP TABLE IF EXISTS `tailor_availability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tailor_availability` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tailor_id` int NOT NULL,
  `type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_open` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tailor_id` (`tailor_id`),
  CONSTRAINT `tailor_availability_ibfk_1` FOREIGN KEY (`tailor_id`) REFERENCES `tailors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tailor_availability`
--

LOCK TABLES `tailor_availability` WRITE;
/*!40000 ALTER TABLE `tailor_availability` DISABLE KEYS */;
INSERT INTO `tailor_availability` VALUES (1,1,'permak',1),(2,1,'custom',1),(3,1,'seragam',1);
/*!40000 ALTER TABLE `tailor_availability` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tailors`
--

DROP TABLE IF EXISTS `tailors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tailors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `shop_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rating` float DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `shop_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT NULL,
  `is_suspended` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `tailors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tailors`
--

LOCK TABLES `tailors` WRITE;
/*!40000 ALTER TABLE `tailors` DISABLE KEYS */;
INSERT INTO `tailors` VALUES (1,2,'Jahit Berkah','Ds Pendawa','087710341232',0,'open','None',NULL,0,0,'2026-05-14 17:00:23');
/*!40000 ALTER TABLE `tailors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active_user` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Administrator','admin@tailorlink.com','admin','scrypt:32768:8:1$NPqvceIH5MWurvnU$e6a3cfb7ca7f203f4d942543c662cc7c19f67ff0a61e8f61e87d75da2debdd585d234b9e36b72528ff08be7331e32c49a853a948db3524b23b2317a4c95600e0','08123456789','admin',NULL,1,'2026-05-14 16:42:55'),(2,'Salsa','Salsa@gmail.com','Santi','scrypt:32768:8:1$AhdTup0ic6QasoZM$603a75aaf99cf87b3623e753b49345d98e68abcd9f2da8383c4f34c655ab3263f9d3c9870a72bf0bbe0bf996580846e919ef88e5c756f7616964311f55204792','087710341232','owner',NULL,1,'2026-05-14 17:00:23'),(3,'salsa','salsa1@gmail.com','salsa','scrypt:32768:8:1$WOfzt6e3s4hOH7TT$8db0bd3958caec46cba7cc864bc752523c5ba4e575a80c706068f0401cf1c8ca37c6db60b439b0106c10f83cff8c9a7b9da1b63aa70b9d49217646bd2a9add9e','087710341232','customer',NULL,1,'2026-05-14 17:55:45');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'tailorlink_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-15 17:43:07

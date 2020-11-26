-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Hôte : mysql
-- Généré le : jeu. 26 nov. 2020 à 11:15
-- Version du serveur :  10.1.48-MariaDB-1~bionic
-- Version de PHP : 7.4.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `expressfood`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`%` PROCEDURE `montant_commandes` ()  NO SQL
SELECT 
order_line.order_id id_commande,
ROUND(SUM(order_line.quantity * (order_line.price_excl_tax + (order_line.price_excl_tax * order_line.tax100 / 100))), 2) prix_ttc FROM order_line
GROUP by order_line.order_id$$

CREATE DEFINER=`root`@`%` PROCEDURE `produits_a_livrer` ()  NO SQL
SELECT 
`order`.id id_commande,
order_status.code statut_commande,
order_line.name as produit
from order_line
INNER JOIN `order` on `order`.id = order_line.order_id
INNER JOIN order_status on order_status.id = `order`.`order_status_id`
WHERE order_status.code != "ok"$$

CREATE DEFINER=`root`@`%` PROCEDURE `statut_commandes` ()  NO SQL
SELECT 
order.id, 
client.lastname nom_client,
`order`.address adresse_livraison, 
order_status.code,
`order`.delivery_man_id id_livreur,
livreur.lastname nom_livreur
from `order`
INNER join order_status ON order_status.id = order.order_status_id
INNER JOIN user client on client.id = `order` . client_id
LEFT JOIN user livreur on livreur.id = `order` . delivery_man_id$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `delivery_man_status`
--

CREATE TABLE `delivery_man_status` (
  `id` int(11) NOT NULL,
  `name` varchar(45) COLLATE latin1_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `delivery_man_status`
--

INSERT INTO `delivery_man_status` (`id`, `name`) VALUES
(1, 'off'),
(2, 'on'),
(3, ' shipping');

-- --------------------------------------------------------

--
-- Structure de la table `inventory`
--

CREATE TABLE `inventory` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `inventory`
--

INSERT INTO `inventory` (`id`, `user_id`, `product_id`, `quantity`) VALUES
(1, 1, 1, 3),
(2, 1, 3, 4);

-- --------------------------------------------------------

--
-- Structure de la table `order`
--

CREATE TABLE `order` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `create_datetime` datetime NOT NULL,
  `address` varchar(45) COLLATE latin1_general_ci NOT NULL,
  `zipcode` char(5) COLLATE latin1_general_ci NOT NULL,
  `city` varchar(45) COLLATE latin1_general_ci NOT NULL,
  `order_status_id` int(11) NOT NULL,
  `estimated_delivery_time` int(11) DEFAULT NULL,
  `delivery_time` int(11) DEFAULT NULL,
  `delivery_man_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `order`
--

INSERT INTO `order` (`id`, `client_id`, `create_datetime`, `address`, `zipcode`, `city`, `order_status_id`, `estimated_delivery_time`, `delivery_time`, `delivery_man_id`) VALUES
(1, 3, '2020-10-15 11:30:01', '3 rue du luc', '33185', 'Blanquefort', 6, NULL, NULL, NULL),
(2, 2, '2020-10-15 15:29:16', 'rue du haillan', '33000', 'Bordeaux', 6, NULL, NULL, NULL),
(3, 3, '2020-10-15 15:41:34', 'rue du haillan', '33185', 'Blanquefort', 9, 16, 15, 4);

-- --------------------------------------------------------

--
-- Structure de la table `order_line`
--

CREATE TABLE `order_line` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `name` varchar(45) COLLATE latin1_general_ci DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `price_excl_tax` float DEFAULT NULL,
  `tax100` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `order_line`
--

INSERT INTO `order_line` (`id`, `order_id`, `product_id`, `name`, `quantity`, `price_excl_tax`, `tax100`) VALUES
(1, 1, 1, 'Green curry de légumes & nouilles de riz', 3, 6.9, 5.5),
(2, 1, 3, 'Yaourt artisanal à la vanille', 1, 1.4, 5.5),
(3, 2, 2, 'Légumes sautés & sauce coco-citronnelle', 1, 6.9, 5.5),
(4, 2, 4, 'Riz au lait au caramel au beurre salé', 1, 6.9, 5.5),
(5, 3, 5, 'Barrata, roquette & olives noires', 1, 6, 5.5);

-- --------------------------------------------------------

--
-- Structure de la table `order_status`
--

CREATE TABLE `order_status` (
  `id` int(11) NOT NULL,
  `code` varchar(45) COLLATE latin1_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `order_status`
--

INSERT INTO `order_status` (`id`, `code`) VALUES
(1, 'new'),
(2, 'waiting_user'),
(3, 'waiting_address'),
(4, 'wayting_payment'),
(5, 'payment_ko'),
(6, 'waiting_delivery_man'),
(7, 'delivery_pending'),
(8, 'waiting_delivery_confirmation'),
(9, 'ok');

-- --------------------------------------------------------

--
-- Structure de la table `order_status_history`
--

CREATE TABLE `order_status_history` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `status_datetime` datetime NOT NULL,
  `order_status_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `order_status_history`
--

INSERT INTO `order_status_history` (`id`, `order_id`, `status_datetime`, `order_status_id`) VALUES
(1, 1, '2020-10-15 10:00:47', 1),
(2, 1, '2020-10-15 10:01:47', 2),
(3, 1, '2020-10-15 10:02:33', 3),
(4, 1, '2020-10-15 10:03:11', 4),
(5, 1, '2020-10-15 10:05:30', 6);

-- --------------------------------------------------------

--
-- Structure de la table `picture`
--

CREATE TABLE `picture` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `filepath` varchar(255) COLLATE latin1_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `product`
--

CREATE TABLE `product` (
  `id` int(11) NOT NULL,
  `name` varchar(45) COLLATE latin1_general_ci NOT NULL,
  `product_datetime` date NOT NULL,
  `price_excl_taxe` float NOT NULL,
  `taxe100` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `product`
--

INSERT INTO `product` (`id`, `name`, `product_datetime`, `price_excl_taxe`, `taxe100`) VALUES
(1, 'Green curry de légumes & nouilles de riz', '2020-10-15', 6.9, 5.5),
(2, 'Légumes sautés & sauce coco-citronnelle', '2020-10-15', 7.4, 5.5),
(3, 'Yaourt artisanal à la vanille', '2020-10-15', 1.4, 5.5),
(4, 'Riz au lait au caramel au beurre salé', '2020-10-15', 2.5, 5.5),
(5, 'Burrata, roquette & olives noires', '2020-10-16', 6.9, 5.5),
(6, 'Courgette au pesto rosso', '2020-10-16', 3.5, 5.5),
(7, 'Crème passion-coco', '2020-10-16', 3.1, 5.5),
(8, 'Crème soyeuse au chocolat noir', '2020-10-16', 3.5, 5.5);

-- --------------------------------------------------------

--
-- Structure de la table `role`
--

CREATE TABLE `role` (
  `id` int(11) NOT NULL,
  `name` varchar(45) COLLATE latin1_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `role`
--

INSERT INTO `role` (`id`, `name`) VALUES
(1, 'Client'),
(2, 'Delivery man');

-- --------------------------------------------------------

--
-- Structure de la table `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `firstname` varchar(45) COLLATE latin1_general_ci NOT NULL,
  `lastname` varchar(45) COLLATE latin1_general_ci NOT NULL,
  `password` char(128) COLLATE latin1_general_ci NOT NULL,
  `email` varchar(255) COLLATE latin1_general_ci NOT NULL,
  `delivery_man_status_id` int(11) DEFAULT NULL,
  `current_lat` float(10,6) DEFAULT NULL,
  `current_lng` float(10,6) DEFAULT NULL,
  `current_last_update` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `user`
--

INSERT INTO `user` (`id`, `role_id`, `firstname`, `lastname`, `password`, `email`, `delivery_man_status_id`, `current_lat`, `current_lng`, `current_last_update`) VALUES
(1, 2, 'Benoit', 'Petivélo', 'f71dbe52628a3f83a77ab494817525c6', 'benoit.livreur@gmail.com', 2, NULL, NULL, NULL),
(2, 1, 'Benjamin', 'Client', 'f71dbe52628a3f83a77ab494817525c6', 'benjamin.client@gmail.com', 1, NULL, NULL, NULL),
(3, 1, 'Stéphane', 'Client', 'f71dbe52628a3f83a77ab494817525c6', 'stephane.client@gmail.com', 1, NULL, NULL, NULL),
(4, 2, 'Laurent', 'Grandvélo', 'f71dbe52628a3f83a77ab494817525c6', 'laurent.livreur@gmail.com', 1, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `user_address`
--

CREATE TABLE `user_address` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `address1` varchar(45) COLLATE latin1_general_ci NOT NULL,
  `address2` varchar(45) COLLATE latin1_general_ci DEFAULT NULL,
  `zipcode` int(11) NOT NULL,
  `city` varchar(45) COLLATE latin1_general_ci NOT NULL,
  `default_adrress` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Déchargement des données de la table `user_address`
--

INSERT INTO `user_address` (`id`, `user_id`, `address1`, `address2`, `zipcode`, `city`, `default_adrress`) VALUES
(1, 3, '3 rue du Luc', NULL, 33290, 'Blanquefort', 1),
(2, 3, 'rue des lois', NULL, 33185, 'Le Haillan', 0);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `delivery_man_status`
--
ALTER TABLE `delivery_man_status`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_inventory_user1` (`user_id`),
  ADD KEY `fk_inventory_product1` (`product_id`);

--
-- Index pour la table `order`
--
ALTER TABLE `order`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_order_user1` (`client_id`),
  ADD KEY `fk_order_order_status1` (`order_status_id`),
  ADD KEY `fk_order_user2` (`delivery_man_id`);

--
-- Index pour la table `order_line`
--
ALTER TABLE `order_line`
  ADD PRIMARY KEY (`id`,`order_id`),
  ADD KEY `fk_order_line_order1` (`order_id`),
  ADD KEY `fk_order_line_product1` (`product_id`);

--
-- Index pour la table `order_status`
--
ALTER TABLE `order_status`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `order_status_history`
--
ALTER TABLE `order_status_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_order_status_history_order1` (`order_id`),
  ADD KEY `fk_order_status_history_order_status1` (`order_status_id`);

--
-- Index pour la table `picture`
--
ALTER TABLE `picture`
  ADD PRIMARY KEY (`id`,`product_id`),
  ADD KEY `fk_picture_product1` (`product_id`);

--
-- Index pour la table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `role`
--
ALTER TABLE `role`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_delivery_man_status1` (`delivery_man_status_id`),
  ADD KEY `fk_user_role1` (`role_id`);

--
-- Index pour la table `user_address`
--
ALTER TABLE `user_address`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_address_user1` (`user_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `delivery_man_status`
--
ALTER TABLE `delivery_man_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `order`
--
ALTER TABLE `order`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `order_line`
--
ALTER TABLE `order_line`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `order_status`
--
ALTER TABLE `order_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `order_status_history`
--
ALTER TABLE `order_status_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `picture`
--
ALTER TABLE `picture`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `product`
--
ALTER TABLE `product`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `role`
--
ALTER TABLE `role`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `user_address`
--
ALTER TABLE `user_address`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `fk_inventory_product1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  ADD CONSTRAINT `fk_inventory_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

--
-- Contraintes pour la table `order`
--
ALTER TABLE `order`
  ADD CONSTRAINT `fk_order_order_status1` FOREIGN KEY (`order_status_id`) REFERENCES `order_status` (`id`),
  ADD CONSTRAINT `fk_order_user1` FOREIGN KEY (`client_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `fk_order_user2` FOREIGN KEY (`delivery_man_id`) REFERENCES `user` (`id`);

--
-- Contraintes pour la table `order_line`
--
ALTER TABLE `order_line`
  ADD CONSTRAINT `fk_order_line_order1` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`),
  ADD CONSTRAINT `fk_order_line_product1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`);

--
-- Contraintes pour la table `order_status_history`
--
ALTER TABLE `order_status_history`
  ADD CONSTRAINT `fk_order_status_history_order1` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`),
  ADD CONSTRAINT `fk_order_status_history_order_status1` FOREIGN KEY (`order_status_id`) REFERENCES `order_status` (`id`);

--
-- Contraintes pour la table `picture`
--
ALTER TABLE `picture`
  ADD CONSTRAINT `fk_picture_product1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`);

--
-- Contraintes pour la table `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `fk_user_delivery_man_status1` FOREIGN KEY (`delivery_man_status_id`) REFERENCES `delivery_man_status` (`id`),
  ADD CONSTRAINT `fk_user_role1` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`);

--
-- Contraintes pour la table `user_address`
--
ALTER TABLE `user_address`
  ADD CONSTRAINT `fk_user_address_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

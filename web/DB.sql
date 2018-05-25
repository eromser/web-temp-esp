-- --------------------------------------------------------

--
-- Table structure for table `DataTable`
--

CREATE TABLE IF NOT EXISTS `DataTable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `logdate` datetime NOT NULL,
  `temperature` decimal(5,2) NOT NULL,
  `humidity` decimal(4,2) unsigned NOT NULL,
  `chipid` int(11) NOT NULL,
  `heap` int(11) NOT NULL,
  `loc_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `pin` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;

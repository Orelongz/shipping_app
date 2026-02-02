/* -------------------------------------------------
   Core cargo & finance tables – legacy import
   ------------------------------------------------- */

/* ------------------------  BL  ------------------- */
DROP TABLE IF EXISTS `bl`;
CREATE TABLE `bl` (
  `id_bl`                INT(14)      NOT NULL,
  `id_upload`            INT(14)      DEFAULT NULL,
  `date_upload`          DATETIME     DEFAULT NULL,
  `numero_bl`            CHAR(9)      NOT NULL,
  `id_client`            INT(14)      DEFAULT NULL,
  `consignee_code`       VARCHAR(20)  DEFAULT NULL,
  `consignee_name`       VARCHAR(60)  DEFAULT NULL,
  `notified_code`        VARCHAR(20)  DEFAULT NULL,
  `notified_name`        VARCHAR(60)  DEFAULT NULL,
  `vessel_name`          VARCHAR(30)  DEFAULT NULL,
  `vessel_voyage`        VARCHAR(10)  DEFAULT NULL,
  `arrival_date`         DATETIME     DEFAULT '0000-00-00 00:00:00',
  `freetime`             INT(6)       DEFAULT NULL,
  `nbre_20pieds_sec`     INT(3)       DEFAULT NULL,
  `nbre_40pieds_sec`     INT(3)       DEFAULT NULL,
  `nbre_20pieds_frigo`   INT(3)       DEFAULT NULL,
  `nbre_40pieds_frigo`   INT(3)       DEFAULT NULL,
  `nbre_20pieds_special` INT(3)       DEFAULT NULL,
  `nbre_40pieds_special` INT(3)       DEFAULT NULL,
  `reef`                 CHAR(1)      DEFAULT '',
  `type_depotage`        VARCHAR(30)  DEFAULT NULL,
  `date_validite`        DATETIME     DEFAULT NULL,
  `statut`               VARCHAR(30)  DEFAULT NULL,
  `exempte`              TINYINT(1)   NOT NULL DEFAULT 0,
  `blocked_for_refund`   TINYINT(1)   NOT NULL DEFAULT 0,
  `reference`            VARCHAR(60)  DEFAULT NULL,
  `comment`              TEXT         DEFAULT NULL,
  `valide`               TINYINT(1)   DEFAULT NULL,
  `released_statut`      VARCHAR(20)  DEFAULT NULL,
  `released_comment`     TEXT         DEFAULT NULL,
  `operator`             VARCHAR(20)  DEFAULT NULL,
  `atp`                  VARCHAR(30)  DEFAULT NULL,
  `consignee_caution`    TINYINT(1)   NOT NULL DEFAULT 0,
  `service_contract`     VARCHAR(200) DEFAULT NULL,
  `bank_account`         VARCHAR(30)  DEFAULT NULL,
  `bank_name`            VARCHAR(30)  DEFAULT NULL,
  `emails`               VARCHAR(60)  DEFAULT NULL,
  `telephone`            VARCHAR(20)  DEFAULT NULL,
  `place_receipt`        VARCHAR(60)  DEFAULT NULL,
  `place_delivery`       VARCHAR(60)  DEFAULT NULL,
  `port_loading`         VARCHAR(60)  DEFAULT NULL,
  `port_discharge`       VARCHAR(60)  DEFAULT NULL,
  PRIMARY KEY (`id_bl`),
  KEY `numero_bl`        (`numero_bl`),
  KEY `consignee_code`   (`consignee_code`),
  KEY `consignee_name`   (`consignee_name`),
  KEY `arrival_date`     (`arrival_date`),
  KEY `reef`             (`reef`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
ALTER TABLE `bl` MODIFY `id_bl` INT(14) NOT NULL AUTO_INCREMENT;
/* source schema:  */

/* ----------------------  CLIENT  ----------------- */
DROP TABLE IF EXISTS `client`;
CREATE TABLE `client` (
  `id_client`     INT(14)      NOT NULL,
  `nom`           VARCHAR(60)  NOT NULL,
  `statut`        VARCHAR(20)  DEFAULT NULL,
  `code_client`   VARCHAR(20)  DEFAULT NULL,
  `nom_groupe`    VARCHAR(150) NOT NULL,
  `paie_caution`  TINYINT(1)   NOT NULL,
  `freetime_frigo`INT(6)       DEFAULT NULL,
  `freetime_sec`  INT(6)       DEFAULT NULL,
  `prioritaire`   TINYINT(1)   DEFAULT NULL,
  `salesrepid`    INT(14)      DEFAULT NULL,
  `financerepid`  INT(14)      DEFAULT NULL,
  `cservrepid`    INT(14)      DEFAULT NULL,
  `date_validite` DATETIME     DEFAULT NULL,
  `operator`      VARCHAR(20)  DEFAULT NULL,
  PRIMARY KEY (`id_client`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
ALTER TABLE `client` MODIFY `id_client` INT(14) NOT NULL AUTO_INCREMENT;
/* source schema:  */

/* --------------------  FACTURE  ------------------ */
DROP TABLE IF EXISTS `facture`;
CREATE TABLE `facture` (
  `id_facture`             INT(14)     NOT NULL,
  `reference`              VARCHAR(10) NOT NULL,
  `numero_bl`              CHAR(9)     NOT NULL,
  `code_client`            VARCHAR(20) NOT NULL,
  `nom_client`             VARCHAR(60) NOT NULL,
  `montant_facture`        DECIMAL(12,0) NOT NULL,
  `montant_orig`           DECIMAL(12,2) DEFAULT NULL,
  `devise`                 VARCHAR(6)  DEFAULT 'XOF',
  `statut`                 VARCHAR(10) NOT NULL DEFAULT 'init',
  `date_facture`           DATETIME    NOT NULL,
  `id_utilisateur`         INT(14)     NOT NULL,
  `create_type_utilisateur`VARCHAR(20) DEFAULT NULL,
  `created_at`             DATETIME    NOT NULL,
  `id_utilisateur_update`  INT(14)     DEFAULT NULL,
  `updated_at`             DATETIME    DEFAULT NULL,
  PRIMARY KEY (`id_facture`),
  UNIQUE KEY `unique_reference` (`reference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
ALTER TABLE `facture` MODIFY `id_facture` INT(14) NOT NULL AUTO_INCREMENT;
/* source schema:  */

/* -----------------  REMBOURSEMENT  --------------- */
DROP TABLE IF EXISTS `remboursement`;
CREATE TABLE `remboursement` (
  `id_remboursement`   INT(14)     NOT NULL,
  `numero_bl`          CHAR(9)     NOT NULL,
  `montant_demande`    VARCHAR(15) DEFAULT NULL,
  `refund_amount`      VARCHAR(15) DEFAULT NULL,
  `deduction`          VARCHAR(15) DEFAULT NULL,
  `statut`             VARCHAR(10) DEFAULT 'PENDING',
  `id_transitaire`     INT(14)     NOT NULL,
  `id_transitaire_maison` INT(14)  DEFAULT NULL,
  `transitaire_notifie`TINYINT(1)  DEFAULT NULL,
  `maison_notifie`     TINYINT(1)  DEFAULT NULL,
  `banque_notifie`     TINYINT(1)  DEFAULT NULL,
  `date_demande`       DATETIME    DEFAULT NULL,
  `date_refund_traite` DATETIME    DEFAULT NULL,
  `type_paiement`      VARCHAR(10) DEFAULT NULL,
  `pret`               VARCHAR(10) DEFAULT NULL,
  `soumis`             VARCHAR(10) DEFAULT NULL,
  `consignee_code`     VARCHAR(14) DEFAULT NULL,
  `refund_party_name`  VARCHAR(200)DEFAULT NULL,
  `beneficiaire`       VARCHAR(20) DEFAULT NULL,
  `deposit_amount`     VARCHAR(15) DEFAULT NULL,
  `reason_for_refund`  VARCHAR(200)DEFAULT NULL,
  `remarks`            VARCHAR(250)DEFAULT NULL,
  `co_code`            VARCHAR(20) DEFAULT NULL,
  `zm_doc_no`          TEXT        DEFAULT NULL,
  `gl_posting_doc`     VARCHAR(15) DEFAULT NULL,
  `clearing_doc`       VARCHAR(15) DEFAULT NULL,
  `email_address`      VARCHAR(60) DEFAULT NULL,
  `type_depotage`      VARCHAR(40) DEFAULT NULL,
  `accord_client`      TINYINT(1)  DEFAULT NULL,
  `comment`            TEXT        DEFAULT NULL,
  `reference`          VARCHAR(30) DEFAULT NULL,
  `date_agent_notified`DATETIME    DEFAULT NULL,
  `date_agency_notified`DATETIME   DEFAULT NULL,
  `date_client_notified`DATETIME   DEFAULT NULL,
  `date_banque_notified`DATETIME   DEFAULT NULL,
  `email_agency`       VARCHAR(60) DEFAULT NULL,
  `email_client`       VARCHAR(60) DEFAULT NULL,
  PRIMARY KEY (`id_remboursement`),
  KEY `numero_bl`      (`numero_bl`),
  KEY `statut`         (`statut`),
  KEY `reason_for_refund` (`reason_for_refund`),
  KEY `date_demande`   (`date_demande`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
ALTER TABLE `remboursement`
  MODIFY `id_remboursement` INT(14) NOT NULL AUTO_INCREMENT;
/* source schema:  */

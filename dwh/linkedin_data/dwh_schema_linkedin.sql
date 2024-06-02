-- MySQL Script generated by MySQL Workbench
-- Wed May 29 14:15:22 2024
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema DWH
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema DWH
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `DWH` DEFAULT CHARACTER SET utf8mb4 ;
USE `DWH` ;

-- -----------------------------------------------------
-- Table `DWH`.`DIM_LIN_Location`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`DIM_LIN_Location` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `countryLetters` CHAR(2) NULL COMMENT 'country attribute',
  `countryName` VARCHAR(43) NULL COMMENT 'country_full_name attribute of person or country attribute of company if more than 2 chars (doesn\'t fit into countryLetters)',
  `state` VARCHAR(56) NULL COMMENT 'state attribute',
  `city` VARCHAR(89) NULL COMMENT 'city attribute',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idLocation_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`DIM_Origin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`DIM_Origin` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `abbreviation` CHAR(3) NOT NULL COMMENT 'Three letter code used for identification of the data',
  `mongoCollectionName` CHAR(15) NOT NULL COMMENT 'name of the mongodb collection that contains the raw dataset',
  `name` VARCHAR(45) NULL COMMENT 'name of the dataset',
  `url` VARCHAR(100) NULL COMMENT 'url to dataset source',
  `importDate` DATE NOT NULL COMMENT 'date the dataset has been imported into dwh',
  `comment` VARCHAR(500) NULL COMMENT 'comment made by the user',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idOrigin_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`FACT_PRF_Person`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`FACT_PRF_Person` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `idLocation` INT NULL,
  `name` VARCHAR(229) NULL COMMENT 'full_name attribute',
  `occupation` VARCHAR(198) NULL COMMENT 'occupation attribute',
  `headline` VARCHAR(220) NULL COMMENT 'headline attribute',
  `summary` VARCHAR(2762) NULL COMMENT 'summary attribute',
  `connections` INT NULL COMMENT 'connections attribute',
  `inferredSalaryMin` INT NULL COMMENT 'inferred_salary[\"min\"] attribute',
  `inferredSalaryMax` INT NULL COMMENT 'inferred_salary[\"max\"] attribute',
  `gender` TINYINT NULL COMMENT 'gender attribute\n\nbool:\nfemale= 1\nmale= 0',
  `industry` VARCHAR(36) NULL COMMENT 'industry attribute',
  `profilePicture` TINYINT NULL COMMENT 'profile_pic_url attribute\n\nBool:\nlink present=1\nno link present=0',
  `backgroundPicture` TINYINT NULL COMMENT 'background_cover_image_url attribute\n\nBool:\nlink present=1\nno link present=0',
  `mongoCollectionId` CHAR(24) NOT NULL COMMENT 'ObjectId for matching mongoDB document',
  `idOrigin` INT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idPerson_UNIQUE` (`id` ASC) ,
  INDEX `fk_FACT_Person_DIM_Country_idx` (`idLocation` ASC) ,
  INDEX `fk_FACT_Person_DIM_Origin1_idx` (`idOrigin` ASC) ,
  CONSTRAINT `fk_FACT_Person_DIM_Country`
    FOREIGN KEY (`idLocation`)
    REFERENCES `DWH`.`DIM_LIN_Location` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FACT_Person_DIM_Origin1`
    FOREIGN KEY (`idOrigin`)
    REFERENCES `DWH`.`DIM_Origin` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`DIM_PRF_Duration`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`DIM_PRF_Duration` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `startDate` DATE NULL COMMENT 'start date, mainly comes from persons qualifications',
  `endDate` DATE NULL COMMENT 'end date, mainly comes from persons qualifications',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idDuration_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`FACT_PRF_Qualification`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`FACT_PRF_Qualification` (
  `idPerson` INT NOT NULL,
  `idDuration` INT NULL,
  `type` CHAR(13) NOT NULL COMMENT 'Name of attribute type, references multiple attributes of person.\n\nMapping is as follows:\nexperiences = experience\neducation = education\naccomplishment_projects = project\nvolunteer_work = volunteer\ncertifications = certification',
  `name` VARCHAR(255) NULL COMMENT 'Name or Title of the attribute, references a different key depending on type.\n\nMapping is as follows:\nexperiences = title\neducation = degree_name + field_of_study\nvolunteer_work = title\ncertifications = name',
  `institution` VARCHAR(234) NULL COMMENT 'Name of institution, references multiple, values have been taken from different attributes depending on the type of qualification referenced.\n\nMapping is as follows:\nexperiences = company\neducation = school\nvolunteer_work = company\ncertifications = authority',
  `description` VARCHAR(2500) NULL COMMENT 'References the description, sometimes multipe keys of the object type had to be combined, if not simply references description key.\n\nMapping is as follows:\nvolunteer_work = cause + description\ncertifications = license_number + display_source',
  INDEX `fk_DIM_Experience_FACT_Person1_idx` (`idPerson` ASC) ,
  INDEX `fk_FACT_Experience_DIM_Duration1_idx` (`idDuration` ASC) ,
  CONSTRAINT `fk_DIM_Experience_FACT_Person1`
    FOREIGN KEY (`idPerson`)
    REFERENCES `DWH`.`FACT_PRF_Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FACT_Experience_DIM_Duration1`
    FOREIGN KEY (`idDuration`)
    REFERENCES `DWH`.`DIM_PRF_Duration` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`DIM_PRF_Language`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`DIM_PRF_Language` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `language` VARCHAR(80) NULL COMMENT 'value of languages list attribute',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idLanguages_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`FACT_PRF_Recommendation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`FACT_PRF_Recommendation` (
  `idPerson` INT NOT NULL,
  `recommendationText` VARCHAR(3122) NOT NULL COMMENT 'value from recommendations list attribute',
  INDEX `fk_FACT_Recommendations_FACT_Person1_idx` (`idPerson` ASC) ,
  CONSTRAINT `fk_FACT_Recommendations_FACT_Person1`
    FOREIGN KEY (`idPerson`)
    REFERENCES `DWH`.`FACT_PRF_Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`DIM_PRF_Group`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`DIM_PRF_Group` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL COMMENT 'name key',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`REL_PRF_Person_Group`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`REL_PRF_Person_Group` (
  `idPerson` INT NOT NULL,
  `idGroup` INT NOT NULL,
  INDEX `fk_REL_Person_Group_FACT_Person1_idx` (`idPerson` ASC) ,
  INDEX `fk_REL_Person_Group_DIM_Group1_idx` (`idGroup` ASC) ,
  CONSTRAINT `fk_REL_Person_Group_FACT_Person1`
    FOREIGN KEY (`idPerson`)
    REFERENCES `DWH`.`FACT_PRF_Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_REL_Person_Group_DIM_Group1`
    FOREIGN KEY (`idGroup`)
    REFERENCES `DWH`.`DIM_PRF_Group` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`FACT_PRF_Related`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`FACT_PRF_Related` (
  `idPerson` INT NOT NULL,
  `type` CHAR(7) NOT NULL COMMENT 'Entry represents either people_also_viewed or similarly_named_profiles attribute.\n\npeople_also_viewed= viewed\nsimilarly_named_profiles= similar',
  `name` VARCHAR(100) NULL COMMENT 'name key',
  `location` VARCHAR(58) NULL COMMENT 'location key',
  `summary` VARCHAR(222) NULL COMMENT 'summary key',
  INDEX `fk_FACT_Related_FACT_Person1_idx` (`idPerson` ASC) ,
  CONSTRAINT `fk_FACT_Related_FACT_Person1`
    FOREIGN KEY (`idPerson`)
    REFERENCES `DWH`.`FACT_PRF_Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`DIM_PRF_Trait`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`DIM_PRF_Trait` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `type` CHAR(9) NOT NULL COMMENT 'Can be: \nskill for skills\ninterest for interests attribute',
  `name` VARCHAR(71) NOT NULL COMMENT 'Represents value for either skills or interests attribute, depending on type.',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`REL_PRF_Person_Trait`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`REL_PRF_Person_Trait` (
  `idPerson` INT NOT NULL,
  `idTrait` INT NOT NULL,
  INDEX `fk_REL_Person_Group_FACT_Person1_idx` (`idPerson` ASC) ,
  INDEX `fk_REL_Person_Group_DIM_Group1_idx` (`idTrait` ASC) ,
  CONSTRAINT `fk_REL_Person_Group_FACT_Person10`
    FOREIGN KEY (`idPerson`)
    REFERENCES `DWH`.`FACT_PRF_Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_REL_Person_Group_DIM_Group10`
    FOREIGN KEY (`idTrait`)
    REFERENCES `DWH`.`DIM_PRF_Trait` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`REL_PRF_Person_Language`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`REL_PRF_Person_Language` (
  `idPerson` INT NOT NULL,
  `idLanguage` INT NOT NULL,
  INDEX `fk_REL_Person_Language_DIM_Language1_idx` (`idLanguage` ASC) ,
  INDEX `fk_REL_Person_Language_FACT_Person1_idx` (`idPerson` ASC) ,
  CONSTRAINT `fk_REL_Person_Language_DIM_Language1`
    FOREIGN KEY (`idLanguage`)
    REFERENCES `DWH`.`DIM_PRF_Language` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_REL_Person_Language_FACT_Person1`
    FOREIGN KEY (`idPerson`)
    REFERENCES `DWH`.`FACT_PRF_Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`DIM_CMP_Size`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`DIM_CMP_Size` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sizeA` INT NULL COMMENT 'first value of company_size list attribute',
  `sizeB` INT NULL COMMENT 'second value of company_size list attribute',
  `sizeLinkedIn` INT NULL COMMENT 'company_size_on_linkedin attribute',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`FACT_CMP_Company`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`FACT_CMP_Company` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `idOrigin` INT NOT NULL,
  `idLocationHQ` INT NULL,
  `idSize` INT NULL COMMENT 'combines company_size list values',
  `mongoCollectionId` CHAR(24) NOT NULL COMMENT 'ObjectId for matching mongoDB document',
  `description` VARCHAR(3754) NULL COMMENT 'description attribute',
  `industry` VARCHAR(53) NULL COMMENT 'industry attribute',
  `type` VARCHAR(23) NULL COMMENT 'company_type attribute',
  `founded` INT NULL COMMENT 'founded_year attribute (year number as int)',
  `name` VARCHAR(154) NULL COMMENT 'name attribute',
  `tagline` VARCHAR(120) NULL COMMENT 'tagline attribute',
  `followers` INT NULL COMMENT 'follower_count attribute',
  `website` TINYINT NULL COMMENT 'website attribute\n\nhas link= 1\nno link= 0',
  `profilePicture` TINYINT NULL COMMENT 'has picture = 1\nno picture = 0',
  `backgroundPicture` TINYINT NULL COMMENT 'has picture = 1\nno picture = 0',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) ,
  INDEX `fk_FACT_LinkedIn_Company_DIM_Origin1_idx` (`idOrigin` ASC) ,
  INDEX `fk_FACT_LinkedIn_Company_DIM_LinkedIn_Location1_idx` (`idLocationHQ` ASC) ,
  INDEX `fk_FACT_LinkedIn_Company_DIM_LinkedIn_CompanySize1_idx` (`idSize` ASC) ,
  CONSTRAINT `fk_FACT_LinkedIn_Company_DIM_Origin1`
    FOREIGN KEY (`idOrigin`)
    REFERENCES `DWH`.`DIM_Origin` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FACT_LinkedIn_Company_DIM_LinkedIn_Location1`
    FOREIGN KEY (`idLocationHQ`)
    REFERENCES `DWH`.`DIM_LIN_Location` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_FACT_LinkedIn_Company_DIM_LinkedIn_CompanySize1`
    FOREIGN KEY (`idSize`)
    REFERENCES `DWH`.`DIM_CMP_Size` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`DIM_CMP_Specialty`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`DIM_CMP_Specialty` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(425) NULL COMMENT 'a value from specialities list attribute',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`REL_CMP_Company_Specialty`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`REL_CMP_Company_Specialty` (
  `idCompany` INT NULL,
  `idSpecialty` INT NULL,
  INDEX `fk_REL_LinkedIn_Company_Specialities_FACT_LinkedIn_Company1_idx` (`idCompany` ASC) ,
  INDEX `fk_REL_LinkedIn_Company_Specialities_DIM_LinkedIn_Specialit_idx` (`idSpecialty` ASC) ,
  CONSTRAINT `fk_REL_LinkedIn_Company_Specialities_FACT_LinkedIn_Company1`
    FOREIGN KEY (`idCompany`)
    REFERENCES `DWH`.`FACT_CMP_Company` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_REL_LinkedIn_Company_Specialities_DIM_LinkedIn_Specialities1`
    FOREIGN KEY (`idSpecialty`)
    REFERENCES `DWH`.`DIM_CMP_Specialty` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`REL_CMP_Company_Location`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`REL_CMP_Company_Location` (
  `idCompany` INT NULL,
  `idLocation` INT NULL,
  INDEX `fk_REL_LinkedIn_Company_Location_FACT_LinkedIn_Company1_idx` (`idCompany` ASC) ,
  INDEX `fk_REL_LinkedIn_Company_Location_DIM_LinkedIn_Location1_idx` (`idLocation` ASC) ,
  CONSTRAINT `fk_REL_LinkedIn_Company_Location_FACT_LinkedIn_Company1`
    FOREIGN KEY (`idCompany`)
    REFERENCES `DWH`.`FACT_CMP_Company` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_REL_LinkedIn_Company_Location_DIM_LinkedIn_Location1`
    FOREIGN KEY (`idLocation`)
    REFERENCES `DWH`.`DIM_LIN_Location` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`FACT_CMP_Similar`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`FACT_CMP_Similar` (
  `idCompany` INT NOT NULL,
  `name` VARCHAR(108) NULL COMMENT 'similar_companies name attribute',
  `industry` VARCHAR(53) NULL COMMENT 'similar_companies industry attribute',
  `location` VARCHAR(160) NULL COMMENT 'similar_companies location attribute',
  INDEX `fk_FACT_LinkedIn_Related_Company_FACT_LinkedIn_Company1_idx` (`idCompany` ASC) ,
  CONSTRAINT `fk_FACT_LinkedIn_Related_Company_FACT_LinkedIn_Company1`
    FOREIGN KEY (`idCompany`)
    REFERENCES `DWH`.`FACT_CMP_Company` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`FACT_CMP_Update`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`FACT_CMP_Update` (
  `idCompany` INT NOT NULL,
  `image` TINYINT NULL COMMENT 'image key\n\nhas image=1\nno image=0',
  `postedOn` DATETIME NULL COMMENT 'posted_on key',
  `text` VARCHAR(2998) NULL COMMENT 'text key',
  `likes` INT NULL COMMENT 'total_likes key',
  INDEX `fk_FACT_LinkedIn_Updates_FACT_LinkedIn_Company1_idx` (`idCompany` ASC) ,
  CONSTRAINT `fk_FACT_LinkedIn_Updates_FACT_LinkedIn_Company1`
    FOREIGN KEY (`idCompany`)
    REFERENCES `DWH`.`FACT_CMP_Company` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DWH`.`FACT_PRF_Accomplishment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DWH`.`FACT_PRF_Accomplishment` (
  `idPerson` INT NOT NULL,
  `type` CHAR(13) NOT NULL COMMENT 'Name of attribute type, references multiple attributes of person.\n\nMapping is as follows:\naccomplishment_organisations = organisation\naccomplishment_publications = publication\naccomplishment_honors_awards = honor\naccomplishment_patents = patent\naccomplishment_courses = course\naccomplishment_projects = project\naccomplishment_test_scores = test\nactivities = activity\narticles = article',
  `name` VARCHAR(255) NULL COMMENT 'Name or Title of the attribute, references a different key depending on type.\n\nMapping is as follows:\naccomplishment_organisations = title\naccomplishment_publications = name\naccomplishment_honors_awards = title\naccomplishment_patents = title\naccomplishment_courses = name\naccomplishment_test_scores = name\nactivities = title\narticles = title',
  `institution` VARCHAR(255) NULL COMMENT 'Name of institution, references multiple, values have been taken from different attributes depending on the type of qualification referenced.\n\nMapping is as follows:\naccomplishment_organisations = org_name\naccomplishment_publications = publisher\naccomplishment_honors_awards = issuer\naccomplishment_patents = issuer\narticles= author',
  `date` DATETIME NULL COMMENT 'References the start_at or publictation date of the accomplishment.\n\nMapping is as follows:\n',
  `description` VARCHAR(2500) NULL COMMENT 'References the description, sometimes multipe keys of the object type had to be combined, if not simply references description key.\n\nMapping is as follows:\naccomplishment_patents = application_number + patent_number + description\naccomplishment_courses = number\naccomplishment_test_scores = score + description\nactivities = activity_status\narticles = link\n',
  INDEX `fk_FACT_PRF_Accomplishment_FACT_PRF_Person1_idx` (`idPerson` ASC) ,
  CONSTRAINT `fk_FACT_PRF_Accomplishment_FACT_PRF_Person1`
    FOREIGN KEY (`idPerson`)
    REFERENCES `DWH`.`FACT_PRF_Person` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
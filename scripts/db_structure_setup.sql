-- Drop and create database
DROP DATABASE IF EXISTS kicad_db;
CREATE DATABASE kicad_db;
USE kicad_db;

-- Core lookup tables
CREATE TABLE manufacturers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE footprints (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Main parts table with ENUM category & revision
CREATE TABLE parts (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  symbol           VARCHAR(256)    NOT NULL,
  category         ENUM(
     'connectors','resistors','capacitors','inductors','diodes',
     'op_amps','leds','bjts','mosfets','igbts',
     'analog_ics','sensor_ics','sensors','digital_ics',
     'pmics','power_drivers','protection_ics','communication_ics',
     'mcus','clocks_and_crystals','memory'
  ) NOT NULL,
  revision         VARCHAR(16)     NOT NULL DEFAULT '1.0',
  footprint_id     INT UNSIGNED    NOT NULL,
  package          VARCHAR(64),
  manufacturer_id  INT UNSIGNED,
  mpn              VARCHAR(64),
  datasheet_url    VARCHAR(512),
  description      TEXT,
  distributor_pn   VARCHAR(64),
  price_usd        DECIMAL(10,4),
  footprint_filters TEXT,
  keywords         TEXT,
  status           ENUM('active','obsolete','pre-release', 'discontinued', 'end-of-life')
                   NOT NULL DEFAULT 'active',
  no_bom           TINYINT(1)      NOT NULL DEFAULT 0,
  schematic_only   TINYINT(1)      NOT NULL DEFAULT 0,
  created_at       TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (footprint_id)    REFERENCES footprints(id),
  FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id),
  INDEX idx_footprint  (footprint_id),
  INDEX idx_manufacturer (manufacturer_id),
  INDEX idx_status       (status),
  INDEX idx_category     (category),
  FULLTEXT(description),
  FULLTEXT(keywords)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Environmental specs (common ranges)
CREATE TABLE environmental_specs (
  part_id    INT UNSIGNED PRIMARY KEY,
  temp_min   DECIMAL(6,2),
  temp_max   DECIMAL(6,2),
  vin_min    DECIMAL(8,3),
  vin_max    DECIMAL(8,3),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Custom one-off specs (EAV)
CREATE TABLE custom_specs (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  part_id    INT UNSIGNED NOT NULL,
  attr_name  VARCHAR(64) NOT NULL,
  attr_value VARCHAR(128) NOT NULL,
  units      VARCHAR(16),
  FOREIGN KEY (part_id) REFERENCES parts(id),
  INDEX (attr_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Category-specific tables
CREATE TABLE connectors (
  part_id            INT UNSIGNED PRIMARY KEY,
  type               VARCHAR(64),
  gender             VARCHAR(32),
  pin_count          INT,
  pitch              DECIMAL(8,4),
  mounting           VARCHAR(64),
  orientation        VARCHAR(64),
  current_rating     DECIMAL(8,3),
  voltage_rating     DECIMAL(8,3),
  power_rating       DECIMAL(8,3),
  temperature_rating DECIMAL(6,2),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE resistors (
  part_id         INT UNSIGNED PRIMARY KEY,
  resistance      VARCHAR(32) NOT NULL,
  tolerance       DECIMAL(5,2),
  power           DECIMAL(5,2),
  temp_co_ppm     DECIMAL(7,3),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE capacitors (
  part_id        INT UNSIGNED PRIMARY KEY,
  capacitance    VARCHAR(64) NOT NULL,
  tolerance      DECIMAL(5,2),
  voltage_rating DECIMAL(8,3),
  type           VARCHAR(64),
  dielectric     VARCHAR(64),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE inductors (
  part_id            INT UNSIGNED PRIMARY KEY,
  inductance         VARCHAR(64) NOT NULL,
  tolerance          DECIMAL(5,2),
  current_rating     DECIMAL(8,3),
  dcr                DECIMAL(10,3),
  srf                DECIMAL(8,3),
  saturation_current DECIMAL(8,3),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE diodes (
  part_id               INT UNSIGNED PRIMARY KEY,
  type                  VARCHAR(32),
  forward_voltage       DECIMAL(8,3),
  reverse_voltage       DECIMAL(8,3),
  zener_voltage         DECIMAL(8,3),
  reverse_recovery_time DECIMAL(10,6),
  current_rating        DECIMAL(8,3),
  power_dissipation     DECIMAL(8,3),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE op_amps (
  part_id               INT UNSIGNED PRIMARY KEY,
  `function`            VARCHAR(64),
  channel_count         INT,
  gain                  VARCHAR(64),
  bandwidth             VARCHAR(64),
  slew_rate             VARCHAR(64),
  input_offset_volt     VARCHAR(64),
  input_bias_current    VARCHAR(64),
  pin_count             INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE leds (
  part_id           INT UNSIGNED PRIMARY KEY,
  color             VARCHAR(32),
  wavelength_nm     INT,
  forward_voltage   DECIMAL(8,3),
  forward_current   DECIMAL(8,3),
  luminosity_cd     DECIMAL(10,3),
  cri               INT,
  current_rating    DECIMAL(8,3),
  power_dissipation DECIMAL(8,3),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bjts (
  part_id        INT UNSIGNED PRIMARY KEY,
  polarity       VARCHAR(16),
  hfe            DECIMAL(10,3),
  vbe            DECIMAL(8,3),
  vce_max        DECIMAL(8,3),
  vcb_breakdown  DECIMAL(8,3),
  current_rating DECIMAL(8,3),
  power_rating   DECIMAL(8,3),
  tj_max_c       DECIMAL(6,2),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE mosfets (
  part_id         INT UNSIGNED PRIMARY KEY,
  polarity        VARCHAR(16),
  vgs             DECIMAL(8,3),
  rds_on          VARCHAR(32),
  gate_charge     VARCHAR(32),
  vds_max         DECIMAL(8,3),
  vgs_max         DECIMAL(8,3),
  current_rating  DECIMAL(8,3),
  power_rating    DECIMAL(8,3),
  tj_max_c        DECIMAL(6,2),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE igbts (
  part_id         INT UNSIGNED PRIMARY KEY,
  polarity        VARCHAR(16),
  vge             DECIMAL(8,3),
  vce             DECIMAL(8,3),
  gate_charge     VARCHAR(32),
  vge_max         DECIMAL(8,3),
  vce_max         DECIMAL(8,3),
  current_rating  DECIMAL(8,3),
  power_rating    DECIMAL(8,3),
  tj_max_c        DECIMAL(6,2),
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE analog_ics (
  part_id             INT UNSIGNED PRIMARY KEY,
  `function`          VARCHAR(64),
  channel_count       INT,
  gain                VARCHAR(64),
  bandwidth           VARCHAR(32),
  resolution_bits     INT,
  sampling_rate       VARCHAR(32),
  operating_current   VARCHAR(32),
  pin_count           INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sensor_ics (
  part_id           INT UNSIGNED PRIMARY KEY,
  `function`        VARCHAR(64),
  channel_count     INT,
  sensor_type       VARCHAR(64),
  gain              VARCHAR(64),
  bandwidth         VARCHAR(32),
  resolution_bits   INT,
  sampling_rate     VARCHAR(32),
  operating_current VARCHAR(32),
  pin_count         INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sensors (
  part_id            INT UNSIGNED PRIMARY KEY,
  type               VARCHAR(64),
  range_spec         VARCHAR(64),
  accuracy           DECIMAL(6,4),
  sensitivity        DECIMAL(10,3),
  response_time      VARCHAR(32),
  output_type        VARCHAR(32),
  operating_current  VARCHAR(32),
  pin_count          INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE digital_ics (
  part_id            INT UNSIGNED PRIMARY KEY,
  `function`         VARCHAR(64),
  logic_family       VARCHAR(64),
  operating_current  VARCHAR(32),
  pin_count          INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pmics (
  part_id           INT UNSIGNED PRIMARY KEY,
  `function`        VARCHAR(64),
  channel_count     INT,
  frequency         VARCHAR(32),
  vout_min          DECIMAL(8,3),
  vout_max          DECIMAL(8,3),
  output_current    DECIMAL(10,3),
  pin_count         INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE power_drivers (
  part_id           INT UNSIGNED PRIMARY KEY,
  `function`        VARCHAR(64),
  channel_count     INT,
  frequency         VARCHAR(32),
  vout_min          DECIMAL(8,3),
  vout_max          DECIMAL(8,3),
  output_current    DECIMAL(10,3),
  pin_count         INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE protection_ics (
  part_id            INT UNSIGNED PRIMARY KEY,
  type               VARCHAR(64),
  isolation_type     VARCHAR(64),
  trigger_voltage    DECIMAL(8,3),
  clamping_voltage   DECIMAL(8,3),
  isolation_voltage  DECIMAL(8,3),
  response_time      VARCHAR(32),
  power_rating       DECIMAL(8,3),
  pin_count          INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE communication_ics (
  part_id            INT UNSIGNED PRIMARY KEY,
  type               VARCHAR(64),
  protocol           VARCHAR(64),
  frequency          VARCHAR(32),
  modulation         VARCHAR(64),
  data_rate_bps      VARCHAR(32),
  operating_current  VARCHAR(32),
  pin_count          INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE mcus (
  part_id            INT UNSIGNED PRIMARY KEY,
  architecture       VARCHAR(64),
  frequency          VARCHAR(32),
  peripherals        VARCHAR(128),
  ram_bytes          VARCHAR(32),
  rom_bytes          VARCHAR(32),
  operating_current  VARCHAR(32),
  pin_count          INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE clocks_and_crystals (
  part_id             INT UNSIGNED PRIMARY KEY,
  type                VARCHAR(64),
  frequency           VARCHAR(32),
  stability           VARCHAR(32),
  jitter_ps           DECIMAL(10,6),
  load_cap_pF         DECIMAL(8,3),
  pin_count           INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE memory (
  part_id            INT UNSIGNED PRIMARY KEY,
  memory_type        VARCHAR(64),
  capacity           VARCHAR(32),
  interface_type     VARCHAR(32),
  endurance_cycles   VARCHAR(32),
  read_time          VARCHAR(32),
  write_time         VARCHAR(32),
  operating_current  VARCHAR(32),
  pin_count          INT,
  FOREIGN KEY (part_id) REFERENCES parts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- ============================================
-- Complete Remote Config Database Setup (MariaDB/MySQL)
-- ============================================
-- Database: useful_links (193.140.136.26:3306)
-- This script creates ALL required tables for remote configuration

-- ============================================
-- 1. USEFUL LINKS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS useful_links (
    id VARCHAR(50) PRIMARY KEY COMMENT 'Unique identifier for the link',
    title VARCHAR(200) NOT NULL COMMENT 'Display title of the link',
    icon VARCHAR(100) NOT NULL COMMENT 'Ionicons icon name',
    url TEXT NOT NULL COMMENT 'Target URL',
    description TEXT COMMENT 'Description of the link',
    color VARCHAR(7) NOT NULL COMMENT 'Hex color code (e.g., #CC0000)',
    order_index INT DEFAULT 0 COMMENT 'Display order (lower = first)',
    is_active TINYINT(1) DEFAULT 1 COMMENT 'Whether the link is active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    INDEX idx_is_active (is_active),
    INDEX idx_order_index (order_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stores useful links for mobile app';

-- Insert default useful links
INSERT INTO useful_links (id, title, icon, url, description, color, order_index, is_active)
VALUES
    ('gaun_homepage', 'GAÜN Ana Sayfa', 'globe-outline', 'https://www.gaziantep.edu.tr', 'Gaziantep Üniversitesi resmi web sitesi', '#CC0000', 1, 1),
    ('obs', 'Öğrenci Bilgi Sistemi', 'school-outline', 'https://obs.gaziantep.edu.tr', 'OBS giriş sayfası', '#003366', 2, 1),
    ('library', 'Kütüphane', 'library-outline', 'https://kutuphane.gaziantep.edu.tr', 'Üniversite kütüphanesi', '#006633', 3, 1),
    ('email', 'E-Posta', 'mail-outline', 'https://mail.gaziantep.edu.tr', 'Üniversite e-posta sistemi', '#0099CC', 4, 1),
    ('yemek', 'Yemek Listesi', 'restaurant-outline', 'https://sks.gaziantep.edu.tr/yemek-listesi', 'Günlük yemek menüsü', '#FF6600', 5, 1)
ON DUPLICATE KEY UPDATE id=id;

-- ============================================
-- 2. DRAWER MENU ITEMS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS drawer_menu_items (
    id VARCHAR(50) PRIMARY KEY,
    title_key VARCHAR(200) NOT NULL COMMENT 'i18n translation key',
    icon VARCHAR(100) NOT NULL COMMENT 'Ionicons icon name',
    route VARCHAR(100) COMMENT 'Navigation route name',
    url TEXT COMMENT 'External URL',
    type VARCHAR(20) NOT NULL COMMENT 'navigation or external',
    color VARCHAR(7) COMMENT 'Hex color code',
    requires_login TINYINT(1) DEFAULT 0 COMMENT 'Requires user login',
    user_types VARCHAR(100) COMMENT 'Comma-separated: student,academic',
    order_index INT DEFAULT 0 COMMENT 'Display order',
    is_active TINYINT(1) DEFAULT 1 COMMENT 'Whether item is active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_type CHECK (type IN ('navigation', 'external')),
    INDEX idx_drawer_menu_active_order (is_active, order_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stores drawer menu items for mobile app';

-- Insert default drawer menu items
INSERT INTO drawer_menu_items (id, title_key, icon, route, url, type, color, requires_login, user_types, order_index, is_active)
VALUES
    ('profile', 'navigation.profile', 'person-outline', 'Profile', NULL, 'navigation', '#003366', 0, NULL, 1, 1),
    ('lessons', 'navigation.lessons', 'book-outline', 'Lessons', NULL, 'navigation', '#CC0000', 1, 'student,academic', 2, 1),
    ('advisor', 'advisor.title', 'person-circle-outline', 'Advisor', NULL, 'navigation', '#006633', 1, 'student', 3, 1),
    ('advisedStudents', 'advisedStudents.menuTitle', 'people-outline', 'AdvisedStudents', NULL, 'navigation', '#006633', 1, 'academic', 4, 1),
    ('snapAndSend', 'navigation.snapAndSend', 'camera-outline', 'SnapAndSend', NULL, 'navigation', '#FF6600', 1, 'student,academic', 5, 1),
    ('usefulLinks', 'navigation.usefulLinks', 'link-outline', 'UsefulLinks', NULL, 'navigation', '#CC0000', 0, NULL, 6, 1),
    ('gaunHomepage', 'navigation.gaunHomepage', 'globe-outline', NULL, 'https://www.gaziantep.edu.tr', 'external', '#0099CC', 0, NULL, 7, 1)
ON DUPLICATE KEY UPDATE id=id;

-- ============================================
-- 3. APP CONFIG TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS app_config (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Auto-increment ID',
    config_key VARCHAR(100) UNIQUE NOT NULL COMMENT 'Configuration key',
    config_value TEXT NOT NULL COMMENT 'Configuration value',
    version VARCHAR(20) NOT NULL COMMENT 'Version number',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    INDEX idx_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Stores app configuration and versioning';

-- Insert default config version
INSERT INTO app_config (config_key, config_value, version)
VALUES ('useful_links_version', 'Initial version', '1.0.0')
ON DUPLICATE KEY UPDATE config_key=config_key;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check all tables
SHOW TABLES;

-- Verify useful_links
SELECT COUNT(*) as useful_links_count FROM useful_links;
SELECT * FROM useful_links ORDER BY order_index;

-- Verify drawer_menu_items
SELECT COUNT(*) as drawer_menu_count FROM drawer_menu_items;
SELECT * FROM drawer_menu_items ORDER BY order_index;

-- Verify app_config
SELECT * FROM app_config;

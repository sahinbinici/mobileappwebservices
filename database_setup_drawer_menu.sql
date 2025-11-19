-- ============================================
-- Drawer Menu Items Table Setup (MariaDB/MySQL)
-- ============================================
-- This script creates the drawer_menu_items table and populates it with default menu items
-- Run this script in your useful_links database
-- Database: useful_links (193.140.136.26:3306)

-- Create drawer_menu_items table
CREATE TABLE IF NOT EXISTS drawer_menu_items (
    id VARCHAR(50) PRIMARY KEY,
    title_key VARCHAR(200) NOT NULL,
    icon VARCHAR(100) NOT NULL,
    route VARCHAR(100),
    url TEXT,
    type VARCHAR(20) NOT NULL,
    color VARCHAR(7),
    requires_login TINYINT(1) DEFAULT 0,
    user_types VARCHAR(100), -- Comma-separated: 'student,academic' or NULL
    order_index INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_type CHECK (type IN ('navigation', 'external'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create index on is_active and order_index for faster queries
CREATE INDEX idx_drawer_menu_active_order ON drawer_menu_items(is_active, order_index);

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

-- Note: updated_at column already has ON UPDATE CURRENT_TIMESTAMP
-- No need for manual trigger in MariaDB/MySQL

-- Verify the data
SELECT * FROM drawer_menu_items ORDER BY order_index;

-- ============================================
-- Sample queries for testing
-- ============================================

-- Get all active drawer menu items (what the mobile app will call)
SELECT * FROM drawer_menu_items WHERE is_active = 1 ORDER BY order_index;

-- Get items for students only
SELECT * FROM drawer_menu_items 
WHERE is_active = 1 
AND (user_types IS NULL OR user_types LIKE '%student%')
ORDER BY order_index;

-- Get items for academics only
SELECT * FROM drawer_menu_items 
WHERE is_active = 1 
AND (user_types IS NULL OR user_types LIKE '%academic%')
ORDER BY order_index;

-- Toggle active status for a specific item
-- UPDATE drawer_menu_items SET is_active = NOT is_active WHERE id = 'snapAndSend';

-- Add a new menu item
-- INSERT INTO drawer_menu_items (id, title_key, icon, route, type, color, requires_login, user_types, order_index, is_active)
-- VALUES ('newItem', 'navigation.newItem', 'star-outline', 'NewScreen', 'navigation', '#FF0000', 0, NULL, 8, 1);

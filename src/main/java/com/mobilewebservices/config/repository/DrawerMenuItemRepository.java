package com.mobilewebservices.config.repository;

import com.mobilewebservices.config.entity.DrawerMenuItem;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

@Repository
@Slf4j
public class DrawerMenuItemRepository {

    private final JdbcTemplate jdbcTemplate;

    public DrawerMenuItemRepository(@Qualifier("remoteConfigJdbcTemplate") JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private static final RowMapper<DrawerMenuItem> ROW_MAPPER = new RowMapper<DrawerMenuItem>() {
        @Override
        public DrawerMenuItem mapRow(ResultSet rs, int rowNum) throws SQLException {
            DrawerMenuItem item = new DrawerMenuItem();
            item.setId(rs.getString("id"));
            item.setTitleKey(rs.getString("title_key"));
            item.setIcon(rs.getString("icon"));
            item.setRoute(rs.getString("route"));
            item.setUrl(rs.getString("url"));
            item.setType(rs.getString("type"));
            item.setColor(rs.getString("color"));
            item.setRequiresLogin(rs.getBoolean("requires_login"));
            item.setUserTypes(rs.getString("user_types"));
            item.setOrderIndex(rs.getInt("order_index"));
            item.setIsActive(rs.getBoolean("is_active"));
            item.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            item.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
            return item;
        }
    };

    /**
     * Find all active drawer menu items ordered by orderIndex
     */
    public List<DrawerMenuItem> findByIsActiveTrueOrderByOrderIndexAsc() {
        String sql = "SELECT * FROM drawer_menu_items WHERE is_active = 1 ORDER BY order_index ASC";
        return jdbcTemplate.query(sql, ROW_MAPPER);
    }

    /**
     * Find all drawer menu items ordered by orderIndex
     */
    public List<DrawerMenuItem> findAllByOrderByOrderIndexAsc() {
        String sql = "SELECT * FROM drawer_menu_items ORDER BY order_index ASC";
        return jdbcTemplate.query(sql, ROW_MAPPER);
    }

    /**
     * Find by ID
     */
    public Optional<DrawerMenuItem> findById(String id) {
        String sql = "SELECT * FROM drawer_menu_items WHERE id = ?";
        List<DrawerMenuItem> results = jdbcTemplate.query(sql, ROW_MAPPER, id);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    /**
     * Check if a drawer menu item exists by ID
     */
    public boolean existsById(String id) {
        String sql = "SELECT COUNT(*) FROM drawer_menu_items WHERE id = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, id);
        return count != null && count > 0;
    }

    /**
     * Save drawer menu item
     */
    public void save(DrawerMenuItem item) {
        String sql = "INSERT INTO drawer_menu_items (id, title_key, icon, route, url, type, color, requires_login, user_types, order_index, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "title_key = VALUES(title_key), icon = VALUES(icon), route = VALUES(route), url = VALUES(url), " +
                     "type = VALUES(type), color = VALUES(color), requires_login = VALUES(requires_login), " +
                     "user_types = VALUES(user_types), order_index = VALUES(order_index), is_active = VALUES(is_active)";

        jdbcTemplate.update(sql,
                item.getId(),
                item.getTitleKey(),
                item.getIcon(),
                item.getRoute(),
                item.getUrl(),
                item.getType(),
                item.getColor(),
                item.getRequiresLogin() != null ? item.getRequiresLogin() : false,
                item.getUserTypes(),
                item.getOrderIndex() != null ? item.getOrderIndex() : 0,
                item.getIsActive() != null ? item.getIsActive() : true);
    }

    /**
     * Delete by ID
     */
    public void deleteById(String id) {
        String sql = "DELETE FROM drawer_menu_items WHERE id = ?";
        jdbcTemplate.update(sql, id);
    }
}

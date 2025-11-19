package com.mobilewebservices.config.service;

import com.mobilewebservices.config.dto.ConfigVersionDto;
import com.mobilewebservices.config.dto.DrawerMenuItemDto;
import com.mobilewebservices.config.dto.UsefulLinkDto;
import com.mobilewebservices.config.entity.DrawerMenuItem;
import com.mobilewebservices.config.repository.AppConfigRepository;
import com.mobilewebservices.config.repository.DrawerMenuItemRepository;
import com.mobilewebservices.config.repository.UsefulLinkRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class RemoteConfigService {

    private final UsefulLinkRepository usefulLinkRepository;
    private final DrawerMenuItemRepository drawerMenuItemRepository;
    private final AppConfigRepository appConfigRepository;

    private static final String CONFIG_VERSION_KEY = "useful_links_version";
    private static final String MIN_APP_VERSION = "1.0.0";

    /**
     * Get all active useful links
     * Cached for 1 hour
     */
    @Cacheable(value = "usefulLinks", unless = "#result == null || #result.isEmpty()")
    public List<UsefulLinkDto> getActiveUsefulLinks() {
        log.info("Fetching active useful links from database");
        return usefulLinkRepository.findByIsActiveTrueOrderByOrderIndexAsc();
    }

    /**
     * Get all useful links (including inactive)
     */
    public List<UsefulLinkDto> getAllUsefulLinks() {
        log.info("Fetching all useful links from database");
        return usefulLinkRepository.findAllByOrderByOrderIndexAsc();
    }

    /**
     * Get configuration version
     */
    @Cacheable(value = "configVersion", unless = "#result == null")
    public ConfigVersionDto getConfigVersion() {
        log.info("Fetching config version");

        Map<String, Object> config = appConfigRepository.findByConfigKey(CONFIG_VERSION_KEY)
                .orElseGet(() -> {
                    createDefaultConfigVersion();
                    return appConfigRepository.findByConfigKey(CONFIG_VERSION_KEY).orElse(null);
                });

        if (config == null) {
            return ConfigVersionDto.builder()
                    .version("1.0.0")
                    .lastUpdated(LocalDateTime.now().toString())
                    .minAppVersion(MIN_APP_VERSION)
                    .build();
        }

        return ConfigVersionDto.builder()
                .version((String) config.get("version"))
                .lastUpdated(config.get("last_updated").toString())
                .minAppVersion(MIN_APP_VERSION)
                .build();
    }

    /**
     * Create a new useful link
     */
    @CacheEvict(value = "usefulLinks", allEntries = true)
    public UsefulLinkDto createUsefulLink(UsefulLinkDto dto) {
        log.info("Creating new useful link: {}", dto.getTitle());

        if (usefulLinkRepository.existsById(dto.getId())) {
            throw new IllegalArgumentException("Link with ID " + dto.getId() + " already exists");
        }

        usefulLinkRepository.save(dto);
        incrementConfigVersion();

        return dto;
    }

    /**
     * Update an existing useful link
     */
    @CacheEvict(value = "usefulLinks", allEntries = true)
    public UsefulLinkDto updateUsefulLink(String id, UsefulLinkDto dto) {
        log.info("Updating useful link: {}", id);

        if (!usefulLinkRepository.existsById(id)) {
            throw new IllegalArgumentException("Link with ID " + id + " not found");
        }

        usefulLinkRepository.update(id, dto);
        incrementConfigVersion();

        return dto;
    }

    /**
     * Delete a useful link
     */
    @CacheEvict(value = "usefulLinks", allEntries = true)
    public void deleteUsefulLink(String id) {
        log.info("Deleting useful link: {}", id);

        if (!usefulLinkRepository.existsById(id)) {
            throw new IllegalArgumentException("Link with ID " + id + " not found");
        }

        usefulLinkRepository.deleteById(id);
        incrementConfigVersion();
    }

    /**
     * Toggle link active status
     */
    @CacheEvict(value = "usefulLinks", allEntries = true)
    public UsefulLinkDto toggleLinkStatus(String id) {
        log.info("Toggling status for useful link: {}", id);

        if (!usefulLinkRepository.existsById(id)) {
            throw new IllegalArgumentException("Link with ID " + id + " not found");
        }

        usefulLinkRepository.toggleStatus(id);
        incrementConfigVersion();

        return usefulLinkRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Link with ID " + id + " not found"));
    }

    /**
     * Get all active drawer menu items
     * Cached for 1 hour
     */
    @Cacheable(value = "drawerMenuItems", unless = "#result == null || #result.isEmpty()")
    public List<DrawerMenuItemDto> getActiveDrawerMenuItems() {
        log.info("Fetching active drawer menu items from database");
        List<DrawerMenuItem> entities = drawerMenuItemRepository.findByIsActiveTrueOrderByOrderIndexAsc();
        return entities.stream().map(this::convertToDto).toList();
    }

    /**
     * Get all drawer menu items (including inactive)
     */
    public List<DrawerMenuItemDto> getAllDrawerMenuItems() {
        log.info("Fetching all drawer menu items from database");
        List<DrawerMenuItem> entities = drawerMenuItemRepository.findAllByOrderByOrderIndexAsc();
        return entities.stream().map(this::convertToDto).toList();
    }

    /**
     * Create a new drawer menu item
     */
    @CacheEvict(value = "drawerMenuItems", allEntries = true)
    public DrawerMenuItemDto createDrawerMenuItem(DrawerMenuItemDto dto) {
        log.info("Creating new drawer menu item: {}", dto.getId());

        if (drawerMenuItemRepository.existsById(dto.getId())) {
            throw new IllegalArgumentException("Drawer menu item with ID " + dto.getId() + " already exists");
        }

        DrawerMenuItem entity = convertToEntity(dto);
        drawerMenuItemRepository.save(entity);
        incrementConfigVersion();

        return dto;
    }

    /**
     * Update an existing drawer menu item
     */
    @CacheEvict(value = "drawerMenuItems", allEntries = true)
    public DrawerMenuItemDto updateDrawerMenuItem(String id, DrawerMenuItemDto dto) {
        log.info("Updating drawer menu item: {}", id);

        if (!drawerMenuItemRepository.existsById(id)) {
            throw new IllegalArgumentException("Drawer menu item with ID " + id + " not found");
        }

        DrawerMenuItem entity = convertToEntity(dto);
        entity.setId(id);
        drawerMenuItemRepository.save(entity);
        incrementConfigVersion();

        return dto;
    }

    /**
     * Delete a drawer menu item
     */
    @CacheEvict(value = "drawerMenuItems", allEntries = true)
    public void deleteDrawerMenuItem(String id) {
        log.info("Deleting drawer menu item: {}", id);

        if (!drawerMenuItemRepository.existsById(id)) {
            throw new IllegalArgumentException("Drawer menu item with ID " + id + " not found");
        }

        drawerMenuItemRepository.deleteById(id);
        incrementConfigVersion();
    }

    /**
     * Toggle drawer menu item active status
     */
    @CacheEvict(value = "drawerMenuItems", allEntries = true)
    public DrawerMenuItemDto toggleDrawerMenuItemStatus(String id) {
        log.info("Toggling status for drawer menu item: {}", id);

        DrawerMenuItem entity = drawerMenuItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Drawer menu item with ID " + id + " not found"));

        entity.setIsActive(!entity.getIsActive());
        drawerMenuItemRepository.save(entity);
        incrementConfigVersion();

        return convertToDto(entity);
    }

    /**
     * Clear all caches
     */
    @CacheEvict(value = {"usefulLinks", "drawerMenuItems", "configVersion"}, allEntries = true)
    public void clearAllCaches() {
        log.info("Clearing all remote config caches");
    }

    // Helper methods

    private void incrementConfigVersion() {
        Map<String, Object> config = appConfigRepository.findByConfigKey(CONFIG_VERSION_KEY).orElse(null);

        String currentVersion;
        if (config == null) {
            createDefaultConfigVersion();
            currentVersion = "1.0.0";
        } else {
            currentVersion = (String) config.get("version");
        }

        // Increment version (e.g., 1.0.0 -> 1.0.1)
        String newVersion = incrementVersion(currentVersion);
        appConfigRepository.updateVersion(CONFIG_VERSION_KEY, newVersion);

        // Clear version cache
        clearVersionCache();

        log.info("Config version incremented from {} to {}", currentVersion, newVersion);
    }

    @CacheEvict(value = "configVersion", allEntries = true)
    private void clearVersionCache() {
        // Cache eviction handled by annotation
    }

    private String incrementVersion(String version) {
        String[] parts = version.split("\\.");
        if (parts.length == 3) {
            int patch = Integer.parseInt(parts[2]);
            return parts[0] + "." + parts[1] + "." + (patch + 1);
        }
        return "1.0.1";
    }

    private void createDefaultConfigVersion() {
        appConfigRepository.save(CONFIG_VERSION_KEY, "Initial version", "1.0.0");
    }

    // Drawer menu item conversion helpers

    private DrawerMenuItemDto convertToDto(DrawerMenuItem entity) {
        List<String> userTypes = null;
        if (entity.getUserTypes() != null && !entity.getUserTypes().isEmpty()) {
            userTypes = List.of(entity.getUserTypes().split(","));
        }

        return DrawerMenuItemDto.builder()
                .id(entity.getId())
                .titleKey(entity.getTitleKey())
                .icon(entity.getIcon())
                .route(entity.getRoute())
                .url(entity.getUrl())
                .type(entity.getType())
                .color(entity.getColor())
                .requiresLogin(entity.getRequiresLogin())
                .userTypes(userTypes)
                .order(entity.getOrderIndex())
                .isActive(entity.getIsActive())
                .build();
    }

    private DrawerMenuItem convertToEntity(DrawerMenuItemDto dto) {
        DrawerMenuItem entity = new DrawerMenuItem();
        entity.setId(dto.getId());
        entity.setTitleKey(dto.getTitleKey());
        entity.setIcon(dto.getIcon());
        entity.setRoute(dto.getRoute());
        entity.setUrl(dto.getUrl());
        entity.setType(dto.getType());
        entity.setColor(dto.getColor());
        entity.setRequiresLogin(dto.getRequiresLogin() != null ? dto.getRequiresLogin() : false);
        
        // Convert userTypes list to comma-separated string
        if (dto.getUserTypes() != null && !dto.getUserTypes().isEmpty()) {
            entity.setUserTypes(String.join(",", dto.getUserTypes()));
        } else {
            entity.setUserTypes(null);
        }
        
        entity.setOrderIndex(dto.getOrder() != null ? dto.getOrder() : 0);
        entity.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);
        
        return entity;
    }
}

package com.mobilewebservices.config.controller;

import com.mobilewebservices.config.dto.DrawerMenuItemDto;
import com.mobilewebservices.config.service.RemoteConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/config")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Drawer Menu Config", description = "Mobile app drawer menu configuration endpoints")
public class DrawerMenuController {

    private final RemoteConfigService remoteConfigService;

    /**
     * Get all active drawer menu items
     * Used by mobile app to fetch dynamic drawer menu
     */
    @GetMapping("/drawer_menu")
    @Operation(summary = "Get active drawer menu items", description = "Returns all active drawer menu items for mobile app")
    public ResponseEntity<List<DrawerMenuItemDto>> getActiveDrawerMenuItems() {
        log.info("GET /mobilewebservices/config/drawer_menu - Fetching active drawer menu items");

        try {
            List<DrawerMenuItemDto> items = remoteConfigService.getActiveDrawerMenuItems();
            log.info("Successfully fetched {} active drawer menu items", items.size());
            return ResponseEntity.ok(items);
        } catch (Exception e) {
            log.error("Error fetching active drawer menu items", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Alternative endpoint with hyphen for consistency
     */
    @GetMapping("/drawer-menu")
    @Operation(summary = "Get active drawer menu items", description = "Returns all active drawer menu items for mobile app")
    public ResponseEntity<List<DrawerMenuItemDto>> getActiveDrawerMenuItemsAlt() {
        log.info("GET /mobilewebservices/config/drawer-menu - Redirecting to standard endpoint");
        return getActiveDrawerMenuItems();
    }

    /**
     * Get all drawer menu items (including inactive) - Admin endpoint
     */
    @GetMapping("/drawer-menu/all")
    @Operation(summary = "Get all drawer menu items", description = "Returns all drawer menu items including inactive ones (admin)")
    public ResponseEntity<List<DrawerMenuItemDto>> getAllDrawerMenuItems() {
        log.info("GET /mobilewebservices/config/drawer-menu/all - Fetching all drawer menu items");

        try {
            List<DrawerMenuItemDto> items = remoteConfigService.getAllDrawerMenuItems();
            log.info("Successfully fetched {} drawer menu items", items.size());
            return ResponseEntity.ok(items);
        } catch (Exception e) {
            log.error("Error fetching all drawer menu items", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Create a new drawer menu item - Admin endpoint
     */
    @PostMapping("/drawer-menu")
    @Operation(summary = "Create drawer menu item", description = "Creates a new drawer menu item (admin)")
    public ResponseEntity<DrawerMenuItemDto> createDrawerMenuItem(@Valid @RequestBody DrawerMenuItemDto dto) {
        log.info("POST /mobilewebservices/config/drawer-menu - Creating new drawer menu item: {}", dto.getId());

        try {
            DrawerMenuItemDto created = remoteConfigService.createDrawerMenuItem(dto);
            log.info("Successfully created drawer menu item with ID: {}", created.getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (IllegalArgumentException e) {
            log.warn("Invalid request: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            log.error("Error creating drawer menu item", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Update an existing drawer menu item - Admin endpoint
     */
    @PutMapping("/drawer-menu/{id}")
    @Operation(summary = "Update drawer menu item", description = "Updates an existing drawer menu item (admin)")
    public ResponseEntity<DrawerMenuItemDto> updateDrawerMenuItem(
            @PathVariable String id,
            @Valid @RequestBody DrawerMenuItemDto dto) {
        log.info("PUT /mobilewebservices/config/drawer-menu/{} - Updating drawer menu item", id);

        try {
            DrawerMenuItemDto updated = remoteConfigService.updateDrawerMenuItem(id, dto);
            log.info("Successfully updated drawer menu item with ID: {}", id);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            log.warn("Invalid request: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("Error updating drawer menu item", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Delete a drawer menu item - Admin endpoint
     */
    @DeleteMapping("/drawer-menu/{id}")
    @Operation(summary = "Delete drawer menu item", description = "Deletes a drawer menu item (admin)")
    public ResponseEntity<Void> deleteDrawerMenuItem(@PathVariable String id) {
        log.info("DELETE /mobilewebservices/config/drawer-menu/{} - Deleting drawer menu item", id);

        try {
            remoteConfigService.deleteDrawerMenuItem(id);
            log.info("Successfully deleted drawer menu item with ID: {}", id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            log.warn("Invalid request: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("Error deleting drawer menu item", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Toggle drawer menu item active status - Admin endpoint
     */
    @PatchMapping("/drawer-menu/{id}/toggle")
    @Operation(summary = "Toggle menu item status", description = "Toggles active/inactive status of a drawer menu item (admin)")
    public ResponseEntity<DrawerMenuItemDto> toggleMenuItemStatus(@PathVariable String id) {
        log.info("PATCH /mobilewebservices/config/drawer-menu/{}/toggle - Toggling menu item status", id);

        try {
            DrawerMenuItemDto updated = remoteConfigService.toggleDrawerMenuItemStatus(id);
            log.info("Successfully toggled status for drawer menu item with ID: {}", id);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            log.warn("Invalid request: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("Error toggling drawer menu item status", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}

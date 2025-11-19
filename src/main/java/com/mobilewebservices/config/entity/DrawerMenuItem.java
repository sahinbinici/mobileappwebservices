package com.mobilewebservices.config.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "drawer_menu_items")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DrawerMenuItem {

    @Id
    @Column(length = 50)
    private String id;

    @Column(name = "title_key", nullable = false, length = 200)
    private String titleKey;

    @Column(nullable = false, length = 100)
    private String icon;

    @Column(length = 100)
    private String route;

    @Column(columnDefinition = "TEXT")
    private String url;

    @Column(nullable = false, length = 20)
    private String type; // 'navigation' or 'external'

    @Column(length = 7)
    private String color;

    @Column(name = "requires_login")
    private Boolean requiresLogin = false;

    @Column(name = "user_types", length = 100)
    private String userTypes; // Comma-separated: 'student,academic' or null

    @Column(name = "order_index")
    private Integer orderIndex = 0;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}

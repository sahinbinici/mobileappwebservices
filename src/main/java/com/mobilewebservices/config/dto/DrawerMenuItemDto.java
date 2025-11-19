package com.mobilewebservices.config.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DrawerMenuItemDto {

    @NotBlank(message = "ID is required")
    @Size(max = 50, message = "ID must not exceed 50 characters")
    private String id;

    @NotBlank(message = "Title key is required")
    @Size(max = 200, message = "Title key must not exceed 200 characters")
    private String titleKey;

    @NotBlank(message = "Icon is required")
    @Size(max = 100, message = "Icon name must not exceed 100 characters")
    private String icon;

    @Size(max = 100, message = "Route must not exceed 100 characters")
    private String route;

    private String url;

    @NotBlank(message = "Type is required")
    @Pattern(regexp = "^(navigation|external)$", message = "Type must be 'navigation' or 'external'")
    private String type;

    @Pattern(regexp = "^#[0-9A-Fa-f]{6}$", message = "Color must be a valid hex code (e.g., #CC0000)")
    private String color;

    private Boolean requiresLogin;

    private List<String> userTypes; // ['student', 'academic'] or null

    private Integer order;

    private Boolean isActive;
}

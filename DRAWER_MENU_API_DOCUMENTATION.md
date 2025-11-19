# Drawer Menu API Documentation

## Overview
This API provides dynamic configuration for the mobile app's drawer menu. Menu items can be managed remotely without requiring app updates.

## Database Setup

### 1. Run the SQL Script
Execute the `database_setup_drawer_menu.sql` script in your `remote_config` database:

```bash
psql -U your_username -d remote_config -f database_setup_drawer_menu.sql
```

This will:
- Create the `drawer_menu_items` table
- Add indexes for performance
- Insert default menu items
- Create update triggers

### 2. Verify Installation
```sql
SELECT * FROM drawer_menu_items ORDER BY order_index;
```

You should see 7 default menu items.

## API Endpoints

### Base URL
```
http://your-server:8080/mobilewebservices/config
```

### 1. Get Active Drawer Menu Items (Mobile App)
**Endpoint:** `GET /drawer_menu` or `GET /drawer-menu`

**Description:** Returns all active drawer menu items ordered by `order_index`. This is the main endpoint used by the mobile app.

**Response Example:**
```json
[
  {
    "id": "profile",
    "titleKey": "navigation.profile",
    "icon": "person-outline",
    "route": "Profile",
    "url": null,
    "type": "navigation",
    "color": "#003366",
    "requiresLogin": false,
    "userTypes": null,
    "order": 1,
    "isActive": true
  },
  {
    "id": "lessons",
    "titleKey": "navigation.lessons",
    "icon": "book-outline",
    "route": "Lessons",
    "url": null,
    "type": "navigation",
    "color": "#CC0000",
    "requiresLogin": true,
    "userTypes": ["student", "academic"],
    "order": 2,
    "isActive": true
  },
  {
    "id": "gaunHomepage",
    "titleKey": "navigation.gaunHomepage",
    "icon": "globe-outline",
    "route": null,
    "url": "https://www.gaziantep.edu.tr",
    "type": "external",
    "color": "#0099CC",
    "requiresLogin": false,
    "userTypes": null,
    "order": 7,
    "isActive": true
  }
]
```

**Caching:** Results are cached for 30 minutes.

---

### 2. Get All Drawer Menu Items (Admin)
**Endpoint:** `GET /drawer-menu/all`

**Description:** Returns all drawer menu items including inactive ones. For admin purposes.

**Response:** Same format as above, but includes inactive items.

---

### 3. Create Drawer Menu Item (Admin)
**Endpoint:** `POST /drawer-menu`

**Request Body:**
```json
{
  "id": "library",
  "titleKey": "navigation.library",
  "icon": "library-outline",
  "route": "Library",
  "type": "navigation",
  "color": "#0099CC",
  "requiresLogin": false,
  "userTypes": null,
  "order": 8,
  "isActive": true
}
```

**Response:** Returns the created item (201 Created).

---

### 4. Update Drawer Menu Item (Admin)
**Endpoint:** `PUT /drawer-menu/{id}`

**Request Body:** Same as create.

**Response:** Returns the updated item (200 OK).

---

### 5. Delete Drawer Menu Item (Admin)
**Endpoint:** `DELETE /drawer-menu/{id}`

**Response:** 204 No Content on success.

---

### 6. Toggle Active Status (Admin)
**Endpoint:** `PATCH /drawer-menu/{id}/toggle`

**Description:** Toggles the `isActive` status of a menu item.

**Response:** Returns the updated item with toggled status.

---

## Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique identifier (max 50 chars) |
| `titleKey` | string | Yes | i18n translation key (e.g., "navigation.profile") |
| `icon` | string | Yes | Ionicons icon name (e.g., "person-outline") |
| `route` | string | No | Navigation route name (for type='navigation') |
| `url` | string | No | External URL (for type='external') |
| `type` | string | Yes | Either "navigation" or "external" |
| `color` | string | No | Hex color code (e.g., "#003366") |
| `requiresLogin` | boolean | No | Whether login is required (default: false) |
| `userTypes` | array | No | User types that can see this item: ["student", "academic"] or null for all |
| `order` | integer | No | Display order (default: 0) |
| `isActive` | boolean | No | Whether item is active (default: true) |

---

## Menu Item Types

### Navigation Items
- **type:** `"navigation"`
- **route:** Must match a screen name in `DrawerNavigator.tsx`
- **url:** Should be `null`

Example:
```json
{
  "id": "profile",
  "titleKey": "navigation.profile",
  "icon": "person-outline",
  "route": "Profile",
  "type": "navigation",
  "color": "#003366"
}
```

### External Link Items
- **type:** `"external"`
- **url:** Full URL to open in browser
- **route:** Should be `null`

Example:
```json
{
  "id": "gaunHomepage",
  "titleKey": "navigation.gaunHomepage",
  "icon": "globe-outline",
  "url": "https://www.gaziantep.edu.tr",
  "type": "external",
  "color": "#0099CC"
}
```

---

## User Type Filtering

### Available User Types
- `"student"` - Students only
- `"academic"` - Academic staff only
- `null` or empty - All users

### Examples

**Student-only menu item:**
```json
{
  "id": "advisor",
  "titleKey": "advisor.title",
  "userTypes": ["student"],
  "requiresLogin": true
}
```

**Academic-only menu item:**
```json
{
  "id": "advisedStudents",
  "titleKey": "advisedStudents.menuTitle",
  "userTypes": ["academic"],
  "requiresLogin": true
}
```

**Both students and academics:**
```json
{
  "id": "lessons",
  "titleKey": "navigation.lessons",
  "userTypes": ["student", "academic"],
  "requiresLogin": true
}
```

**All users (including guests):**
```json
{
  "id": "profile",
  "titleKey": "navigation.profile",
  "userTypes": null,
  "requiresLogin": false
}
```

---

## Default Menu Items

The system comes with 7 pre-configured menu items:

1. **Profile** - User profile (all users)
2. **Lessons** - Student/academic lessons (requires login)
3. **Advisor** - Academic advisor (students only, requires login)
4. **Advised Students** - Student list (academics only, requires login)
5. **Snap & Send** - Photo submission (students/academics, requires login)
6. **Useful Links** - Useful links page (all users)
7. **GAÜN Homepage** - External link to university website (all users)

---

## Mobile App Integration

### Frontend Implementation
The mobile app automatically fetches and displays drawer menu items from this API:

1. **Endpoint:** `GET /mobilewebservices/config/drawer_menu`
2. **Caching:** Results cached for 1 hour on mobile
3. **Fallback:** If API fails, uses hardcoded default menu
4. **Filtering:** App filters items based on:
   - `isActive` status
   - `requiresLogin` + user login state
   - `userTypes` + current user type

### Text Translation
- Menu titles are NOT stored in the API
- `titleKey` field references i18n translation keys
- Translations stored in mobile app's `tr.json` / `en.json`
- Example: `titleKey: "navigation.profile"` → `t('navigation.profile')` → "Profil" (TR) / "Profile" (EN)

---

## Cache Management

### Cache Duration
- **Mobile App:** 1 hour
- **Backend:** 30 minutes

### Clear Cache
To force cache refresh after making changes:

**Endpoint:** `POST /useful/config/cache/clear`

This clears all remote config caches including drawer menu items.

---

## Testing

### Test Active Items
```bash
curl http://localhost:8080/mobilewebservices/config/drawer_menu
```

### Test All Items (Admin)
```bash
curl http://localhost:8080/mobilewebservices/config/drawer-menu/all
```

### Create New Item
```bash
curl -X POST http://localhost:8080/mobilewebservices/config/drawer-menu \
  -H "Content-Type: application/json" \
  -d '{
    "id": "test",
    "titleKey": "navigation.test",
    "icon": "star-outline",
    "route": "TestScreen",
    "type": "navigation",
    "color": "#FF0000",
    "order": 99,
    "isActive": true
  }'
```

### Toggle Status
```bash
curl -X PATCH http://localhost:8080/mobilewebservices/config/drawer-menu/test/toggle
```

### Delete Item
```bash
curl -X DELETE http://localhost:8080/mobilewebservices/config/drawer-menu/test
```

---

## Database Queries

### Get Student-Visible Items
```sql
SELECT * FROM drawer_menu_items 
WHERE is_active = TRUE 
AND (user_types IS NULL OR user_types LIKE '%student%')
ORDER BY order_index;
```

### Get Academic-Visible Items
```sql
SELECT * FROM drawer_menu_items 
WHERE is_active = TRUE 
AND (user_types IS NULL OR user_types LIKE '%academic%')
ORDER BY order_index;
```

### Reorder Items
```sql
UPDATE drawer_menu_items SET order_index = 1 WHERE id = 'profile';
UPDATE drawer_menu_items SET order_index = 2 WHERE id = 'lessons';
-- etc.
```

---

## Error Handling

### Common Errors

**404 Not Found**
- Menu item with specified ID doesn't exist

**400 Bad Request**
- Invalid request body
- Missing required fields
- Invalid field values (e.g., wrong type)

**409 Conflict**
- Trying to create item with existing ID

**500 Internal Server Error**
- Database connection issues
- Unexpected server errors

---

## Best Practices

1. **Always use unique IDs** - Use descriptive, lowercase IDs
2. **Set appropriate order** - Leave gaps (1, 5, 10, 15) for future insertions
3. **Test before activating** - Create items as inactive first, test, then activate
4. **Match route names** - Ensure `route` matches actual screen names in mobile app
5. **Use meaningful titleKeys** - Follow existing i18n key patterns
6. **Clear cache after changes** - Use cache clear endpoint for immediate updates
7. **Backup before bulk changes** - Export table before major modifications

---

## Troubleshooting

### Menu not updating in app
1. Check if item is active: `SELECT * FROM drawer_menu_items WHERE id = 'your-id';`
2. Clear backend cache: `POST /useful/config/cache/clear`
3. Force refresh in mobile app (pull to refresh)
4. Check mobile app logs for API errors

### Item not showing for specific user type
1. Verify `user_types` field: `SELECT id, user_types FROM drawer_menu_items;`
2. Check if user is logged in (for `requiresLogin: true` items)
3. Verify user type matches (student/academic)

### External link not opening
1. Verify URL is complete with protocol: `https://example.com`
2. Check `type` is set to `"external"`
3. Ensure `route` is `null` for external items

---

## Support

For issues or questions:
1. Check logs: `tail -f logs/mobilewebservices.log`
2. Verify database connection
3. Test API endpoints with curl/Postman
4. Review mobile app console logs

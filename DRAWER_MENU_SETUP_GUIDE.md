# Drawer Menu API - Quick Setup Guide

## What Was Created

### Backend Files Created:
1. **Entity:** `DrawerMenuItem.java` - Database model
2. **DTO:** `DrawerMenuItemDto.java` - API response/request model
3. **Repository:** `DrawerMenuItemRepository.java` - Database access
4. **Service:** Updated `RemoteConfigService.java` - Business logic
5. **Controller:** `DrawerMenuController.java` - REST endpoints
6. **Config:** Updated `CacheConfig.java` - Added cache support
7. **SQL:** `database_setup_drawer_menu.sql` - Database setup script
8. **Docs:** `DRAWER_MENU_API_DOCUMENTATION.md` - Full API documentation

### Frontend Files (Already Updated):
1. **API Config:** `src/config/api.ts` - Added endpoint
2. **Service:** `src/services/remoteConfigService.ts` - Added drawer menu methods
3. **Component:** `src/components/CustomDrawer/CustomDrawerContent.tsx` - Now uses API

---

## Quick Start

### Step 1: Setup Database
```bash
# Connect to your PostgreSQL database
psql -U your_username -d remote_config

# Run the setup script
\i database_setup_drawer_menu.sql

# Verify
SELECT * FROM drawer_menu_items ORDER BY order_index;
```

### Step 2: Build & Deploy Backend
```bash
cd C:\Users\cdikici\IdeaProjects\mobileswebservices

# Build the project
mvn clean package

# Deploy (use your existing deployment method)
# The new endpoints will be automatically available
```

### Step 3: Test the API
```bash
# Test the main endpoint (what mobile app uses)
curl http://localhost:8080/mobilewebservices/config/drawer_menu

# Should return JSON array with 7 default menu items
```

### Step 4: Test Mobile App
```bash
cd C:\Users\cdikici\Desktop\GaunMobil

# Run the app
npm start

# Open drawer menu - should load from API
# If API is not available, will use fallback menu
```

---

## API Endpoint

### Main Endpoint (Mobile App)
```
GET http://your-server:8080/mobilewebservices/config/drawer_menu
```

**Response:**
```json
[
  {
    "id": "profile",
    "titleKey": "navigation.profile",
    "icon": "person-outline",
    "route": "Profile",
    "type": "navigation",
    "color": "#003366",
    "requiresLogin": false,
    "userTypes": null,
    "order": 1,
    "isActive": true
  }
  // ... more items
]
```

---

## How It Works

### Backend Flow:
1. Mobile app calls `GET /config/drawer_menu`
2. `DrawerMenuController` receives request
3. `RemoteConfigService` checks cache
4. If cache miss, queries database via `DrawerMenuItemRepository`
5. Converts entities to DTOs
6. Returns JSON response
7. Caches result for 30 minutes

### Frontend Flow:
1. `CustomDrawerContent` component mounts
2. Calls `remoteConfigService.getDrawerMenuItems()`
3. Service calls API endpoint
4. Caches response for 1 hour
5. If API fails, uses fallback menu
6. Converts `titleKey` to localized text via `t(titleKey)`
7. Filters by `requiresLogin` and `userTypes`
8. Renders menu items

---

## Default Menu Items

| ID | Title Key | Icon | Type | Login Required | User Types |
|----|-----------|------|------|----------------|------------|
| profile | navigation.profile | person-outline | navigation | No | All |
| lessons | navigation.lessons | book-outline | navigation | Yes | student, academic |
| advisor | advisor.title | person-circle-outline | navigation | Yes | student |
| advisedStudents | advisedStudents.menuTitle | people-outline | navigation | Yes | academic |
| snapAndSend | navigation.snapAndSend | camera-outline | navigation | Yes | student, academic |
| usefulLinks | navigation.usefulLinks | link-outline | navigation | No | All |
| gaunHomepage | navigation.gaunHomepage | globe-outline | external | No | All |

---

## Managing Menu Items

### Add New Menu Item
```sql
INSERT INTO drawer_menu_items 
(id, title_key, icon, route, type, color, requires_login, user_types, order_index, is_active)
VALUES 
('library', 'navigation.library', 'library-outline', 'Library', 'navigation', '#0099CC', FALSE, NULL, 8, TRUE);
```

### Update Menu Item
```sql
UPDATE drawer_menu_items 
SET color = '#FF0000', order_index = 5 
WHERE id = 'library';
```

### Disable Menu Item
```sql
UPDATE drawer_menu_items 
SET is_active = FALSE 
WHERE id = 'library';
```

### Delete Menu Item
```sql
DELETE FROM drawer_menu_items 
WHERE id = 'library';
```

### Clear Cache (Force Update)
```bash
curl -X POST http://localhost:8080/mobilewebservices/useful/config/cache/clear
```

---

## Important Notes

### Text Translations
- Menu item **titles are NOT in the API**
- API only provides `titleKey` (e.g., "navigation.profile")
- Mobile app translates using i18n: `t('navigation.profile')`
- Add new translations to:
  - `GaunMobil/src/i18n/locales/tr.json`
  - `GaunMobil/src/i18n/locales/en.json`

### Route Names
- `route` field must match screen names in `DrawerNavigator.tsx`
- Available routes:
  - Profile, Lessons, Advisor, AdvisedStudents
  - SnapAndSend, UsefulLinks, etc.

### User Type Filtering
- `null` or empty = All users (including guests)
- `"student"` = Students only
- `"academic"` = Academic staff only
- `"student,academic"` = Both (comma-separated in DB)

---

## Troubleshooting

### Menu not updating in mobile app?
1. Clear backend cache: `POST /useful/config/cache/clear`
2. Force refresh in app (pull to refresh)
3. Check API response: `curl http://localhost:8080/mobilewebservices/config/drawer_menu`

### New menu item not showing?
1. Check `is_active = TRUE`
2. Check `requires_login` vs user login state
3. Check `user_types` matches current user
4. Verify `route` exists in `DrawerNavigator.tsx`

### API returning 500 error?
1. Check database connection
2. Verify table exists: `\dt drawer_menu_items`
3. Check backend logs: `tail -f logs/mobilewebservices.log`

---

## Next Steps

1. ✅ Database setup complete
2. ✅ Backend code complete
3. ✅ Frontend code complete
4. 🔄 Deploy backend
5. 🔄 Test API endpoint
6. 🔄 Test mobile app
7. 🔄 Add custom menu items (optional)

---

## Full Documentation

See `DRAWER_MENU_API_DOCUMENTATION.md` for:
- Complete API reference
- All endpoints (CRUD operations)
- Field descriptions
- Examples
- Best practices
- Advanced usage

---

## Summary

You now have a **fully dynamic drawer menu** system:
- ✅ Menu items managed via database
- ✅ No app updates needed to change menu
- ✅ User type filtering (student/academic)
- ✅ Login requirement support
- ✅ External links support
- ✅ Caching for performance
- ✅ Fallback for offline/errors
- ✅ i18n support for multiple languages

The mobile app will automatically fetch and display menu items from the API!

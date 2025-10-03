# Navigation Structure & Status Indicator Update

## Overview
Restructured the entire app to use a persistent sidebar and top bar layout with dynamic content switching, similar to modern admin panels. Added an online/offline status indicator in the top bar.

## New Navigation Structure

### Main Layout (`main_layout_screen.dart`)
- **Persistent Components:**
  - Top bar (AppBar) - stays visible on all pages
  - Sidebar (left menu) - stays visible on all pages
  - Online/Offline status indicator - always visible in top bar
  
- **Dynamic Content Area:**
  - Middle container changes based on sidebar selection
  - Only the page content switches, layout remains constant

### Pages/Screens

1. **Dashboard** (Index 0)
   - Overview with stats cards
   - Total scans, successful, errors
   - Recent activity list

2. **QR Scanner** (Index 1)
   - Camera preview moved to dedicated page
   - Scanner controls
   - Member info display
   - Status overview

3. **Check-ins** (Index 2)
   - Analytics and statistics
   - Check-in trends

4. **History** (Index 3)
   - Activity history
   - Scan logs

5. **Search** (Index 4)
   - Member search functionality

6. **Settings** (Index 5)
   - App configuration

## Online/Offline Status Indicator

### Location
- Top bar (AppBar)
- Left side, before notification icon

### Features
- **Visual Indicator:**
  - Green dot with glow effect when online
  - Red dot with glow effect when offline
  - Text label: "Online" or "Offline"
  
- **Styling:**
  - Background color changes based on status
  - Border color matches status
  - Animated glow effect on the status dot
  - Uses app theme colors (success/error)

### Implementation
- Uses `offlineProvider` to watch connectivity state
- Automatically updates when connection status changes
- Connected to `ConnectivityService` which monitors network status

## Updated Sidebar Navigation

### Menu Items
1. Dashboard (home icon)
2. QR Scanner (QR code icon) - NEW
3. Check-ins (trending up icon)
4. History (history icon)
5. Search (search icon)
6. Settings (settings icon)

### Active State
- Highlighted with cyan/turquoise gradient background
- Icon and text color changes to primary color
- Visual feedback for current page

## File Changes

### New Files Created
1. `lib/screens/main_layout_screen.dart` - Main layout with persistent sidebar/topbar
2. `lib/screens/dashboard_screen.dart` - Dashboard page content
3. `lib/screens/scanner_screen.dart` - QR scanner page content

### Modified Files
1. `lib/widgets/modern_sidebar_widget.dart`
   - Changed callback structure to use index-based navigation
   - Added `selectedIndex` and `onNavigate` parameters
   - Removed individual callback parameters

2. `lib/screens/splash_screen.dart`
   - Updated to navigate to `MainLayoutScreen` instead of `HomeScreen`

### Deleted Files
1. `lib/screens/home_screen.dart` - Replaced by new structure

## User Experience Improvements

### Better Navigation
- No more full-page navigation (no push/pop)
- Instant page switching
- Consistent layout reduces cognitive load
- Navigation state is preserved

### Visual Feedback
- Always know which page you're on (highlighted in sidebar)
- Always know connection status (top bar indicator)
- Smooth transitions between pages

### Performance
- Only content area re-renders on navigation
- Sidebar and top bar remain static
- Reduced widget rebuilds

## Color Scheme Integration
- Status indicator uses new cyan/turquoise theme colors
- Success: `#00E6A6` (bright green)
- Error: `#FF6B6B` (red)
- Matches admin panel design language

## Technical Details

### State Management
- Uses Riverpod for state management
- `offlineProvider` watches connectivity status
- Real-time updates without manual polling

### Connectivity Monitoring
- `ConnectivityService` monitors network changes
- `connectivity_plus` package for cross-platform support
- Broadcast stream for multiple listeners

### Layout Structure
```
MainLayoutScreen
├── AppBar (Top Bar)
│   ├── Logo
│   ├── Status Indicator (NEW)
│   ├── Notifications
│   └── User Profile
├── Body
│   ├── Sidebar (Persistent)
│   └── Content Area (Dynamic)
│       └── [Current Page Widget]
```

## Benefits

1. **Consistent UX** - Layout never changes, only content
2. **Modern Design** - Matches admin panel aesthetics
3. **Clear Status** - Always know if you're connected
4. **Easy Navigation** - Single-click page switching
5. **Maintainable** - Centralized layout management
6. **Scalable** - Easy to add new pages

## Next Steps (Potential)

- Add page transition animations
- Implement breadcrumb navigation
- Add keyboard shortcuts for navigation
- Persist last visited page
- Add loading states for page content


# Search Functionality - Med Shakthi App

## Overview
Comprehensive search functionality has been added to the Med Shakthi application, allowing users to search for medicines and medical devices across the app.

## Features Implemented

### 1. **Global Search Page** (`search_page.dart`)
- **Location**: `lib/src/features/search/search_page.dart`
- **Access**: Tap the search bar on the home screen
- **Features**:
  - Real-time search across both medicines and devices
  - Search by:
    - Medicine name, manufacturer, composition, and uses
    - Device name, manufacturer, and model number
  - Popular search suggestions
  - Recent search history
  - Categorized results (medicines vs devices)
  - Detailed item views with bottom sheets
  - Wishlist integration for medicines
  - Empty state with helpful messaging

### 2. **Home Screen Search Bar**
- **Location**: `lib/src/features/dashboard/pharmacy_home_screen.dart`
- **Features**:
  - Tappable search bar in the top navigation
  - Opens the global search page
  - Visual feedback on tap

### 3. **Medicines Page Search** (`category_products_page.dart`)
- **Location**: `lib/src/features/category/category_products_page.dart`
- **Features**:
  - Toggle search icon in the app bar
  - In-page search field when activated
  - Real-time filtering of medicines
  - Search by:
    - Medicine name
    - Manufacturer
    - Composition
  - Clear button to reset search
  - Empty state when no results found

### 4. **Devices Page Search** (`devices_page.dart`)
- **Location**: `lib/src/features/category/devices_page.dart`
- **Features**:
  - Toggle search icon in the app bar
  - In-page search field when activated
  - Real-time filtering of devices
  - Search by:
    - Device name
    - Manufacturer
    - Model number
  - Clear button to reset search
  - Empty state when no results found

## User Experience Flow

### Global Search Flow:
1. User taps search bar on home screen
2. Search page opens with keyboard ready
3. User types query
4. Results appear in real-time
5. User can tap on any result to view details
6. User can add medicines to wishlist from search results

### In-Page Search Flow:
1. User navigates to Medicines or Devices page
2. User taps search icon in app bar
3. Search field appears with keyboard
4. User types query
5. Grid view filters in real-time
6. User can tap X to close search and reset

## Technical Implementation

### Search Algorithm
- Case-insensitive matching
- Substring matching (contains)
- Multi-field search (name, manufacturer, composition, etc.)
- Efficient filtering using Dart's `where()` method

### State Management
- Local state using `setState()`
- TextEditingController for search input
- Separate filtered lists to maintain original data
- Boolean flags for search mode toggling

### Performance Considerations
- Data loaded once from CSV files
- Filtering happens in memory (fast)
- Debouncing not needed due to efficient filtering
- Lazy loading with ListView/GridView builders

## Data Sources
- **Medicines**: `assets/data/Medicine_Details.csv`
- **Devices**: `assets/data/medical_device_manuals_dataset.csv`

## UI Components

### Search Bar Styles
- Rounded corners (30px radius for home, 25px for search page)
- Light gray background
- Search icon prefix
- Clear button suffix (when text present)
- Placeholder text with gray color

### Result Cards
- **Medicines**: Image, name, manufacturer, rating, price, wishlist button
- **Devices**: Icon, badge, name, manufacturer, model number

### Empty States
- Search icon (64px)
- Contextual message
- Gray color scheme

## Future Enhancements (Suggestions)
1. Search history persistence (local storage)
2. Voice search integration
3. Barcode/QR code scanning
4. Search filters (price range, rating, etc.)
5. Search suggestions/autocomplete
6. Recently viewed items
7. Search analytics
8. Fuzzy matching for typos
9. Search result sorting options
10. Save favorite searches

## Testing Checklist
- [ ] Search bar on home screen opens search page
- [ ] Global search returns results for medicines
- [ ] Global search returns results for devices
- [ ] Search works with partial matches
- [ ] Search is case-insensitive
- [ ] Clear button resets search
- [ ] Empty state shows when no results
- [ ] Medicines page search filters correctly
- [ ] Devices page search filters correctly
- [ ] Search toggle works on both pages
- [ ] Wishlist integration works from search
- [ ] Detail views open from search results

## Files Modified/Created

### Created:
- `lib/src/features/search/search_page.dart` - Global search page

### Modified:
- `lib/src/features/dashboard/pharmacy_home_screen.dart` - Added search navigation
- `lib/src/features/category/category_products_page.dart` - Added in-page search
- `lib/src/features/category/devices_page.dart` - Added in-page search

## Dependencies
No new dependencies required. Uses existing packages:
- `flutter/material.dart` - UI components
- `flutter/services.dart` - Asset loading
- `csv` - CSV parsing
- `provider` - State management (for wishlist)

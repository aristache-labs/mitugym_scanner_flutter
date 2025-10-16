# Gym Schedule API Implementation Guide

## Overview
The Flutter app now fetches gym opening hours from the backend to display the traffic chart only during operating hours. This allows gym administrators to manage the schedule from the web panel, and the chart will automatically adjust.

## API Endpoint

### **GET** `/api/gym-schedule`

Fetches the gym schedule for a specific day of the week.

#### Query Parameters
- `api_key` (string, required) - API key for authentication
- `day` (string, required) - Day of the week in lowercase: `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday`, `sunday`

#### Response Format

**Success Response (200 OK):**
```json
{
  "success": true,
  "schedule": {
    "id": "schedule-123",
    "day_of_week": "monday",
    "open_time": "06:00",
    "close_time": "22:00",
    "is_closed": false
  }
}
```

**Closed Day Response (200 OK):**
```json
{
  "success": true,
  "schedule": {
    "id": "schedule-124",
    "day_of_week": "sunday",
    "open_time": null,
    "close_time": null,
    "is_closed": true
  }
}
```

**Error Response (400/500):**
```json
{
  "success": false,
  "error": "Invalid API key"
}
```

## Database Table: `gym_schedule`

Suggested table structure:

```sql
CREATE TABLE gym_schedule (
  id VARCHAR(255) PRIMARY KEY,
  location_id VARCHAR(255) NOT NULL,
  day_of_week VARCHAR(20) NOT NULL, -- monday, tuesday, etc.
  open_time TIME NULL, -- 24-hour format (e.g., '06:00:00')
  close_time TIME NULL, -- 24-hour format (e.g., '22:00:00')
  is_closed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_location_day (location_id, day_of_week),
  FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE
);
```

## Expected Behavior

### Time Format
- Use 24-hour format for times: `"HH:MM"` (e.g., `"06:00"`, `"22:00"`)
- The app will parse the hour portion to determine operating hours

### Closed Days
- If `is_closed` is `true`, the chart will not show any data for that day
- `open_time` and `close_time` can be `null` when `is_closed` is `true`

### Overnight Schedules
- The app supports overnight schedules (e.g., `22:00` to `02:00`)
- If close time is earlier than open time, it's interpreted as crossing midnight

### Default Behavior
- If the API endpoint is not available or returns an error, the chart defaults to showing all 24 hours (00:00 - 23:00)
- This ensures the app continues to work even if the schedule feature is not implemented yet

## Example Schedules

### Typical Gym (Mon-Sat: 6am-10pm, Sun: Closed)
```json
[
  {"day_of_week": "monday", "open_time": "06:00", "close_time": "22:00", "is_closed": false},
  {"day_of_week": "tuesday", "open_time": "06:00", "close_time": "22:00", "is_closed": false},
  {"day_of_week": "wednesday", "open_time": "06:00", "close_time": "22:00", "is_closed": false},
  {"day_of_week": "thursday", "open_time": "06:00", "close_time": "22:00", "is_closed": false},
  {"day_of_week": "friday", "open_time": "06:00", "close_time": "22:00", "is_closed": false},
  {"day_of_week": "saturday", "open_time": "08:00", "close_time": "20:00", "is_closed": false},
  {"day_of_week": "sunday", "open_time": null, "close_time": null, "is_closed": true}
]
```

### 24/7 Gym
```json
[
  {"day_of_week": "monday", "open_time": "00:00", "close_time": "23:59", "is_closed": false},
  // ... same for all days
]
```

## Web Panel Integration

The web panel should allow administrators to:
1. Set opening and closing times for each day of the week
2. Mark specific days as closed
3. Support special hours for holidays (future enhancement)
4. Changes should take effect immediately for all connected scanner apps

## Testing

Test the API with:
```bash
curl "https://your-api.com/api/gym-schedule?api_key=YOUR_KEY&day=monday"
```

Expected behaviors to test:
- ✅ Returns correct schedule for each day
- ✅ Handles closed days properly
- ✅ Returns error for invalid API key
- ✅ Returns error for invalid day name
- ✅ Handles missing schedule gracefully


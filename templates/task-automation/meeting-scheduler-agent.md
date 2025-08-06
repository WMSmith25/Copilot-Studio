# Meeting Scheduler Agent Template

An intelligent task automation agent that handles meeting scheduling, room booking, and calendar management across Microsoft 365.

## Agent Overview

**Purpose**: Automate meeting scheduling, room booking, and calendar coordination
**Target Users**: All employees who schedule meetings
**Integration**: Outlook, Microsoft Graph, Exchange, Teams

## Agent Configuration

### Basic Settings

```yaml
Agent Name: Meeting Assistant
Description: Smart meeting scheduler and calendar coordinator
Language: English (US)
Tone: Efficient and helpful
Automation Level: High (minimal user intervention)
```

### Core Topics

#### 1. Welcome Topic

```yaml
Topic: Welcome
Trigger: Agent start, greeting phrases
Message: |
  Hello! 📅 I'm your Meeting Assistant. I can help you:
  
  • Schedule meetings with automatic availability checking
  • Book conference rooms and resources
  • Send meeting invitations and manage responses
  • Reschedule or cancel meetings
  • Find optimal meeting times for groups
  
  What would you like me to help you with?

Quick Replies:
  - "Schedule a meeting"
  - "Find available rooms"
  - "Check my calendar"
  - "Cancel a meeting"
```

#### 2. Schedule Meeting Topic

```yaml
Topic: Schedule Meeting
Trigger Phrases:
  - "schedule a meeting"
  - "book a meeting"
  - "set up a call"
  - "arrange a meeting"
  - "plan a meeting"

Variables:
  - Meeting.Title: Text
  - Meeting.Duration: Choice (30min, 1hr, 1.5hr, 2hr, Custom)
  - Meeting.Attendees: Text (email addresses)
  - Meeting.PreferredDate: DateTime
  - Meeting.PreferredTime: Time
  - Meeting.Location: Choice (InPerson, Teams, Hybrid)
  - Meeting.Room: Choice (RoomTypes)
  - Meeting.Priority: Choice (Normal, High, Urgent)

Conversation Flow:
  Step 1: Collect Meeting Details
    Message: "Great! Let's schedule your meeting. What's the meeting title or subject?"
    Collect: Meeting.Title
    
  Step 2: Get Duration
    Message: "How long should the meeting be?"
    Quick Replies: ["30 minutes", "1 hour", "1.5 hours", "2 hours", "Other"]
    Collect: Meeting.Duration
    
  Step 3: Add Attendees
    Message: |
      Who should I invite? You can provide:
      • Email addresses (john@company.com, jane@company.com)
      • Names (I'll look them up in the directory)
      • Distribution lists
    Collect: Meeting.Attendees
    
  Step 4: Choose Format
    Message: "Will this be an in-person meeting, Teams call, or hybrid?"
    Quick Replies: ["In-person", "Teams call", "Hybrid"]
    Collect: Meeting.Location
    
  Step 5: Find Time Slot
    Call Action: Find_Available_Times
    If Available_Times_Found:
      Message: |
        I found these available times when everyone is free:
        
        🕐 {Time_Option_1} - {Date_Option_1}
        🕑 {Time_Option_2} - {Date_Option_2}
        🕒 {Time_Option_3} - {Date_Option_3}
        
        Which time works best?
    Else:
      Message: |
        I couldn't find a time when everyone is available. Options:
        • See times with partial availability
        • Suggest alternative attendees
        • Schedule for a different week
        • Proceed with conflicts noted
        
  Step 6: Book Room (if in-person)
    If Meeting.Location = "In-person" OR "Hybrid":
      Call Action: Find_Available_Rooms
      Message: |
        I found these available rooms:
        
        🏢 Conference Room A (8 people) - Projector, Whiteboard
        🏢 Conference Room B (12 people) - Video conferencing, Projector
        🏢 Huddle Room 1 (4 people) - TV screen, Phone
        
        Which room would you prefer?
        
  Step 7: Final Confirmation
    Message: |
      Perfect! Here's your meeting summary:
      
      📋 **Meeting Details:**
      • Title: {Meeting.Title}
      • Date & Time: {Meeting.DateTime}
      • Duration: {Meeting.Duration}
      • Location: {Meeting.Room} / Teams
      • Attendees: {Meeting.Attendees}
      
      Should I send the invitations?
      
    If User_Confirms:
      Call Action: Create_Meeting
      Call Action: Send_Invitations
      Message: |
        ✅ Meeting scheduled successfully!
        
        **Next Steps:**
        • Invitations sent to all attendees
        • Room reserved: {Meeting.Room}
        • Teams link created (if applicable)
        • Calendar events created
        
        Meeting ID: {Meeting.ID}
```

#### 3. Find Available Rooms Topic

```yaml
Topic: Find Available Rooms
Trigger Phrases:
  - "find a room"
  - "book a conference room"
  - "available meeting rooms"
  - "room booking"

Variables:
  - Room.DateTime: DateTime
  - Room.Duration: Number
  - Room.Capacity: Number
  - Room.Equipment: MultiChoice (Projector, Whiteboard, Video, Phone)
  - Room.Building: Choice (BuildingList)

Conversation Flow:
  Step 1: Get Requirements
    Message: "I'll help you find the perfect room! When do you need it?"
    Collect: Room.DateTime
    
    Message: "How long will you need the room?"
    Collect: Room.Duration
    
    Message: "How many people will attend?"
    Collect: Room.Capacity
    
  Step 2: Equipment Needs
    Message: "Do you need any special equipment?"
    Quick Replies: ["Projector", "Video conferencing", "Whiteboard", "Nothing special"]
    Collect: Room.Equipment
    
  Step 3: Search and Present Options
    Call Action: Search_Available_Rooms
    
    If Rooms_Found:
      Message: |
        Here are available rooms matching your criteria:
        
        {ForEach Room in Available_Rooms:
          🏢 **{Room.Name}**
          • Capacity: {Room.Capacity} people
          • Equipment: {Room.Equipment}
          • Building: {Room.Building}
          • Floor: {Room.Floor}
          [Book This Room]
        }
        
    Else:
      Message: |
        No rooms match your exact criteria. Here are some alternatives:
        • Different time slots with your preferred rooms
        • Rooms with slightly different capacity
        • Rooms in other buildings
        
        Would you like to see these options?
        
  Step 4: Book Selected Room
    Call Action: Reserve_Room
    Message: |
      ✅ Room booked successfully!
      
      **Booking Details:**
      • Room: {Room.Name}
      • Date & Time: {Room.DateTime}
      • Duration: {Room.Duration}
      • Booking ID: {Booking.ID}
      
      Would you like me to create a meeting invitation for this room?
```

#### 4. Reschedule Meeting Topic

```yaml
Topic: Reschedule Meeting
Trigger Phrases:
  - "reschedule meeting"
  - "change meeting time"
  - "move meeting"
  - "different time"

Variables:
  - Original.MeetingID: Text
  - New.DateTime: DateTime
  - Reschedule.Reason: Text
  - Notify.Attendees: Boolean

Conversation Flow:
  Step 1: Identify Meeting
    Message: |
      I can help you reschedule a meeting. Which meeting would you like to change?
      You can provide:
      • Meeting title
      • Meeting ID
      • Date and partial title
      
    Collect: Original.MeetingID
    Call Action: Find_Meeting
    
  Step 2: Confirm Meeting Found
    Message: |
      Found this meeting:
      
      📋 **{Meeting.Title}**
      • Current time: {Meeting.DateTime}
      • Attendees: {Meeting.AttendeeCount} people
      • Location: {Meeting.Location}
      
      Is this the right meeting?
      
  Step 3: Find New Time
    Message: "When would you like to reschedule it to?"
    
    Quick Replies: 
      - "Tomorrow same time"
      - "Next week same time"
      - "Let me pick a time"
      - "Find when everyone is free"
      
    If "Find when everyone is free":
      Call Action: Find_Available_Times_For_Attendees
      Present time options similar to Schedule Meeting
      
  Step 4: Update Meeting
    Call Action: Update_Meeting
    Call Action: Send_Reschedule_Notifications
    
    Message: |
      ✅ Meeting rescheduled successfully!
      
      **Updated Details:**
      • New time: {New.DateTime}
      • All attendees notified
      • Room updated (if applicable)
      • Calendar events updated
      
      Reschedule ID: {Reschedule.ID}
```

#### 5. Cancel Meeting Topic

```yaml
Topic: Cancel Meeting
Trigger Phrases:
  - "cancel meeting"
  - "delete meeting"
  - "remove meeting"
  - "meeting cancelled"

Variables:
  - Cancel.MeetingID: Text
  - Cancel.Reason: Text
  - Cancel.NotifyAttendees: Boolean

Conversation Flow:
  Step 1: Identify Meeting
    Message: "Which meeting would you like to cancel?"
    Collect: Cancel.MeetingID
    Call Action: Find_Meeting
    
  Step 2: Confirm Cancellation
    Message: |
      ⚠️ **Confirm Cancellation**
      
      📋 **{Meeting.Title}**
      • Time: {Meeting.DateTime}
      • Attendees: {Meeting.AttendeeCount} people
      • Room: {Meeting.Room}
      
      Are you sure you want to cancel this meeting?
      
  Step 3: Cancellation Reason (Optional)
    Message: "Would you like to include a reason for the cancellation?"
    Collect: Cancel.Reason (Optional)
    
  Step 4: Process Cancellation
    Call Action: Cancel_Meeting
    Call Action: Release_Room
    Call Action: Send_Cancellation_Notifications
    
    Message: |
      ✅ Meeting cancelled successfully!
      
      **Actions Completed:**
      • Meeting removed from all calendars
      • Attendees notified of cancellation
      • Room booking cancelled
      • Resources released
      
      Cancellation ID: {Cancel.ID}
```

## Power Automate Flows

### Find Available Times Flow

```yaml
Flow Name: Find_Available_Times
Trigger: When called from copilot
Inputs:
  - Attendee_Emails: Array
  - Meeting_Duration: Number
  - Preferred_Date_Range: Object
  - Meeting_Priority: Text

Actions:
  1. Get Free/Busy Information
     - For each attendee in Attendee_Emails
     - Call Microsoft Graph Calendar API
     - Get availability for date range
     
  2. Calculate Available Slots
     - Find common free time blocks
     - Consider meeting duration
     - Apply business hours filter
     - Sort by preference score
     
  3. Check Room Availability
     - For each potential time slot
     - Query room booking system
     - Filter by capacity and equipment needs
     
  4. Return Results
     - Top 5 time options
     - Include confidence scores
     - Provide alternative suggestions
```

### Create Meeting Flow

```yaml
Flow Name: Create_Meeting
Trigger: When called from copilot
Inputs:
  - Meeting_Details: Object
  - Attendee_List: Array
  - Room_Booking: Object
  - Teams_Required: Boolean

Actions:
  1. Create Calendar Event
     - Use Microsoft Graph Calendar API
     - Set meeting details and attendees
     - Add room as resource
     
  2. Generate Teams Meeting (if required)
     - Create Teams meeting link
     - Add to calendar event
     - Configure meeting options
     
  3. Send Invitations
     - For each attendee
     - Send calendar invitation
     - Include agenda and details
     
  4. Book Room
     - Reserve room in booking system
     - Set up equipment requests
     - Add catering if requested
     
  5. Create Follow-up Reminders
     - 24-hour reminder
     - 1-hour reminder
     - Post-meeting follow-up prompt
```

### Room Management Flow

```yaml
Flow Name: Search_Available_Rooms
Trigger: When called from copilot
Inputs:
  - DateTime_Start: DateTime
  - Duration_Minutes: Number
  - Capacity_Required: Number
  - Equipment_Needed: Array
  - Building_Preference: Text

Actions:
  1. Query Room Database
     - Get all rooms matching capacity
     - Filter by building/location
     - Check equipment availability
     
  2. Check Availability
     - For each qualifying room
     - Query booking system for conflicts
     - Consider setup/cleanup time
     
  3. Score and Rank
     - Calculate preference score
     - Consider proximity to attendees
     - Factor in equipment match
     
  4. Return Results
     - Top 10 room options
     - Include booking details
     - Provide images and maps
```

## Entities and Variables

### Entities

```yaml
RoomTypes:
  - Small Conference Room (4-6 people)
  - Medium Conference Room (8-12 people)
  - Large Conference Room (15-20 people)
  - Auditorium (50+ people)
  - Huddle Room (2-4 people)
  - Phone Booth (1-2 people)

EquipmentTypes:
  - Projector
  - Large Monitor/TV
  - Video Conferencing Camera
  - Whiteboard
  - Conference Phone
  - Wireless Presentation
  - Catering Setup

MeetingDurations:
  - 15 minutes
  - 30 minutes
  - 45 minutes
  - 1 hour
  - 1.5 hours
  - 2 hours
  - Half day (4 hours)
  - Full day (8 hours)

TimeSlots:
  - Morning (9:00-12:00)
  - Afternoon (13:00-17:00)
  - Evening (17:00-20:00)
```

### Variables

```yaml
Global Variables:
  User.TimeZone: Text
  User.WorkingHours: Object
  User.PreferredRooms: Array
  Organization.BusinessHours: Object
  Organization.Holidays: Array

Meeting Variables:
  Meeting.ID: Text
  Meeting.Title: Text
  Meeting.DateTime: DateTime
  Meeting.Duration: Number
  Meeting.Attendees: Array
  Meeting.Room: Text
  Meeting.TeamsLink: Text
  Meeting.Status: Choice (Scheduled, Confirmed, Cancelled)

Booking Variables:
  Room.ID: Text
  Room.Name: Text
  Room.Capacity: Number
  Room.Equipment: Array
  Room.Building: Text
  Room.Floor: Text
  Booking.Status: Choice (Reserved, Confirmed, Cancelled)
```

## Integration Points

### Microsoft Graph API

```yaml
Required Permissions:
  - Calendars.ReadWrite: Create and modify calendar events
  - Calendars.ReadWrite.Shared: Access shared calendars
  - Mail.Send: Send meeting invitations
  - User.Read.All: Look up user information
  - Place.Read.All: Access room and resource information

API Endpoints Used:
  - /me/calendar/events: Manage calendar events
  - /me/calendar/getSchedule: Check availability
  - /places: Query room information
  - /communications/onlineMeetings: Create Teams meetings
  - /users/{id}/calendar/calendarView: View calendars
```

### Exchange Online

```yaml
Room Lists:
  - Query available room lists
  - Get room details and capacity
  - Check equipment and features
  - Access booking policies

Resource Booking:
  - Reserve rooms and equipment
  - Handle booking conflicts
  - Manage recurring reservations
  - Process approval workflows
```

## Security and Compliance

### Authentication

```yaml
Authentication Method: Azure AD OAuth 2.0
Required Scopes:
  - Calendars.ReadWrite
  - Mail.Send
  - User.Read.All
  - Place.Read.All

Conditional Access:
  - Device compliance required
  - Multi-factor authentication
  - Location-based restrictions
```

### Data Protection

```yaml
Data Handling:
  - No meeting content stored in agent
  - Attendee lists encrypted in transit
  - Room bookings logged for audit
  - Personal calendar data never cached
  - Automatic data purging after 30 days

Privacy Controls:
  - Users can opt out of scheduling assistance
  - Private meetings remain private
  - Delegation permissions respected
  - Guest access properly controlled
```

## Testing Scenarios

### Functional Tests

```yaml
Test Case 1: Basic Meeting Scheduling
  Input: "Schedule a team meeting for tomorrow at 2pm"
  Expected: 
    - Collect missing details (attendees, duration)
    - Check availability
    - Present options
    - Create meeting successfully

Test Case 2: Complex Scheduling
  Input: "Find time for 8 people next week, need video conferencing"
  Expected:
    - Find optimal times for all attendees
    - Suggest appropriate rooms
    - Handle scheduling conflicts
    - Provide alternatives

Test Case 3: Room Booking Only
  Input: "Book conference room B for Friday 3-5pm"
  Expected:
    - Check room availability
    - Reserve room successfully
    - Confirm booking details
    - Provide booking reference

Test Case 4: Meeting Conflicts
  Input: Schedule meeting when attendees have conflicts
  Expected:
    - Identify conflicts
    - Suggest alternative times
    - Offer partial attendance options
    - Allow override with warnings

Test Case 5: Cancellation
  Input: "Cancel my 3pm meeting today"
  Expected:
    - Identify correct meeting
    - Confirm cancellation
    - Notify all attendees
    - Release booked resources
```

## Performance Optimization

### Response Time Targets

```yaml
Operation Performance Targets:
  - Availability check: < 3 seconds
  - Room search: < 2 seconds
  - Meeting creation: < 5 seconds
  - Invitation sending: < 10 seconds
  - Cancellation: < 3 seconds

Optimization Strategies:
  - Cache room information
  - Parallel availability checks
  - Asynchronous invitation sending
  - Pre-computed time slot suggestions
  - Background data refresh
```

### Scalability Considerations

```yaml
Scaling Strategies:
  - Rate limiting for API calls
  - Connection pooling for Graph API
  - Batch operations where possible
  - Queue system for bulk operations
  - Load balancing across regions

Monitoring Metrics:
  - API response times
  - Success/failure rates
  - User satisfaction scores
  - Room utilization rates
  - Peak usage patterns
```

## Deployment and Maintenance

### Deployment Checklist

- [ ] Configure Microsoft Graph API permissions
- [ ] Set up room and resource data sources
- [ ] Create Power Automate flows
- [ ] Configure authentication and security
- [ ] Import entities and test data
- [ ] Test all scheduling scenarios
- [ ] Train facility management team
- [ ] Set up monitoring and alerts
- [ ] Document support procedures
- [ ] Deploy to pilot users first

### Ongoing Maintenance

```yaml
Daily Tasks:
  - Monitor API health and quotas
  - Check for scheduling conflicts
  - Review error logs and failures
  - Update room availability status

Weekly Tasks:
  - Analyze usage patterns
  - Review user feedback
  - Update room equipment lists
  - Check data synchronization

Monthly Tasks:
  - Performance review and optimization
  - User satisfaction surveys
  - Feature usage analysis
  - Security compliance audit
```

## Support and Resources

- **Microsoft Graph API Documentation**: [https://docs.microsoft.com/graph/](https://docs.microsoft.com/graph/)
- **Exchange Online PowerShell**: [https://docs.microsoft.com/powershell/exchange/](https://docs.microsoft.com/powershell/exchange/)
- **Teams Meeting APIs**: [https://docs.microsoft.com/graph/api/application-post-onlinemeetings](https://docs.microsoft.com/graph/api/application-post-onlinemeetings)
- **Room and Resource Management**: [https://docs.microsoft.com/exchange/recipients/room-mailboxes](https://docs.microsoft.com/exchange/recipients/room-mailboxes)
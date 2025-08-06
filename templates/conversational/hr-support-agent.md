# HR Support Agent Template

A comprehensive conversational agent template for handling common HR inquiries, policy questions, and employee support requests.

## Agent Overview

**Purpose**: Provide 24/7 access to HR information, policies, and support for employees
**Target Users**: All company employees
**Integration**: Microsoft Teams, SharePoint (policy documents), Outlook (calendar)

## Agent Configuration

### Basic Settings

```yaml
Agent Name: HR Helper
Description: Your friendly HR assistant for policies, benefits, and support
Language: English (US)
Tone: Professional yet approachable
Escalation: Human HR representative when needed
```

### Core Topics

#### 1. Welcome Topic

```yaml
Topic: Welcome
Trigger: Agent start, greeting phrases
Message: |
  Hi there! 👋 I'm your HR Helper, here to assist you with:
  
  • Company policies and procedures
  • Benefits information
  • Time-off requests
  • General HR questions
  • Directory assistance
  
  What can I help you with today?

Quick Replies:
  - "Company policies"
  - "Benefits info"
  - "Time off"
  - "Contact information"
```

#### 2. Company Policies Topic

```yaml
Topic: Company Policies
Trigger Phrases:
  - "company policy"
  - "policy about"
  - "what's the rule for"
  - "company handbook"
  - "employee guidelines"

Variables:
  - Topic.PolicyType (Entity: PolicyTypes)

Message: |
  I can help you find information about our company policies. 
  What specific policy are you looking for?

Conditions:
  If Topic.PolicyType = "Vacation":
    Call Action: Get_Vacation_Policy
  If Topic.PolicyType = "Dress Code":
    Call Action: Get_Dress_Code_Policy
  If Topic.PolicyType = "Remote Work":
    Call Action: Get_Remote_Work_Policy
  If Topic.PolicyType = "Other":
    Message: "Let me search our policy database for you."
    Call Action: Search_Policies
```

#### 3. Benefits Information Topic

```yaml
Topic: Benefits Information
Trigger Phrases:
  - "benefits"
  - "health insurance"
  - "401k"
  - "retirement plan"
  - "dental coverage"
  - "vision insurance"

Variables:
  - User.Department
  - User.HireDate
  - Benefit.Type

Message: |
  I'd be happy to help with benefits information! 
  What specific benefit would you like to know about?

Quick Replies:
  - "Health Insurance"
  - "Dental & Vision"
  - "401(k) Retirement"
  - "Paid Time Off"
  - "Life Insurance"

Conditions:
  If Benefit.Type = "Health Insurance":
    Call Action: Get_Health_Insurance_Info
    Message: |
      Our health insurance options include:
      
      🏥 **Premium Plan**: Comprehensive coverage with low deductibles
      💊 **Standard Plan**: Balanced coverage and costs
      💡 **High Deductible Plan**: Lower premiums with HSA option
      
      Would you like details about a specific plan or enrollment information?

  If Benefit.Type = "401(k) Retirement":
    Call Action: Get_401k_Info
    Message: |
      401(k) Plan Details:
      
      💰 **Company Match**: 50% of contributions up to 6% of salary
      📈 **Vesting Schedule**: Immediate vesting for employee contributions
      🎯 **Investment Options**: 20+ fund choices including target-date funds
      
      Want to know about enrollment or changing your contribution?
```

#### 4. Time Off Requests Topic

```yaml
Topic: Time Off Requests
Trigger Phrases:
  - "time off"
  - "vacation request"
  - "sick leave"
  - "PTO"
  - "holiday schedule"
  - "request vacation"

Variables:
  - TimeOff.Type (Entity: TimeOffTypes)
  - TimeOff.StartDate
  - TimeOff.EndDate
  - TimeOff.Reason

Message: |
  I can help you with time-off requests! What type of time off do you need?

Quick Replies:
  - "Vacation/PTO"
  - "Sick Leave"
  - "Personal Day"
  - "Holiday Schedule"

Conditions:
  If TimeOff.Type = "Vacation/PTO":
    Message: "Great! Let me help you submit a vacation request."
    Ask for: TimeOff.StartDate
    Ask for: TimeOff.EndDate
    Call Action: Check_PTO_Balance
    If PTO_Balance >= Requested_Days:
      Call Action: Submit_PTO_Request
      Message: |
        ✅ Your PTO request has been submitted!
        
        **Details:**
        • Start Date: {TimeOff.StartDate}
        • End Date: {TimeOff.EndDate}
        • Days Requested: {Calculated_Days}
        • Remaining Balance: {Updated_Balance} days
        
        Your manager will be notified for approval.
    Else:
      Message: |
        ⚠️ Insufficient PTO balance. 
        
        You requested {Requested_Days} days but only have {PTO_Balance} days available.
        Would you like to:
        • Adjust your request dates
        • Request unpaid time off
        • Speak with HR about options
```

#### 5. Directory Assistance Topic

```yaml
Topic: Directory Assistance
Trigger Phrases:
  - "find contact"
  - "phone number"
  - "email address"
  - "who is"
  - "contact information"
  - "employee directory"

Variables:
  - Search.Name
  - Search.Department
  - Search.Title

Message: |
  I can help you find contact information for employees. 
  You can search by name, department, or job title.

Ask for: Search.Name OR Search.Department OR Search.Title

Call Action: Search_Employee_Directory

If Results_Found:
  Display: Employee_Contact_Card
Else:
  Message: |
    I couldn't find anyone matching that search. Try:
    • Checking the spelling
    • Using just the first or last name
    • Searching by department instead
    
    Or would you like me to connect you with HR for assistance?
```

#### 6. Escalation Topic

```yaml
Topic: Escalation to Human
Trigger Phrases:
  - "speak to someone"
  - "human agent"
  - "HR representative"
  - "can't help"
  - "complex issue"

Message: |
  I understand you'd like to speak with a human HR representative. 
  Let me help you get connected.

Variables:
  - Issue.Category
  - Issue.Priority
  - User.ContactPreference

Ask for: Issue.Category
Ask for: Issue.Priority
Ask for: User.ContactPreference

Call Action: Create_HR_Ticket
Call Action: Notify_HR_Team

Message: |
  ✅ I've created a support ticket and notified our HR team.
  
  **Ticket Details:**
  • Ticket #: {Ticket.Number}
  • Category: {Issue.Category}
  • Priority: {Issue.Priority}
  
  **Next Steps:**
  An HR representative will contact you within {Expected_Response_Time}.
  
  Is there anything else I can help you with while you wait?
```

## Actions and Integrations

### Power Automate Flows

#### Get Vacation Policy Flow
```yaml
Flow Name: Get_Vacation_Policy
Trigger: When called from copilot
Actions:
  1. Get SharePoint list item (Policy Documents)
  2. Filter by Policy Type = "Vacation"
  3. Return policy content and effective date
  4. Log access for analytics
```

#### Submit PTO Request Flow
```yaml
Flow Name: Submit_PTO_Request
Trigger: When called from copilot
Inputs:
  - Employee ID
  - Start Date
  - End Date
  - Request Type
Actions:
  1. Create item in PTO Requests SharePoint list
  2. Send approval email to manager
  3. Update employee PTO balance
  4. Send confirmation to employee
  5. Add calendar placeholder
```

#### Search Employee Directory Flow
```yaml
Flow Name: Search_Employee_Directory
Trigger: When called from copilot
Inputs:
  - Search Term
  - Search Type (Name/Department/Title)
Actions:
  1. Query Azure AD or SharePoint employee list
  2. Filter results based on search criteria
  3. Return contact information (respecting privacy settings)
  4. Log directory access
```

## Entities

### PolicyTypes Entity
```yaml
Entity: PolicyTypes
Values:
  - Vacation
  - Sick Leave
  - Remote Work
  - Dress Code
  - Code of Conduct
  - Harassment
  - Safety
  - IT Security
  - Expense Reporting
  - Travel
```

### TimeOffTypes Entity
```yaml
Entity: TimeOffTypes
Values:
  - Vacation/PTO
  - Sick Leave
  - Personal Day
  - Bereavement
  - Jury Duty
  - Military Leave
  - Maternity/Paternity
  - Unpaid Leave
```

### DepartmentTypes Entity
```yaml
Entity: DepartmentTypes
Values:
  - Human Resources
  - Information Technology
  - Finance
  - Marketing
  - Sales
  - Operations
  - Legal
  - Executive
  - Customer Service
  - Research & Development
```

## Variables

### Global Variables
```yaml
Variables:
  User.EmployeeID: Text
  User.Department: Choice (DepartmentTypes)
  User.Manager: Text
  User.HireDate: DateTime
  User.PTOBalance: Number
  Session.StartTime: DateTime
  Session.ConversationID: Text
```

### Topic-Specific Variables
```yaml
Policy Variables:
  Topic.PolicyType: Choice (PolicyTypes)
  Policy.EffectiveDate: DateTime
  Policy.LastUpdated: DateTime

PTO Variables:
  TimeOff.Type: Choice (TimeOffTypes)
  TimeOff.StartDate: DateTime
  TimeOff.EndDate: DateTime
  TimeOff.DaysRequested: Number
  TimeOff.Reason: Text
  TimeOff.ManagerApproval: Boolean

Search Variables:
  Search.Term: Text
  Search.Type: Choice (Name, Department, Title)
  Search.Results: Table
```

## Authentication and Security

### Authentication Setup
```yaml
Authentication Type: Azure AD (Single Sign-On)
Required Scopes:
  - User.Read (basic profile)
  - Directory.Read.All (employee directory)
  - Calendars.ReadWrite (PTO calendar entries)
  - Mail.Send (notifications)

Security Groups:
  - All Employees (basic access)
  - HR Team (admin access)
  - Managers (approval workflows)
```

### Data Privacy
```yaml
Privacy Settings:
  - Employee directory access limited to basic contact info
  - PTO balances only visible to employee and manager
  - Policy access logged for compliance
  - Personal information never stored in chat history
  - Escalation tickets encrypted and access-controlled
```

## Testing Scenarios

### Test Cases
```yaml
Test Scenario 1: Policy Lookup
  Input: "What's our vacation policy?"
  Expected: Display vacation policy with current effective date
  
Test Scenario 2: PTO Request
  Input: "I want to request vacation from Dec 20-30"
  Expected: Check balance, create request, notify manager
  
Test Scenario 3: Directory Search
  Input: "Find John Smith's email"
  Expected: Return contact card with email and phone
  
Test Scenario 4: Benefits Question
  Input: "Tell me about health insurance options"
  Expected: Display plan options with details and enrollment info
  
Test Scenario 5: Escalation
  Input: "I need to speak with HR about a sensitive issue"
  Expected: Create priority ticket and immediate HR notification
```

## Deployment Checklist

- [ ] Configure SharePoint lists for policies and PTO requests
- [ ] Set up Power Automate flows for backend processing
- [ ] Configure Azure AD authentication and permissions
- [ ] Import entities and variables
- [ ] Test all conversation flows
- [ ] Set up escalation procedures with HR team
- [ ] Configure analytics and monitoring
- [ ] Train HR team on agent capabilities
- [ ] Create user documentation and training materials
- [ ] Deploy to pilot group first, then company-wide

## Maintenance and Updates

### Regular Tasks
- Update policy documents in SharePoint
- Review conversation analytics monthly
- Update FAQ based on common questions
- Test integrations and flows quarterly
- Refresh employee directory data
- Monitor escalation patterns

### Continuous Improvement
- Analyze conversation transcripts for improvement opportunities
- Add new topics based on user requests
- Optimize response times and accuracy
- Expand integration capabilities
- Update language and tone based on feedback

## Support Resources

- [HR Team Contact Information](mailto:hr@company.com)
- [Copilot Studio Documentation](https://docs.microsoft.com/copilot-studio/)
- [Power Automate Flow Examples](https://docs.microsoft.com/power-automate/)
- [SharePoint Integration Guide](https://docs.microsoft.com/sharepoint/)
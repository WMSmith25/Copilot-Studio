# SharePoint Integration Example

This example demonstrates how to integrate a Microsoft 365 Copilot agent with SharePoint to access documents, lists, and site content.

## Overview

This integration enables your Copilot agent to:
- Search and retrieve documents from SharePoint sites
- Access and update SharePoint lists
- Query document metadata and properties
- Provide document recommendations
- Create and manage SharePoint content

## Prerequisites

### Required Permissions

```yaml
Microsoft Graph API Permissions:
  Sites.Read.All: Read SharePoint sites and content
  Sites.ReadWrite.All: Create and modify SharePoint content
  Files.Read.All: Access files across SharePoint
  Files.ReadWrite.All: Create and modify files

SharePoint Permissions:
  Site Collection Admin: For configuration and setup
  Site Owner: For content management
  Site Member: For regular content access
```

### SharePoint Site Configuration

```yaml
Site Structure:
  - Document Libraries:
    - Policies: Company policy documents
    - Procedures: Standard operating procedures
    - Templates: Document templates
    - Training: Training materials

  - Lists:
    - Document Metadata: Additional document information
    - Feedback: User feedback and ratings
    - Access Log: Document access tracking
    - Approval Status: Document approval workflow
```

## Power Automate Flow Examples

### 1. Document Search Flow

```yaml
Flow Name: SharePoint_Document_Search
Trigger: When called from Copilot Studio

Inputs:
  - SearchQuery: Text
  - SiteUrl: Text (optional)
  - DocumentType: Choice (Policy, Procedure, Template, Training)
  - MaxResults: Number (default: 10)

Actions:
  1. Initialize Variables
     SearchResults: Array
     SiteUrls: Array of site URLs to search
     
  2. Condition: Check if specific site provided
     If SiteUrl is provided:
       Use single site
     Else:
       Use predefined list of sites
       
  3. Apply to Each Site
     For each site in SiteUrls:
       
     3a. Get Site Information
         Action: Get site
         Site Address: {SiteUrl}
         
     3b. Search Files
         Action: Search for files and folders
         Site Address: {SiteUrl}
         Search Query: {SearchQuery}
         
     3c. Filter Results
         Apply Filter: File type matches DocumentType
         
     3d. Get File Properties
         For each file in search results:
         - Get file metadata
         - Get file content (if text-based)
         - Add to SearchResults array
         
  4. Sort and Limit Results
     Sort by: Relevance, Last Modified
     Take: {MaxResults} items
     
  5. Format Response
     Create formatted response with:
     - File name and description
     - File path and SharePoint URL
     - Last modified date and author
     - File size and type
     - Quick preview (if available)
     
  6. Return Response
     Return formatted results to Copilot Studio

Error Handling:
  - Site not found: Log error, continue with other sites
  - Permission denied: Skip site, notify in results
  - Service unavailable: Retry with exponential backoff
  - Invalid search query: Return helpful error message
```

### 2. Document Upload Flow

```yaml
Flow Name: SharePoint_Document_Upload
Trigger: When called from Copilot Studio

Inputs:
  - FileName: Text
  - FileContent: File content (base64 encoded)
  - TargetLibrary: Choice (Policies, Procedures, Templates, Training)
  - DocumentType: Text
  - Tags: Array of text
  - Author: Text (user who uploaded)

Actions:
  1. Validate Input
     Check required fields are present
     Validate file name and extension
     Check file size limits
     
  2. Determine Target Location
     Based on DocumentType:
     - Map to appropriate document library
     - Set folder path if categorization needed
     - Apply naming conventions
     
  3. Check for Existing File
     Action: Get file metadata
     If file exists:
       - Offer to version or rename
       - Get user confirmation
       
  4. Upload File
     Action: Create file
     Site Address: {TargetSiteUrl}
     Folder Path: {TargetLibraryPath}
     File Name: {FileName}
     File Content: {FileContent}
     
  5. Set Metadata
     Action: Update file properties
     Properties:
       - Document Type: {DocumentType}
       - Tags: {Tags}
       - Author: {Author}
       - Upload Date: {utcNow()}
       - Status: Draft
       
  6. Create Approval Workflow (if required)
     If document requires approval:
     - Start approval workflow
     - Notify approvers
     - Set status to "Pending Approval"
     
  7. Update Document Index
     Add entry to document tracking list:
     - File ID and metadata
     - Upload audit information
     - Access permissions
     
  8. Return Success Response
     Include:
     - File URL and access link
     - Document ID
     - Upload confirmation
     - Next steps (if approval needed)

Error Handling:
  - File too large: Provide size limits and alternatives
  - Invalid file type: List allowed file types
  - Permission denied: Escalate to admin
  - Storage quota exceeded: Notify site admin
```

### 3. List Data Access Flow

```yaml
Flow Name: SharePoint_List_Access
Trigger: When called from Copilot Studio

Inputs:
  - ListName: Text
  - Operation: Choice (Get, Create, Update, Delete)
  - ItemID: Number (for specific item operations)
  - FilterQuery: Text (OData filter)
  - ItemData: Object (for create/update operations)

Actions:
  1. Validate Operation
     Check user permissions for requested operation
     Validate input parameters
     
  2. Switch on Operation Type
  
     Case: Get Items
       2a. Get List Items
           Action: Get items
           Site Address: {SiteUrl}
           List Name: {ListName}
           Filter Query: {FilterQuery}
           Order By: Modified descending
           Top Count: 100
           
       2b. Format Response
           Transform items to user-friendly format
           Include relevant metadata
           Add action buttons (Edit, Delete) if permitted
           
     Case: Create Item
       2a. Validate Required Fields
           Check all required list fields are provided
           Validate field formats and constraints
           
       2b. Create List Item
           Action: Create item
           Site Address: {SiteUrl}
           List Name: {ListName}
           Item Data: {ItemData}
           
       2c. Set Additional Properties
           Update created by/modified by
           Set workflow status if applicable
           
     Case: Update Item
       2a. Get Current Item
           Verify item exists and user has edit permissions
           
       2b. Update List Item
           Action: Update item
           Site Address: {SiteUrl}
           List Name: {ListName}
           Item ID: {ItemID}
           Item Data: {ItemData}
           
       2c. Log Change
           Record what changed and who changed it
           
     Case: Delete Item
       2a. Confirm Permissions
           Verify user can delete this item
           Check for dependencies
           
       2b. Archive Item (Soft Delete)
           Move to archive list instead of permanent delete
           Maintain audit trail
           
  3. Return Operation Result
     Include status and any relevant data
     Provide next steps or related actions

Error Handling:
  - List not found: Provide list of available lists
  - Item not found: Suggest search alternatives
  - Permission denied: Escalate or request access
  - Validation errors: Provide specific field guidance
  - Concurrent modification: Offer refresh and retry
```

## Copilot Studio Topic Implementation

### Document Search Topic

```yaml
Topic Name: Search SharePoint Documents
Trigger Phrases:
  - "find document"
  - "search for file"
  - "look for policy"
  - "find procedure"
  - "search documents"

Variables:
  - Search.Query: Text
  - Search.Type: Choice (Any, Policy, Procedure, Template, Training)
  - Search.Results: Table

Conversation Flow:
  Message: "I can help you find documents in SharePoint. What are you looking for?"
  
  Collect: Search.Query
  
  Message: "What type of document are you looking for?"
  Quick Replies: ["Any type", "Policy", "Procedure", "Template", "Training material"]
  Collect: Search.Type
  
  Message: "🔍 Searching SharePoint for '{Search.Query}'..."
  
  Call Power Automate: SharePoint_Document_Search
  Input Parameters:
    - SearchQuery: {Search.Query}
    - DocumentType: {Search.Type}
    - MaxResults: 10
    
  Condition: If results found
    Message: |
      I found {Search.Results.Count} documents matching your search:
      
      {ForEach result in Search.Results:
        📄 **{result.Name}**
        📁 Location: {result.Path}
        📅 Modified: {result.Modified}
        👤 Author: {result.Author}
        [View Document]({result.Url}) | [Download]({result.DownloadUrl})
        
        {result.Description}
        ---
      }
      
      Would you like me to:
      • Search for something else
      • Help you access one of these documents
      • Create a new document
      
  Else:
    Message: |
      I couldn't find any documents matching "{Search.Query}".
      
      Suggestions:
      • Try different keywords
      • Check spelling
      • Search for a broader term
      • Browse by document type
      
      Would you like me to show you:
      • Recent documents
      • Popular documents
      • All available document types
```

### Document Upload Topic

```yaml
Topic Name: Upload Document to SharePoint
Trigger Phrases:
  - "upload document"
  - "add file"
  - "create document"
  - "save to sharepoint"

Variables:
  - Upload.FileName: Text
  - Upload.Type: Choice (Policy, Procedure, Template, Training)
  - Upload.Description: Text
  - Upload.Tags: Text
  - Upload.File: File

Conversation Flow:
  Message: |
    I can help you upload a document to SharePoint. 
    
    Please provide:
    1. The file you want to upload
    2. Document type and details
    
    What would you like to upload?
    
  Collect: Upload.File
  
  Message: "What type of document is this?"
  Quick Replies: ["Policy", "Procedure", "Template", "Training material", "Other"]
  Collect: Upload.Type
  
  Message: "Please provide a brief description of the document:"
  Collect: Upload.Description
  
  Message: "Add any tags to help others find this document (separate with commas):"
  Collect: Upload.Tags
  
  Message: "📤 Uploading your document to SharePoint..."
  
  Call Power Automate: SharePoint_Document_Upload
  Input Parameters:
    - FileName: {Upload.File.Name}
    - FileContent: {Upload.File.Content}
    - TargetLibrary: {Upload.Type}
    - Description: {Upload.Description}
    - Tags: {Upload.Tags}
    - Author: {User.DisplayName}
    
  Condition: If upload successful
    Message: |
      ✅ Document uploaded successfully!
      
      **Document Details:**
      📄 Name: {Upload.FileName}
      📁 Location: {Upload.SharePointPath}
      🔖 Type: {Upload.Type}
      🏷️ Tags: {Upload.Tags}
      
      **Next Steps:**
      • Document is now available in SharePoint
      • Others can find it by searching for your tags
      • You'll be notified when it's approved (if applicable)
      
      [View in SharePoint]({Upload.SharePointUrl})
      
  Else:
    Message: |
      ❌ Upload failed: {Upload.ErrorMessage}
      
      Common solutions:
      • Check file size (max 250MB)
      • Ensure file type is allowed
      • Verify you have upload permissions
      
      Would you like me to:
      • Try uploading again
      • Help you with a different file
      • Connect you with IT support
```

### List Management Topic

```yaml
Topic Name: Manage SharePoint Lists
Trigger Phrases:
  - "update list"
  - "add to list"
  - "check list"
  - "view list items"

Variables:
  - List.Name: Choice (Document Metadata, Feedback, Approval Status)
  - List.Operation: Choice (View, Add, Update, Search)
  - List.ItemData: Object

Conversation Flow:
  Message: "I can help you work with SharePoint lists. Which list do you need to access?"
  
  Quick Replies: ["Document Metadata", "Feedback", "Approval Status", "Other"]
  Collect: List.Name
  
  Message: "What would you like to do with the {List.Name} list?"
  Quick Replies: ["View items", "Add new item", "Update existing item", "Search items"]
  Collect: List.Operation
  
  Switch on List.Operation:
  
    Case: View
      Message: "📋 Getting {List.Name} list items..."
      
      Call Power Automate: SharePoint_List_Access
      Input Parameters:
        - ListName: {List.Name}
        - Operation: Get
        - FilterQuery: "" (get all recent items)
        
      Display results in adaptive card format
      
    Case: Add
      Message: "I'll help you add a new item to {List.Name}."
      
      Collect required fields based on list type
      
      Call Power Automate: SharePoint_List_Access
      Input Parameters:
        - ListName: {List.Name}
        - Operation: Create
        - ItemData: {collected field values}
        
      Confirm creation success
      
    Case: Update
      Message: "Which item would you like to update?"
      
      First show list of existing items
      Let user select item to update
      Collect new field values
      
      Call Power Automate: SharePoint_List_Access
      Input Parameters:
        - ListName: {List.Name}
        - Operation: Update
        - ItemID: {selected item ID}
        - ItemData: {updated field values}
        
    Case: Search
      Message: "What are you looking for in the {List.Name} list?"
      
      Collect search criteria
      
      Call Power Automate: SharePoint_List_Access
      Input Parameters:
        - ListName: {List.Name}
        - Operation: Get
        - FilterQuery: {build filter from search criteria}
        
      Display filtered results
```

## Adaptive Cards for Rich Display

### Document Search Results Card

```json
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.4",
  "body": [
    {
      "type": "TextBlock",
      "text": "SharePoint Document Search Results",
      "weight": "Bolder",
      "size": "Medium"
    },
    {
      "type": "TextBlock",
      "text": "Found ${resultsCount} documents matching '${searchQuery}'",
      "wrap": true
    },
    {
      "type": "Container",
      "items": [
        {
          "type": "ColumnSet",
          "columns": [
            {
              "type": "Column",
              "width": "auto",
              "items": [
                {
                  "type": "Image",
                  "url": "${fileIcon}",
                  "width": "32px",
                  "height": "32px"
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "${fileName}",
                  "weight": "Bolder",
                  "wrap": true
                },
                {
                  "type": "TextBlock",
                  "text": "${fileDescription}",
                  "wrap": true,
                  "isSubtle": true
                },
                {
                  "type": "FactSet",
                  "facts": [
                    {
                      "title": "Modified:",
                      "value": "${lastModified}"
                    },
                    {
                      "title": "Author:",
                      "value": "${author}"
                    },
                    {
                      "title": "Size:",
                      "value": "${fileSize}"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.OpenUrl",
      "title": "View in SharePoint",
      "url": "${sharePointUrl}"
    },
    {
      "type": "Action.OpenUrl",
      "title": "Download",
      "url": "${downloadUrl}"
    },
    {
      "type": "Action.Submit",
      "title": "More Like This",
      "data": {
        "action": "similarDocuments",
        "fileId": "${fileId}"
      }
    }
  ]
}
```

### Document Upload Status Card

```json
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.4",
  "body": [
    {
      "type": "Container",
      "style": "good",
      "items": [
        {
          "type": "ColumnSet",
          "columns": [
            {
              "type": "Column",
              "width": "auto",
              "items": [
                {
                  "type": "Image",
                  "url": "https://cdn.icon-icons.com/icons2/1154/PNG/32/1486395872-rounded23_81519.png",
                  "width": "32px",
                  "height": "32px"
                }
              ]
            },
            {
              "type": "Column",
              "width": "stretch",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "Document Uploaded Successfully",
                  "weight": "Bolder",
                  "color": "Good"
                },
                {
                  "type": "TextBlock",
                  "text": "${fileName} has been uploaded to SharePoint",
                  "wrap": true
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "FactSet",
      "facts": [
        {
          "title": "File Name:",
          "value": "${fileName}"
        },
        {
          "title": "Location:",
          "value": "${sharePointPath}"
        },
        {
          "title": "Document Type:",
          "value": "${documentType}"
        },
        {
          "title": "Status:",
          "value": "${approvalStatus}"
        }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.OpenUrl",
      "title": "View in SharePoint",
      "url": "${sharePointUrl}"
    },
    {
      "type": "Action.Submit",
      "title": "Share with Team",
      "data": {
        "action": "shareDocument",
        "fileId": "${fileId}"
      }
    }
  ]
}
```

## Security and Permissions

### Access Control Configuration

```yaml
SharePoint Site Permissions:
  Site Collection Administrators:
    - IT Administrators
    - SharePoint Administrators
    
  Site Owners:
    - Department Heads
    - Content Managers
    
  Site Members:
    - All Employees (read access)
    - Content Contributors (write access to specific libraries)
    
  Site Visitors:
    - External partners (limited access)
    - Temporary employees

Document Library Permissions:
  Policies Library:
    - HR Team: Full Control
    - All Employees: Read
    - Managers: Contribute
    
  Procedures Library:
    - Department Owners: Full Control
    - Team Members: Contribute
    - Other Employees: Read
    
  Templates Library:
    - Template Owners: Full Control
    - All Employees: Read and Contribute

List Permissions:
  Document Metadata:
    - Content Managers: Full Control
    - Contributors: Edit own items
    - All Users: Read
    
  Feedback List:
    - All Users: Contribute (add feedback)
    - Content Managers: Read all feedback
    - Users: Read own feedback only
```

### Data Security Measures

```yaml
Encryption:
  - Data in transit: TLS 1.2 or higher
  - Data at rest: SharePoint Online encryption
  - File content: Microsoft 365 encryption

Access Logging:
  - Document access tracking
  - Download/edit activities
  - Search queries and results
  - Permission changes
  - Administrative actions

Data Loss Prevention:
  - Sensitive content detection
  - External sharing restrictions
  - Download restrictions for confidential documents
  - Audit alerts for suspicious activity

Compliance:
  - Retention policies for different document types
  - Legal hold capabilities
  - eDiscovery support
  - Privacy compliance (GDPR, CCPA)
```

## Performance Optimization

### Caching Strategy

```yaml
Client-Side Caching:
  - Search results: 5 minutes
  - Document metadata: 15 minutes
  - List schema: 1 hour
  - User permissions: 30 minutes

Server-Side Caching:
  - Site information: 1 hour
  - Library structure: 4 hours
  - Search indexes: Updated nightly
  - Popular documents: 2 hours

Flow Optimization:
  - Parallel API calls where possible
  - Batch operations for multiple items
  - Efficient OData queries
  - Minimal data transfer
```

### Search Optimization

```yaml
Search Configuration:
  - Full-text indexing enabled
  - Metadata property mapping
  - Custom search scopes
  - Relevance tuning

Query Optimization:
  - Use specific properties when possible
  - Implement query suggestions
  - Cache popular search results
  - Limit result sets to reasonable sizes

Performance Monitoring:
  - Query execution times
  - Search result relevance
  - User click-through rates
  - Popular content tracking
```

## Troubleshooting Guide

### Common Issues

```yaml
Authentication Errors:
  Symptoms: "Access denied" or "Authentication failed"
  Causes:
    - Missing Graph API permissions
    - SharePoint site permissions not configured
    - Token expiration
  Solutions:
    - Verify and grant required permissions
    - Check SharePoint site access
    - Refresh authentication tokens

Search Not Working:
  Symptoms: No results or incomplete results
  Causes:
    - SharePoint search service issues
    - Index not updated
    - Query syntax errors
  Solutions:
    - Check SharePoint search service health
    - Trigger manual re-indexing
    - Validate OData query syntax

Upload Failures:
  Symptoms: "Upload failed" errors
  Causes:
    - File size too large
    - Unsupported file type
    - Storage quota exceeded
    - Permission issues
  Solutions:
    - Check file size limits (250MB default)
    - Verify allowed file types
    - Check site storage quota
    - Verify upload permissions

Performance Issues:
  Symptoms: Slow response times
  Causes:
    - Large result sets
    - Network latency
    - SharePoint throttling
    - Inefficient queries
  Solutions:
    - Implement result pagination
    - Optimize queries
    - Use caching strategies
    - Monitor and adjust throttling
```

### Diagnostic Tools

```yaml
SharePoint Admin Center:
  - Site usage reports
  - Search analytics
  - Performance metrics
  - Error logs

Power Platform Admin Center:
  - Flow execution history
  - Performance analytics
  - Connection status
  - Error details

Graph Explorer:
  - Test API calls
  - Validate permissions
  - Query optimization
  - Response analysis

Network Monitoring:
  - API response times
  - Bandwidth usage
  - Connection reliability
  - Error rates
```

## Maintenance and Updates

### Regular Maintenance Tasks

```yaml
Daily:
  - Monitor search performance
  - Check upload/download success rates
  - Review error logs
  - Verify service connectivity

Weekly:
  - Analyze usage patterns
  - Review popular content
  - Check storage usage
  - Update document tags and metadata

Monthly:
  - Review and update permissions
  - Optimize search configurations
  - Clean up obsolete content
  - Performance tuning

Quarterly:
  - Security compliance review
  - User access audit
  - Content governance review
  - System capacity planning
```

### Update Procedures

```yaml
SharePoint Updates:
  - Monitor Microsoft 365 message center
  - Test new features in development environment
  - Update documentation and training materials
  - Communicate changes to users

Power Automate Updates:
  - Review and test flow modifications
  - Update error handling logic
  - Optimize performance improvements
  - Version control and rollback procedures

Copilot Studio Updates:
  - Enhance conversation flows
  - Add new document types and categories
  - Improve search algorithms
  - Update user interface elements
```

## Validated References

- [SharePoint REST API Reference](https://docs.microsoft.com/sharepoint/dev/sp-add-ins/complete-basic-operations-using-sharepoint-rest-endpoints) - Official REST API documentation
- [Microsoft Graph SharePoint API](https://docs.microsoft.com/graph/api/resources/sharepoint) - Graph API for SharePoint integration
- [SharePoint Search REST API](https://docs.microsoft.com/sharepoint/dev/general-development/sharepoint-search-rest-api-overview) - Search service integration
- [Power Automate SharePoint Connector](https://docs.microsoft.com/connectors/sharepointonline/) - Connector documentation and examples
- [SharePoint Online Limits](https://docs.microsoft.com/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits) - Performance and capacity limits
- [SharePoint Security and Compliance](https://docs.microsoft.com/sharepoint/security-for-sharepoint-server) - Security best practices
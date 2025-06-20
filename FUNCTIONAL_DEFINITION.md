# AMRRIC Application Functional Definition

## Overview
AMRRIC (Australian Marine Mammal Research and Information Centre) is a cross-platform mobile application built using .NET MAUI (previously Xamarin.Forms). The application provides functionality for managing and tracking marine mammal data, including animals, houses, and census information.

## Core Components

### 1. Application Structure
- **Main Application (App.cs)**
  - Handles application lifecycle (OnStart, OnSleep, OnResume)
  - Manages user authentication state
  - Controls navigation flow based on user state
  - Integrates with AppCenter for analytics and crash reporting

### 2. Authentication System
- **AuthService**
  - Implements Microsoft Identity authentication
  - Handles user sign-in/sign-out
  - Manages authentication tokens
  - Platform-specific authentication flows for iOS and Android

### 3. Data Management
- **Cloud Service (AzureCloudService)**
  - Handles data synchronization with Azure backend
  - Manages offline data storage
  - Tracks pending operations
  - Provides sync status information

### 4. User Interface Components

#### AppBar
- Displays application logo
- Shows sync status
- Provides sync and push change controls
- Displays pending changes count

#### Navigation
- Tab-based navigation structure
- Shell-based navigation system
- Support for popup pages
- Custom navigation handlers

### 5. Platform-Specific Features

#### iOS
- Custom renderers for UI components
- Platform-specific authentication handling
- Location services integration
- Camera and photo library access
- Custom effects for UI elements

#### Android
- Custom renderers and effects
- Platform-specific authentication
- Location services
- Camera and storage access
- Custom UI components

### 6. Data Models
- Animal records
- House records
- Census data
- User profiles
- Attachment management

### 7. Error Handling
- Custom exception handling (AmrricException)
- Crash reporting integration
- User-friendly error messages
- Error tracking with AppCenter

## Technical Requirements

### Dependencies
- Microsoft.Maui.Controls (8.0.3)
- Microsoft.Azure.Mobile.Client (4.2.0)
- Microsoft.Identity.Client (4.59.0)
- Plugin.Media (5.0.1)
- Rg.Plugins.Popup (2.0.0.7)
- Microsoft.AppCenter (Analytics & Crashes)
- Telerik UI Components

### Platform Support
- iOS (minimum version 8.0)
- Android
- MacCatalyst

### Permissions Required
- Camera access
- Photo library access
- Location services
- Network access
- Storage access

## Security Features
- Azure AD authentication
- Secure token storage
- Platform-specific security implementations
- Secure data transmission

## Data Synchronization
- Offline-first architecture
- Background sync capabilities
- Conflict resolution
- Pending operations tracking

## User Interface Guidelines
- Consistent styling across platforms
- Responsive design
- Platform-specific UI adaptations
- Custom effects and animations

## Error Handling Strategy
- Graceful degradation
- User-friendly error messages
- Automatic error reporting
- Offline error handling

## Performance Considerations
- Efficient data loading
- Background processing
- Memory management
- Battery optimization

## Future Considerations
- MAUI migration completion
- Telerik UI component updates
- Enhanced offline capabilities
- Performance optimizations
- Additional platform support

## Development Guidelines
- Follow MVVM pattern
- Implement platform-specific code when necessary
- Maintain consistent error handling
- Document custom components
- Follow MAUI best practices

## Database Management
- SQLite local storage
- Azure Mobile Services integration
- Data migration strategies
- Backup and restore capabilities

## Testing Strategy
- Unit testing for core components
- Platform-specific testing
- UI testing
- Performance testing
- Security testing

## Deployment Process
- App Store deployment
- Google Play Store deployment
- Version management
- Beta testing process
- Release management

## Monitoring and Analytics
- AppCenter integration
- Usage analytics
- Crash reporting
- Performance monitoring
- User behavior tracking

## Accessibility
- Screen reader support
- Dynamic text sizing
- Color contrast compliance
- Platform-specific accessibility features

## Internationalization
- Multi-language support
- Regional settings
- Date and time formatting
- Number formatting
- Currency handling

## Documentation
- Code documentation
- API documentation
- User guides
- Troubleshooting guides
- Development guides

## Theming and Colors

### Color Palette
- **Primary Colors**
  - Primary: #512BD4 (Deep Purple)
  - Secondary: #DFD8F7 (Light Purple)
  - Tertiary: #2B0B98 (Dark Blue)

- **Grayscale**
  - White: #FFFFFF
  - Black: #000000
  - Gray100: #E1E1E1
  - Gray200: #C8C8C8
  - Gray300: #ACACAC
  - Gray400: #919191
  - Gray500: #6E6E6E
  - Gray600: #404040
  - Gray900: #212121
  - Gray950: #141414

### Typography
- **Font Families**
  - Primary: OpenSans-Regular
  - Secondary: OpenSans-Semibold
  - Font Awesome for icons

- **Font Sizes**
  - Micro: 12px
  - Small: 14px
  - Medium: 16px
  - Large: 18px
  - Extra Large: 24px

### UI Components Styling

#### Buttons
- Background: Primary color
- Text: White
- Font: OpenSans-Regular
- Size: 14px
- Padding: 14,10
- Minimum Height: 44px
- Minimum Width: 200px

#### Labels
- Text Color: Gray900
- Font: OpenSans-Regular
- Size: 14px

#### Entries
- Text Color: Gray900
- Font: OpenSans-Regular
- Size: 14px
- Placeholder Color: Gray400

#### Editors
- Text Color: Gray900
- Font: OpenSans-Regular
- Size: 14px
- Placeholder Color: Gray400

#### Frames
- Border Color: Gray300
- Background: White
- Padding: 14,10
- Corner Radius: 8px

#### Collection Views
- Background: White

#### Search Bars
- Text Color: Gray900
- Font: OpenSans-Regular
- Size: 14px
- Placeholder Color: Gray400

### Shell Navigation Styling
- Background: White
- Foreground: Primary color
- Title Color: Primary color
- Disabled Color: Gray300
- Unselected Color: Gray400
- Tab Bar Background: White
- Tab Bar Foreground: Primary color
- Tab Bar Unselected: Gray400
- Tab Bar Title: Primary color

### Resource Dictionaries
- App_Colours.xaml
- App_FontSizes.xaml
- Style.xaml

### Platform-Specific Styling
- iOS-specific adjustments
- Android-specific adjustments
- MacCatalyst-specific adjustments

### Dark Mode Support
- Color scheme variations
- Contrast adjustments
- Accessibility considerations

### Custom Effects
- Entry Line Color Effect
- Circle Effect
- Entry Move Next Effect
- Base Container Effect

## User Roles and Navigation Flow

### User Role Types
The AMRRIC application supports four distinct user roles, each with specific access levels and navigation flows:

1. **System Admin** - Full system access and administrative controls
2. **Municipality Admin** - Council-level management and oversight
3. **Veterinary User** - Animal health management and treatment tracking
4. **Census User** - Population data collection and house management

### Navigation Flow by User Role

#### System Admin Users
- **Direct Access**: Full application functionality through main dashboard
- **Capabilities**: 
  - User management
  - Council management
  - Community management
  - House management (global)
  - System settings
  - All animal management features
  - Complete reporting suite

#### Municipality Admin Users
- **Direct Access**: Council-level management through main dashboard
- **Capabilities**:
  - Council data management
  - Community management within their councils
  - Reports for their jurisdiction
  - Animal data within their councils

#### Veterinary Users - Hierarchical Navigation Flow
**Step 1: Council Selection**
- Upon login, display list of councils they have access to
- Click on a council to proceed to communities

**Step 2: Community Selection**
- Display list of communities within the selected council
- Show house count per community
- Click on a community to proceed to houses

**Step 3: House Management**
- Display list of houses within the selected community
- **House Operations Available:**
  - View existing houses
  - Add new houses
  - Edit house details (address, owner, GPS coordinates, description)
  - Delete houses
  - Search and filter houses

**Step 4: House Selection & Animal Management**
- Click on a specific house to access animal management
- **Animal Operations Available:**
  - View all animals associated with the house
  - Add new animals to the house
  - **Complete Animal Management:**
    - Animal registration and identification
    - Medical treatment administration and recording
    - Treatment history timeline
    - Vaccination schedules and records
    - Health condition monitoring
    - Medication tracking
    - Surgical procedure records
    - Follow-up appointment scheduling
    - Photo documentation
    - Clinical notes and observations
  - **Historical Data:**
    - If an animal was previously recorded at this house, display complete history
    - Treatment timeline showing all previous interventions
    - Medical history continuity across visits
    - Progress tracking over time

**Navigation Breadcrumbs:** Council > Community > Houses > Selected House > Animals

#### Census Users - Hierarchical Navigation Flow
**Step 1: Council Selection**
- Upon login, display list of councils they have access to
- Click on a council to proceed to communities

**Step 2: Community Selection**
- Display list of communities within the selected council
- Show house count and animal population data per community
- Click on a community to proceed to houses

**Step 3: House Management**
- Display list of houses within the selected community
- **House Operations Available:**
  - View existing houses
  - Add new houses
  - Edit house details (address, owner, GPS coordinates, description)
  - Delete houses
  - Search and filter houses

**Step 4: House Selection & Animal Census**
- Click on a specific house to access animal census management
- **Animal Census Operations Available:**
  - View all animals recorded at the house
  - Add new animals discovered during census
  - **Census-Specific Animal Management:**
    - Animal identification and registration
    - Population counting and tracking
    - Basic health condition assessment
    - Sterilization status recording
    - Ownership verification
    - Photo documentation for identification
    - Census notes and observations
  - **Historical Census Data:**
    - If an animal was previously counted at this house, display census history
    - Population changes over time
    - Health status progression
    - Ownership changes
    - Movement tracking between census periods

**Navigation Breadcrumbs:** Council > Community > Houses > Selected House > Census Animals

### Key Features of the Hierarchical Flow

#### Data Persistence and History
- **Animal Continuity**: When animals are encountered again at the same house, all previous data is retained and displayed
- **Treatment History**: Complete timeline of all veterinary interventions and treatments
- **Census History**: Population tracking over multiple census periods
- **Photo History**: Visual documentation over time for identification and condition monitoring

#### House-Centric Data Organization
- All animal data is organized by house location
- Easy tracking of animal populations per household
- Simplified data collection workflow
- Geographic organization of animal health and census data

#### Role-Specific Data Views
- **Veterinary Users**: Focus on medical treatments, health conditions, and clinical data
- **Census Users**: Focus on population data, basic health status, and demographic information
- **Shared Data**: Both roles contribute to the complete animal profile

#### Offline Capability
- All data collection can occur offline
- Synchronization when connectivity is restored
- Local data storage maintains navigation state
- Pending changes tracking per location level

## Screen Functionality

### 1. Login Screen
- User authentication interface
- Email and password validation
- Terms and conditions acceptance check
- Offline login support
- Error handling and user feedback
- Secure credential storage

### 2. Terms and Conditions Screen
- Display current terms and conditions
- Version tracking
- User acceptance mechanism
- Navigation back to login if rejected

### 3. Dashboard (Main Navigation)
- Tab-based navigation with four main sections:
  - My Councils/Census Council
  - Home
  - Search
  - Settings
- Platform-specific toolbar placement
- State management for navigation
- Sync status display

### 4. My Councils Screen
- List of councils managed by user
- Council selection functionality
- Community count display
- Census mode integration
- Navigation to community locations
- Refresh capabilities

### 5. Community Location Screen
- List of communities within selected council
- House count per community
- Census mode filtering
- Navigation to house list
- Community management
- Location-based filtering

### 6. House List Screen
- List of houses within selected community
- House details display
- Animal count per house
- Census mode integration
- Search and filter capabilities
- Navigation to house details
- Comment system integration

### 7. House Detail Screen
- Detailed house information display
- Address management
- Owner information
- Location coordinates
- Animal count tracking
- Edit capabilities
- Comment system
- Census mode integration

### 8. Search Screen
- Animal search functionality
- Multiple search criteria:
  - Chip number
  - Name
  - Owner
- Council-based filtering
- Census mode integration
- Search result navigation
- Minimum search length validation

### 9. Settings Screen
- User profile management
- Sync process control
- Clinical note templates
- Census mode configuration
- Password management
- Logout functionality
- App version information
- Pending changes tracking

### 10. Census Mode Screens
- Census selection interface
- Census-specific functionality
- Unconfirmed animals display
- Census data management
- Navigation controls
- Mode switching capabilities

### 11. Animal Management Screens
- Animal details display
- Species-specific information
- Age and size tracking
- Condition monitoring
- Census integration
- Location tracking
- Photo attachment support

### 12. Comment System
- Location-based comments
- House-specific comments
- Photo attachment support
- User attribution
- Timestamp tracking
- Offline support

### 13. Sync Process Screen
- Data synchronization status
- Pending changes display
- Sync controls
- Error handling
- Progress tracking
- Background sync support

## Entity Relationship Diagram

### Core Entities

#### User
- Primary Key: Id
- Fields:
  - Name: User's full name (Required, Max 100 chars)
  - Email: User's email address (Required, Unique, Valid email format)
  - Password: Encrypted password (Required, Min 8 chars, Must contain numbers and letters)
  - CensusMode: User's access mode (Required, Enum: Vet/Census/Both)
  - CreatedAt: Account creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - Email must be unique across all users
  - Password must be hashed before storage
  - CensusMode must be one of the predefined values
- Additional Validations:
  - Password must contain at least one uppercase letter
  - Password must contain at least one special character
  - Email domain must be from approved list
  - Name must not contain special characters
  - Account must be activated within 24 hours of creation
  - Failed login attempts limited to 5 within 15 minutes
- Description: Represents application users with different access levels
- Usage: Authentication, authorization, and user-specific data management

#### Council
- Primary Key: Id
- Fields:
  - Name: Full council name (Required, Max 200 chars)
  - ShortName: Abbreviated council name (Required, Max 50 chars)
  - State: Australian state/territory (Required, Valid state code)
  - Author: Council administrator (Required, Max 100 chars)
  - ImageId: Reference to council logo/image (Optional, Valid image reference)
  - CreatedAt: Council record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - Name must be unique across all councils
  - State must be a valid Australian state/territory code
  - ImageId must reference a valid image if provided
- Additional Validations:
  - ShortName must be unique across all councils
  - State code must be valid Australian state/territory abbreviation
  - Image must be in PNG or JPG format
  - Image size must not exceed 2MB
  - Author must be an active user in the system
  - Council cannot be deleted if it has associated communities
- Description: Represents local government councils
- Usage: Organization management and data segregation

#### Location (Community)
- Primary Key: Id
- Fields:
  - Name: Community name (Required, Max 100 chars)
  - AltName: Alternative community name (Optional, Max 100 chars)
  - Code: Unique community code (Required, Max 20 chars)
  - LocationTypeId: Type of community (Required, FK)
  - CouncilId: Associated council (Required, FK)
  - UseLotNumber: Boolean for address format (Required, Default: false)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - Code must be unique within a council
  - LocationTypeId must reference a valid location type
  - CouncilId must reference a valid council
- Additional Validations:
  - Code must start with council's state code
  - Code must not contain spaces or special characters
  - Name must be unique within the same council
  - AltName must be unique within the same council if provided
  - Community cannot be deleted if it has associated houses
  - LocationTypeId must be from predefined list of valid types
- Description: Represents communities within councils
- Usage: Geographic organization and address management

#### House
- Primary Key: Id
- Fields:
  - StreetNumber: Property street number (Required, Max 20 chars)
  - StreetName: Property street name (Required, Max 100 chars)
  - LotName: Property lot number (Optional, Max 50 chars)
  - Owner: Property owner's name (Required, Max 100 chars)
  - LocationId: Associated community (Required, FK)
  - CouncilId: Associated council (Required, FK)
  - Dogs: Number of dogs (Required, Min 0)
  - Cats: Number of cats (Required, Min 0)
  - Puppies: Number of puppies (Required, Min 0)
  - EntireFemale: Number of unsterilized females (Required, Min 0)
  - UseLotNumber: Boolean for address format (Required, Default: false)
  - Longitude: Geographic longitude (Required, Range: -180 to 180)
  - Latitude: Geographic latitude (Required, Range: -90 to 90)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - LocationId must reference a valid community
  - CouncilId must reference a valid council
  - All numeric counts must be non-negative
  - Coordinates must be within valid ranges
- Additional Validations:
  - StreetNumber must match format based on UseLotNumber setting
  - StreetName must not contain special characters except spaces and hyphens
  - LotName must be provided if UseLotNumber is true
  - Owner name must not contain special characters except spaces and hyphens
  - Total animal count (Dogs + Cats + Puppies) must not exceed 20
  - Coordinates must be within Australia's geographic bounds
  - House cannot be deleted if it has associated animals
  - StreetName must be a valid street name from the community's street list
- Description: Represents individual properties
- Usage: Property management and animal tracking

#### Animal
- Primary Key: Id
- Fields:
  - Name: Animal's name (Required, Max 100 chars)
  - SpeciesId: Animal species (Required, FK)
  - Gender: Animal's gender (Required, Enum: Male/Female/Unknown)
  - AgeId: Age group (Required, FK)
  - Size: Physical size (Required, Enum: Small/Medium/Large)
  - Colour: Coat color (Required, Max 50 chars)
  - StatusId: Current status (Required, Enum: Alive/Deceased)
  - CouncilId: Associated council (Required, FK)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - SpeciesId must reference a valid species
  - AgeId must reference a valid age group
  - CouncilId must reference a valid council
  - Gender must be one of the predefined values
  - Size must be one of the predefined values
  - StatusId must be one of the predefined values
- Additional Validations:
  - Name must not contain special characters except spaces and hyphens
  - Colour must be from predefined list of valid colors
  - AgeId must be compatible with SpeciesId
  - Status cannot be changed to Deceased without death date
  - Animal must have at least one associated house
  - Microchip number must be unique if provided
  - Size must be appropriate for the species
  - Status changes must be logged with reason
- Description: Represents individual animals
- Usage: Animal tracking and management

#### Census
- Primary Key: Id
- Fields:
  - Name: Census name (Required, Max 100 chars)
  - CouncilId: Associated council (Required, FK)
  - LocationId: Target community (Required, FK)
  - ValidFrom: Census start date (Required, Valid date)
  - ValidTo: Census end date (Required, Valid date, Must be after ValidFrom)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - CouncilId must reference a valid council
  - LocationId must reference a valid community
  - ValidTo must be after ValidFrom
  - Name must be unique within a council
- Additional Validations:
  - Name must include year and community code
  - ValidFrom must not be in the past
  - ValidTo must not be more than 12 months after ValidFrom
  - Census cannot overlap with existing census for same community
  - Census must have at least one assigned user
  - Census cannot be deleted if it has associated animal records
  - Census status must be one of: Draft/Active/Completed
  - Census completion requires minimum 90% coverage
- Description: Represents animal census periods
- Usage: Population tracking and management

### Junction Tables

#### AnimalHouse
- Primary Key: Id
- Fields:
  - AnimalId: Associated animal (Required, FK)
  - HouseId: Associated property (Required, FK)
  - ValidFrom: Start date of residence (Required, Valid date)
  - ValidTo: End date of residence (Optional, Valid date, Must be after ValidFrom)
  - CouncilId: Associated council (Required, FK)
  - LocationId: Associated community (Required, FK)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - AnimalId must reference a valid animal
  - HouseId must reference a valid house
  - CouncilId must reference a valid council
  - LocationId must reference a valid community
  - ValidTo must be after ValidFrom if provided
  - No overlapping date ranges for same animal-house combination
- Additional Validations:
  - ValidFrom must not be in the future
  - ValidTo must not be more than 5 years in the future
  - Animal must have at least one active residence
  - House must be in the same community as the animal's council
  - Residence changes must be logged with reason
  - Cannot have more than 20 animals per house at any time
  - Cannot have more than 5 dogs per house at any time
  - Cannot have more than 10 cats per house at any time
- Description: Tracks animal residence history
- Usage: Animal location history and movement tracking

#### AnimalCensuses
- Primary Key: Id
- Fields:
  - AnimalId: Associated animal (Required, FK)
  - CensusId: Associated census (Required, FK)
  - Name: Animal's name at census time (Required, Max 100 chars)
  - Species: Species at census time (Required, Max 50 chars)
  - Gender: Gender at census time (Required, Enum: Male/Female/Unknown)
  - ReproStatus: Reproductive status (Required, Enum: Entire/Desexed/Unknown)
  - Colour: Coat color at census time (Required, Max 50 chars)
  - BodyCondition: Physical condition (Required, Enum: Poor/Fair/Good)
  - HairSkin: Coat condition (Required, Enum: Poor/Fair/Good)
  - CommonProblem: Health issues (Optional, Max 500 chars)
  - AgeId: Age group at census time (Required, FK)
  - Size: Size at census time (Required, Enum: Small/Medium/Large)
  - TicksCondition: Tick infestation status (Required, Enum: None/Light/Heavy)
  - FleasCondition: Flea infestation status (Required, Enum: None/Light/Heavy)
  - Behaviours: Behavioral observations (Optional, Max 500 chars)
  - StatusId: Status at census time (Required, Enum: Alive/Deceased)
  - CensusName: Census name (Required, Max 100 chars)
  - CensusStatus: Animal's census status (Required, Enum: Confirmed/Unconfirmed)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - AnimalId must reference a valid animal
  - CensusId must reference a valid census
  - AgeId must reference a valid age group
  - All enum fields must have valid values
  - Text fields must not exceed maximum lengths
- Additional Validations:
  - Species must match the animal's current species
  - Gender must match the animal's current gender
  - AgeId must be compatible with the species
  - BodyCondition must be assessed by qualified personnel
  - Health issues must be documented if BodyCondition is Poor
  - Size must be appropriate for the species and age
  - Status changes must be documented with reason
  - CensusStatus can only be Confirmed by authorized users
  - Photo evidence required for Poor condition rating
  - Multiple health issues must be comma-separated
- Description: Records animal data during censuses
- Usage: Historical animal data tracking

#### MyCensuses
- Primary Key: Id
- Fields:
  - UserId: Associated user (Required, FK)
  - CensusId: Associated census (Required, FK)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - UserId must reference a valid user
  - CensusId must reference a valid census
  - Unique combination of UserId and CensusId
- Additional Validations:
  - User must have appropriate permissions for census
  - User cannot be assigned to more than 5 active censuses
  - Assignment must be approved by census administrator
  - User must be from the same council as the census
  - Assignment cannot be removed if census is in progress
- Description: Links users to their assigned censuses
- Usage: User-census assignment management

### Supporting Entities

#### Species
- Primary Key: Id
- Fields:
  - Name: Species name (Required, Max 50 chars)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - Name must be unique across all species
- Additional Validations:
  - Name must be from approved species list
  - Species cannot be deleted if it has associated animals
  - Name must not contain special characters
  - Species must have at least one age group defined
- Description: Defines animal species
- Usage: Animal classification

#### AgeGroup
- Primary Key: Id
- Fields:
  - Name: Age group name (Required, Max 50 chars)
  - SpeciesId: Associated species (Required, FK)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - SpeciesId must reference a valid species
  - Name must be unique within a species
- Additional Validations:
  - Name must be from predefined age group list
  - Age groups must be in correct order
  - Age ranges must not overlap
  - Age group cannot be deleted if it has associated animals
  - Species must have at least one age group
- Description: Defines age categories for species
- Usage: Age-based animal classification

#### ConditionType
- Primary Key: Id
- Fields:
  - Name: Condition type name (Required, Max 100 chars)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - Name must be unique across all condition types
- Additional Validations:
  - Name must be from approved condition list
  - Condition type cannot be deleted if it has associated records
  - Name must not contain special characters
  - Condition type must have severity levels defined
- Description: Defines types of health conditions
- Usage: Health condition categorization

#### AnimalCondition
- Primary Key: Id
- Fields:
  - AnimalId: Associated animal (Required, FK)
  - Conditions: Health conditions (Required, Max 500 chars)
  - Description: Condition details (Required, Max 1000 chars)
  - Author: Recording user (Required, Max 100 chars)
  - Note: Additional notes (Optional, Max 1000 chars)
  - AnimalCensusId: Associated census record (Optional, FK)
  - CensusName: Census name (Optional, Max 100 chars)
  - LocationId: Associated community (Required, FK)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - AnimalId must reference a valid animal
  - LocationId must reference a valid community
  - AnimalCensusId must reference a valid census record if provided
  - Text fields must not exceed maximum lengths
- Additional Validations:
  - Conditions must be from approved condition types
  - Author must be qualified to assess conditions
  - Severe conditions require immediate notification
  - Photo evidence required for severe conditions
  - Multiple conditions must be comma-separated
  - Description must include severity level
  - Note must include treatment recommendations
  - Condition cannot be added to deceased animals
  - Follow-up date required for chronic conditions
- Description: Records animal health conditions
- Usage: Health monitoring and tracking

#### AnimalBehaviour
- Primary Key: Id
- Fields:
  - AnimalId: Associated animal (Required, FK)
  - Behaviours: Observed behaviors (Required, Max 500 chars)
  - Description: Behavior details (Required, Max 1000 chars)
  - Author: Recording user (Required, Max 100 chars)
  - Note: Additional notes (Optional, Max 1000 chars)
  - AnimalCensusId: Associated census record (Optional, FK)
  - CensusName: Census name (Optional, Max 100 chars)
  - LocationId: Associated community (Required, FK)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - AnimalId must reference a valid animal
  - LocationId must reference a valid community
  - AnimalCensusId must reference a valid census record if provided
  - Text fields must not exceed maximum lengths
- Additional Validations:
  - Behaviours must be from approved behavior list
  - Author must be qualified to assess behaviors
  - Aggressive behaviors require immediate notification
  - Photo/video evidence required for unusual behaviors
  - Multiple behaviors must be comma-separated
  - Description must include context and frequency
  - Note must include management recommendations
  - Behavior cannot be recorded for deceased animals
  - Follow-up required for concerning behaviors
- Description: Records animal behaviors
- Usage: Behavioral monitoring and tracking

#### Note
- Primary Key: Id
- Fields:
  - ReferenceType: Type of referenced entity (Required, Enum: Animal/House/Location)
  - ReferenceId: ID of referenced entity (Required)
  - Description: Note content (Required, Max 1000 chars)
  - Author: Note creator (Required, Max 100 chars)
  - CouncilId: Associated council (Required, FK)
  - LocationId: Associated community (Required, FK)
  - CreatedAt: Record creation timestamp (Required, Auto-generated)
  - UpdatedAt: Last update timestamp (Required, Auto-updated)
- Constraints:
  - ReferenceType must be one of the predefined values
  - ReferenceId must reference a valid entity of the specified type
  - CouncilId must reference a valid council
  - LocationId must reference a valid community
  - Text fields must not exceed maximum lengths
- Additional Validations:
  - Author must have permission to add notes
  - Description must not contain sensitive information
  - Note cannot be deleted after 24 hours
  - Photo attachments must be less than 5MB
  - Maximum 5 photos per note
  - Notes must be in English
  - Notes must be properly formatted
  - Notes cannot be added to deleted entities
  - Notes require approval for sensitive content
- Description: Generic note system for various entities
- Usage: General commenting and documentation

### Relationships

1. Council -> Location: One-to-Many
   - A council can have multiple communities
   - Each community belongs to one council

2. Location -> House: One-to-Many
   - A community can have multiple houses
   - Each house belongs to one community

3. House -> AnimalHouse: One-to-Many
   - A house can have multiple animal residents over time
   - Each animal-house association is time-bound

4. Animal -> AnimalHouse: One-to-Many
   - An animal can live at multiple houses over time
   - Each residence is tracked with validity period

5. Animal -> AnimalCensuses: One-to-Many
   - An animal can be included in multiple censuses
   - Each census record contains snapshot of animal data

6. Census -> AnimalCensuses: One-to-Many
   - A census can include multiple animals
   - Each record represents one animal in the census

7. User -> MyCensuses: One-to-Many
   - A user can be assigned to multiple censuses
   - Each assignment links user to specific census

8. Census -> MyCensuses: One-to-Many
   - A census can be assigned to multiple users
   - Each assignment links census to specific user

9. Species -> AgeGroup: One-to-Many
   - A species can have multiple age groups
   - Each age group is specific to one species

10. Animal -> AnimalCondition: One-to-Many
    - An animal can have multiple health conditions
    - Each condition is recorded with details

11. Animal -> AnimalBehaviour: One-to-Many
    - An animal can have multiple behavior records
    - Each record captures specific behavior observation

12. Animal -> Note: One-to-Many
    - An animal can have multiple notes
    - Each note is linked to specific animal

13. House -> Note: One-to-Many
    - A house can have multiple notes
    - Each note is linked to specific house

14. Location -> Note: One-to-Many
    - A community can have multiple notes
    - Each note is linked to specific community

### Common Fields
All entities include:
- Id (Primary Key): Unique identifier
- UserId: Creator of the record
- UserModifierId: Last modifier of the record
- OfflineCreatedAt: Local creation timestamp
- OfflineUpdatedAt: Local update timestamp

### Business Rules

#### User Management
1. User Access Levels
   - Vet users can only access veterinary functions
   - Census users can only access census functions
   - Users with Both access can access all functions
   - Admin users have full system access

2. User Permissions
   - Users can only access data within their assigned councils
   - Users cannot modify data from other councils
   - Users can only view their own notes and comments
   - Admin users can view and modify all data

3. User Security
   - Passwords must be changed every 90 days
   - Account locked after 5 failed login attempts
   - Password reset requires email verification
   - Session timeout after 30 minutes of inactivity

4. User Training
   - New users must complete mandatory training
   - Training records must be maintained
   - Annual refresher training required
   - Training completion must be verified

5. User Activity Monitoring
   - User actions must be logged
   - Suspicious activities must be flagged
   - Regular activity reports must be generated
   - Inactive accounts must be reviewed

#### Council Management
1. Council Data Access
   - Council data is isolated from other councils
   - Council administrators can manage their council's data
   - Council data can only be accessed by authorized users
   - Council deletion requires approval from system admin

2. Council Configuration
   - Each council must have at least one administrator
   - Council settings must be configured before use
   - Council boundaries must be defined
   - Council-specific rules must be documented

3. Council Reporting
   - Monthly activity reports required
   - Annual compliance reports mandatory
   - Incident reports must be filed within 24 hours
   - Performance metrics must be tracked

4. Council Communication
   - Council-wide announcements must be approved
   - Emergency notifications must be prioritized
   - Communication logs must be maintained
   - Response times must be monitored

#### Community Management
1. Community Rules
   - Communities must be within council boundaries
   - Community codes must follow council's naming convention
   - Community cannot span multiple councils
   - Community deletion requires council admin approval

2. Community Data
   - Community data is restricted to council users
   - Community boundaries must be defined
   - Community-specific rules must be documented
   - Community status must be tracked

3. Community Engagement
   - Community meetings must be documented
   - Local feedback must be collected
   - Community concerns must be addressed
   - Engagement metrics must be tracked

4. Community Resources
   - Resource allocation must be documented
   - Resource usage must be tracked
   - Resource maintenance schedules must be maintained
   - Resource availability must be monitored

#### House Management
1. House Registration
   - Houses must be registered within a community
   - House addresses must be unique within a community
   - House coordinates must be accurate
   - House status must be tracked

2. House Occupancy
   - Maximum 20 animals per house
   - Maximum 5 dogs per house
   - Maximum 10 cats per house
   - House occupancy must be updated annually

3. House Inspections
   - Regular inspections must be scheduled
   - Inspection reports must be filed
   - Violations must be documented
   - Follow-up actions must be tracked

4. House Maintenance
   - Maintenance schedules must be maintained
   - Repair requests must be logged
   - Maintenance history must be documented
   - Property conditions must be assessed

#### Animal Management
1. Animal Registration
   - Animals must be registered with a valid owner
   - Animals must have a unique identifier
   - Animal status must be tracked
   - Animal location must be updated when changed

2. Animal Health
   - Health conditions must be assessed by qualified personnel
   - Severe conditions require immediate notification
   - Health records must be maintained
   - Follow-up appointments must be scheduled

3. Animal Movement
   - Animal movements must be tracked
   - Movement history must be maintained
   - Movement notifications must be sent
   - Movement restrictions must be enforced

4. Animal Welfare
   - Welfare checks must be scheduled
   - Welfare concerns must be reported
   - Intervention plans must be documented
   - Welfare outcomes must be tracked

5. Animal Identification
   - Microchip numbers must be verified
   - Visual identification must be maintained
   - ID changes must be documented
   - ID verification must be periodic

#### Census Management
1. Census Planning
   - Censuses must be planned in advance
   - Census areas must be defined
   - Census teams must be assigned
   - Census resources must be allocated

2. Census Execution
   - Census data must be collected within defined period
   - Census coverage must meet minimum requirements
   - Census data must be validated
   - Census results must be reviewed

3. Census Reporting
   - Census reports must be generated
   - Census data must be analyzed
   - Census findings must be documented
   - Census recommendations must be made

4. Census Quality Control
   - Data accuracy must be verified
   - Coverage gaps must be identified
   - Quality metrics must be tracked
   - Quality improvement plans must be developed

5. Census Follow-up
   - Follow-up visits must be scheduled
   - Missing data must be collected
   - Data corrections must be documented
   - Follow-up results must be reported

#### Data Management
1. Data Integrity
   - All data changes must be logged
   - Data backups must be maintained
   - Data validation must be performed
   - Data consistency must be maintained

2. Data Access
   - Data access must be audited
   - Sensitive data must be protected
   - Data sharing must be controlled
   - Data retention must be managed

3. Data Synchronization
   - Offline changes must be synchronized
   - Conflicts must be resolved
   - Sync status must be tracked
   - Sync errors must be handled

4. Data Quality
   - Data accuracy must be verified
   - Data completeness must be checked
   - Data timeliness must be monitored
   - Data quality reports must be generated

5. Data Security
   - Data encryption must be maintained
   - Access controls must be enforced
   - Security breaches must be reported
   - Security measures must be reviewed

#### Reporting
1. Report Generation
   - Reports must be scheduled
   - Report formats must be standardized
   - Report data must be validated
   - Reports must be archived

2. Report Access
   - Report access must be controlled
   - Report distribution must be managed
   - Report confidentiality must be maintained
   - Report retention must be enforced

3. Report Analysis
   - Trends must be identified
   - Patterns must be analyzed
   - Insights must be documented
   - Recommendations must be made

4. Report Distribution
   - Distribution lists must be maintained
   - Delivery schedules must be followed
   - Receipt must be confirmed
   - Feedback must be collected

#### Compliance
1. Regulatory Requirements
   - Local regulations must be followed
   - State requirements must be met
   - Federal guidelines must be adhered to
   - International standards must be considered

2. Documentation
   - All actions must be documented
   - Documentation must be maintained
   - Documentation must be accessible
   - Documentation must be secure

3. Compliance Monitoring
   - Regular audits must be conducted
   - Violations must be reported
   - Corrective actions must be taken
   - Compliance status must be tracked

4. Compliance Training
   - Training programs must be developed
   - Training attendance must be recorded
   - Training effectiveness must be assessed
   - Training materials must be updated

5. Data Protection Compliance
   - GDPR compliance requirements must be met
   - Australian Privacy Principles must be followed
   - Data retention periods must be enforced
   - Data subject rights must be respected
   - Data breach notification procedures must be in place
   - Data transfer restrictions must be enforced
   - Data minimization principles must be applied
   - Data accuracy must be maintained

6. Animal Welfare Compliance
   - Animal welfare standards must be met
   - Veterinary practice guidelines must be followed
   - Animal handling protocols must be adhered to
   - Emergency response procedures must be in place
   - Animal transport regulations must be followed
   - Euthanasia guidelines must be complied with
   - Animal research ethics must be considered
   - Wildlife protection laws must be followed

7. Environmental Compliance
   - Environmental protection regulations must be followed
   - Waste management guidelines must be adhered to
   - Resource conservation requirements must be met
   - Environmental impact assessments must be conducted
   - Sustainable practices must be implemented
   - Carbon footprint must be monitored
   - Environmental reporting must be maintained
   - Green initiatives must be supported

8. Occupational Health and Safety
   - Workplace safety regulations must be followed
   - Risk assessments must be conducted
   - Safety procedures must be documented
   - Personal protective equipment must be provided
   - Emergency response plans must be in place
   - Injury reporting procedures must be followed
   - Safety training must be provided
   - Workplace inspections must be conducted

9. Financial Compliance
   - Financial reporting standards must be met
   - Budgetary controls must be implemented
   - Financial records must be maintained
   - Audit trails must be preserved
   - Financial policies must be followed
   - Expense management must be controlled
   - Financial transparency must be maintained
   - Financial risk management must be practiced

10. Information Security Compliance
    - Information security standards must be met
    - Access control policies must be enforced
    - Security incident response procedures must be in place
    - Security awareness training must be provided
    - Security assessments must be conducted
    - Security documentation must be maintained
    - Security controls must be implemented
    - Security monitoring must be performed

11. Quality Management Compliance
    - Quality management standards must be met
    - Quality control procedures must be followed
    - Quality assurance processes must be implemented
    - Quality documentation must be maintained
    - Quality audits must be conducted
    - Quality metrics must be tracked
    - Quality improvement plans must be developed
    - Quality training must be provided

12. Human Resources Compliance
    - Employment laws must be followed
    - Workplace policies must be enforced
    - Employee rights must be protected
    - Discrimination laws must be adhered to
    - Workplace harassment policies must be followed
    - Employee records must be maintained
    - Training requirements must be met
    - Performance management must be conducted

13. Records Management Compliance
    - Records management standards must be met
    - Record retention policies must be followed
    - Record disposal procedures must be implemented
    - Record access controls must be enforced
    - Record documentation must be maintained
    - Record audits must be conducted
    - Record security must be ensured
    - Record recovery procedures must be in place

14. Communication Compliance
    - Communication standards must be met
    - Communication protocols must be followed
    - Communication records must be maintained
    - Communication security must be ensured
    - Communication policies must be enforced
    - Communication training must be provided
    - Communication monitoring must be performed
    - Communication documentation must be maintained

15. Emergency Management Compliance
    - Emergency management standards must be met
    - Emergency response procedures must be in place
    - Emergency communication protocols must be followed
    - Emergency documentation must be maintained
    - Emergency training must be provided
    - Emergency drills must be conducted
    - Emergency equipment must be maintained
    - Emergency contacts must be updated

16. Asset Management Compliance
    - Asset management standards must be met
    - Asset tracking procedures must be followed
    - Asset maintenance schedules must be maintained
    - Asset documentation must be kept
    - Asset security must be ensured
    - Asset disposal procedures must be followed
    - Asset audits must be conducted
    - Asset reporting must be maintained

17. Vendor Management Compliance
    - Vendor management standards must be met
    - Vendor selection criteria must be followed
    - Vendor agreements must be maintained
    - Vendor performance must be monitored
    - Vendor documentation must be kept
    - Vendor security must be assessed
    - Vendor compliance must be verified
    - Vendor reporting must be maintained

18. Change Management Compliance
    - Change management standards must be met
    - Change procedures must be followed
    - Change documentation must be maintained
    - Change impact assessments must be conducted
    - Change communication must be managed
    - Change training must be provided
    - Change monitoring must be performed
    - Change reporting must be maintained

19. Risk Management Compliance
    - Risk management standards must be met
    - Risk assessments must be conducted
    - Risk mitigation procedures must be implemented
    - Risk documentation must be maintained
    - Risk monitoring must be performed
    - Risk reporting must be maintained
    - Risk training must be provided
    - Risk reviews must be conducted

20. Project Management Compliance
    - Project management standards must be met
    - Project procedures must be followed
    - Project documentation must be maintained
    - Project monitoring must be performed
    - Project reporting must be maintained
    - Project training must be provided
    - Project reviews must be conducted
    - Project closure procedures must be followed

## User Flow Stories

### 1. Standard User Flow (Vet Mode)

#### Initial Login and Setup
1. User launches the application and enters their credentials
2. System validates credentials and loads user profile
3. User accepts terms and conditions if first-time login
4. System loads user's assigned councils and permissions
5. User selects their primary council from the dashboard

#### Council Management
1. User navigates to My Councils screen
2. Views list of assigned councils with community counts
3. Selects a council to view its communities
4. Reviews council statistics and recent activities
5. Updates council settings if authorized

#### Community Management
1. User views communities within selected council
2. Reviews community statistics and house counts
3. Adds new community if authorized
4. Updates community information as needed
5. Manages community-specific settings

#### House Management
1. User selects a community to view houses
2. Reviews house list with animal counts
3. Adds new house with property details
4. Updates house information and coordinates
5. Manages house-specific notes and comments

#### Animal Management
1. User selects a house to view animals
2. Reviews animal list with health status
3. Adds new animal with details
4. Updates animal information and health records
5. Manages animal-specific notes and conditions

#### Health Monitoring
1. User records animal health conditions
2. Updates treatment plans and medications
3. Schedules follow-up appointments
4. Documents behavioral observations
5. Manages health-related notes

### 2. Census Mode Flow

#### Census Preparation
1. User switches to Census mode
2. Views assigned census areas
3. Reviews census requirements and guidelines
4. Prepares census materials and forms
5. Coordinates with team members

#### Census Execution
1. User navigates to assigned community
2. Reviews house list for census
3. Records animal information
4. Documents health conditions
5. Takes photos as required

#### Data Collection
1. User enters census data
2. Validates information accuracy
3. Records missing data flags
4. Documents special cases
5. Manages census-specific notes

#### Census Review
1. User reviews collected data
2. Validates census coverage
3. Identifies data gaps
4. Plans follow-up visits
5. Generates census reports

### 3. Combined Mode Flow (Vet & Census)

#### Mode Switching
1. User switches between Vet and Census modes
2. System adjusts available functions
3. User maintains context between modes
4. Data remains consistent across modes
5. User manages mode-specific tasks

#### Integrated Workflow
1. User performs health checks during census
2. Updates animal records in both modes
3. Manages census and health data
4. Coordinates with team members
5. Generates combined reports

### 4. Search and Navigation Flow

#### Search Operations
1. User accesses search screen
2. Enters search criteria
3. Filters results by council/community
4. Reviews search results
5. Navigates to specific records

#### Advanced Search
1. User applies multiple filters
2. Uses date range filters
3. Searches by health status
4. Filters by census status
5. Exports search results

### 5. Settings and Configuration Flow

#### User Settings
1. User accesses settings screen
2. Updates profile information
3. Configures notification preferences
4. Manages sync settings
5. Updates password

#### Application Settings
1. User configures display options
2. Sets default council/community
3. Manages offline data
4. Configures backup options
5. Updates clinical note templates

### 6. Data Synchronization Flow

#### Manual Sync
1. User initiates sync process
2. Reviews pending changes
3. Resolves conflicts if any
4. Confirms sync completion
5. Reviews sync status

#### Background Sync
1. System performs automatic sync
2. Notifies user of completion
3. Reports any issues
4. Updates sync status
5. Maintains data consistency

### 7. Emergency Response Flow

#### Emergency Situation
1. User identifies emergency
2. Records emergency details
3. Notifies appropriate personnel
4. Documents response actions
5. Updates status

#### Follow-up Actions
1. User schedules follow-up
2. Updates emergency records
3. Documents resolution
4. Generates incident report
5. Updates prevention measures

### 8. Reporting Flow

#### Report Generation
1. User selects report type
2. Configures report parameters
3. Generates report
4. Reviews report content
5. Exports or shares report

#### Report Management
1. User saves report templates
2. Schedules regular reports
3. Manages report access
4. Archives reports
5. Tracks report history

### 9. Documentation Flow

#### Note Creation
1. User selects entity for note
2. Creates new note
3. Attaches photos if needed
4. Tags relevant personnel
5. Saves and shares note

#### Note Management
1. User reviews note history
2. Updates existing notes
3. Manages note access
4. Archives old notes
5. Searches through notes

### 10. Training and Support Flow

#### User Training
1. User accesses training materials
2. Completes required modules
3. Takes assessments
4. Receives certification
5. Updates training records

#### Support Access
1. User accesses help resources
2. Contacts support team
3. Submits support tickets
4. Receives assistance
5. Documents resolution

Each flow represents a different aspect of the application's functionality, and users may combine these flows based on their roles and requirements. The system maintains consistency and data integrity across all flows while providing appropriate access controls and validation at each step.

## Offline Features

### 1. Offline Data Storage

#### Local Database
- Uses SQLite for local storage
- Implements MobileServiceSQLiteStore for offline data management
- Stores data for 42 different tables including:
  - Core data (Animals, Houses, Censuses)
  - Reference data (Species, Breeds, Conditions)
  - User data (MyCouncils, MyCensuses)
  - Supporting data (Notes, Attachments, Clinical Notes)

#### Data Synchronization
- Full sync capability for complete data refresh
- Incremental sync for efficient updates
- Parameter sync for lookup tables
- Attachment sync for file management
- Background sync for automatic updates

### 2. Offline Operations

#### Data Creation
- Users can create new records without internet connection
- Local timestamps track creation time
- User attribution maintained for offline changes
- Data stored locally until sync

#### Data Modification
- Edit existing records offline
- Track modifications with local timestamps
- Maintain modification history
- Queue changes for sync

#### Data Deletion
- Support for offline record deletion
- Track deleted records locally
- Sync deletions when online
- Maintain referential integrity

### 3. Sync Management

#### Manual Sync
- User-initiated sync process
- Full sync option available
- Selective sync for specific data types
- Progress tracking and status updates

#### Automatic Sync
- Background sync when online
- Periodic sync checks
- Configurable sync intervals
- Network-aware sync scheduling

#### Conflict Resolution
- Server-wins conflict resolution
- Conflict detection and logging
- User notification of conflicts
- Conflict resolution history

### 4. Offline UI Components

#### Sync Status Display
- Show current sync status
- Display pending changes count
- Indicate network connectivity
- Show last sync timestamp

#### Sync Controls
- Manual sync triggers
- Sync type selection
- Progress indicators
- Error notifications

#### Offline Indicators
- Visual indicators for offline mode
- Pending changes warnings
- Sync status messages
- Network status display

### 5. Data Integrity

#### Offline Tracking
- OfflineCreatedAt timestamp
- OfflineUpdatedAt timestamp
- User attribution tracking
- Change history maintenance

#### Data Validation
- Local validation rules
- Data integrity checks
- Required field validation
- Relationship validation

#### Error Handling
- Network error management
- Sync error recovery
- Data corruption prevention
- Error logging and reporting

### 6. Performance Optimization

#### Data Management
- Efficient local storage
- Optimized query performance
- Batch processing support
- Cache management

#### Resource Usage
- Minimal storage footprint
- Efficient memory usage
- Battery usage optimization
- Network bandwidth management

### 7. Security

#### Data Protection
- Local data encryption
- Secure storage practices
- Access control maintenance
- Privacy protection

#### Authentication
- Offline authentication support
- Token management
- Session handling
- Security state maintenance

### 8. User Experience

#### Seamless Operation
- Transparent online/offline transition
- Consistent user interface
- Intuitive sync controls
- Clear status feedback

#### Error Recovery
- Automatic retry mechanisms
- User-friendly error messages
- Recovery procedures
- Data loss prevention

### 9. Monitoring and Maintenance

#### Sync Monitoring
- Sync success tracking
- Error rate monitoring
- Performance metrics
- Usage statistics

#### Maintenance Tools
- Cache cleanup utilities
- Data repair tools
- Sync reset options
- Diagnostic capabilities

### 10. Business Rules

#### Offline Workflows
- Defined offline procedures
- Data entry guidelines
- Validation requirements
- Business process maintenance

#### Compliance
- Regulatory requirements
- Data retention rules
- Privacy compliance
- Audit trail maintenance

Each component of the offline functionality is designed to provide a seamless experience for users working in areas with limited or no internet connectivity while maintaining data integrity and security. The system automatically handles the transition between online and offline states, ensuring that users can continue their work without interruption.

## UI Elements

### 1. Logos and Branding

#### Application Logo
- Primary Logo: AMRRIC logo in PNG format
- Size: 200x60 pixels
- Color: Primary color (#512BD4)
- Placement: Top-left corner of app bar
- Usage: App identification and branding

#### Council Logos
- Format: PNG or JPG
- Size: 100x100 pixels maximum
- Placement: Council detail screens
- Usage: Council identification

#### Loading Logo
- Animated AMRRIC logo
- Size: 100x100 pixels
- Color: Primary color (#512BD4)
- Usage: Loading screens and sync operations

### 2. Banners

#### Top Banner
- Height: 60 pixels
- Background: Primary color (#512BD4)
- Content:
  - Application logo (left)
  - Sync status indicator (right)
  - Pending changes count (right)
- Usage: Main navigation and status display

#### Status Banner
- Height: 40 pixels
- Background: Secondary color (#DFD8F7)
- Content:
  - Current mode (Vet/Census)
  - Selected council
  - Network status
- Usage: Context and status information

#### Warning Banner
- Height: 40 pixels
- Background: Warning color (#FFA500)
- Content:
  - Warning message
  - Action button (if applicable)
- Usage: Important notifications and warnings

#### Success Banner
- Height: 40 pixels
- Background: Success color (#4CAF50)
- Content:
  - Success message
  - Action button (if applicable)
- Usage: Operation completion notifications

### 3. Footers

#### Main Footer
- Height: 50 pixels
- Background: White
- Content:
  - Copyright information
  - Version number
  - Build number
- Usage: Application information

#### Sync Footer
- Height: 40 pixels
- Background: Gray100 (#E1E1E1)
- Content:
  - Last sync time
  - Pending changes count
  - Sync status
- Usage: Sync status information

### 4. Menu Items

#### Main Menu
1. My Councils
   - Council list
   - Council selection
   - Council management
   - Council settings

2. Home
   - Dashboard
   - Recent activities
   - Quick actions
   - Notifications

3. Search
   - Animal search
   - House search
   - Advanced filters
   - Search history

4. Settings
   - User profile
   - Sync settings
   - App configuration
   - Help and support

#### Context Menus

##### Animal Context Menu
- View Details
- Edit Information
- Add Condition
- Add Note
- Take Photo
- View History
- Delete Animal

##### House Context Menu
- View Details
- Edit Information
- Add Note
- View Animals
- Take Photo
- View History
- Delete House

##### Census Context Menu
- View Details
- Edit Information
- Add Note
- View Animals
- Generate Report
- Export Data
- Delete Census

#### Action Menus

##### Sync Menu
- Full Sync
- Sync Changes
- Sync Attachments
- View Sync Status
- Clear Cache
- Reset Sync

##### Settings Menu
- User Profile
- App Settings
- Sync Settings
- Notification Settings
- Privacy Settings
- Help & Support
- About
- Logout

##### Help Menu
- User Guide
- FAQ
- Contact Support
- Report Issue
- Check Updates
- Terms & Conditions
- Privacy Policy

### 5. Navigation Elements

#### Tab Bar
- Background: White
- Height: 50 pixels
- Items:
  - My Councils
  - Home
  - Search
  - Settings
- Active color: Primary (#512BD4)
- Inactive color: Gray400 (#919191)

#### Breadcrumb Navigation
- Background: Gray100 (#E1E1E1)
- Height: 40 pixels
- Content: Current location path
- Usage: Location context

#### Back Button
- Style: Icon + Text
- Color: Primary (#512BD4)
- Size: 44x44 pixels
- Usage: Navigation history

### 6. Common UI Elements

#### Buttons
1. Primary Button
   - Background: Primary (#512BD4)
   - Text: White
   - Size: 44x44 pixels minimum
   - Usage: Main actions

2. Secondary Button
   - Background: Secondary (#DFD8F7)
   - Text: Primary (#512BD4)
   - Size: 44x44 pixels minimum
   - Usage: Alternative actions

3. Danger Button
   - Background: Red (#FF0000)
   - Text: White
   - Size: 44x44 pixels minimum
   - Usage: Destructive actions

#### Icons
- Style: Material Design
- Size: 24x24 pixels
- Color: Primary (#512BD4)
- Usage: Visual indicators

#### Loading Indicators
1. Progress Bar
   - Height: 4 pixels
   - Color: Primary (#512BD4)
   - Usage: Operation progress

2. Activity Indicator
   - Size: 40x40 pixels
   - Color: Primary (#512BD4)
   - Usage: Loading states

### 7. Form Elements

#### Input Fields
- Height: 44 pixels
- Border: Gray300 (#ACACAC)
- Focus color: Primary (#512BD4)
- Error color: Red (#FF0000)

#### Dropdowns
- Height: 44 pixels
- Background: White
- Border: Gray300 (#ACACAC)
- Arrow color: Gray400 (#919191)

#### Checkboxes
- Size: 24x24 pixels
- Border: Gray300 (#ACACAC)
- Check color: Primary (#512BD4)

#### Radio Buttons
- Size: 24x24 pixels
- Border: Gray300 (#ACACAC)
- Selected color: Primary (#512BD4)

### 8. List Elements

#### List Items
- Height: 60 pixels
- Background: White
- Border: Gray100 (#E1E1E1)
- Padding: 16 pixels

#### List Headers
- Height: 40 pixels
- Background: Gray100 (#E1E1E1)
- Text: Gray600 (#404040)

#### List Footers
- Height: 40 pixels
- Background: Gray100 (#E1E1E1)
- Text: Gray600 (#404040)

### 9. Modal Elements

#### Alert Dialogs
- Width: 80% of screen
- Background: White
- Border radius: 8 pixels
- Shadow: 4 pixels

#### Action Sheets
- Width: 100% of screen
- Background: White
- Border radius: 8 pixels top
- Shadow: 4 pixels

#### Popup Pages
- Width: 90% of screen
- Height: 80% of screen
- Background: White
- Border radius: 8 pixels
- Shadow: 4 pixels

### 10. Platform-Specific Elements

#### iOS
- Native navigation bar
- iOS-style buttons
- iOS-style alerts
- iOS-style action sheets

#### Android
- Material Design components
- Android-style buttons
- Android-style alerts
- Android-style bottom sheets

#### MacCatalyst
- macOS-style navigation
- macOS-style buttons
- macOS-style alerts
- macOS-style sheets

Each UI element is designed to provide a consistent and intuitive user experience across all platforms while maintaining platform-specific design guidelines where appropriate. The elements are optimized for both touch and mouse input, ensuring accessibility and usability for all users.

## Images and Icons

### 1. Application Images

#### Logo Images
- **Primary Logo**
  - File: `Resources/Images/amrric_logo.png`
  - Size: 200x60 pixels
  - Format: PNG with transparency
  - Usage: Main app bar, splash screen
  - Color: Primary (#512BD4)

- **Loading Logo**
  - File: `Resources/Images/amrric_loading.png`
  - Size: 100x100 pixels
  - Format: PNG with transparency
  - Usage: Loading screens, sync operations
  - Animation: Rotating animation

- **Splash Screen Logo**
  - File: `Resources/Images/amrric_splash.png`
  - Size: 300x300 pixels
  - Format: PNG with transparency
  - Usage: Application launch screen
  - Animation: Fade-in effect

#### Council Images
- **Council Logo**
  - File: `Resources/Images/councils/{council_id}.png`
  - Size: 100x100 pixels
  - Format: PNG or JPG
  - Usage: Council detail screens
  - Storage: Azure Blob Storage

- **Council Banner**
  - File: `Resources/Images/councils/{council_id}_banner.png`
  - Size: 800x200 pixels
  - Format: PNG or JPG
  - Usage: Council header
  - Storage: Azure Blob Storage

### 2. UI Icons

#### Navigation Icons
- **Home Icon**
  - File: `Resources/Icons/home.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Primary (#512BD4)

- **Search Icon**
  - File: `Resources/Icons/search.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Primary (#512BD4)

- **Settings Icon**
  - File: `Resources/Icons/settings.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Primary (#512BD4)

#### Action Icons
- **Add Icon**
  - File: `Resources/Icons/add.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Primary (#512BD4)

- **Edit Icon**
  - File: `Resources/Icons/edit.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Primary (#512BD4)

- **Delete Icon**
  - File: `Resources/Icons/delete.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Danger (#FF0000)

#### Status Icons
- **Success Icon**
  - File: `Resources/Icons/success.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Success (#4CAF50)

- **Warning Icon**
  - File: `Resources/Icons/warning.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Warning (#FFA500)

- **Error Icon**
  - File: `Resources/Icons/error.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Error (#FF0000)

#### Feature Icons
- **Animal Icons**
  - File: `Resources/Icons/animal.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Primary (#512BD4)

- **House Icons**
  - File: `Resources/Icons/house.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Primary (#512BD4)

- **Census Icons**
  - File: `Resources/Icons/census.png`
  - Size: 24x24 pixels
  - Style: Material Design
  - Color: Primary (#512BD4)

### 3. Animal Images

#### Profile Images
- **Animal Photo**
  - File: `Resources/Images/animals/{animal_id}.jpg`
  - Size: 400x400 pixels
  - Format: JPG
  - Usage: Animal profile
  - Storage: Azure Blob Storage

- **Animal Thumbnail**
  - File: `Resources/Images/animals/{animal_id}_thumb.jpg`
  - Size: 100x100 pixels
  - Format: JPG
  - Usage: Animal list items
  - Storage: Azure Blob Storage

#### Medical Images
- **Condition Photos**
  - File: `Resources/Images/conditions/{condition_id}.jpg`
  - Size: 800x600 pixels
  - Format: JPG
  - Usage: Medical records
  - Storage: Azure Blob Storage

- **Treatment Photos**
  - File: `Resources/Images/treatments/{treatment_id}.jpg`
  - Size: 800x600 pixels
  - Format: JPG
  - Usage: Treatment records
  - Storage: Azure Blob Storage

### 4. House Images

#### Property Images
- **House Photo**
  - File: `Resources/Images/houses/{house_id}.jpg`
  - Size: 800x600 pixels
  - Format: JPG
  - Usage: House profile
  - Storage: Azure Blob Storage

- **House Thumbnail**
  - File: `Resources/Images/houses/{house_id}_thumb.jpg`
  - Size: 200x150 pixels
  - Format: JPG
  - Usage: House list items
  - Storage: Azure Blob Storage

### 5. Image Management

#### Storage
- **Azure Blob Storage**
  - Container: `amrric-images`
  - Access: Private
  - CDN: Enabled
  - Backup: Daily

#### Processing
- **Image Optimization**
  - Compression: Enabled
  - Format: WebP with fallback
  - Quality: 80%
  - Max size: 2MB

#### Caching
- **Client Cache**
  - Duration: 7 days
  - Strategy: Cache-Control
  - Validation: ETag

#### Security
- **Access Control**
  - Authentication: Required
  - Authorization: Role-based
  - Encryption: At rest

All images and icons are optimized for both performance and quality, with appropriate caching strategies and security measures in place. The system supports multiple image sizes and formats to ensure optimal display across different devices and network conditions.

## Screen Designs

### 1. House Management Screens

#### Add House Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - Height: 60px
  - Title: "Add House" (centered, white text)
  - Left button: X icon (white)
  - Right button: "Save" text (white)
- **Form Elements**
  - Field labels: Light gray text, left-aligned
  - Required fields: Marked with asterisk (*)
  - Input fields: Full width, white background
  - GPS Coordinates section: Boxed container
  - GPS buttons: "Current Location" (teal) and "Clear Coordinates" (red)
- **Input Types**
  - Location: Community selector (pre-filled)
  - Street Address: Text input
  - Owner: Text input
  - GPS Coordinates: Numeric inputs with placeholders showing format
- **Layout**
  - Vertical form with standard spacing
  - iOS keyboard displayed when focused

#### House Listing Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - Height: 60px
  - Title structure: "Community Name" with back button
  - Edit button: Pencil icon (right)
- **Tab Navigation**
  - Tab options: "Houses" and "Comments"
  - Selected tab: Underlined with blue
  - Count indicators: Circular badges with counts
- **List Items**
  - House names: Gray text, left-aligned
  - Animal counts: Right-aligned with animal icons
  - Warning indicators: Red triangle icon for attention
  - Comments: Speech bubble indicator (filled/empty)
- **Actions**
  - Floating action button: Green "+" in bottom-right
- **Footer Navigation**
  - Four icons: My Councils, Home, Search, Settings
  - Active icon: Highlighted in application color

### 2. Animal Management Screens

#### Animal Details Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - Height: 60px
  - Title: "Animal" with save button
  - Back button: X icon (left)
- **Tab Navigation**
  - Tab options: "Details", "Condition", "Behaviour"
  - Selected tab: Underlined with blue
- **Form Fields**
  - Status: With health icon (green heart)
  - Name: Text input
  - Owner: Text input
  - Gender: With animal icon, dropdown
  - Breed: With clear button (X)
  - Reproductive status: With icon, dropdown
  - Age: Dropdown (showing "Adult")
  - Size: Dropdown
  - Weight: Numeric input
  - Microchip: With barcode icon
  - Registration: Text input
  - Colour: With color circle icon, dropdown
- **Navigation**
  - Next/Previous buttons: Teal buttons at bottom
  - House change: With house icon

#### Animal Condition Screen
- **Layout**
  - Sliders for condition ratings
  - Condition categories: Body Condition, Hair & Skin, Ticks, Fleas
  - Default position: Left (Unknown)
  - Slider color: Orange to red gradient
  - Next/Previous buttons: Teal buttons at bottom

#### Animal Behaviour Screen
- **Layout**
  - Behavior categories separated by horizontal lines
  - Behavior options: Multiple selections possible
  - Selected behaviors: Highlighted in blue
  - Behavior categories:
    - General behaviors: Roaming, Hunting, Barking, Fearful
    - Chasing behaviors: Chasing Dogs, Chasing, Chasing Bikes, Chasing Cars
    - Threatening behaviors: Threatening Dogs, Threatening
    - Biting behaviors: Biting, Biting Dogs, Biting People
  - Notes section: Light blue text area
  - Add/Previous buttons: Teal buttons at bottom

#### Animal Listing Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - House information: "House Name" with Owner
- **Tab Navigation**
  - Tab options: "Animals" and "Comments"
  - Selected tab: Underlined with blue
  - Count indicators: Circular badges with counts
- **List Items**
  - Animal names: Gray text, left-aligned
  - Animal details: Color-coded icons for:
    - Species (dog/cat with color coding)
    - Health status (green heart)
    - Gender (male/female/unknown symbols)
    - Comments (speech bubble)
    - Microchip (barcode)
  - Empty photo placeholders: Left side
- **Actions**
  - Floating action button: Green "+" in bottom-right

### 3. Settings and System Screens

#### Settings Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - Height: 60px
  - Title: "Settings" (centered)
- **Menu Items**
  - Data Synchronisation: With count of pending changes
  - Clinical Note Templates: With navigation arrow
  - Change Password: With navigation arrow
- **User Information**
  - User display: "Signed in as: [Username]"
  - Logout button: Red button
  - Version information: App version and build date
- **Footer Navigation**
  - Four icons: My Councils, Home, Search, Settings
  - Active icon: Highlighted in red/orange

#### Sync Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - Title: "Sync Changes"
  - Back button to Settings
- **Sync Sections**
  - AMRRIC data: With last sync time
  - Data entered by users: With changes count
  - Attachments: With status
- **Actions**
  - Sync buttons: Blue circular refresh icons
- **Timestamps**
  - Last synced times: Gray text with date and time format

#### Clinical Note Templates Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - Title: "Clinical Note Templates"
  - Edit button: Pencil icon (right)
- **List Items**
  - Template names: Bold black text
  - Template descriptions: Gray text underneath
  - Global indicators: Globe icon
  - Navigation arrows: Right-facing chevrons
- **Actions**
  - Floating action button: Green "+" in bottom-right

### 4. Search and Community Screens

#### Search Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - Title: "Search"
  - Council selection: Dropdown above search field
- **Search Interface**
  - Search field: "At least 3 characters" placeholder
  - Search button: Magnifying glass icon
  - Results area: Shows "No results found" when empty
- **Footer Navigation**
  - Four icons: My Councils, Home, Search, Settings
  - Active icon: Highlighted in application color

#### Community Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - Title: "Test Council - Towcha" with community name
  - Back button: Left chevron
- **Tab Navigation**
  - Tab options: "Houses" and "Comments"
  - Selected tab: Underlined with blue
  - Count indicators: Circular badges with counts
- **Comment Listing**
  - Organized by month/year sections
  - Comment text: Blue background
  - Timestamp: Gray text with date and time
  - Author: Gray text, right-aligned
  - Edit indicator: Pencil icon
- **Dialog Boxes**
  - Add dialog: Green header "Add to [Community]"
  - Options: "House" or "Comment" buttons
  - Close button: X icon (white)

### 5. Color Picker and Comment Screens

#### Color Picker Modal
- **Header**
  - Background: Orange-red (#D75F41)
  - Title: "Select Colour"
  - Close button: X icon (white)
- **Color Options**
  - Grid layout with:
    - Tabby & White (with image)
    - Chocolate (with image)
    - White (with image)
    - Cream (with image)
    - Colourpoint (with image and detailed description)
    - Other option
  - Swatches: Actual fur texture images
  - Text labels: Centered below images

#### Comment Screen
- **Header**
  - Background: Orange-red (#D75F41)
  - Title: "Comment"
  - Left button: X icon (white)
  - Right button: "Add" text (white)
- **Content Area**
  - Comment text: Light blue background
  - Example text: "hi"
  - Input area: White background below
- **Layout**
  - Simple vertical layout
  - Full-width text areas

### 6. UI Patterns and Consistency

#### Navigation Patterns
- Consistent back button (chevron) placement in top-left
- Consistent action buttons placement in top-right
- Standardized footer navigation across all screens
- Tab-based content organization with blue highlights

#### Color System
- Primary actions: Teal (#009688)
- Destructive actions: Red (#FF0000)
- Warning indicators: Orange (#FFA500)
- Selected items: Blue (#2196F3)
- Header backgrounds: Orange-red (#D75F41)
- Inactive elements: Gray (#919191)
- Health indicators: Green (#4CAF50)

#### Typography
- Titles: 18px, white (in headers)
- Section titles: 16px, black, bold
- Field labels: 14px, gray
- Input text: 16px, black
- Secondary information: 14px, gray
- Timestamps: 12px, gray

#### Iconography
- Animal species: Gray/pink/blue silhouettes
- Health status: Green heart icon
- Gender: Standard male/female/unknown symbols
- House: Simple house icon
- Edit: Pencil icon
- Add: Plus icon
- Delete/Clear: X icon
- Navigation: Tab bar icons (simplified silhouettes)

All screens maintain a consistent visual language, with standardized header patterns, navigation elements, form controls, and action buttons. The interface follows iOS design guidelines while implementing a custom color scheme based on the AMRRIC branding.

## Enhanced Clinical Notes System

### Template Management
The clinical notes system supports a comprehensive templated approach to veterinary record keeping, with pre-built clinical templates that can be customized and filtered based on animal characteristics.

#### Pre-built Clinical Templates
- **Template Naming Convention**: Year + Location + Procedure (e.g., "2024 APY Castrate", "2024 APY Dog Spay", "2024 UQ Cherbourg Dog Spey")
- **Template Categories**: 
  - Castration procedures
  - Spay procedures
  - Species-specific protocols
  - Location-specific procedures
- **Template Versioning**: Annual updates and location-specific variations
- **Template Access Control**: Role-based access to specific templates

#### Template Filtering System
- **Species Filter**: Any Species, Dog, Cat
- **Gender Filter**: Any Gender, Male, Female
- **Dynamic Content**: Templates adjust available options based on selected filters
- **Quick Selection**: Common combinations readily available

### Clinical Note Structure Categories

#### 1. Problems/Status Categories
The system provides standardized status options for rapid classification:
- **Biosecurity**: For disease containment and prevention protocols
- **Cancel Desexing**: When surgical procedures need to be postponed or cancelled
- **Deceased**: For recording animal deaths with associated protocols
- **Fencing Issues**: For property-related animal welfare concerns
- **Found**: For stray or found animals
- **Lost**: For missing animals
- **Needs Desexing**: For animals requiring sterilization
- **Stolen**: For theft reports and investigations
- **Suspect Ehrlichia**: For potential tick-borne disease cases
- **Vet Needed Now**: For urgent veterinary attention
- **Welfare Case**: For animal welfare investigations

#### 2. Clinical Signs Assessment
Comprehensive list of observable clinical signs:
- **Blood in Wee**: Urinary system issues
- **Dehydrated**: Fluid balance problems
- **Diarrhoea**: Gastrointestinal issues
- **Distended Abdomen**: Potential internal problems
- **Itchy**: Dermatological conditions
- **Limping**: Musculoskeletal issues
- **Lump**: Potential masses or growths
- **Open Wound**: Traumatic injuries
- **Other Sign**: Free text for unlisted observations
- **Sore Ear**: Aural problems
- **Sore Eye**: Ocular conditions
- **Vomiting**: Gastrointestinal distress

#### 3. Disease Classification
Systematic disease categorization:
- **Bacterial**: Bacterial infections and diseases
- **CTVT**: Canine Transmissible Venereal Tumor
- **Fracture**: Bone fractures and breaks
- **Fungal**: Fungal infections
- **Other Disease**: Non-categorized diseases
- **Other Neoplasia**: Various tumor types
- **Parasitic**: Parasitic infections
- **Protozoal**: Protozoal diseases
- **Soft Tissue**: Soft tissue injuries and diseases
- **Vector-borne**: Tick and flea-borne diseases
- **Viral**: Viral infections

#### 4. Procedure Categories

**General Procedures:**
- **Clinical Exam**: Routine health assessments
- **Clip Coat**: Grooming and preparation procedures
- **Microchip**: Identification implantation
- **Trim Nails**: Basic grooming
- **Wound Treatment**: Injury management

**Surgical Procedures:**
- **Amputation**: Limb or tail removal
- **CTVT debridement**: Tumor removal and treatment
- **Lump Removal**: Mass excision
- **Stitchup**: Wound closure

**Desexing Procedures:**
- **Species-specific protocols**: Different approaches for dogs vs cats
- **Gender-specific procedures**: Tailored to male/female anatomy
- **Age-appropriate techniques**: Protocols based on animal age

**Other Procedures:**
- **Custom procedure entry**: Free text for non-listed procedures

#### 5. Treatment Categories and Drug Database

**Treatment Classifications:**
- **Anaesthetic/sedative**: For surgical and diagnostic procedures
- **Analgesic**: Pain management medications
- **Antibiotic**: Infection prevention and treatment
- **Anti-Inflammatory (Anti-Inflam)**: Inflammation reduction

**Comprehensive Drug Database:**
- **ACP**: Various concentrations (2mg/ml, 10mg/ml, 25mg tablets)
- **Alfaxan**: Anaesthetic agent
- **Antipam/Antisedan**: Reversal agents
- **Atrosite**: Haemostatic agent
- **Carprieve/Rimadyl/Carprofen**: Anti-inflammatory medications
- **Cephazolin**: Antibiotic
- **Dexafort/Dexapent**: Corticosteroids
- **Diazepam/Valium**: Sedative and muscle relaxant
- **Iso**: Isoflurane anaesthetic
- **Ketamine**: Anaesthetic agent
- **Lignocaine**: Local anaesthetic
- **Medetate/Domitor**: Sedative agents
- **Meloxicam/Metacam/Loxicom**: Anti-inflammatory medications
- **Methadone**: Opioid analgesic
- **Nexgard Spectra**: Parasite prevention
- **Pred-X/Macralone/Prednil**: Corticosteroids
- **Previcox**: Anti-inflammatory medication
- **Propofol Lipuro 1%**: Anaesthetic agent
- **Thiobarb**: Barbiturate anaesthetic
- **Torbugesic/Butorgesic**: Opioid analgesics
- **Trocoxil**: Long-acting anti-inflammatory
- **Xylazil**: Sedative (various concentrations: 20, 100)
- **Zoletil**: Anaesthetic combination

### Drug Administration Details
For each medication administered, the system captures:
- **Drug Name**: Selected from searchable database with auto-complete
- **Dose**: Numeric value with validation
- **Dose Unit**: ml, mg, tablets, etc. with species-appropriate defaults
- **Route**: IV, IM, SC, PO, topical, etc. with drug-specific options
- **Notes**: Free text for additional instructions and observations

### Enhanced Clinical Note Fields
- **Body Part(s)**: Anatomical location specification for procedures, signs, or diseases
- **Procedure Details**: Specific procedure information with pre-populated options
- **Responsible Vet Selection**: Dropdown with available veterinarians and "No Responsible Vet" option
- **Date/Time Stamping**: Automatic timestamps for all entries with manual override capability
- **Species/Gender Filtering**: Dynamic template filtering based on animal characteristics
- **Clinical Assessment**: Structured assessment forms with scoring systems
- **Follow-up Requirements**: Automated scheduling and reminder system
- **Photo Documentation**: Integrated camera access with automatic association to clinical notes

### Data Structure for Upstash Storage

```json
{
  "clinical_note_templates": {
    "template_id": "string",
    "template_name": "string",
    "year": "number",
    "location": "string",
    "procedure_type": "string",
    "species_filter": ["Any", "Dog", "Cat"],
    "gender_filter": ["Any", "Male", "Female"],
    "categories": {
      "problems": ["Biosecurity", "Cancel Desexing", "Deceased", "Fencing Issues", "Found", "Lost", "Needs Desexing", "Stolen", "Suspect Ehrlichia", "Vet Needed Now", "Welfare Case"],
      "procedures": ["General", "Surgical", "Desexed", "Other"],
      "treatments": ["Anaesthetic/sedative", "Analgesic", "Antibiotic", "Anti-Inflammatory"]
    },
    "predefined_content": {
      "clinical_signs": ["Blood in Wee", "Dehydrated", "Diarrhoea", "Distended Abdomen", "Itchy", "Limping", "Lump", "Open Wound", "Other Sign", "Sore Ear", "Sore Eye", "Vomiting"],
      "diseases": ["Bacterial", "CTVT", "Fracture", "Fungal", "Other Disease", "Other Neoplasia", "Parasitic", "Protozoal", "Soft Tissue", "Vector-borne", "Viral"],
      "procedures": ["Clinical Exam", "Clip Coat", "Microchip", "Trim Nails", "Wound Treatment", "Amputation", "CTVT debridement", "Lump Removal", "Stitchup"],
      "medications": [
        {
          "name": "ACP",
          "concentrations": ["2mg/ml", "10mg/ml", "25mg tablets"],
          "default_route": ["IM", "IV", "PO"]
        },
        // ... additional medications
      ]
    },
    "created_by": "string",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  },
  "drug_database": {
    "drug_id": "string",
    "drug_name": "string",
    "common_names": ["array of alternative names"],
    "concentrations": ["array of available concentrations"],
    "default_dose_units": ["ml", "mg", "tablets"],
    "common_routes": ["IV", "IM", "SC", "PO", "topical"],
    "species_specific": "boolean",
    "contraindications": ["array of conditions"],
    "standard_doses": {
      "dog": "dosing_information",
      "cat": "dosing_information"
    }
  },
  "clinical_notes": {
    "note_id": "string",
    "animal_id": "string",
    "template_id": "string",
    "date": "timestamp",
    "responsible_vet": "string",
    "problems": ["array of selected problems"],
    "clinical_signs": [
      {
        "sign": "string",
        "body_parts": ["array"],
        "notes": "string"
      }
    ],
    "diseases": [
      {
        "disease": "string",
        "body_parts": ["array"],
        "notes": "string"
      }
    ],
    "procedures": [
      {
        "procedure": "string",
        "body_parts": ["array"],
        "notes": "string"
      }
    ],
    "treatments": [
      {
        "drug_name": "string",
        "dose": "number",
        "dose_unit": "string",
        "route": "string",
        "notes": "string"
      }
    ],
    "additional_notes": "string",
    "photos": ["array of photo URLs"],
    "created_by": "string",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
}
```

### User Interface Requirements
- **Multi-tab Interface**: Problems/Procedure/Treatment tabs for organized data entry
- **Searchable Dropdowns**: For medications, procedures, and clinical signs
- **Dynamic Filtering**: Real-time filtering based on species/gender selection
- **Template Builder**: Administrative interface for creating custom templates
- **Quick-add Buttons**: For frequently used items
- **Auto-complete Functionality**: For drug names and procedures with fuzzy matching
- **Responsive Design**: Optimized for tablet use in field conditions
- **Offline Capability**: Full functionality without internet connection
- **Photo Integration**: Direct camera access with automatic image compression and association

### Business Rules and Validation
- **Template Access**: Users can only access templates appropriate for their role and location
- **Drug Calculations**: Automatic dose calculations based on animal weight and species
- **Contraindication Warnings**: Alerts for drug interactions and contraindications
- **Completion Validation**: Required fields must be completed before saving
- **Audit Trail**: All changes tracked with user attribution and timestamps
- **Data Integrity**: Cross-references between procedures, treatments, and diagnoses
- **Regulatory Compliance**: Meets veterinary record-keeping requirements
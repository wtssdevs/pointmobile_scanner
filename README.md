# Xstream Gatepass — Functional Specification (Summary)

This document summarizes what the application does from a user’s perspective. It focuses on capabilities and workflows, not on how they are implemented.

## Overview

The app supports gate access operations across pre-booked loads, visitor and staff access, and yard activities. It identifies people and assets using scanning, guides operators through validations and checklists, records incidents, captures media, and works in low-connectivity conditions.

Primary users: gate officers, yard operators, supervisors.

## Core capabilities

### 1. Authentication and startup

- Terms and privacy acceptance.
- User sign-in to access features.
- Startup initialization (environment, connectivity) and optional data sync.

### 2. Home and navigation

- Home dashboard as the post-login entry point.
- Gate Access Menu with quick access to:
  - Pre-Bookings
  - Visitors
  - Staff
  - Yard Operations
- Device Scan Settings screen to configure device-level scanning behavior.
- Access to account and data sync screens.

### 3. Gate Pass management

- View, create, and edit a Gate Pass record.
- Capture and maintain:
  - Driver info
  - Vehicle info
  - Trailer(s) info
  - Container info
  - Times/milestones
  - Attachments (photos/documents)
- Actions:
  - Authorize for entry
  - Authorize for exit
  - Reject entry

### 4. Scanning and identification

- Hardware-triggered barcode/QR scanning on supported devices.
- Camera-based QR/barcode capture alternative.
- Supported scan contexts include (examples):
  - Load instruction QR
  - Staff QR (GUID code)
  - Driver’s license card
  - Vehicle license disk
  - Temporary/other license formats
  - Container number (camera assist)
- Operators can switch the expected scan type per workflow.

### 5. Gate Access — Pre-Bookings

- Scan a load instruction QR or manually enter known identifiers (e.g., Voyage No, booking/order numbers, vehicle registration, references).
- Validate and find a matching pre-booked load.
- On success, open the Gate Pass edit screen pre-populated with booking data.
- Show a summary of scanned/typed values and validation errors with retry options.

### 6. Gate Access — Visitors

- Check-in and check-out visitor access at the gate.
- For check-in, select a service type when required.
- Support pre-booked visitor flows as well as ad-hoc scanning from IDs/license disks.
- Provide clear error feedback (e.g., missing connection, missing required inputs).

### 7. Gate Access — Staff

- Paged list of staff with fast search/filter.
- Toggle scan mode between “Scan Staff In” and “Scan Staff Out”.
- Scan staff QR (GUID) to perform check-in/out and refresh the list state.
- Option to find by a QR code value manually.

### 8. Yard operations

- Capture a Load Slip QR with fields such as Voyage No, Customer Ref No, and Load Item Code.
- Capture a Stockpile QR and select a stockpile where applicable.
- Capture or read a Container Number using a camera-assisted flow.
- Combine these pieces to progress yard workflows and show live summaries.

### 9. Checklists and incidents

- Retrieve a relevant checklist template for a given Gate Pass context (booking/delivery type, template id, etc.).
- Fill out and submit checklist responses.
- Create and review incidents linked to operations.

### 10. Media capture and viewing

- Capture images, optionally open an editor to annotate/crop.
- View images as a gallery attached to records.

### 11. Localization and permissions

- Use localized labels and values throughout the UI.
- Role/permission gating for visibility and access to:
  - Pre-Bookings
  - Visitors (Scan, Check-In, Check-Out, Pre-Book Check-In)
  - Staff (Scan, Check-In, Check-Out, Pre-Book Check-In)
  - Yard Operations
  - General Gate Access operations

### 12. Connectivity and offline resilience

- Detect connectivity and present user feedback when offline.
- Queue operations (e.g., uploads/updates) for background processing; send automatically when the connection resumes.

### 13. Notifications and overlays

- In-app prompts, confirmations, and error alerts via dialogs/overlays and bottom sheets.

## Key workflows (contracts)

### A. Pre-booking → Gate Pass edit

- Inputs: Load instruction QR or manual identifiers (e.g., Voyage No, order/booking numbers, vehicle reg).
- Process: Parse and validate → search for pre-booking → on success open Gate Pass edit → on return clear temporary scanned state.
- Success: Matching pre-booking found and editable Gate Pass displayed.
- Errors: Invalid QR; no booking found; network issues; show actionable messages.

### B. Staff check-in/out

- Inputs: Staff QR (GUID); operator sets mode (In/Out).
- Process: Submit check-in/out; update the paged list and show per-staff status.
- Success: Staff entry/exit recorded; list reflects current state.
- Errors: Invalid/unknown code; network issues; provide retry.

### C. Visitor check-in/out

- Inputs: ID/license scan (or pre-booked visitor reference); service type for check-in where required.
- Process: Parse ID/scan → build visitor access model → submit check-in/out.
- Success: Visitor entry/exit recorded; confirmation shown.
- Errors: Missing service type; invalid scan; offline.

### D. Yard ops association

- Inputs: Load Slip QR, Stockpile QR, optional Container No (camera reader).
- Process: Capture all, validate completeness, present summaries.
- Success: Valid association set; proceed to next operational step.
- Errors: Partial/invalid scans; offline.

## Visual process flows

> Note: These diagrams use Mermaid. They render on GitHub and in VS Code’s Markdown preview (with Mermaid support).

### A. Pre-booking → Gate Pass edit (flow)

```mermaid
flowchart TD;
  Start([Pre-Bookings]);
  Choose{Scan QR or Manual?};
  Start --> Choose;
  Choose -->|Scan| Scan[Scan Load Instruction QR];
  Choose -->|Manual| Manual[Enter Voyage/Ref/Reg];
  Scan --> Parse{Valid data?};
  Parse -->|Yes| Lookup[Find pre-booked load];
  Parse -->|No| Error1[Show validation errors];
  Error1 --> Retry[Retry or Rescan];
  Retry --> Choose;
  Manual --> Lookup;
  Lookup --> Found{Match found?};
  Found -->|Yes| Edit[Open Gate Pass Edit];
  Edit --> Actions[Edit fields, capture media, run checklist];
  Actions --> Done[Return to Pre-Bookings; clear scanned state];
  Found -->|No| NotFound[Show no pre-booking found];
  NotFound --> Retry;
```

### B. Staff check-in/out (flow)

```mermaid
flowchart TD;
  Staff([Staff List]);
  Mode{Mode: In or Out};
  Staff --> Mode;
  Mode --> ScanQR[Scan Staff QR GUID];
  ScanQR --> Valid{Valid code and online?};
  Valid -->|Yes| API[Call ScanStaffIn/Out API];
  API --> Success[Update list and status icon];
  Success --> Mode;
  Valid -->|No| Fail[Show error and retry];
  Fail --> ScanQR;
```

### C. Visitor check-in/out (flow)

```mermaid
flowchart TD;
  Visitors([Visitors]);
  CheckMode{Check-In or Check-Out};
  Visitors --> CheckMode;
  CheckMode -->|Check-In| Service{Service type selected?};
  Service -->|Yes| StartScan[Start scan: license or ID];
  Service -->|No| ErrService[Service type required];
  CheckMode -->|Check-Out| StartScan;
  StartScan --> Parse{Parsed OK?};
  Parse -->|Yes| Build[Build Visitor Access];
  Build --> Next{Mode?};
  Next -->|In| APIIn[ScanVisitorIn];
  Next -->|Out| APIOut[ScanVisitorOut];
  APIIn --> Done[Show confirmation];
  APIOut --> Done;
  Parse -->|No| Err[Error; rescan];
```

### D. Yard operations association (flow)

```mermaid
flowchart TD;
  Yard([Yard Ops]);
  Load[Scan Load Slip QR];
  Stockpile[Scan Stockpile QR];
  Container[Capture Container Number camera];
  Complete{All info complete};
  Online{Online};
  Proceed[Proceed and associate];
  Queue[Queue for background sync];
  Submit[Submit now];
  Hold[Prompt to complete and rescan or select];
  Yard --> Load;
  Load --> Stockpile;
  Stockpile --> Container;
  Container --> Complete;
  Complete -->|Yes| Online;
  Online -->|Yes| Submit;
  Submit --> Proceed;
  Online -->|No| Queue;
  Queue --> Proceed;
  Complete -->|No| Hold;
  Hold --> Load;
```

### E. Gate Pass management actions (flow)

```mermaid
flowchart TD;
  Edit([Gate Pass Edit]);
  Actions{Action?};
  AuthIn[Authorize Entry];
  AuthOut[Authorize Exit];
  Reject[Reject Entry];
  Success[Success confirmation];
  Error[Show errors];
  Edit --> Actions;
  Actions -->|Authorize Entry| AuthIn;
  Actions -->|Authorize Exit| AuthOut;
  Actions -->|Reject Entry| Reject;
  AuthIn --> Success;
  AuthOut --> Success;
  Reject --> Success;
  Success --> Edit;
  AuthIn -.-> Error;
  Error -.-> Edit;
  AuthOut -.-> Error;
  Reject -.-> Error;
```

### F. Startup and login (flow)

```mermaid
flowchart TD;
  Launch([App Launch]);
  Init[Init env and splash];
  Terms{Terms accepted?};
  ShowTerms[Show Terms and Privacy];
  Login[Login];
  Online{Online?};
  Home[Home];
  NoNet[Show connection status];
  Launch --> Init;
  Init --> Terms;
  Terms -->|Yes| Login;
  Terms -->|No| ShowTerms;
  ShowTerms --> Login;
  Login --> Online;
  Online -->|Yes| Home;
  Online -->|No| NoNet;
  NoNet --> Home;
```

### G. Media capture and viewing (flow)

```mermaid
flowchart TD;
  From([From Gate Pass/Edit]);
  Capture[Capture Image];
  EditImg[Optional: Edit Image];
  Attach[Attach to record];
  View[Open Gallery];
  Done[Done];
  From --> Capture;
  Capture --> EditImg;
  EditImg --> Attach;
  Attach --> View;
  View --> Done;
```

### H. Checklist flow

```mermaid
flowchart TD;
  FromGP([From Gate Pass Edit]);
  Find[Find checklist template];
  Open[Open Checklist];
  Fill[Fill responses];
  Submit[Submit];
  Success[Saved/Submitted];
  Fail[Show errors; retry];
  FromGP --> Find;
  Find --> Open;
  Open --> Fill;
  Fill --> Submit;
  Submit --> Success;
  Submit -.-> Fail;
  Fail -.-> Open;
```

## Navigation map (screens)

- Startup → Login → Home → Gate Access Menu
- Gate Access Pre-Booking → Gate Pass Edit
- Gate Access Staff List
- Gate Access Visitors List (with a scan bottom sheet)
- Yard Ops → Yard Ops Select → Container No Reader (camera)
- Camera capture / Barcode reader / Image editor / Image gallery
- Device Scan Settings
- Checklists
- Data Sync and Account areas

## Edge cases to expect

- Offline or unstable network during scans and submissions.
- Scans producing malformed or incomplete data.
- Duplicate scans while a submission is in progress.
- Missing required fields (e.g., service type) before action.
- Insufficient permissions for a requested view/action.


---


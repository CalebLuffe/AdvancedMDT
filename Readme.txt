AdvancedMDT & Dispatch System for FiveM RP
==========================================

Overview
--------
The Intention of the AdvancedMDT is to be a modular Mobile Data Terminal and Dispatch System for FiveM RP servers. 
It integrates with emergency services (police, fire, EMS) and provides advanced features for evidence collection, case management, NPC witness generation, scenario tracking, and officer reputation. 
The system should supports ESX, QBCore, and custom frameworks.

Features
--------
- Automated evidence detection and logging (shell casings, blood, fingerprints, weapon fragments, drug residue, etc.)
- Secure evidence locker with metadata (location, time, officer, description)
- NPC witness detection and statement generation, linked to cases
- Incident/scenario management for dispatch and unit tracking
- Officer reputation tracking
- Role-based permissions for police, judges, and admins
- Robust MDT UI with search, sorting, pagination, and export functionality

Installation
------------
1. **Database Setup**
   - Import the provided `sql/schema.sql` file into your MySQL database.

2. **Resource Setup**
   - Place all server and client Lua scripts in your FiveM resource folder (e.g., `advancedmdt`).
   - Place the React frontend in the `web` folder and build it for NUI usage.

3. **Configuration**
   - Edit `config.lua` to set your framework (`QBCore` or `ESX`) and job names for permissions.
   - Ensure your database credentials are set for `oxmysql`.

4. **Server Integration**
   - Add `ensure advancedmdt` to your `server.cfg`.
   - Make sure `oxmysql` is installed and running.

5. **NUI Integration**
   - The MDT UI communicates with the backend via NUI callbacks. Ensure your server endpoints (see `api.lua`) are registered and working.

Usage
-----
- **Officers**: Open the MDT to view and manage cases, collect evidence, and respond to scenarios.
- **Judges/Admins**: Review witness statements, oversee cases, and manage evidence.
- **Dispatch**: Track active scenarios and assign units.

UI Features
-----------
- **Search & Sort**: Filter and sort evidence, witnesses, and scenarios by case, type, officer, or timestamp.
- **Pagination**: Navigate large datasets with page controls.
- **Export**: Export case data for court or record-keeping.
- **Role-Based Actions**: Only authorized users can add/edit evidence or statements.

Tweaks & Customization
----------------------
- **Evidence Types**: Add or remove evidence types in `config.lua`.
- **Permissions**: Adjust job names and roles in `config.lua` for your server structure.
- **UI Customization**: Modify React components in `web/src/layers/mdt` for branding or workflow changes.
- **Scenario Logic**: Expand server scripts to support more complex callouts or multi-department responses.

Troubleshooting
---------------
- If data does not appear in the MDT, check your NUI callbacks and database connection.
- Ensure all endpoints return standardized responses (`{success, data, error}`).
- For permission issues, verify job names and framework settings in `config.lua`.

Support
-------
This is highly experimental and has not been fully tested yet, still Alpha stage and cleaning up code as we speak. Looking for constructive help 

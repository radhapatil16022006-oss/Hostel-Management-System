# Hostel Management System

A responsive Flutter application for hostel wardens and student residents. The prototype uses seeded in-memory data, so it can be demonstrated without Firebase or a network connection.

## Run

```powershell
flutter pub get
flutter run
```

For web, use `flutter run -d chrome`. Run checks with `flutter analyze` and `flutter test`.

## Demo access

- Admin / Warden: `warden` / `demo123`
- Students: `student_001` through `student_009` / `demo123`

## Included workflows

- Role-based sign-in, responsive navigation, light and dark appearance, and sign-out.
- Live dashboard summaries for students, rooms, bed occupancy, pending fees, complaints, and attendance.
- Student directory with search, year filter, add, edit, details, and confirmed deletion.
- Room inventory, capacity editing, allocation, transfer, deallocation, and occupancy tracking.
- Fee balances and payment history, with validated, bounded payment entry.
- Student complaints, status tracking, and warden status updates.
- Notice publishing and deletion, daily attendance, visitor entry/exit, mess menu editing, profile/settings, and report summaries.

## Data and limitations

Sample and newly entered records live in memory and reset when the application process restarts. Authentication is a local demonstration flow; credentials are not secure and there is no backend, persistence, real payment processing, push notification service, or remote file storage. Student accounts are demo accounts and are not provisioned through an identity provider.
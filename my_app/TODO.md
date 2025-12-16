# TODO: Fix Firebase Data Disappearing Issue

## Steps to Complete

- [x] Update lib/AddTask.dart: Change 'createdAt' to 'timestamp', add 'status' field set to 'todo' for new tasks.
- [x] Update lib/homePage.dart ToDoTab: Change orderBy('createdAt') to orderBy('timestamp'), add where('status', isEqualTo: 'todo') and where('isCompleted', isEqualTo: false), add error handling in StreamBuilder.
- [x] Update lib/homePage.dart InProgressTab: Add error handling in StreamBuilder.
- [x] Update lib/homePage.dart CompletedTab: Add error handling in StreamBuilder.
- [x] Test the app and check Firebase console for index creation if needed.

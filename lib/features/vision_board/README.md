# Vision Board Feature

## Purpose
Visual goal board where users pin images and milestones representing their financial dreams. Inspiration-driven motivation.

## Models
- `VisionItem` — id, title, imagePath, targetAmount, deadline, isAchieved, position
- `VisionBoard` — id, name, items, createdAt

## Screens
- `VisionBoardView` — grid/board layout with pinned vision items
- `AddVisionItemView` — create/edit vision item with image picker

## ViewModels
- `VisionBoardViewModel` — CRUD vision items, reorder, toggle achieved

## Future Tasks
- [ ] Pinterest-style masonry grid
- [ ] Image picker integration (gallery/camera)
- [ ] Drag-to-reorder items
- [ ] Progress overlay on images
- [ ] Celebration animation on achievement
- [ ] Multiple boards support

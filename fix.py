import os

fixes = [
    (r"lib/features/analytics/view/analytics_screen.dart", 37),
    (r"lib/features/dashboard/widgets/daily_motivation_card.dart", 46),
    (r"lib/features/dashboard/widgets/dashboard_hero_header.dart", 33),
    (r"lib/features/dashboard/widgets/financial_overview_card.dart", 31),
    (r"lib/features/dashboard/widgets/goal_spotlight_card.dart", 72),
    (r"lib/features/dashboard/widgets/streak_progress_card.dart", 60),
    (r"lib/features/dashboard/widgets/streak_progress_card.dart", 72),
    (r"lib/features/gamification/view/profile_progress_screen.dart", 53),
    (r"lib/features/gamification/widgets/gamification_banner.dart", 56),
    (r"lib/features/gamification/widgets/xp_progress_bar.dart", 32),
    (r"lib/features/goals/view/add_goal_screen.dart", 52),
    (r"lib/features/goals/view/add_goal_screen.dart", 139),
    (r"lib/features/goals/widgets/goal_card.dart", 99),
    (r"lib/features/security/view/app_lock_screen.dart", 42),
    (r"lib/features/security/view/backup_screen.dart", 82),
    (r"lib/features/security/view/backup_screen.dart", 114),
    (r"lib/features/settings/view/settings_view.dart", 56),
    (r"lib/features/transactions/view/transactions_view.dart", 55),
    (r"lib/features/transactions/view/transactions_view.dart", 228),
    (r"lib/features/vision_board/view/create_vision_item_screen.dart", 113),
    (r"lib/features/vision_board/view/vision_board_screen.dart", 58),
    (r"lib/features/vision_board/view/vision_item_detail_screen.dart", 149),
    (r"lib/features/vision_board/view/vision_item_detail_screen.dart", 195),
    (r"lib/features/vision_board/widgets/vision_banner.dart", 39),
    (r"lib/features/vision_board/widgets/vision_card.dart", 97),
    (r"lib/features/vision_board/widgets/vision_card.dart", 147),
    (r"lib/shared/widgets/kosh_button.dart", 108),
]

for filepath, line_num in fixes:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        # Search backwards from the line
        for i in range(line_num - 1, max(-1, line_num - 15), -1):
            if 'const ' in lines[i]:
                lines[i] = lines[i].replace('const ', '', 1)
                break
                
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        print(f"Fixed {filepath}:{line_num}")
    except Exception as e:
        print(f"Error {filepath}: {e}")


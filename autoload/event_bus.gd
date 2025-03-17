extends Node

# Сигналы для взаимодействия
# interactive_ui_shown - показать интерфейс взаимодействия
# interactive_ui_hide - скрыть интерфейс
# interactive_item_interacted - объект был использован
@warning_ignore("unused_signal")
signal interactive_ui_shown(item)
@warning_ignore("unused_signal")
signal interactive_ui_hide
@warning_ignore("unused_signal")
signal interactive_item_interacted(item)

# Игрока поймали
@warning_ignore("unused_signal")
signal get_caught

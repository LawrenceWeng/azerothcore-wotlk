-- mod-dungeon-roguelite: Change dungeon_roguelite_group to one row per (persistent_group_id, dungeon_order).
-- Run only when the table exists (module installed). Existing data is preserved as history.

CREATE TABLE IF NOT EXISTS dungeon_roguelite_group_new (
    persistent_group_id INT UNSIGNED NOT NULL,
    dungeon_order INT NOT NULL,
    start_time INT UNSIGNED NOT NULL DEFAULT 0,
    finish_time INT UNSIGNED NOT NULL DEFAULT 0,
    time_taken INT UNSIGNED NOT NULL DEFAULT 0,
    lives INT NOT NULL DEFAULT -1,
    deaths INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (persistent_group_id, dungeon_order),
    INDEX idx_persistent_group_id (persistent_group_id)
);

INSERT INTO dungeon_roguelite_group_new (persistent_group_id, dungeon_order, start_time, finish_time, time_taken, lives, deaths)
SELECT persistent_group_id, dungeon_order, start_time, finish_time, time_taken, lives, deaths
FROM dungeon_roguelite_group;

DROP TABLE IF EXISTS dungeon_roguelite_group;
RENAME TABLE dungeon_roguelite_group_new TO dungeon_roguelite_group;

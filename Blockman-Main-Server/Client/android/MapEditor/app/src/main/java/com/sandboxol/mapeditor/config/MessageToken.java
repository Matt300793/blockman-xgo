package com.sandboxol.mapeditor.config;

/**
 * Created by Jimmy on 2017/11/30 0030.
 */
public interface MessageToken {

    String IMPORT_MY_MAP = "import.my.map";
    String REMOVE_MY_MAP = "remove.my.map";
    String CHANGE_MY_MAP = "change.my.map.%s";

    String REMOVE_MY_MAP_SELECT_ALL = "remove.my.map.select.all";
    String CHANGE_REMOVE_SELECT_ALL = "change.remove.select.all";
    String ENABLED_REMOVE = "enabled.remove";

    String EXPORT_MY_MAP_SELECT_ALL = "export.my.map.select.all";
    String CHANGE_EXPORT_SELECT_ALL = "change.export.select.all";
    String ENABLED_EXPORT = "enabled.export";

    String CHANGE_BACKUP_MAP = "change.backup.map.%s";
    String REMOVE_BACKUP_MAP = "remove.backup.map";
}
